for ((i=5;i<=64;i++))
do 
echo "    <MGCP_ENDPOINT no=\"$i\" name=\"aaln/$i\">   " >> test.txt
echo "      <TEST type=\"RING_DETECTION_MG\"      /> " >> test.txt
echo "      <TEST type=\"ANSWER_DETECTION_MG\"    /> " >> test.txt
echo "      <TEST type=\"SPEECH_DTMF_MGCP\"       /> " >> test.txt
echo "      <TEST type=\"SPEECH_DTMF_LB_MGCP\"    /> " >> test.txt
echo "      <TEST type=\"COT_LB_MGCP\"    />         " >> test.txt
echo "    </MGCP_ENDPOINT>                           " >> test.txt
done
