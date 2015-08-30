#!/bin/bash
# Note: each round take N seconds to write the stats, so the actual stat interval is about STATS_INTERVAL + Ns.


######################################################################
# main starts
#######################################################################

echo "main starts"
 
ISA_INSTANCE_PID=`/opt/irisGroovyExpect/monStatus.sh -p appName:isaInstances | awk '/pid/{print $2}' ` 
echo "ISA_INSTANCE_PID: $ISA_INSTANCE_PID"


#In seconds
STATS_INTERVAL=5


rm -rf latency_data/*
mkdir -p latency_data

echo > latency_data/round-time.txt
date  >  latency_data/sar.txt
echo "00:00:00    %usr    %sys    %wio   %idle" >>  latency_data/sar.txt

date  >  latency_data/mpstat.txt

date  >  latency_data/prstat_all.txt

date  >  latency_data/geoAdapter_total.txt
echo " NPROC USERNAME  SWAP   RSS MEMORY      TIME  CPU" >>  latency_data/geoAdapter_total.txt

date  >  latency_data/geoAdapter_all.txt

date  > latency_data/isaInstance.txt
echo "   PID USERNAME  SIZE   RSS STATE  PRI NICE      TIME  CPU PROCESS/NLWP" >>  latency_data/isaInstance.txt

date  >  latency_data/jmap_heap_isaInstance.txt
echo "Eden,From,To,Old,Perm,Total_Used" > latency_data/jmap_heap_stats_isaInstance.csv

date  > latency_data/jstat_isaInstance.txt 
echo "Timestamp         S0     S1     E      O      P     YGC     YGCT    FGC    FGCT     GCT    LGCC                 GCC"  >> latency_data/jstat_isaInstance.txt



#irStatAll in the beginning
echo "irStatAll before test:" > latency_data/irStatAll.txt
date >> latency_data/irStatAll.txt
su - iris /opt/irisGroovyExpect/monStatus.sh -p appFamily:IRIS >> latency_data/irStatAll.txt

n=0
while [ "$n" -lt 100000 ]
do
        n=`expr $n + 1`
        round_time_str="round $n - `date`"
  echo $round_time_str 
  echo $round_time_str  >> latency_data/round-time.txt

  #overall stats
  #echo "--> round $n `date`" >> latency_data/sar.txt
  sar 1 1 |tail -1 >> latency_data/sar.txt
  echo "--> round $n `date`" >> latency_data/prstat_all.txt
  prstat -a -s rss 1 1  >> latency_data/prstat_all.txt
  echo "--> round $n `date`" >> latency_data/mpstat.txt
  mpstat   >> latency_data/mpstat.txt

  
  #geo adapter stats
  prstat -t -u geo 1 1 | grep geo >> latency_data/geoAdapter_total.txt
  echo "--> round $n `date`" >> latency_data/geoAdapter_all.txt
  prstat -a -u geo -s rss 1 1  >> latency_data/geoAdapter_all.txt
  
  #ISA Instance stats
  prstat -p $ISA_INSTANCE_PID 1 1 | grep $ISA_INSTANCE_PID | grep iris >> latency_data/isaInstance.txt
  # If process is down, print a line with DOWN.
  if [ `prstat -p $ISA_INSTANCE_PID 1 1 | grep $ISA_INSTANCE_PID | grep iris | wc -l` -eq 0 ]; then
    echo "   DOWN DOWN  DOWN   DOWN DOWN  DOWN DOWN      DOWN  DOWN DOWN" >> latency_data/isaInstance.txt
  fi 
  /usr/iris-java/bin/jstat -gccause -t $ISA_INSTANCE_PID 1s 1 | tail -1 >> latency_data/jstat_isaInstance.txt
  echo "--> round $n `date`" >> latency_data/jmap_heap_isaInstance.txt
  /usr/iris-java/bin/jmap -d64  -heap $ISA_INSTANCE_PID > latency_data/temp.txt
  cat latency_data/temp.txt >> latency_data/jmap_heap_isaInstance.txt
  #get Eden, From, To, Old Gen, Perm used memory.
  cat latency_data/temp.txt | awk '/Configuration/{ed=0;fr=0;to=0;pso=0;psp=0} {if (NR == 21) {ed= $3} if(NR==26){fr= $3} if(NR==31){to= $3} if(NR==36){pso= $3} {OFS=","} if(NR==41){psp= $3; ttt=ed+fr+to+pso+psp; print ed,fr,to,pso,psp,ttt} }'  >> latency_data/jmap_heap_stats_isaInstance.csv


        echo "sleep $STATS_INTERVAL"
        sleep $STATS_INTERVAL
done


#irStatAll in the end
echo "irStatAll after test:" >> latency_data/irStatAll.txt
date >> latency_data/irStatAll.txt
su - iris /opt/irisGroovyExpect/monStatus.sh -p appFamily:IRIS >> latency_data/irStatAll.txt

echo "memory watch done"