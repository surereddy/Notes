#!/bin/bash
# Note: each round take some seconds (suppose N) to write the stats, so the actual stat interval is STATS_INTERVAL + Ns.
# Last Update: Feb 11, 2014

######################################################################
# main starts
#######################################################################

#Paramters:
#In seconds
STATS_INTERVAL=4
LOOP_TIMES=999999


echo "main starts"
 
TP_PID=`/iris/current/x64-linux-deb-6/bin64/ast | awk '/TrafficProcessor-1-1/{print $3}' ` 
echo "TP_PID: $TP_PID"

rm -rf latency_data/*
mkdir -p latency_data

date_text=`date '+%Y/%m/%d.%H:%M:%S'`
HOSTNAME=`hostname`


#TP
touch latency_data/top_TP_all.txt
echo "$date_text   PID USER      PR  NI  VIRT  RES  SHR S %CPU %MEM    TIME+  COMMAND  " > latency_data/top_DP.txt


n=0
while [ "$n" -lt $LOOP_TIMES ]
do
  n=`expr $n + 1`
  
  date_text=`date '+%Y/%m/%d.%H:%M:%S'`
  round_time_str="round $n $date_text"
  echo $round_time_str 
#  echo $round_time_str  >> latency_data/round-time.txt


  #TP 
  top_output=`top -b -H -n 1 -p $TP_PID`
  echo "$date_text $top_output" >> latency_data/top_TP_all.txt
  top_DP_output=`top -b -H -n 1 -p $TP_PID | grep DeliveryPoint`
  echo "$date_text $top_DP_output" >> latency_data/top_DP.txt
                 
        echo "sleep ${STATS_INTERVAL}s"
        sleep $STATS_INTERVAL
done


echo "memory watch done"
