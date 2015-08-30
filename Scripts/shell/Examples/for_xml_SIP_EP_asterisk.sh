rm -f test.txt
for ((i=33;i<=64;i++))
do 
echo "[CDC_3_EP$i]" >> test.txt
echo "type=friend" >> test.txt
echo "context=from-internal" >> test.txt
echo "host=dynamic" >> test.txt
echo "username=CDC_3_EP$i" >> test.txt
echo "secret=cdc_3" >> test.txt
echo "" >> test.txt
done

;[CDC_3_EP1]
;type=friend
;context=from-internal
;host=dynamic
;username=CDC_3_EP1
;secret=cdc_3


rm -f test.txt
for ((i=33;i<=64;i++))
do 
echo "exten => CDC_3_EP$i,1,Dial(SIP/CDC_3_EP$i@10.10.5.63,20)" >> test.txt
done
;exten => CDC_3_EP32,1,Dial(SIP/CDC_3_EP32@10.10.5.63,20)


#############
QA11Y
############
rm -f test.txt
for ((i=33;i<=64;i++))
do 
echo "[30111$i]" >> test.txt
echo "type=friend" >> test.txt
echo "context=from-internal" >> test.txt
echo "host=dynamic" >> test.txt
echo "username=30111$i" >> test.txt
echo "secret=QA11" >> test.txt
echo "" >> test.txt
done

[3011132]
type=friend
context=from-internal
host=dynamic
username=3011132
secret=QA11


rm -f test.txt
for ((i=33;i<=64;i++))
do 
echo "exten => 30111$i,1,Dial(SIP/30111$i@10.10.9.111,20)" >> test.txt
done
;exten => 3011132,1,Dial(SIP/3011132@10.10.9.111,20)


#############
QA12Y
############
rm -f test.txt
for ((i=33;i<=64;i++))
do 
echo "[30112$i]" >> test.txt
echo "type=friend" >> test.txt
echo "context=from-internal" >> test.txt
echo "host=dynamic" >> test.txt
echo "username=30112$i" >> test.txt
echo "secret=QA12" >> test.txt
echo "" >> test.txt
done

[3011232]
type=friend
context=from-internal
host=dynamic
username=3011232
secret=QA12


rm -f test.txt
for ((i=33;i<=64;i++))
do 
echo "exten => 30112$i,1,Dial(SIP/30112$i@10.10.8.200,20)" >> test.txt
done
;exten => 3011232,1,Dial(SIP/3011232@10.10.8.200,20)