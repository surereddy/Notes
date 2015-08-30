set verify off
PROMPT specify a password for sys as parameter 1;
DEFINE sysPassword = &1
PROMPT specify a password for system as parameter 2;
DEFINE systemPassword = &2
PROMPT specify a password for sysman as parameter 3;
DEFINE sysmanPassword = &3
PROMPT specify a password for dbsnmp as parameter 4;
DEFINE dbsnmpPassword = &4
host /opt/oracle/product/10.2.0/db_1/bin/orapwd file=/opt/oracle/product/10.2.0/db_1/dbs/orapwtest1 password=&&sysPassword force=y
@/opt/oracle/admin/test1/scripts/CloneRmanRestore.sql
@/opt/oracle/admin/test1/scripts/cloneDBCreation.sql
@/opt/oracle/admin/test1/scripts/postScripts.sql
@/opt/oracle/admin/test1/scripts/postDBCreation.sql
