#!/bin/bash
# Note: each round take 3 seconds to write the stats, so the actual stat interval is STATS_INTERVAL + 3s.


######################################################################
# main starts
#######################################################################

echo "main starts"
 
ISA_INSTANCE_PID="20968"
declare -a DECODER_PIDs=('13338' '13376' '13415' '13444');
NUM_DECODERS=${#DECODER_PIDs[@]}

#In seconds
STATS_INTERVAL=10


rm -rf latency_data
mkdir latency_data

date  >  latency_data/sar.txt
date  >  latency_data/prstat_all.txt

date  >  latency_data/geoAdapter_total.txt
echo " NPROC USERNAME  SWAP   RSS MEMORY      TIME  CPU" >>  latency_data/geoAdapter_total.txt

date  >  latency_data/geoAdapter_all.txt

date  >  latency_data/isaInstance.txt
echo "   PID USERNAME  SIZE   RSS STATE  PRI NICE      TIME  CPU PROCESS/NLWP" >>  latency_data/isaInstance.txt

date  >  latency_data/isaDecoder1.txt
echo "   PID USERNAME  SIZE   RSS STATE  PRI NICE      TIME  CPU PROCESS/NLWP" >>  latency_data/isaDecoder1.txt
date  >  latency_data/isaDecoder2.txt
echo "   PID USERNAME  SIZE   RSS STATE  PRI NICE      TIME  CPU PROCESS/NLWP" >>  latency_data/isaDecoder2.txt
date  >  latency_data/isaDecoder3.txt
echo "   PID USERNAME  SIZE   RSS STATE  PRI NICE      TIME  CPU PROCESS/NLWP" >>  latency_data/isaDecoder3.txt
date  >  latency_data/isaDecoder4.txt
echo "   PID USERNAME  SIZE   RSS STATE  PRI NICE      TIME  CPU PROCESS/NLWP" >>  latency_data/isaDecoder4.txt

date  > latency_data/jstat_isaInstance.txt 
echo "  S0     S1     E      O      P     YGC     YGCT    FGC    FGCT     GCT    LGCC                 GCC "  >> latency_data/jstat_isaInstance.txt
date  > latency_data/jstat_isaDecoder1.txt
echo "  S0     S1     E      O      P     YGC     YGCT    FGC    FGCT     GCT    LGCC                 GCC "  >> latency_data/jstat_isaDecoder1.txt
date  > latency_data/jstat_isaDecoder2.txt 
echo "  S0     S1     E      O      P     YGC     YGCT    FGC    FGCT     GCT    LGCC                 GCC "  >> latency_data/jstat_isaDecoder2.txt
date  > latency_data/jstat_isaDecoder3.txt 
echo "  S0     S1     E      O      P     YGC     YGCT    FGC    FGCT     GCT    LGCC                 GCC "  >> latency_data/jstat_isaDecoder3.txt
date  > latency_data/jstat_isaDecoder4.txt 
echo "  S0     S1     E      O      P     YGC     YGCT    FGC    FGCT     GCT    LGCC                 GCC "  >> latency_data/jstat_isaDecoder4.txt

#irStatAll in the beginning
echo "irStatAll before test:" > latency_data/irStatAll.txt
date >> latency_data/irStatAll.txt
su - iris /opt/irisGroovyExpect/monStatus.sh -p appFamily:IRIS >> latency_data/irStatAll.txt

n=0
while [ "$n" -lt 100000 ]
do
	n=`expr $n + 1`

  #overall stats
  echo "--> round $n `date`" >> latency_data/sar.txt
  sar 1 1 >> latency_data/sar.txt
  echo "--> round $n `date`" >> latency_data/prstat_all.txt
  prstat -a -s rss 1 1  >> latency_data/prstat_all.txt
  
  
  #geo adapter stats
  prstat -t -u geo 1 1 | grep geo >> latency_data/geoAdapter_total.txt
  echo "--> round $n `date`" >> latency_data/geoAdapter_all.txt
  prstat -a -u geo -s rss 1 1  >> latency_data/geoAdapter_all.txt
  
  #ISA Instance stats
  prstat -p $ISA_INSTANCE_PID 1 1 | grep $ISA_INSTANCE_PID >> latency_data/isaInstance.txt
  # If process is down, print a line with DOWN.
  if [ `prstat -p $ISA_INSTANCE_PID 1 1 | grep $ISA_INSTANCE_PID | wc -l` -eq 0 ]; then
    echo "   DOWN DOWN  DOWN   DOWN DOWN  DOWN DOWN      DOWN  DOWN DOWN" >> latency_data/isaInstance.txt
  fi 
  /usr/iris-java/bin/jstat -gccause $ISA_INSTANCE_PID 1s 1 | grep "No GC" >> latency_data/jstat_isaInstance.txt
   
  #ISA decoder stats
  for i in 1 2 3 4; do
  decoder_pid=${DECODER_PIDs[`expr $i-1`]}
  prstat -p $decoder_pid 1 1 | grep $decoder_pid >> latency_data/isaDecoder$i.txt
  # If process is down, print a line with DOWN.
  if [ `prstat -p $decoder_pid 1 1 | grep $decoder_pid | wc -l` -eq 0 ]; then
    echo "   DOWN DOWN  DOWN   DOWN DOWN  DOWN DOWN      DOWN  DOWN DOWN" >> latency_data/isaDecoder$i.txt
  fi 
  /usr/iris-java/bin/jstat -gccause $decoder_pid 1s 1 | grep "No GC" >> latency_data/jstat_isaDecoder$i.txt  
  done;
                 
	echo sleep $STATS_INTERVAL
	sleep $STATS_INTERVAL
done


#irStatAll in the end
echo "irStatAll after test:" >> latency_data/irStatAll.txt
date >> latency_data/irStatAll.txt
su - iris /opt/irisGroovyExpect/monStatus.sh -p appFamily:IRIS >> latency_data/irStatAll.txt

echo "memory watch done"

