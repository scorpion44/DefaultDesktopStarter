#tag Module
Protected Module PlatformUtilities
	#tag Method, Flags = &h1
		Protected Sub CloseNSColorPanel()
		  
		  #If TargetMacOS Then
		    Declare Function NSClassFromString Lib "AppKit" ( className As CFStringRef ) As ptr
		    Declare Function sharedColorPanel Lib "AppKit" selector "sharedColorPanel" ( classRef As Ptr ) As Ptr
		    Declare Sub close Lib "AppKit" selector "close" ( panel As Ptr )
		    close( sharedColorPanel( NSClassFromString( "NSColorPanel" ) ) ) 
		  #endif
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function DoubleClickInterval() As Double
		  // returns as double that is the # of TICKS
		  
		  #If TargetMacOS
		    
		    Const CocoaLib As String = "Cocoa.framework"
		    Declare Function NSClassFromString Lib CocoaLib(aClassName As CFStringRef) As ptr
		    Declare Function doubleClickInterval Lib CocoaLib selector "doubleClickInterval" (aClass As ptr) As Double
		    
		    Try
		      dim RefToClass as Ptr = NSClassFromString("NSEvent")
		      Return doubleClickInterval(RefToClass) * 60
		    Catch err As ObjCException
		      Break
		      #If debugbuild
		        MsgBox err.message
		      #EndIf
		    End
		  #EndIf
		  
		  #If TargetWin32
		    Declare Function GetDoubleClickTime Lib "User32.DLL" () As Integer
		    Try
		      Return GetDoubleClickTime
		    Catch err As ObjCException
		      Break
		      #If debugbuild
		        MsgBox err.message
		      #EndIf
		    End
		  #EndIf
		  
		  Break
		  #If debugbuild
		    MsgBox CurrentMethodName + " Unhandled case"
		  #EndIf
		  Return 0
		  
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function HIBYTE(wValue as Uint16) As Uint8
		  return bitwise.shiftright(wvalue and &hFF00,8)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub Initialize()
		  If m_Initialized Then 
		    Return
		  End If
		  
		  m_Initialized = True
		  
		  #If TargetMacOS
		    
		    // --- We're using 10.10
		    Declare Function NSClassFromString Lib "AppKit" ( className As CFStringRef ) As Ptr
		    Declare Function processInfo Lib "AppKit" selector "processInfo" ( ClassRef As Ptr ) As Ptr
		    Dim myInfo As Ptr = processInfo( NSClassFromString( "NSProcessInfo" ) )
		    Declare Function operatingSystemVersion Lib "AppKit" selector "operatingSystemVersion" ( NSProcessInfo As Ptr ) As OSVersionInfo
		    Dim rvalue As OSVersionInfo = operatingSystemVersion( myInfo )
		    
		    m_MajorVersion = rValue.major
		    m_MinorVersion = rvalue.major
		    m_Bug = rvalue.bug
		    
		  #ElseIf TargetWindows
		    
		    Dim m As MemoryBlock
		    Dim wsuitemask As Integer
		    Dim ret As Integer
		    Dim szCSDVersion As String
		    Dim s As String
		    
		    Soft Declare Function GetVersionExA Lib "kernel32" (lpVersionInformation As ptr) As Integer
		    Soft Declare Function GetVersionExW Lib "kernel32" (lpVersionInformation As ptr) As Integer
		    
		    Dim retryUsingAVersion As Boolean = True
		    
		    If System.IsFunctionAvailable( "GetVersionExW", "Kernel32" ) Then
		      
		      retryUsingAVersion = False
		      
		      m = NewMemoryBlock(284) ''use this for osversioninfoex structure (2000+ only)
		      m.long(0) = m.size 'must set size before calling getversionex 
		      ret = GetVersionExW(m) 'if not 2000+, will return 0
		      
		      If ret = 0 Then
		        // need to rety since 0 means "FAILED"
		        m = NewMemoryBlock(276)
		        m.long(0) = m.size 'must set size before calling getversionex 
		        ret = GetVersionExW(m)
		        
		        If ret = 0 Then
		          // Something really strange has happened, so use the A version
		          // instead
		          retryUsingAVersion = True
		        End
		      End
		      
		    End If
		    
		    If retryUsingAVersion = True Then
		      m = NewMemoryBlock(156) ''use this for osversioninfoex structure (2000+ only)
		      m.long(0) = m.size 'must set size before calling getversionex
		      ret = GetVersionExA(m) 'if not 2000+, will return 0
		      If ret = 0 Then
		        m = NewMemoryBlock(148) ' 148 sum of the bytes included in the structure (long = 4bytes, etc.)
		        m.long(0) = m.size 'must set size before calling getversionex
		        ret = GetVersionExA(m)
		        If ret = 0 Then
		          Return
		        End
		      End
		    End If
		    
		    m_MajorVersion = m.long(4)
		    m_MinorVersion = m.long(8)
		    m_Bug = m.long(12)
		    
		  #EndIf
		  
		  
		  Dim p As New picture(1,1)
		  p.Graphics.TextFont = "System"
		  m_SystemZeroSize = p.Graphics.TextSize
		  
		  p.Graphics.TextFont = "SmallSystem"
		  m_SmallSystemZeroSize = p.Graphics.TextSize
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function IsWindows10OrGreater() As boolean
		  #If TargetWindows
		    
		    // _WIN32_WINNT version constants
		    //
		    Const _WIN32_WINNT_NT4   =                  &h0400 // Windows NT 4.0
		    Const _WIN32_WINNT_WIN2K =                 &h0500 // Windows 2000
		    Const _WIN32_WINNT_WINXP =                 &h0501 // Windows XP
		    Const _WIN32_WINNT_WS03  =                 &h0502 // Windows Server 2003
		    Const _WIN32_WINNT_WIN6  =                 &h0600 // Windows Vista
		    Const _WIN32_WINNT_VISTA =                 &h0600 // Windows Vista
		    Const _WIN32_WINNT_WS08  =                 &h0600 // Windows Server 2008
		    Const _WIN32_WINNT_LONGHORN =              &h0600 // Windows Vista
		    Const _WIN32_WINNT_WIN7     =              &h0601 // Windows 7
		    Const _WIN32_WINNT_WIN8     =              &h0602 // Windows 8
		    Const _WIN32_WINNT_WINBLUE  =              &h0603 // Windows 8.1
		    Const _WIN32_WINNT_WINTHRESHOLD =           &h0A00 // Windows 10
		    Const _WIN32_WINNT_WIN10 =                 &h0A00 // Windows 10
		    
		    Return IsWindowsVersionOrGreater(HIBYTE(_WIN32_WINNT_WINTHRESHOLD), LOBYTE(_WIN32_WINNT_WINTHRESHOLD), 0)
		  #Else
		    Return False
		  #EndIf
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function IsWindows7OrGreater() As boolean
		  #If TargetWindows
		    // _WIN32_WINNT version constants
		    //
		    Const _WIN32_WINNT_NT4   =                  &h0400 // Windows NT 4.0
		    Const _WIN32_WINNT_WIN2K =                 &h0500 // Windows 2000
		    Const _WIN32_WINNT_WINXP =                 &h0501 // Windows XP
		    Const _WIN32_WINNT_WS03  =                 &h0502 // Windows Server 2003
		    Const _WIN32_WINNT_WIN6  =                 &h0600 // Windows Vista
		    Const _WIN32_WINNT_VISTA =                 &h0600 // Windows Vista
		    Const _WIN32_WINNT_WS08  =                 &h0600 // Windows Server 2008
		    Const _WIN32_WINNT_LONGHORN =              &h0600 // Windows Vista
		    Const _WIN32_WINNT_WIN7     =              &h0601 // Windows 7
		    Const _WIN32_WINNT_WIN8     =              &h0602 // Windows 8
		    Const _WIN32_WINNT_WINBLUE  =              &h0603 // Windows 8.1
		    Const _WIN32_WINNT_WINTHRESHOLD =           &h0A00 // Windows 10
		    Const _WIN32_WINNT_WIN10 =                 &h0A00 // Windows 10
		    
		    Return IsWindowsVersionOrGreater(HIBYTE(_WIN32_WINNT_WIN7), LOBYTE(_WIN32_WINNT_WIN7), 0)
		  #Else
		    Return False
		  #EndIf
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function IsWindows7SP1OrGreater() As boolean
		  #If TargetWindows
		    // _WIN32_WINNT version constants
		    //
		    Const _WIN32_WINNT_NT4   =                  &h0400 // Windows NT 4.0
		    Const _WIN32_WINNT_WIN2K =                 &h0500 // Windows 2000
		    Const _WIN32_WINNT_WINXP =                 &h0501 // Windows XP
		    Const _WIN32_WINNT_WS03  =                 &h0502 // Windows Server 2003
		    Const _WIN32_WINNT_WIN6  =                 &h0600 // Windows Vista
		    Const _WIN32_WINNT_VISTA =                 &h0600 // Windows Vista
		    Const _WIN32_WINNT_WS08  =                 &h0600 // Windows Server 2008
		    Const _WIN32_WINNT_LONGHORN =              &h0600 // Windows Vista
		    Const _WIN32_WINNT_WIN7     =              &h0601 // Windows 7
		    Const _WIN32_WINNT_WIN8     =              &h0602 // Windows 8
		    Const _WIN32_WINNT_WINBLUE  =              &h0603 // Windows 8.1
		    Const _WIN32_WINNT_WINTHRESHOLD =           &h0A00 // Windows 10
		    Const _WIN32_WINNT_WIN10 =                 &h0A00 // Windows 10
		    
		    Return IsWindowsVersionOrGreater(HIBYTE(_WIN32_WINNT_WIN7), LOBYTE(_WIN32_WINNT_WIN7), 1)
		  #Else
		    Return False
		  #EndIf
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function IsWindows8OrGreater() As boolean
		  #If TargetWindows
		    // _WIN32_WINNT version constants
		    //
		    Const _WIN32_WINNT_NT4   =                  &h0400 // Windows NT 4.0
		    Const _WIN32_WINNT_WIN2K =                 &h0500 // Windows 2000
		    Const _WIN32_WINNT_WINXP =                 &h0501 // Windows XP
		    Const _WIN32_WINNT_WS03  =                 &h0502 // Windows Server 2003
		    Const _WIN32_WINNT_WIN6  =                 &h0600 // Windows Vista
		    Const _WIN32_WINNT_VISTA =                 &h0600 // Windows Vista
		    Const _WIN32_WINNT_WS08  =                 &h0600 // Windows Server 2008
		    Const _WIN32_WINNT_LONGHORN =              &h0600 // Windows Vista
		    Const _WIN32_WINNT_WIN7     =              &h0601 // Windows 7
		    Const _WIN32_WINNT_WIN8     =              &h0602 // Windows 8
		    Const _WIN32_WINNT_WINBLUE  =              &h0603 // Windows 8.1
		    Const _WIN32_WINNT_WINTHRESHOLD =           &h0A00 // Windows 10
		    Const _WIN32_WINNT_WIN10 =                 &h0A00 // Windows 10
		    
		    Return IsWindowsVersionOrGreater(HIBYTE(_WIN32_WINNT_WIN8), LOBYTE(_WIN32_WINNT_WIN8), 0)
		  #Else
		    Return False
		  #EndIf
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function IsWindows8Point1OrGreater() As boolean
		  #If TargetWindows
		    // _WIN32_WINNT version constants
		    //
		    Const _WIN32_WINNT_NT4   =                  &h0400 // Windows NT 4.0
		    Const _WIN32_WINNT_WIN2K =                 &h0500 // Windows 2000
		    Const _WIN32_WINNT_WINXP =                 &h0501 // Windows XP
		    Const _WIN32_WINNT_WS03  =                 &h0502 // Windows Server 2003
		    Const _WIN32_WINNT_WIN6  =                 &h0600 // Windows Vista
		    Const _WIN32_WINNT_VISTA =                 &h0600 // Windows Vista
		    Const _WIN32_WINNT_WS08  =                 &h0600 // Windows Server 2008
		    Const _WIN32_WINNT_LONGHORN =              &h0600 // Windows Vista
		    Const _WIN32_WINNT_WIN7     =              &h0601 // Windows 7
		    Const _WIN32_WINNT_WIN8     =              &h0602 // Windows 8
		    Const _WIN32_WINNT_WINBLUE  =              &h0603 // Windows 8.1
		    Const _WIN32_WINNT_WINTHRESHOLD =           &h0A00 // Windows 10
		    Const _WIN32_WINNT_WIN10 =                 &h0A00 // Windows 10
		    
		    Return IsWindowsVersionOrGreater(HIBYTE(_WIN32_WINNT_WINBLUE), LOBYTE(_WIN32_WINNT_WINBLUE), 0)
		  #Else
		    Return False
		  #EndIf
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function IsWindowsServer() As boolean
		  #If TargetWindows
		    // 
		    // // _WIN32_WINNT version constants
		    // //
		    // Const _WIN32_WINNT_NT4   =                  &h0400 // Windows NT 4.0
		    // Const _WIN32_WINNT_WIN2K =                 &h0500 // Windows 2000
		    // Const _WIN32_WINNT_WINXP =                 &h0501 // Windows XP
		    // Const _WIN32_WINNT_WS03  =                 &h0502 // Windows Server 2003
		    // Const _WIN32_WINNT_WIN6  =                 &h0600 // Windows Vista
		    // Const _WIN32_WINNT_VISTA =                 &h0600 // Windows Vista
		    // Const _WIN32_WINNT_WS08  =                 &h0600 // Windows Server 2008
		    // Const _WIN32_WINNT_LONGHORN =              &h0600 // Windows Vista
		    // Const _WIN32_WINNT_WIN7     =              &h0601 // Windows 7
		    // Const _WIN32_WINNT_WIN8     =              &h0602 // Windows 8
		    // Const _WIN32_WINNT_WINBLUE  =              &h0603 // Windows 8.1
		    // Const _WIN32_WINNT_WINTHRESHOLD =           &h0A00 // Windows 10
		    // Const _WIN32_WINNT_WIN10 =                 &h0A00 // Windows 10
		    // 
		    // OSVERSIONINFOEXW osvi = { sizeof(osvi), 0, 0, 0, 0, {0}, 0, 0, 0, VER_NT_WORKSTATION };
		    // DWORDLONG        Const dwlConditionMask = VerSetConditionMask( 0, VER_PRODUCT_TYPE, VER_EQUAL );
		    // 
		    // Return !VerifyVersionInfoW(&osvi, VER_PRODUCT_TYPE, dwlConditionMask);
		  #Else
		    Return False
		  #EndIf
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function IsWindowsVersionOrGreater(wMajorVersion as integer, wMinorVersion as integer, wServicePackMajor as integer) As boolean
		  #Pragma unused wMajorVersion
		  #Pragma unused wMinorVersion 
		  #pragma unused wServicePackMajor
		  
		  #If TargetWindows
		    // typedef struct _OSVERSIONINFOEXW {
		    // DWORD dwOSVersionInfoSize;   //    uint32 -> 4
		    // DWORD dwMajorVersion;        //    uint32 -> 4
		    // DWORD dwMinorVersion;        //    uint32 -> 4
		    // DWORD dwBuildNumber;         //    uint32 -> 4
		    // DWORD dwPlatformId;          //    uint32 -> 4
		    // WCHAR szCSDVersion[128];     // 128 * 2 -> 256
		    // WORD  wServicePackMajor;     //    uint16 -> 2
		    // WORD  wServicePackMinor;     //    uint16 -> 2
		    // WORD  wSuiteMask;            //    uint16 -> 2
		    // Byte  wProductType;          //     uint8 -> 1
		    // Byte  wReserved;             //     uint8 -> 1
		    // } OSVERSIONINFOEXW, *POSVERSIONINFOEXW, *LPOSVERSIONINFOEXW, RTL_OSVERSIONINFOEXW, *PRTL_OSVERSIONINFOEXW;
		    
		    // OSVERSIONINFOEXW osvi = { sizeof(osvi), 0, 0, 0, 0, {0}, 0, 0 };
		    // DWORDLONG Const dwlConditionMask = VerSetConditionMask( VerSetConditionMask( VerSetConditionMask( 0, VER_MAJORVERSION, VER_GREATER_EQUAL), VER_MINORVERSION, VER_GREATER_EQUAL), VER_SERVICEPACKMAJOR, VER_GREATER_EQUAL);
		    
		    
		    Soft Declare Function VerSetConditionMask Lib "Kernel32" ( ConditionMask As UInt64, TypeMask As UInt32, Condition As Uint8 ) As UInt64
		    Soft Declare Function VerifyVersionInfoW Lib "Kernel32" ( lpVersionInformation As Ptr, dwTypeMask As UInt32, dwlConditionMask As UInt64 ) As Boolean
		    
		    Const VER_BUILDNUMBER = &h0000004 
		    Const VER_MAJORVERSION = &h0000002
		    Const VER_MINORVERSION = &h0000001
		    Const VER_PLATFORMID = &h0000008
		    Const VER_PRODUCT_TYPE = &h0000080 
		    Const VER_SERVICEPACKMAJOR = &h0000020 
		    Const VER_SERVICEPACKMINOR = &h0000010 
		    Const VER_SUITENAME = &h0000040 
		    
		    Const VER_EQUAL = 1 // The current value must be equal To the specified value.
		    Const VER_GREATER = 2 // The current value must be greater than the specified value.
		    Const VER_GREATER_EQUAL = 3 // The current value must be greater than Or equal To the specified value.
		    Const VER_LESS = 4 // The current value must be less than the specified value.
		    Const VER_LESS_EQUAL = 5 // The current value must be less than Or equal To the specified value.
		    
		    // If dwTypeBitMask Is VER_SUITENAME, this parameter can be one Of the following values.
		    // VER_AND           6 All product suites specified In the wSuiteMask member must be present In the current System.
		    // VER_OR            7 At least one Of the specified product suites must be present In the current System.
		    
		    Dim dwlConditionMask As UInt64
		    dwlConditionMask = VerSetConditionMask( VerSetConditionMask( VerSetConditionMask( 0, VER_MAJORVERSION, VER_GREATER_EQUAL), VER_MINORVERSION, VER_GREATER_EQUAL), VER_SERVICEPACKMAJOR, VER_GREATER_EQUAL)
		    
		    Dim mb As New MemoryBlock(284)
		    Dim osvi As Ptr
		    osvi = mb
		    
		    osvi.OSVERSIONINFOEXW.dwMajorVersion = wMajorVersion
		    osvi.OSVERSIONINFOEXW.dwMinorVersion = wMinorVersion
		    osvi.OSVERSIONINFOEXW.wServicePackMajor = wServicePackMajor
		    
		    Return VerifyVersionInfoW(osvi, VER_MAJORVERSION + VER_MINORVERSION + VER_SERVICEPACKMAJOR, dwlConditionMask) <> False
		  #Else
		    Return False
		  #EndIf
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub LaunchAppWithArguments(app as string, args() as String)
		  #If TargetMacOS
		    Dim w As New NSWorkspaceMBS
		    
		    Dim file As FolderItem = GetFolderItem(app, FolderItem.PathTypeNative)
		    
		    Dim error As NSErrorMBS
		    Dim configuration As New Dictionary
		    Dim options As Integer
		    
		    configuration.Value(w.NSWorkspaceLaunchConfigurationArguments) = args
		    
		    // and hide all others
		    // options = w.NSWorkspaceLaunchAndHideOthers
		    options = w.NSWorkspaceLaunchAsync
		    
		    Dim r As NSRunningApplicationMBS = w.launchApplicationAtFile(file, options, configuration, error)
		    
		    If r = Nil Then
		      Break
		      MsgBox "Error: " + error.LocalizedDescription
		    Else
		      // MsgBox "Started: "+r.localizedName
		    End If
		    
		  #ElseIf TargetWin32
		    
		    Soft Declare Sub ShellExecuteA Lib "Shell32" ( hwnd As Integer, operation As CString, file As CString, params As CString, directory As CString, show As Integer )
		    Soft Declare Sub ShellExecuteW Lib "Shell32" ( hwnd As Integer, operation As WString, file As WString, params As WString, directory As WString, show As Integer )
		    
		    Dim params As String
		    params = Join( args, " " )
		    
		    Dim file As FolderItem = GetFolderItem(app, FolderItem.PathTypeNative)
		    
		    If System.IsFunctionAvailable( "ShellExecuteW", "Shell32" ) Then
		      ShellExecuteW( 0, "open", file.nativePath, params, "", 1 )
		    Else
		      ShellExecuteA( 0, "open", file.nativePath, params, "", 1 )
		    End If
		    
		  #Else
		    
		  #EndIf
		  
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function LOBYTE(wValue as Uint16) As Uint8
		  Return wvalue And &h00FF
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function OSBugVersion() As integer
		  Initialize
		  
		  Return m_Bug
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function OSMajorVersion() As integer
		  Initialize
		  
		  Return m_MajorVersion
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function OSMinorVersion() As integer
		  Initialize
		  
		  Return m_MinorVersion
		  
		  
		End Function
	#tag EndMethod


	#tag Property, Flags = &h21
		Private m_Bug As integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private m_Initialized As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private m_MajorVersion As integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private m_MinorVersion As integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private m_SmallSystemZeroSize As single
	#tag EndProperty

	#tag Property, Flags = &h21
		Private m_SystemZeroSize As Single
	#tag EndProperty

	#tag ComputedProperty, Flags = &h1
		#tag Getter
			Get
			  If m_Initialized = False Then
			    Initialize
			  End If
			  
			  return m_SmallSystemZeroSize
			End Get
		#tag EndGetter
		Protected SmallSystemZeroSize As Single
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h1
		#tag Getter
			Get
			  If m_Initialized = False Then
			    Initialize
			  End If
			  
			  Return m_SystemZeroSize
			End Get
		#tag EndGetter
		Protected SystemZeroSize As Single
	#tag EndComputedProperty


	#tag Structure, Name = OSVersionInfo, Flags = &h1, Attributes = \"StructureAlignment \x3D 1"
		major as integer
		  minor as integer
		bug as integer
	#tag EndStructure

	#tag Structure, Name = OSVERSIONINFOEXW, Flags = &h1
		dwOSVersionInfoSize as Uint32
		  dwMajorVersion as Uint32
		  dwMinorVersion as Uint32
		  dwBuildNumber as Uint32
		  dwPlatformId as Uint32
		  szCSDVersion(127) as Uint16
		  wServicePackMajor as Uint16
		  wServicePackMinor as Uint16
		  wSuiteMask as Uint16
		  wProductType as Uint8
		wReserved as Uint8
	#tag EndStructure


	#tag ViewBehavior
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			InitialValue=""
			Type="String"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			InitialValue="-2147483648"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			InitialValue=""
			Type="String"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Left"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
	#tag EndViewBehavior
End Module
#tag EndModule
