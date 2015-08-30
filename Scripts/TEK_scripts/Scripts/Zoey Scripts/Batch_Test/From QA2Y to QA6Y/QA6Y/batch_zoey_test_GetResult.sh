echo "Batch Zoey test starts for getting result...">/home/minacom/jxie/result.txt
for ((i=1;i<=1440;i++))
do 
echo "#######Occurrrence $i########" >> /home/minacom/jxie/result.txt 
date        >>  /home/minacom/jxie/result.txt

sleep 2m
voxget -c zoey >> /home/minacom/jxie/result.txt
voxget -c zoey --ack
;sleep 2s
done

echo "Batch Zoey test ends!!!">>/home/minacom/jxie/result.txt
