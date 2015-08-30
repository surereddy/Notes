# Usage:
# Summarize zone 1 2 3.
# ./a.sh <data file name>

dataFileName=$1;
newDataFileName=newDataFile.txt;
maxCount=0;
for arg_zoneID in 1 2 3
do
var_zoneID=$arg_zoneID;
#var_zoneID2=$2;
#var_zoneID=1;

# replace Zone-x with Zone x
sed -e "s/zone : Zone-/zone : Zone /" $dataFileName > $newDataFileName;

# $11 zone id
# $27 count number
# $24 F value

#calculate the max count.
maxCount=`grep 'created time' $newDataFileName |awk -v zoneID="$var_zoneID" ' BEGIN {maxCount=0;}  { if($11 == zoneID && $27 >= maxCount) maxCount=$27;}   END {print maxCount;}'`;
#echo "maxCount:${maxCount}.";

var_buffer=2;
maxBufferCount=$((maxCount - var_buffer));
#echo "maxBufferCount $maxBufferCount."

for (( i=$maxCount;  i>= $maxBufferCount; i-- ))
# for i in {$maxBufferCount..$maxCount}
do
var_countNum=$i;
#echo "countNum is $i .";

#calculate max f value for a count number

#print f value and count number to a temp file first.
grep 'created time' $newDataFileName |awk -v zoneID="$var_zoneID" -v countNum="$var_countNum"  ' { if($11 == zoneID && $27 == countNum ) print $24,$27;}' > temp.txt;
#cat temp.txt;
awk -v zoneID="$var_zoneID" -v countNum="$var_countNum" 'BEGIN {minFvalue=999;} {if($1 <= minFvalue) minFvalue=$1;} END { if(minFvalue != 999) print "Min F value of zone", zoneID,":", minFvalue, countNum;}' temp.txt;
done;


done;
