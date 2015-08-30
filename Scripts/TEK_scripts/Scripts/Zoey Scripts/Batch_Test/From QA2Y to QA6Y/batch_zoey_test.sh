echo "Batch Zoey test starts...">/home/minacom/jxie/result.txt
for ((i=1;i<=1440;i++))
do 
echo "#######Occurrrence $i########" >> /home/minacom/jxie/result.txt
date        >>  /home/minacom/jxie/result.txt 
voxstart -p5 -c zoey_2 -b  3001080
voxstart -p6 -c zoey_2 -b  3001081
voxstart -p7 -c zoey_2 -b  3001082
voxstart -p8 -c zoey_2 -b  3001083
voxstart -p9 -c zoey_2 -b  3001084
voxstart -p10 -c zoey_2 -b 3001085
voxstart -p11 -c zoey_2 -b 3001086
voxstart -p12 -c zoey_2 -b 3001087
voxstart -p13 -c zoey_2 -b 3001088
voxstart -p14 -c zoey_2 -b 3001089
voxstart -p15 -c zoey_2 -b 3001090
voxstart -p16 -c zoey_2 -b 3001091
voxstart -p17 -c zoey_2 -b 3001092
voxstart -p18 -c zoey_2 -b 3001093
voxstart -p19 -c zoey_2 -b 3001094
voxstart -p20 -c zoey_2 -b 3001095
voxstart -p21 -c zoey_2 -b 3001096
voxstart -p22 -c zoey_2 -b 3001097
voxstart -p23 -c zoey_2 -b 3001098
voxstart -p24 -c zoey_2 -b 3001099
voxstart -p25 -c zoey_2 -b 3001100
voxstart -p26 -c zoey_2 -b 3001101

sleep 2m
done

echo "Batch Zoey test ends!!!">>/home/minacom/jxie/result.txt
