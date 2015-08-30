#!/bin/bash

cd `dirname "$0"`

pid=`/opt/irisGroovyExpect/monStatus.sh |awk '/isaInstances/{n=0;m=1} {n++} n==3&&m==1 {m=0; print $NF}'`
echo "isainstance pid: $pid"
if [ -z $pid ]; then
    echo "no isainstance pid found, exit now"
    return
fi

filenamelive=./mapData/histo.live
filenameheapResult=./mapData/heapResult
totalNum=20

rm -rf mapData
mkdir mapData 

#jmap -d64 -histo:live $pid >> $filenamelive.$pid
index=0
while true
do
    index=`expr $index + 1`
    if [ $index -ge $totalNum ];then
         
        break
    fi

    jmap -d64 -histo:live $pid >> $filenamelive.$index.$pid
    date -u
    echo "-----------------jmap index: $index"
    jmap -d64 -heap $pid > $filenameheapResult.$index.$pid 
    sleep 10 
done



#./jmapanalysis.sh $pid $index

echo "edenused fromused toused oldused permused memorysummary" 
for (( i = 1; i<$index; i++))
do
      FileName=$filenameheapResult.$i.$pid
      cat $FileName| awk '/Configuration/{ed=0;fr=0;to=0;pso=0;psp=0} {if (NR == 21) {ed= $3} if(NR==26){fr= $3} if(NR==31){to= $3} if(NR==36){pso= $3} if(NR==41){psp= $3; ttt=ed+fr+to+pso+psp; print ed,fr,to,pso,psp,ttt} }' >> a.txt
   
done


