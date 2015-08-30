set oracle_sid=cbas
set BACKUP_DIR=%date:~4,2%_%date:~7,2%_%date:~10,4%
mkdir E:\oracle\ora_backup\%BACKUP_DIR%
mkdir E:\oracle\ora_backup\%BACKUP_DIR%\archive
cd E:\oracle\ora_backup\%BACKUP_DIR%
sqlplus system/system @E:\oracle\ora_backup\online_backup.sql
del E:\oracle\ora92\database\control.bck
