' ---------------------------------------------------------------------------------------
' Script for Starting Tektronix services
' ---------------------------------------------------------------------------------------
Option Explicit 

Const ForReading = 1
Dim objFSO, objFile

Set objFSO = CreateObject("Scripting.FileSystemObject")
Set objFile = objFSO.OpenTextFile("ServiceUtilities.vbs", ForReading)
Execute objFile.ReadAll()

Dim servicesToStart, needToWait, serviceName, serviceList

servicesToStart = Array ( _
						"Tektronix Auditing Service", _
						"Tektronix DQ on Rails", _
						"Tektronix Service", _
						"TektronixGatewayDQ", _
						"TektronixSMSGatewayService" _
						)

For Each serviceName in servicesToStart
	Set serviceList = GetService ( serviceName )
	needToWait = StartServices ( serviceList, serviceName, True )
Next

WScript.Echo "All Done !!!"
