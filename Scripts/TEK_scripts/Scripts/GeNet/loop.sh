#Define parameters:
#Note: bitrate=0 means not specify a bitrate.
#      max_round means loop rounds, each round will run all cap files
bitrate_=5000
max_round_=2
interface_=mgmt0

echo > loop.log
for ((round=1;round<=$max_round_;round++))
do
echo "Round $round starts..." >> loop.log
echo `ls *.pcap *.cap */*.pcap */*.cap` >> loop.log

for i in `ls *.pcap *.cap */*.pcap */*.cap`
do
echo $i >> loop.log
if [ $bitrate_ -eq 0 ]; then
echo "GeNet --interface $interface_ --plugin Ethernet --capture-replay $i" >> loop.log
GeNet --interface $interface_ --plugin Ethernet --capture-replay $i >> loop.log
else
echo "GeNet --interface $interface_ --plugin Ethernet --capture-replay $i --bitrate $bitrate_" >> loop.log
GeNet --interface $interface_ --plugin Ethernet --capture-replay $i --bitrate $bitrate_ >> loop.log
fi
done
echo "Round $round Done!" >> loop.log
echo "++++++++++++++++++" >> loop.log

done
echo "All rounds Done!" >> loop.log