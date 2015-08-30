@echo OFF
goto START_SVC

rem IF "%1" == "start" goto START_SVC
rem IF "%1" == "START" goto START_SVC
rem 
rem IF "%1" == "stop" goto STOP_SVC
rem IF "%1" == "STOP" goto STOP_SVC
rem 
rem IF "%1" == "show" goto SHOW_SVC
rem IF "%1" == "SHOW" goto SHOW_SVC


@echo -----------------------------------------------------
@echo Usage
@echo -----------------------------------------------------
echo     %0 start
echo     %0 stop
echo     %0 show
@echo -----------------------------------------------------
goto complete

:START_SVC
@echo -----------------------------------------------------
@echo Starting Tektronix Services
@echo -----------------------------------------------------
CSCRIPT /NoLogo StartTekServices.vbs
IF NOT %ERRORLEVEL% == 0 goto showError

goto complete

:STOP_SVC
@echo -----------------------------------------------------
@echo Stopping Tektronix Services
@echo -----------------------------------------------------
CSCRIPT /NoLogo StopTekServices.vbs
IF NOT %ERRORLEVEL% == 0 goto showError

goto complete

:SHOW_SVC
@echo -----------------------------------------------------
@echo Stopping Tektronix Services
@echo -----------------------------------------------------
CSCRIPT /NoLogo ShowTekServices.vbs
IF NOT %ERRORLEVEL% == 0 goto showError

goto complete

:showError
echo ======================================================
echo              EEEE RRRR  RRRR   OOO  RRRR  
echo              E    R   R R   R O   O R   R 
echo              EEE  RRRR  RRRR  O   O RRRR  
echo              E    R R   R R   O   O R R   
echo              EEEE R  RR R  RR  OOO  R  RR 
echo ======================================================  
goto done

:complete
echo ======================================================  
echo     CCC  OOO  M   M PPPP  L    EEEE TTTTTT EEEE 
echo    C    O   O MM MM P   P L    E      TT   E    
echo    C    O   O M M M PPPP  L    EEE    TT   EEE  
echo    C    O   O M   M P     L    E      TT   E    
echo     CCC  OOO  M   M P     LLLL EEEE   TT   EEEE 
echo ======================================================

:done
pause