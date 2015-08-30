'----------------------------------------------------------------------------------------------------
'	Purpose		:	Utility Script for Stopping a Service and Its Dependents
'	Reference	: 	https://www.microsoft.com/technet/scriptcenter/guide/sas_ser_zhcb.mspx?mfr=true
'----------------------------------------------------------------------------------------------------

Option Explicit 

' ---------------------------------------------------------------------------------------
' Construct display string of service
'----------------------------------------------------------------------------------------
Function GetServiceDisplayStr ( objService )
	GetServiceDisplayStr = objService.DisplayName & "[" & objService.name & "]"
End Function

' ---------------------------------------------------------------------------------------
' Show service state
'----------------------------------------------------------------------------------------
Function ShowServiceState ( objService )

	WScript.Echo "    " & objService.State & " : " & GetServiceDisplayStr ( objService )

End Function

' ---------------------------------------------------------------------------------------
' Show the states of the services.
'----------------------------------------------------------------------------------------
Function ShowServiceStates ( serviceList )

Dim objService

	For Each objService in serviceList
		ShowServiceState ( objService )
	Next

End Function

'----------------------------------------------------------------------------------------------------
' For each service in the collection, use the StopService method to stop the service.
'----------------------------------------------------------------------------------------------------
Function StopServices ( serviceList, parentName, isParent )

Dim needToWait, objService, errReturn

	If isParent Then
		WScript.Echo "Stopping " & parentName & " ..."
	Else
		WScript.Echo "Stopping Dependent Services of " & parentName & " ..."
	End If

	needToWait = False
	For Each objService in serviceList
		If objService.State <> "Stopped" and objService.State <> "Stop Pending" Then
			WScript.Echo "    Stopping : " & GetServiceDisplayStr ( objService )  & " ..."
			errReturn = objService.StopService()
			needToWait = True
		Else
			ShowServiceState ( objService )
		End If
	Next
    StopServices = needToWait

	Call WaitForService ( needToWait, parentName, isParent, "Stopped" )

End Function

' ---------------------------------------------------------------------------------------
' For each service in the collection, use the StartService method to start the service.
'----------------------------------------------------------------------------------------
Function StartServices ( serviceList, parentName, isParent )

Dim needToWait, objService, errReturn

	If isParent Then
		WScript.Echo "Starting " & parentName & " ..."
	Else
		WScript.Echo "Starting Dependent Services of " & parentName & " ..."
	End If

	needToWait = False
	For Each objService in serviceList
		If objService.State = "Stopped" or objService.State = "Stop Pending" Then
			WScript.Echo "    Starting : " & GetServiceDisplayStr ( objService ) & " ..."
			errReturn = objService.StartService()
			needToWait = True
		Else
			ShowServiceState ( objService )
		End If
	Next
    StartServices = needToWait

	Call WaitForService ( needToWait, parentName, isParent, "Running" )

End Function

' ---------------------------------------------------------------------------------------
' Wait for services to start
'----------------------------------------------------------------------------------------
Function WaitForService ( needToWait, parentName, isParent, targetState )

Const maxWait = 60000 'Wait 60 seconds max
Const singleWait = 5000 'Wait 5 seconds

Dim totalWait, objService, colServiceList
	
	totalWait = 0

'	If isParent Then
'		WScript.Echo "Checking " & parentName & " ..."
'	Else
'		WScript.Echo "Checking Dependent Services of " & parentName & " ..."
'	End If

	While needToWait
		If isParent Then
			Set colServiceList = GetService ( parentName )
		Else
			Set colServiceList = GetDependentServices ( parentName )
		End If

		needToWait = False
		For Each objService in colServiceList
			WScript.Echo "    " & objService.State & " : " & GetServiceDisplayStr ( objService )
			If objService.State <> targetState Then
				needToWait = True
			End If
		Next

		If needToWait Then
			If totalWait < maxWait Then
				Wscript.Sleep singleWait
				totalWait = totalWait + singleWait
			Else
				WScript.Echo "    Have been waiting for " & maxWait & " seconds. Forget it !"
				needToWait = False
			End If
		End If
	Wend

End Function

' ---------------------------------------------------------------------------------------
' Get parent service object
' Use a GetObject call to connect to the WMI namespace root\cimv2,
' and set the impersonation level to "impersonate."
'----------------------------------------------------------------------------------------
Function GetService ( parentName )

Dim objWMIService, serviceList
	Set objWMIService = GetObject("winmgmts:" & "{impersonationLevel=impersonate}!\\.\root\cimv2")
	Set serviceList = objWMIService.ExecQuery ("SELECT * FROM Win32_Service WHERE Name='" & parentName & "'")
	Set GetService = serviceList

End Function

' ---------------------------------------------------------------------------------------
' Get dependent service objects
' Use the ExecQuery method to query the Win32_Service class.
'	This query must use an Associators of query and specify the following information:
'	- The instance of the service on which the query is performed (Win32_Service.Name = 'IISAdmin').
'	- The name of the Association class (AssocClass = Win32_DependentService). If the class name is not specified, the query returns all associated classes and their instances.
'	- The role played by the IISAdmin Service. In this case, IISAdmin is Antecedent to the services to be returned by the query.
' The query returns a collection consisting of all the services dependent on the IIS Admin Service.
'----------------------------------------------------------------------------------------------------
Function GetDependentServices ( parentName )

Dim objWMIService, serviceList

	Set objWMIService = GetObject("winmgmts:" & "{impersonationLevel=impersonate}!\\.\root\cimv2")
	Set serviceList = objWMIService.ExecQuery ("ASSOCIATORS OF {Win32_Service.Name='" & parentName & "'} WHERE " & "AssocClass=Win32_DependentService Role=Antecedent" )
	Set GetDependentServices = serviceList

End Function

' ---------------------------------------------------------------------------------------
