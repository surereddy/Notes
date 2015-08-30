'***********************
Dim strProjectName
strProjectName="GMS"
'***********************

'Wscript environment only
'-----------------------------
Function getCurrentPath()

 Dim objFSO,strScriptFullName
 
 Set objFSO = CreateObject("Scripting.FileSystemObject")
 strScriptFullName=WScript.ScriptFullName 
 getCurrentPath=objFSO.GetParentFolderName(strScriptFullName)

' MsgBox "ScriptFullName: " & strScriptFullName
' MsgBox "ScriptPath: " & objFSO.GetParentFolderName(strScriptFullName)
 
End Function
'MsgBox getCurrentPath()

'Main()
'-----------------------------
Dim strCurrentPath
strCurrentPath= getCurrentPath()

Dim oShell,run
Dim strCRT_Path,strVBS_Script,strCMD
 Set oShell = CreateObject("WScript.Shell") 
'strVBS_Script="D:\Projects\a_TestTools\Test\Framework\Scripts\CommonServerConfig.vbs"
strCMD="mkdir " & Chr(34) & strCurrentPath & "\" & strProjectName  & Chr(34) 
oShell.Run strCMD
strCMD="mkdir " & Chr(34) & strCurrentPath & "\" & strProjectName & "\Doc" & Chr(34) 
oShell.Run strCMD
strCMD="mkdir " & Chr(34) & strCurrentPath & "\" & strProjectName & "\Test" & Chr(34)
oShell.Run strCMD 
strCMD="mkdir " & Chr(34) & strCurrentPath & "\" & strProjectName & "\Info" & Chr(34)
oShell.Run strCMD

'Trace(strCMD)
'MsgBox strCMD

Set oShell=Nothing

