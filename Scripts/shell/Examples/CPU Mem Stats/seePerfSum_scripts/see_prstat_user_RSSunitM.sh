#!/bin/bash

stat_file=$1
calc_column=$2
start_time=$3
end_time=$4

#echo $1 $2 $3;

CPU_NR=8
#CPU_NR=$2
RSS_COL=5

#cat $stat_file | awk '{if (NR==1) {print}}; if{}'

#not work
#awk_string="'{CPU[NR]=\$10}; END{{print CPU[3]}}'"

#echo $awk_string;
#cat $stat_file | awk $awk_string;

#cat $stat_file | awk '{if (NR>1) {CPU[NR]=$"'$CPU_NR'"}}; {if (NR>1) {print CPU[NR] }}' > raw_data.txt;
#echo "$raw_data"; {FS="[%]"} 
#cat "raw_data.txt";
#cat raw_data.txt | awk '{CPU_NoPer[NR]=$1}; { {print CPU_NoPer[NR] }}';
#{NR==1{max=$1;min=$2;avg=$3;print max,min,avg} {CPU_NoPer[NR]=$1} { if (NR>=1){print CPU_NoPer[NR] }}
#echo "$raw_data" | awk 'BEGIN{FS="%"}  {if(NR==1) {max=$1;min=$1;avg=$1;print max,min,avg}} 

echo "CPU:"
raw_data=`cat $stat_file | awk '{if (NR>1) {CPU[NR]=$"'$CPU_NR'"}}; {if (NR>1) {print CPU[NR] }}'`;
echo "$raw_data" | awk 'BEGIN{FS="%"} {if(NR==1) {max=$1;min=$1;sum=0}} {CPU_NoPer[NR]=$1; if (min>CPU_NoPer[NR]){min=CPU_NoPer[NR]};if (max<CPU_NoPer[NR]){max=CPU_NoPer[NR]};sum=sum+CPU_NoPer[NR]} {if(NR==1){ print "First one:", CPU_NoPer[NR]}} END{printf " max:%0.1f%%\n min:%0.1f%%\n sum:%0.1f%%\n avg:%0.1f%%\n",max,min,sum,sum/NR}';

echo "RSS:"
raw_data=`cat $stat_file | awk '{if (NR>1) {CPU[NR]=$"'$RSS_COL'"}}; {if (NR>1) {print CPU[NR] }}'`;
echo "$raw_data" | awk 'BEGIN{FS="M"} {if(NR==1) {max=$1;min=$1;sum=0}} {CPU_NoPer[NR]=$1; if (min>CPU_NoPer[NR]){min=CPU_NoPer[NR]};if (max<CPU_NoPer[NR]){max=CPU_NoPer[NR]};sum=sum+CPU_NoPer[NR]} {if(NR==1){ print "First one:", CPU_NoPer[NR]}} END{printf " max:%0.1f\n min:%0.1f\n sum:%0.1f\n avg:%0.1f\n",max,min,sum,sum/NR}';