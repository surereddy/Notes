echo "Batch Zoey test starts...">/home/minacom/jxie/result.txt
for ((i=1;i<=1440;i++))
do 
echo "#######Occurrrence $i########" >> /home/minacom/jxie/result.txt 
voxstart -p13 -c zoey_2 -b 3001095
voxstart -p14 -c zoey_2 -b 3001096
voxstart -p15 -c zoey_2 -b 3001097
voxstart -p16 -c zoey_2 -b 3001098
voxstart -p17 -c zoey_2 -b 3001099
voxstart -p18 -c zoey_2 -b 3001100
voxstart -p19 -c zoey_2 -b 3001101
voxstart -p20 -c zoey_2 -b 3001102
voxstart -p21 -c zoey_2 -b 3001103
voxstart -p22 -c zoey_2 -b 3001104
voxstart -p23 -c zoey_2 -b 3001105
voxstart -p24 -c zoey_2 -b 3001106
voxstart -p25 -c zoey_2 -b 3001107
voxstart -p26 -c zoey_2 -b 3001108
voxstart -p27 -c zoey_2 -b 3001109

sleep 2m
voxget -c zoey >> /home/minacom/jxie/result.txt
voxget -c zoey --ack
sleep 2s
done

echo "Batch Zoey test ends!!!">>/home/minacom/jxie/result.txt
