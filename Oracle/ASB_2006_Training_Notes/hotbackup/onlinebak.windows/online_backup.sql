connect system/system
spool onlinebackup.log
alter tablespace SYSTEM begin backup;              
host copy E:\ORACLE\ORA92\CBAS\SYSTEM01.DBF system01.dbf 
alter tablespace SYSTEM end backup;    

alter tablespace UNDOTBS1 begin backup;            
host copy E:\ORACLE\ORA92\CBAS\UNDOTBS01.DBF UNDOTBS01.DBF 
alter tablespace UNDOTBS1 end backup;

alter tablespace DRSYS begin backup;               
host copy E:\ORACLE\ORA92\CBAS\DRSYS01.DBF DRSYS01.DBF 
alter tablespace DRSYS end backup;
 
alter tablespace INDX begin backup;                
host copy E:\ORACLE\ORA92\CBAS\INDX01.DBF INDX01.DBF 
alter tablespace INDX end backup;

alter tablespace TOOLS begin backup;               
host copy E:\ORACLE\ORA92\CBAS\TOOLS01.DBF TOOLS01.DBF 
alter tablespace TOOLS end backup;

alter tablespace USERS begin backup;               
host copy E:\ORACLE\ORA92\CBAS\USERS01.DBF USERS01.DBF 
alter tablespace USERS end backup;

alter tablespace CBAS begin backup;                 
host copy E:\ORACLE\ORA92\CBAS\CBAS.ORA CBAS.ORA 
alter tablespace CBAS end backup;

alter tablespace XDB begin backup;                 
host copy E:\ORACLE\ORA92\CBAS\XDB01.DBF XDB01.DBF 
alter tablespace XDB end backup;

alter database backup controlfile to 'control.bck';

alter system archive log current;
alter system archive log stop;
host COPY E:\ORACLE\archive\CBAS\*.* .\archive
HOST MOVE E:\oracle\ora92\database\control.bck . 
alter system archive log start;

spool off;
exit;
