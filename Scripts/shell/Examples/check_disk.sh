echo > afc.txt
echo > log.txt
echo > data.txt
n=0
while [ "$n" -lt 999999 ]
do
  n=`expr $n + 1`
  date_text=`date '+%Y-%m-%d_%H:%M:%S'`
  
echo "$date_text" `df -h |grep afc |grep -v var` >> afc.txt
echo "$date_text" `du -sk /afc/data` >> data.txt
echo "$date_text" `du -sk /afc/log` >> log.txt


sleep 60

done