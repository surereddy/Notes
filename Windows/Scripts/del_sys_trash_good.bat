echo ɾ����ϵͳ��һЩ��Ҫ����ʱ�ļ�����Ӱ��ϵͳ��������������������ϵͳ������cmd����Щ������ã���del.
echo ȷ��Please play any key
pause
@echo off
echo �������ϵͳ�����ļ������Ե�......
del /f /s /q %systemdrive%\*.tmp
del /f /s /q %systemdrive%\*._mp
del /f /s /q %systemdrive%\*.log
del /f /s /q %systemdrive%\*.gid
del /f /s /q %systemdrive%\*.chk
del /f /s /q %systemdrive%\*.old
del /f /s /q %systemdrive%\recycled\*.*
del /f /s /q %windir%\*.bak
del /f /s /q %windir%\prefetch\*.*
rd /s /q %windir%\temp & md %windir%\temp
rem del /f /q %userprofile%\Cookies\*.*
del /f /q %userprofile%\recent\*.*
del /f /s /q "%userprofile%\Local Settings\Temporary Internet Files\*.*"
del /f /s /q "%userprofile%\Local Settings\Temp\*.*"
del /f /s /q "%userprofile%\recent\*.*"
del /f /s /q "D:\*.bak"
del /f /s /q "G:\*.bak"
echo ���ϵͳLJ��ɣ�
pause