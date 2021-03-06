STARTUP NOMOUNT
CREATE CONTROLFILE REUSE DATABASE "ORCL" NORESETLOGS  ARCHIVELOG
--  SET STANDBY TO MAXIMIZE PERFORMANCE
    MAXLOGFILES 50
    MAXLOGMEMBERS 5
    MAXDATAFILES 100
    MAXINSTANCES 1
    MAXLOGHISTORY 226
LOGFILE
  GROUP 2 'D:\ORACLE\ORADATA\ORCL\REDO02.LOG'  SIZE 100M,
  GROUP 3 'D:\ORACLE\ORADATA\ORCL\REDO03.LOG'  SIZE 100M,
  GROUP 4 'D:\ORACLE\ORADATA\LOG\REDO04_2.LOG'  SIZE 10M
-- STANDBY LOGFILE
DATAFILE
  'D:\ORACLE\ORADATA\ORCL\SYSTEM01.DBF',
  'D:\ORACLE\ORADATA\ORCL\CWMLITE01.DBF',
  'D:\ORACLE\ORADATA\ORCL\DRSYS01.DBF',
  'D:\ORACLE\ORADATA\ORCL\EXAMPLE01.DBF',
  'D:\ORACLE\ORADATA\ORCL\INDX01.DBF',
  'D:\ORACLE\ORADATA\ORCL\ODM01.DBF',
  'D:\ORACLE\ORADATA\ORCL\TOOLS01.DBF',
  'D:\ORACLE\ORADATA\USERS\USERS01.DBF',
  'D:\ORACLE\ORADATA\ORCL\XDB01.DBF',
  'D:\ORACLE\ORADATA\ORCL\SAMPLE01.DBF',
  'D:\ORACLE\ORADATA\ORCL\HTMLDB01.DBF',
  'D:\ORACLE\ORADATA\USERS\USERS02.DBF',
  'D:\ORACLE\ORADATA\ORCL\DATA01.DBF',
  'D:\ORACLE\ORADATA\ORCL\DATA02.DBF',
  'D:\ORACLE\ORADATA\ORCL\DATA03.DBF',
  'D:\ORACLE\ORADATA\ORCL\DATA04.DBF',
  'D:\ORACLE\ORADATA\ORCL\DATA05.DBF',
  'D:\ORACLE\ORADATA\ORCL\UNDO1.ORA',
  'D:\ORACLE\ORADATA\ORCL\UNDO1_2.DBF'
CHARACTER SET ZHS16GBK
;
# Configure RMAN configuration record 1
VARIABLE RECNO NUMBER;
EXECUTE :RECNO := SYS.DBMS_BACKUP_RESTORE.SETCONFIG('RETENTION POLICY','TO REDUNDANCY 2');
# Configure RMAN configuration record 2
VARIABLE RECNO NUMBER;
EXECUTE :RECNO := SYS.DBMS_BACKUP_RESTORE.SETCONFIG('DEFAULT DEVICE TYPE TO','DISK');
# Configure RMAN configuration record 3
VARIABLE RECNO NUMBER;
EXECUTE :RECNO := SYS.DBMS_BACKUP_RESTORE.SETCONFIG('DEVICE TYPE','DISK PARALLELISM 1');
# Configure RMAN configuration record 4
VARIABLE RECNO NUMBER;
EXECUTE :RECNO := SYS.DBMS_BACKUP_RESTORE.SETCONFIG('CHANNEL','DEVICE TYPE DISK FORMAT   ''D:\oracle\backup\orcl\backupsets\orcl_%U.rman'' MAXPIECESIZE 500 M');
# Configure RMAN configuration record 5
VARIABLE RECNO NUMBER;
EXECUTE :RECNO := SYS.DBMS_BACKUP_RESTORE.SETCONFIG('CONTROLFILE AUTOBACKUP FORMAT FOR DEVICE TYPE','DISK TO ''D:\oracle\backup\orcl\backupsets/orcl-%F.ctl''');
# Configure RMAN configuration record 6
VARIABLE RECNO NUMBER;
EXECUTE :RECNO := SYS.DBMS_BACKUP_RESTORE.SETCONFIG('CONTROLFILE AUTOBACKUP','ON');
# Recovery is required if any of the datafiles are restored backups,
# or if the last shutdown was not normal or immediate.
RECOVER DATABASE
# All logs need archiving and a log switch is needed.
ALTER SYSTEM ARCHIVE LOG ALL;
# Database can now be opened normally.
ALTER DATABASE OPEN;
# Commands to add tempfiles to temporary tablespaces.
# Online tempfiles have complete space information.
# Other tempfiles may require adjustment.
ALTER TABLESPACE TEMP1 ADD TEMPFILE 'D:\ORACLE\ORADATA\ORCL\TMP1.DBF'
     SIZE 104857600  REUSE AUTOEXTEND OFF;
