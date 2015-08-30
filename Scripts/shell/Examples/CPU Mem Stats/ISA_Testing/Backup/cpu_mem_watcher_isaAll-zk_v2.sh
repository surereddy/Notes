#!/bin/bash
# Note: each round take some seconds (suppose N) to write the stats, so the actual stat interval is STATS_INTERVAL + Ns.
# Last Update: Jan 20, 2014

######################################################################
# main starts
#######################################################################

#Paramters:
#----------------
#In seconds
STATS_INTERVAL=7
LOOP_TIMES=999999
#grep string for monitored disk. 
#check by "iostat -xn" and "df -h".
IO_DISK_STRING="c0t0d0"

echo "main starts"
 
ISA_INSTANCE_PID=`/opt/irisGroovyExpect/monStatus.sh -p appName:isaInstances | awk '/pid/{print $2}' ` 
echo "ISA_INSTANCE_PID: $ISA_INSTANCE_PID"

ISA_MASTER_PID=`/opt/irisGroovyExpect/monStatus.sh -p appName:isaMasters | awk '/pid/{print $2}' ` 
echo "ISA_MASTER_PID: $ISA_MASTER_PID"

IRIS_PROXY_PID=`/opt/irisGroovyExpect/monStatus.sh -p appName:irisProxy | awk '/pid/{print $2}' ` 
echo "IRIS_PROXY_PID: $IRIS_PROXY_PID"


NAME_SERVER_PID=`/opt/irisGroovyExpect/monStatus.sh -p appName:nameServiceZk | awk '/pid/{print $2}' ` 
echo "NAME_SERVER_PID: $NAME_SERVER_PID"

PROPERTY_SERVER_PID=`/opt/irisGroovyExpect/monStatus.sh -p appName:irisPropertyServiceZk | awk '/pid/{print $2}' ` 
echo "PROPERTY_SERVER_PID: $PROPERTY_SERVER_PID"

rm -rf latency_data/*
mkdir -p latency_data

date_text=`date '+%Y/%m/%d.%H:%M:%S'`
HOSTNAME=`hostname`

#overall stat files
touch latency_data/round-time.txt
echo "00:00:00    %usr    %sys    %wio   %idle" >  latency_data/sar_$HOSTNAME.txt
#touch latency_data/prstat_all.txt
#echo "$date_text     r/s    w/s   kr/s   kw/s wait actv wsvc_t asvc_t  %w  %b device" > latency_data/iostat.txt


#ISA instance
echo "$date_text    PID USERNAME  SIZE   RSS STATE  PRI NICE      TIME  CPU PROCESS/NLWP" > latency_data/prstat_isa.txt
echo "$date_text   S0     S1     E      O      P     YGC     YGCT    FGC    FGCT     GCT    LGCC                 GCC"  > latency_data/jstat_isa.txt
#touch  latency_data/jmap_heap_details_isa.txt
#echo "Timestamp,Eden,From,To,Old,Perm,Total_Used" > latency_data/jmap_heap_isa.csv

#ISA Master and IRIS Proxy
echo "$date_text    PID USERNAME  SIZE   RSS STATE  PRI NICE      TIME  CPU PROCESS/NLWP" > latency_data/prstat_isamaster.txt
echo "$date_text    PID USERNAME  SIZE   RSS STATE  PRI NICE      TIME  CPU PROCESS/NLWP" > latency_data/prstat_irisproxy.txt

#ZK
echo "$date_text    PID USERNAME  SIZE   RSS STATE  PRI NICE      TIME  CPU PROCESS/NLWP" > latency_data/prstat_ns.txt
echo "$date_text    PID USERNAME  SIZE   RSS STATE  PRI NICE      TIME  CPU PROCESS/NLWP" > latency_data/prstat_ps.txt

#irStatAll in the beginning
echo "irStatAll before test:" > latency_data/irStatAll.txt
date >> latency_data/irStatAll.txt
/opt/irisGroovyExpect/monStatus.sh -p appFamily:IRIS >> latency_data/irStatAll.txt
#su - iris /opt/irisGroovyExpect/monStatus.sh -p appFamily:IRIS >> latency_data/irStatAll.txt

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
  echo -e "\n--> round $n $date_text" >> latency_data/prstat_all.txt
  prstat -a -s rss 1 1  >> latency_data/prstat_all.txt

#  #iostat
#  iostat_output=`iostat -xns -Td 1 1 |grep $IO_DISK_STRING`
#  echo "$date_text $iostat_output" >> latency_data/iostat.txt

  #ISA instance
  prstat_output=`prstat -p $ISA_INSTANCE_PID 1 1 | grep $ISA_INSTANCE_PID | grep iris `
  echo "$date_text $prstat_output" >> latency_data/prstat_isa.txt
  # If process is down, print a line with DOWN.
  if [ `echo  $prstat_output| wc -l` -eq 0 ]; then
    echo "   DOWN DOWN  DOWN   DOWN DOWN  DOWN DOWN      DOWN  DOWN DOWN" >> latency_data/prstat_isa.txt    
  fi 
  jstat_output=`/usr/iris-java/bin/jstat -gccause $ISA_INSTANCE_PID 1s 1 | tail -1`
  echo "$date_text $jstat_output" >> latency_data/jstat_isa.txt
#  echo -e "\n--> round $n $date_text" >> latency_data/jmap_heap_details_isa.txt
#  jmap_output=`/usr/iris-java/bin/jmap -d64  -heap $ISA_INSTANCE_PID `
#  echo "$jmap_output" >> latency_data/jmap_heap_details_isa.txt
#  #get Eden, From, To, Old Gen, Perm used memory.
#  jmap_text=`echo "$jmap_output" | awk '/Configuration/{ed=0;fr=0;to=0;pso=0;psp=0} {if (NR == 21) {ed= $3} if(NR==26){fr= $3} if(NR==31){to= $3} if(NR==36){pso= $3} {OFS=","} if(NR==41){psp= $3; total_used=ed+fr+to+pso+psp; printf "%d,%d,%d,%d,%d,%d\n", ed/1024/1024,fr/1024/1024,to/1024/1024,pso/1024/1024,psp/1024/1024,total_used/1024/1024} }'` 
#  echo "$date_text,$jmap_text">> latency_data/jmap_heap_isa.csv  

  #ISA Master and IRIS Proxy
  prstat_output=`prstat -p $ISA_MASTER_PID 1 1 | grep $ISA_MASTER_PID | grep iris `
  echo "$date_text $prstat_output" >> latency_data/prstat_isamaster.txt
  # If process is down, print a line with DOWN.
  if [ `echo  $prstat_output| wc -l` -eq 0 ]; then
    echo "   DOWN DOWN  DOWN   DOWN DOWN  DOWN DOWN      DOWN  DOWN DOWN" >> latency_data/prstat_isamaster.txt    
  fi 
  
  prstat_output=`prstat -p $IRIS_PROXY_PID 1 1 | grep $IRIS_PROXY_PID | grep iris `
  echo "$date_text $prstat_output" >> latency_data/prstat_irisproxy.txt
  # If process is down, print a line with DOWN.
  if [ `echo  $prstat_output| wc -l` -eq 0 ]; then
    echo "   DOWN DOWN  DOWN   DOWN DOWN  DOWN DOWN      DOWN  DOWN DOWN" >> latency_data/prstat_irisproxy.txt    
  fi 
  

  #ZK
  prstat_output=`prstat -p $NAME_SERVER_PID 1 1 | grep $NAME_SERVER_PID | grep iris `
  echo "$date_text $prstat_output" >> latency_data/prstat_ns.txt
  # If process is down, print a line with DOWN.
  if [ `echo  $prstat_output| wc -l` -eq 0 ]; then
    echo "   DOWN DOWN  DOWN   DOWN DOWN  DOWN DOWN      DOWN  DOWN DOWN" >> latency_data/prstat_ns.txt    
  fi 
  prstat_output=`prstat -p $PROPERTY_SERVER_PID 1 1 | grep $PROPERTY_SERVER_PID | grep iris `
  echo "$date_text $prstat_output" >> latency_data/prstat_ps.txt
  # If process is down, print a line with DOWN.
  if [ `echo  $prstat_output| wc -l` -eq 0 ]; then
    echo "   DOWN DOWN  DOWN   DOWN DOWN  DOWN DOWN      DOWN  DOWN DOWN" >> latency_data/prstat_ps.txt    
  fi 
                 
        echo "sleep ${STATS_INTERVAL}s"
        sleep $STATS_INTERVAL
done


echo "memory watch done"
