connect "SYS"/"&&sysPassword" as SYSDBA
set echo on
spool /opt/oracle/admin/test1/scripts/cloneDBCreation.log
Create controlfile reuse set database "test1"
MAXINSTANCES 8
MAXLOGHISTORY 1
MAXLOGFILES 16
MAXLOGMEMBERS 3
MAXDATAFILES 100
Datafile 
'/opt/oracle/oradata/test1/system01.dbf',
'/opt/oracle/oradata/test1/undotbs01.dbf',
'/opt/oracle/oradata/test1/sysaux01.dbf',
'/opt/oracle/oradata/test1/users01.dbf'
LOGFILE GROUP 1 ('/opt/oracle/oradata/test1/redo01.log') SIZE 51200K,
GROUP 2 ('/opt/oracle/oradata/test1/redo02.log') SIZE 51200K,
GROUP 3 ('/opt/oracle/oradata/test1/redo03.log') SIZE 51200K RESETLOGS;
exec dbms_backup_restore.zerodbid(0);
shutdown immediate;
startup nomount pfile="/opt/oracle/admin/test1/scripts/inittest1Temp.ora";
Create controlfile reuse set database "test1"
MAXINSTANCES 8
MAXLOGHISTORY 1
MAXLOGFILES 16
MAXLOGMEMBERS 3
MAXDATAFILES 100
Datafile 
'/opt/oracle/oradata/test1/system01.dbf',
'/opt/oracle/oradata/test1/undotbs01.dbf',
'/opt/oracle/oradata/test1/sysaux01.dbf',
'/opt/oracle/oradata/test1/users01.dbf'
LOGFILE GROUP 1 ('/opt/oracle/oradata/test1/redo01.log') SIZE 51200K,
GROUP 2 ('/opt/oracle/oradata/test1/redo02.log') SIZE 51200K,
GROUP 3 ('/opt/oracle/oradata/test1/redo03.log') SIZE 51200K RESETLOGS;
alter system enable restricted session;
alter database "test1" open resetlogs;
alter database rename global_name to "test1";
ALTER TABLESPACE TEMP ADD TEMPFILE '/opt/oracle/oradata/test1/temp01.dbf' SIZE 20480K REUSE AUTOEXTEND ON NEXT 640K MAXSIZE UNLIMITED;
select tablespace_name from dba_tablespaces where tablespace_name='USERS';
select sid, program, serial#, username from v$session;
alter database character set INTERNAL_CONVERT AL32UTF8;
alter database national character set INTERNAL_CONVERT AL16UTF16;
alter user sys identified by "&&sysPassword";
alter user system identified by "&&systemPassword";
alter system disable restricted session;
