#!/bin/bash
echo "main starts"

STATS_FILE=top_stat_DP.txt
STATS_INTERVAL=5

rm -rf $STATS_FILE
date > $STATS_FILE
echo "                     PID USER      PR  NI  VIRT  RES  SHR S %CPU %MEM    TIME+  COMMAND" >> $STATS_FILE

TP_PID=`/iris/current/x64-linux-deb-6/bin64/ast | awk '/TrafficProcessor-1-1/{print $3}' ` ;
echo $TP_PID;

n=0
#while [ "$n" -lt 3 ]
while [ "$n" -lt 1000000 ]
do
	n=`expr $n + 1`
	date_text=`date '+%Y/%m/%d.%H:%M:%S'`
  top_output=`top -b -n1 -H -p $TP_PID |grep iris |grep DeliveryPoint`
  echo "$date_text $top_output" |tee -a $STATS_FILE
	#echo sleep $STATS_INTERVAL
	sleep $STATS_INTERVAL
done

echo "cpu/memory watch done"