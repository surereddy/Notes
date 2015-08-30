for ((i=205;i<=264;i++))
do 
echo "    <SIP_ENDPOINT no=\"$i\">  " >> test.txt
echo "       <TEST type=\"RING_DETECTION_SIP\"   />   " >> test.txt
echo "       <TEST type=\"ANSWER_DETECTION_SIP\"    />   " >> test.txt
echo "       <TEST type=\"SPEECH_DTMF_SIP\"       />     " >> test.txt
echo "       <TEST type=\"SPEECH_DTMF_LB_SIP\"       />  " >> test.txt
echo "       <TEST type=\"COT_LB_SIP\"    />             " >> test.txt
echo "    </SIP_ENDPOINT>                              " >> test.txt
done
