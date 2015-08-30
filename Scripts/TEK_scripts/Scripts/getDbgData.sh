#!/bin/bash

function usage () {
    echo "usage: "
    echo "./getDbgData.sh \[-h|--help\] \"<start time>\" \"<end time>\""
    echo ""
    echo "examples:" 
    echo "./getDbgData.sh -h" 
    echo "./getDbgData.sh --help" 
    echo "./getDbgData.sh \"14-9-23 12:00\" \"14-9-23 13:00\""

    exit 1
}

if [ "$1" == "-h" ] | [ "$1" == "--help" ] | [ "$#" -ne 2 ]; then
    usage
fi


date -d "$1"
if [ "$?" -ne 0 ]; then
    echo "date: invalid date $1."
    exit 1
fi

date -d "$2"
if [ "$?" -ne 0 ]; then
    echo "date: invalid date $2."
    exit 1
fi

d1_sec=`date -d "$1" +%s`
d2_sec=`date -d "$2" +%s`

if [ "$d1_sec" -ge "$d2_sec" ]; then
    echo "Invalid Timeframe. Date2 should occur after Date1."
    exit 1
fi

probe_name=`cat /iris/etc/probename`
curr_date=`date`
dir_ts=`echo $curr_date | sed "s/ /_/g" | sed "s/:/_/g"`
dir_name="$probe_name"_"$dir_ts"
dir_path="/iris/scratch/bkup/$dir_name"
bkup_path="/iris/scratch/bkup"

mkdir -p $dir_path

echo "Collecting showHw Information..."
showHw >& $dir_path/showHw

echo "Collecting inventory Information..."
aui ProbeManager -c "send ProbeManager pm_dis_pe_inv" >& $dir_path/pm_dis_pe_inv

echo "Collecting sv Information..."
sv >& $dir_path/sv

cp -r --parent /iris/current/config $dir_path/
cp -r --parent /iris/current/octeon2-x500-cvmx-mv-6/bin64/ $dir_path/ 
cp -r --parent /var/log/iris.log $dir_path/
cp -r --parent /var/log/kern.log $dir_path/

touch_ts_1=`date -d "$1"`
touch_ts_2=`date -d "$2"`

touch -d "$touch_ts_1" $dir_path/start_marker
touch -d "$touch_ts_2" $dir_path/stop_marker

start="$dir_path/start_marker"
stop="$dir_path/stop_marker"

find /log/trace/ -newer $start \! -newer $stop | while read tracefile
do
    cp -r --parent $tracefile $dir_path/
done

find /iris/home/stats -newer $start \! -newer $stop | while read statsfile
do
    cp -r --parent $statsfile $dir_path/
done

find /iris/home/alarms -newer $start \! -newer $stop | while read alarmsfile
do
    cp -r --parent $alarmsfile $dir_path/
done

find /iris/scratch/iicLogs -newer $start \! -newer $stop | while read alarmsfile
do
    cp -r --parent $alarmsfile $dir_path/
done

rm $dir_path/start_marker
rm $dir_path/stop_marker

echo "Creating tar archive.....this may take long time depending on size of archive."
cd $bkup_path
tar -zcf "$bkup_path/$dir_name.tgz" $dir_name/
cd -

echo "Created archive file - $bkup_path/$dir_name.tgz"
rm -rf $dir_path
