# Full_Backup.sh
REMOTE_DIR=/backup/MEMA/remotes/data1
export REMOTE_DIR
BACKUP_DIR=`date +%y%m%d.%H%M`
export BACKUP_DIR
cd /backup/MEMA/backups
rm -f *
cd $REMOTE_DIR
mkdir $BACKUP_DIR
cd /backup/MEMA/scripts
sqlplus "/ as sysdba" @Gen_Hotbackup_Script.sql
sqlplus "/ as sysdba" @HOTBACKUP.SQL
cd /backup/MEMA/backups
compress *
cd $REMOTE_DIR
#mkdir $BACKUP_DIR
cd $BACKUP_DIR
cp /backup/MEMA/backups/* .
cd $REMOTE_DIR
find . -type d -mtime +15 -exec rm -fr {} \;