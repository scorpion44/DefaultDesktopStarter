#tag Module
Protected Module Debug
	#tag Method, Flags = &h0
		Sub Assert(condition as Boolean, message as string)
		  If condition = False Then
		    
		    #If DebugBuild Then
		      
		      Dim skipShowingMsgBox As Boolean
		      
		      // at least on macOS we cant show a msgbox IF we are in a paint event
		      // so we need to figure out if that is the case
		      
		      #Pragma BreakOnExceptions False
		      
		      #If TargetMacOS
		        Try
		          Raise New nilobjectException
		        Catch noe As nilobjectexception
		          Dim s() As String = noe.Stack
		          For i As Integer = 0 To s.ubound
		            Dim eventName As String = NthField(s(i),".",2)
		            If eventName.Left(Len("Event_Paint%%o")) = "Event_Paint%%o" Then
		              skipShowingMsgBox = True
		              Exit
		            End If
		          Next
		        End Try
		      #EndIf
		      
		      #Pragma BreakOnExceptions Default
		      
		      If skipShowingMsgBox = False Then
		        MsgBox "Assertion failed" + EndOfLine + message
		      End If
		      
		      // now we can go see what caused the assertion in the debugger
		      // by walking the stack
		      Break 
		      
		    #Else
		      
		      System.Log System.LogLevelCritical, "Assertion failed " + EndOfLine + message
		      
		    #EndIf
		    
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0, Description = 41206C6F6767696E67206D6574686F6420746861742077696C6C204E4F5420776F726B20696E2072656C65617365206275696C647320756E6C65737320796F75206578706C696369746C792070617373205452554520666F7220746865207365636F6E6420706172616D6174657220746F20464F52434520746865206465627567206C6F6720746F20657865637574652E0A54686973206D616B65732069742065737920746F206D616B65207375726520796F757220646562756767696E67206D6573736167657320617265204E4F542070726573656E7420696E20796F7572206275696C7420736F667477617265206279206163636964656E742E
		Sub Log(msg as string, forced as boolean = false)
		  #Pragma unused msg
		  #pragma unused forced
		  
		  // make it so this code only exists in debug builds and does nothing in builds
		  // UNLESS the log is forced
		  
		  #If DebugBuild 
		    System.log System.LogLevelDebug, msg
		    Return
		  #Else
		    If forced Then
		      System.log System.LogLevelDebug, msg
		    End If
		  #EndIf
		  
		End Sub
	#tag EndMethod


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
