SET ECHO OFF
SET SERVEROUTPUT ON SIZE 1000000
SET FEEDBACK OFF
--#--------------------------------------------------------------------------------------------
--# Generate Oracle database hot backup scripts
--#   - Oracle version > 8i 
--#   - run with sqlplus as sysdba
--# 2005/04/04
--# Writed by WangJianping / MEMA / oracleservice@china.com
--#--------------------------------------------------------------------------------------------

SET VERIFY OFF
SET PAGESIZE 40
SET LINESIZE 110
SET HEADING OFF
COLUMN file_name FORMAT a70
COLUMN tablespace_name FORMAT a30
--
DEFINE DIR=/backup/MEMA/backups
SPOOL /backup/MEMA/scripts/HOTBACKUP.SQL

SELECT '--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~' FROM DUAL;
SELECT '--~                                                                                                   ~' FROM DUAL;
SELECT '--~                                   DATABASE HOT BACKUP SCRIPTS                                     ~' FROM DUAL;
SELECT '--~                                                                                                   ~' FROM DUAL;
SELECT '--~                     Provided and Supported by MEMA Software (ShangHai) Co.,Ltd                    ~' FROM DUAL;
SELECT '--~                                     oracleservice@china.com                                       ~' FROM DUAL;
SELECT '--~                               Copyright 2005,MEMA. All rights reserved                            ~' FROM DUAL;
SELECT '--~                                                                                                   ~' FROM DUAL;
SELECT '--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~' FROM DUAL;
SELECT '-------------------------------------------------------------------------------------------------------' FROM DUAL;
SELECT '-- ',tablespace_name,file_name FROM dba_data_files ORDER BY tablespace_name;
SELECT '--  TOTAL SIZE:',SUM(BYTES)/(1024*1024),'MB' FROM V$DATAFILE;
SELECT '-------------------------------------------------------------------------------------------------------' FROM DUAL;
DECLARE
 
 CURSOR cur_tablespace IS select distinct tablespace_name from dba_data_files;
 CURSOR cur_datafile(p_tablespace varchar2) is select file_name from dba_data_files where tablespace_name=p_tablespace;
 v_line NUMBER:=1;
BEGIN
 DBMS_OUTPUT.PUT_LINE('SET ECHO ON');
 DBMS_OUTPUT.PUT_LINE('SPOOL '||'/backup/MEMA/logs/HOTBACKUP.LOG');
 FOR rec_tablespace IN cur_tablespace LOOP
  DBMS_OUTPUT.PUT_LINE('-- '||TO_CHAR(v_line)||' --');
  DBMS_OUTPUT.PUT_LINE('ALTER TABLESPACE '||rec_tablespace.tablespace_name||' BEGIN BACKUP;');
  FOR rec_datafile in cur_datafile(rec_tablespace.tablespace_name) LOOP
    DBMS_OUTPUT.PUT_LINE('HOST COPY '||rec_datafile.file_name||' &DIR');	
  END LOOP;
  DBMS_OUTPUT.PUT_LINE('ALTER TABLESPACE '||rec_tablespace.tablespace_name||' END BACKUP;');
  v_line:=v_line+1;
 END LOOP;
 DBMS_OUTPUT.PUT_LINE('-- BACKUP CONTROLFILE --');
 DBMS_OUTPUT.PUT_LINE('ALTER DATABASE BACKUP CONTROLFILE TO '||'''&DIR'||'/control.backup'''||';');
 DBMS_OUTPUT.PUT_LINE('-- CREATE STANDBY CONTROLFILE --');
 DBMS_OUTPUT.PUT_LINE('ALTER DATABASE CREATE STANDBY CONTROLFILE AS '||'''&DIR'||'/control.standby'''||';');
 DBMS_OUTPUT.PUT_LINE('SPOOL OFF');
END;
/

--
SPOOL OFF
SET ECHO ON
SET FEEDBACK ON
