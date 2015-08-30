Usage:
1. su - root
2. ./batch_zoey_test.pl &
3. Check /home/minacom/jxie/result.txt for the outputs
4. 'ps -ef|grep batch_zoey_test.pl' to check the status of the batch script

Note:
You must root to run the command in background, otherwise it will be stopped when you quit the putty even you use '&'.


for ((i=28;i<=42;i++))
do 
vox_configure --run_TRU $i=zoey
done

for ((i=28;i<=42;i++))
do 
vox_configure --run_TRU $i
done

for ((i=18;i<=28;i++))
do 
vox_configure --clear_TRU $i
done