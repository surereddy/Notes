PATH=/export/oracle/product/9.2.0/bin:/usr/bin:/usr/openwin/bin:/usr/ucb:/etc:.
export PATH

ORACLE_BASE=/export/oracle
export ORACLE_BASE
ORACLE_OWNER=oracle
export ORACLE_OWNER
ORACLE_HOME=/export/oracle/product/9.2.0
export ORACLE_HOME
ORACLE_SID=jsjd
export ORACLE_SID
ORACLE_TERM=sun
export ORACLE_TERM

BACKUP_DATE=`date +%y%m%d`
export BACKUP_DATE
cd /export/oracle/orabackup/data
mkdir $BACKUP_DATE
BACKUP_DIR=/export/oracle/orabackup/data/$BACKUP_DATE
export BACKUP_DIR
BACKUP_ARC=/export/oracle/orabackup/archive
export BACKUP_ARC

sqlplus /nolog <<EOF

connect / as sysdba

alter tablespace SYSTEM begin backup; 
!cp /export/oracle/oradata/jsjd/system01.dbf $BACKUP_DIR
alter tablespace SYSTEM end backup; 

alter tablespace UNDOTBS1 begin backup; 
!cp /export/oracle/oradata/jsjd/undotbs01.dbf $BACKUP_DIR
alter tablespace UNDOTBS1 end backup;

alter tablespace INDX begin backup;
!cp /export/oracle/oradata/jsjd/indx01.dbf $BACKUP_DIR
alter tablespace INDX end backup; 

alter tablespace TOOLS begin backup; 
!cp /export/oracle/oradata/jsjd/tools01.dbf $BACKUP_DIR
alter tablespace TOOLS end backup;

alter tablespace EP begin backup;
!cp /export/oracle/oradata/jsjd/EP.dbf $BACKUP_DIR 
alter tablespace EP end backup;

alter tablespace EPP begin backup;
!cp /export/oracle/oradata/jsjd/EPP.dbf $BACKUP_DIR 
alter tablespace EPP end backup; 

alter tablespace ZPEPTRI begin backup;
!cp /export/oracle/oradata/jsjd/ZPEPTRI.dbf $BACKUP_DIR
alter tablespace ZPEPTRI end backup; 

alter tablespace JHEP begin backup;
!cp /export/oracle/oradata/jsjd/JHEP.dbf $BACKUP_DIR
alter tablespace JHEP end backup;  

alter tablespace JXEPP begin backup;
!cp /export/oracle/oradata/jsjd/JXEPP.dbf $BACKUP_DIR
alter tablespace JXEPP end backup;  

alter tablespace BLEPP begin backup;
!cp /export/oracle/oradata/jsjd/BLEPP.dbf $BACKUP_DIR
alter tablespace BLEPP end backup;  

alter tablespace HUEP begin backup;
!cp /export/oracle/oradata/jsjd/HUEP.dbf $BACKUP_DIR
alter tablespace HUEP end backup;  

alter tablespace MONITOR begin backup;
!cp /export/oracle/oradata/jsjd/MONITOR.dbf $BACKUP_DIR
alter tablespace MONITOR end backup;  

alter tablespace NBEP begin backup;
!cp /export/oracle/oradata/jsjd/NBEP.dbf $BACKUP_DIR
alter tablespace NBEP end backup;  

alter tablespace QZEP begin backup;
!cp /export/oracle/oradata/jsjd/QZEP.dbf $BACKUP_DIR
alter tablespace QZEP end backup;  

alter tablespace TZEP begin backup;
!cp /export/oracle/oradata/jsjd/TZEP.dbf $BACKUP_DIR
alter tablespace TZEP end backup;  

alter tablespace WZEP begin backup;
!cp /export/oracle/oradata/jsjd/WZEP.dbf $BACKUP_DIR
alter tablespace WZEP end backup;  

alter tablespace XSEPP begin backup;
!cp /export/oracle/oradata/jsjd/XSEPP.dbf $BACKUP_DIR
alter tablespace XSEPP end backup;  

alter system archive log current;
alter system archive log stop;
!cp /export/oracle/oradata/jsjd/archive/*.* $BACKUP_ARC	\
!rm /export/oracle/oradata/jsjd/archive/*.*
alter system archive log start;

alter database backup controlfile to $BACKUP_DIR/ctl.bck;

EOF