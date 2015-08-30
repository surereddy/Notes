#!/bin/sh

mkdir -p /opt/oracle/admin/test1/adump
mkdir -p /opt/oracle/admin/test1/bdump
mkdir -p /opt/oracle/admin/test1/cdump
mkdir -p /opt/oracle/admin/test1/dpdump
mkdir -p /opt/oracle/admin/test1/pfile
mkdir -p /opt/oracle/admin/test1/udump
mkdir -p /opt/oracle/flash_recovery_area
mkdir -p /opt/oracle/oradata/test1
mkdir -p /opt/oracle/product/10.2.0/db_1/cfgtoollogs/dbca/test1
mkdir -p /opt/oracle/product/10.2.0/db_1/dbs
ORACLE_SID=test1; export ORACLE_SID
echo You should Add this entry in the /etc/oratab: test1:/opt/oracle/product/10.2.0/db_1:Y
/opt/oracle/product/10.2.0/db_1/bin/sqlplus /nolog @/opt/oracle/admin/test1/scripts/test1.sql
