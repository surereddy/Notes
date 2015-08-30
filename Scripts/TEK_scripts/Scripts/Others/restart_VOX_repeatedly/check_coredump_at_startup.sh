for ((i=1;i<=10;i++))
do 
echo "#######Occurrrence $i########" >> /home/minacom/jxie/result.txt 
voxd
sleep 3m
echo "-------Occ $i voxinfo after startup--------" >> /home/minacom/jxie/result.txt 
voxinfo >> /home/minacom/jxie/result.txt 
echo "-------Occ $i core--------" >> /home/minacom/jxie/result.txt 
ls core.* >> /home/minacom/jxie/result.txt
voxstop --voxd
sleep 30s
echo "-------Occ $i voxinfo after stop--------" >> /home/minacom/jxie/result.txt 
voxinfo >> /home/minacom/jxie/result.txt 
done