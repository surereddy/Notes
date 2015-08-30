connect "SYS"/"&&sysPassword" as SYSDBA
set echo on
spool /opt/oracle/admin/test1/scripts/CloneRmanRestore.log
startup nomount pfile="/opt/oracle/admin/test1/scripts/init.ora";
@/opt/oracle/admin/test1/scripts/rmanRestoreDatafiles.sql;
