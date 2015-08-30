#!/bin/bash
# Note: each round take some seconds (suppose N) to write the stats, so the actual stat interval is STATS_INTERVAL + Ns.
# Last Update: Jan 23, 2014

######################################################################
# main starts
#######################################################################

#Paramters:
#----------------
#In seconds
STATS_INTERVAL=9
LOOP_TIMES=999999


echo "main starts"
 

NAME_SERVER_PID=`/opt/irisGroovyExpect/monStatus.sh -p appName:nameServiceZk | awk '/pid/{print $2}' ` 
echo "NAME_SERVER_PID: $NAME_SERVER_PID"


date_text=`date '+%Y/%m/%d.%H:%M:%S'`
HOSTNAME=`hostname`


#Defaults                                     
remove_latency_data="y"
                                                                         
echo "Do you want to remove existing latency_data/* files before test? (y or n) Default=${remove_latency_data}:"
read INPUT_STRING                              
                                              
if [ "$INPUT_STRING" != "" ]; then                  
	remove_latency_data=$INPUT_STRING                          
fi                                            
                                              
echo "remove_latency_data = ${remove_latency_data}"


if [ ${remove_latency_data} == "y" ]; then
echo "Excuting command: rm -rf latency_data/*"
rm -rf latency_data/*

elif [ ${remove_latency_data} == "Y" ]; then
echo "Excuting command: rm -rf latency_data/*"
rm -rf latency_data/*
fi

mkdir -p latency_data


#ZK
echo "$date_text    PID USERNAME  SIZE   RSS STATE  PRI NICE      TIME  CPU PROCESS/NLWP" > latency_data/prstat_ns.txt

n=0
while [ "$n" -lt $LOOP_TIMES ]
do
  n=`expr $n + 1`
  
  date_text=`date '+%Y/%m/%d.%H:%M:%S'`
  round_time_str="round $n $date_text"
  echo $round_time_str 
  

  #ZK Name Server
  prstat_output=`prstat -p $NAME_SERVER_PID 1 1 | grep $NAME_SERVER_PID | grep iris `
  echo "$date_text $prstat_output" >> latency_data/prstat_ns.txt
  # If process is down, print a line with DOWN.
  if [ `echo  $prstat_output| wc -l` -eq 0 ]; then
    echo "   DOWN DOWN  DOWN   DOWN DOWN  DOWN DOWN      DOWN  DOWN DOWN" >> latency_data/prstat_ns.txt    
  fi 

        echo "sleep ${STATS_INTERVAL}s"
        sleep $STATS_INTERVAL
done


echo "memory watch done"
