connect "SYS"/"&&sysPassword" as SYSDBA
set echo on
spool /opt/oracle/admin/test1/scripts/postDBCreation.log
connect "SYS"/"&&sysPassword" as SYSDBA
set echo on
create spfile='/opt/oracle/product/10.2.0/db_1/dbs/spfiletest1.ora' FROM pfile='/opt/oracle/admin/test1/scripts/init.ora';
shutdown immediate;
connect "SYS"/"&&sysPassword" as SYSDBA
startup ;
alter user SYSMAN identified by "&&sysmanPassword" account unlock;
alter user DBSNMP identified by "&&dbsnmpPassword" account unlock;
select 'utl_recomp_begin: ' || to_char(sysdate, 'HH:MI:SS') from dual;
execute utl_recomp.recomp_serial();
select 'utl_recomp_end: ' || to_char(sysdate, 'HH:MI:SS') from dual;
host /opt/oracle/product/10.2.0/db_1/bin/emca -config dbcontrol db -silent -DB_UNIQUE_NAME test1 -PORT 1521 -EM_HOME /opt/oracle/product/10.2.0/db_1 -LISTENER LISTENER -SERVICE_NAME test1 -SYS_PWD &&sysPassword -SID test1 -ORACLE_HOME /opt/oracle/product/10.2.0/db_1 -DBSNMP_PWD &&dbsnmpPassword -HOST linux-1wsu.ad4 -LISTENER_OH /opt/oracle/product/10.2.0/db_1 -LOG_FILE /opt/oracle/admin/test1/scripts/emConfig.log -SYSMAN_PWD &&sysmanPassword;
spool /opt/oracle/admin/test1/scripts/postDBCreation.log
