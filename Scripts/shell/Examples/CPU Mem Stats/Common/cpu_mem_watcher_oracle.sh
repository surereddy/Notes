#!/bin/bash
# Note: each round take some seconds (suppose N) to write the stats, so the actual stat interval is STATS_INTERVAL + Ns.


######################################################################
# main starts
#######################################################################

#Paramters:
#In seconds, default 9
STATS_INTERVAL=9
LOOP_TIMES=99999
#grep string for monitored disk, e.g. "c0t0d0". If empty, it collects all disk io stats.
#check by "iostat -xn" and "df -h".
IO_DISK_STRING=""
#lines of 'iostat -xn 1 2' to tail, i.e. one time lines number.
#IO_LINES=8

#oracle user in this case
PRSTAT_GREP_USER="oracle"

echo "main starts"
 
rm -rf latency_data/*
mkdir -p latency_data

date_text=`date '+%Y/%m/%d.%H:%M:%S'`
HOSTNAME=`hostname`

GREP_IO_DISK=0
if [ `echo "$IO_DISK_STRING" | wc -w` -gt 0 ]; then
  GREP_IO_DISK=1
fi 

#overall stat files
touch latency_data/round-time.txt
echo "00:00:00    %usr    %sys    %wio   %idle" >  latency_data/sar_$HOSTNAME.txt
touch latency_data/swap.txt
touch latency_data/iostat.txt
if [ $GREP_IO_DISK -eq 1 ]; then
  echo "$date_text     r/s    w/s   kr/s   kw/s wait actv wsvc_t asvc_t  %w  %b device" >> latency_data/iostat.txt  
fi 

#oracle
echo "$date_text  NPROC USERNAME  SWAP   RSS MEMORY      TIME  CPU" > latency_data/prstat_oracle.txt


n=0
while [ "$n" -lt $LOOP_TIMES ]
do
  n=`expr $n + 1`
  
  date_text=`date '+%Y/%m/%d.%H:%M:%S'`
  round_time_str="round $n $date_text"
  echo $round_time_str 
  echo $round_time_str  >> latency_data/round-time.txt

  #overall stats
  sar 1 1 |tail -1 >> latency_data/sar_$HOSTNAME.txt
  swap -s >> latency_data/swap.txt
  #iostat
  #The first round of iostat is always fixed values, so we get the output of second round.
  iostat_output_2round=`iostat -xns 1 2`
  IOSTAT_LINE_NUM_2round=`echo "$iostat_output_2round" | wc -l | awk '{print $1}'`
  IOSTAT_LINE_NUM=`expr $IOSTAT_LINE_NUM_2round / 2`
  iostat_output=`echo "$iostat_output_2round" | tail -$IOSTAT_LINE_NUM`
  #iostat_output=`iostat -xns -Td 1 2 | tail -$IOSTAT_LINE_NUM` 
  if [ "$GREP_IO_DISK" -eq 1 ]; then
    iostat_output_grep=`echo "$iostat_output" | grep $IO_DISK_STRING`
    echo "$date_text $iostat_output_grep" >> latency_data/iostat.txt
  else
    echo -e "\n--> round $n $date_text" >> latency_data/iostat.txt
    echo "$iostat_output" >> latency_data/iostat.txt
  fi


  #oracle stats
  prstat_output=`prstat -t -u $PRSTAT_GREP_USER 1 1 | grep $PRSTAT_GREP_USER` 
  echo "$date_text $prstat_output" >> latency_data/prstat_oracle.txt
                 
        echo "sleep $STATS_INTERVAL"
        sleep $STATS_INTERVAL
done


echo "memory watch done"