#!/bin/bash

stat_file=$1
start_time=$2
end_time=$3
calc_column=$4

#echo $1 $2 $3;

STAT_COL=7
SPLIT_COL=","
SPLIT_COL_RAW=""

START_TIME_DEF=`echo $2 | wc -w | awk '{print $1}'`
END_TIME_DEF=`echo $3 | wc -w | awk '{print $1}'`

echo "START_TIME_DEF:$START_TIME_DEF"

#cat $stat_file | awk '{if (NR==1) {print}}; if{}'

#not work
#awk_string="'{CPU[NR]=\$10}; END{{print CPU[3]}}'"

#echo $awk_string;
#cat $stat_file | awk $awk_string;

#cat $stat_file | awk '{if (NR>1) {CPU[NR]=$"'$STAT_COL'"}}; {if (NR>1) {print CPU[NR] }}' > raw_data.txt;
#echo "$raw_data"; {FS="[%]"} 
#cat "raw_data.txt";
#cat raw_data.txt | awk '{CPU_NoPer[NR]=$1}; { {print CPU_NoPer[NR] }}';
#{NR==1{max=$1;min=$2;avg=$3;print max,min,avg} {CPU_NoPer[NR]=$1} { if (NR>=1){print CPU_NoPer[NR] }}
#echo "$raw_data" | awk 'BEGIN{FS="%"}  {if(NR==1) {max=$1;min=$1;avg=$1;print max,min,avg}} 
#awk 'BEGIN{FS=","} {if (NR>1) {CPU[NR]=$7}}; {if (NR>=START_LINE && NR<=4) {print CPU[NR] }}'


#FIND start line and end line
START_LINE=2
END_LINE=`wc -l $stat_file | awk '{print $1}'` 
#echo "END_LINE: $END_LINE"
#if [ $START_TIME_DEF -eq 1 ] ; then
##START_LINE=`cat $stat_file | awk '{TIMESTAMP[NR]=$1;if(TIMESTAMP[NR]!="2013/12/24.16:13:44"){print $1}}'`;
#cat $stat_file | awk 'BEGIN{FS=","} {if(NR==2){print $1}}';
#echo "new START LINE: $START_LINE";
#fi


#raw_data=`cat $stat_file | awk 'BEGIN{FS="'$SPLIT_COL'"} {if (NR>1) {CPU[NR]=$"'$STAT_COL'"}}; {if (NR>='$START_LINE') {print CPU[NR] }}'`;
raw_data=`cat $stat_file | awk 'BEGIN{FS="'$SPLIT_COL'"} {if (NR>1) {CPU[NR]=$"'$STAT_COL'"}}; {if (NR>='$START_LINE' && NR<='$END_LINE') {print CPU[NR] }}'`;
if [ `echo "$SPLIT_COL_RAW" | wc -w` -gt 0 ];then
echo "$raw_data" | awk 'BEGIN{FS="'$SPLIT_COL_RAW'"} {if(NR==1) {max=$1;min=$1;sum=0}} {CPU_NoPer[NR]=$1; if (min>CPU_NoPer[NR]){min=CPU_NoPer[NR]};if (max<CPU_NoPer[NR]){max=CPU_NoPer[NR]};sum=sum+CPU_NoPer[NR]} {if(NR==1){ print "First one:", CPU_NoPer[NR]}} END{printf " avg:%0.1f\n max:%0.1f\n min:%0.1f\n sum:%0.1f\n",sum/NR,max,min,sum}';
else 
echo "$raw_data" | awk ' {if(NR==1) {max=$1;min=$1;sum=0}} {CPU_NoPer[NR]=$1; if (min>CPU_NoPer[NR]){min=CPU_NoPer[NR]};if (max<CPU_NoPer[NR]){max=CPU_NoPer[NR]};sum=sum+CPU_NoPer[NR]} {if(NR==1){ print "First one:", CPU_NoPer[NR]}} END{printf " avg:%0.1f\n max:%0.1f\n min:%0.1f\n sum:%0.1f\n",sum/NR,max,min,sum}';
fi