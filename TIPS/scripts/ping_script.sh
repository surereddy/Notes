#Use in bash of linux/UNIX/cygwin
#Usage: bash ping_script.sh 
#Author: XIE Jiping
#!/usr/bin/env bash
for ((i=254;i<255;i++)); do ping 6.172.201.$i; done|tee ping_detail.txt|grep TTL|tee ping_ok.txt


#if [ $(wc -l ping_ok.txt) -eq 0 ] ;NOK
#then
#echo "IP not Found!"
#else
#echo "IP Found:"
#cat ping_ok.txt
#fi