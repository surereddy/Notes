@echo off

rem setlocal enabledelayedexpansion

rem set a=2201
for /l %%i in (2100,1,2348) do (
rem  ren "%%i" "!a!%%~xi"
rem  set /a a=!a!+1 
rem echo start openRTSP.exe rtsp://172.18.11.242:1554/%%i >> 300rtsp.bat
 echo start openRTSP.exe rtsp://172.18.11.248:554/media/%%i >> 1.bat
)

rem endlocal

echo on