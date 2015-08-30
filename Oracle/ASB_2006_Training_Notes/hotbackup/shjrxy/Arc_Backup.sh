ARC_DIR=/oracledata/oracle/oraarch/syntong
export ARC_DIR
REMOTE_DIR=/backup/MEMA/remotes/data2
export REMOTE_DIR
BACKUP_DIR=`date +%y%m%d.%H%M`
export BACKUP_DIR

cd $REMOTE_DIR
mkdir $BACKUP_DIR

cd $ARC_DIR
find . -type f -mtime -3 -exec cp {} $REMOTE_DIR/$BACKUP_DIR \;

cd $REMOTE_DIR
find . -type d -mtime +15 -exec rm -fr {} \;
cd $ARC_DIR
find . -type f -mtime +15 -exec rm -fr {} \;