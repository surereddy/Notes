#$language = "VBScript"
#$interface = "1.0"

' This automatically generated script may need to be
' edited in order to work correctly.

Sub Main
	crt.Screen.Send chr(13)
	crt.Screen.WaitForString "linux:" & chr(126) & " # "
	crt.Screen.Send "ssh -p 999 192.168.0.50" & chr(13)
	crt.Screen.WaitForString "Password: "
	crt.Screen.Send "bell!234" & chr(13)
End Sub
