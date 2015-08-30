rm -f test.txt
for ((i=1;i<=64;i++))
do 
echo "    <MGCP_ENDPOINT no=\"$i\" name=\"aaln/$i\">   " >> test.txt
echo "      <TEST type=\"RING_DETECTION_MG\"      /> " >> test.txt
echo "      <TEST type=\"ANSWER_DETECTION_MG\"    /> " >> test.txt
echo "      <TEST type=\"SPEECH_DTMF_MGCP\"       /> " >> test.txt
echo "      <TEST type=\"SPEECH_DTMF_LB_MGCP\"    /> " >> test.txt
echo "      <TEST type=\"COT_LB_MGCP\"    />         " >> test.txt
echo "    </MGCP_ENDPOINT>                           " >> test.txt
done

rm -f test.txt
for ((i=33;i<=64;i++))
do 
echo "    <MGCP_ENDPOINT no=\"1$i\" name=\"aaln/$i\">   " >> test.txt
echo "      <TEST type=\"RING_DETECTION_MG\"      /> " >> test.txt
echo "      <TEST type=\"ANSWER_DETECTION_MG\"    /> " >> test.txt
echo "      <TEST type=\"SPEECH_DTMF_MGCP\"       /> " >> test.txt
echo "      <TEST type=\"SPEECH_DTMF_LB_MGCP\"    /> " >> test.txt
echo "      <TEST type=\"COT_LB_MGCP\"    />         " >> test.txt
echo "    </MGCP_ENDPOINT>                           " >> test.txt
done

;		<MGCP_ENDPOINT no="132" name="aaln/32">
;            <TEST type="RING_DETECTION_MG"      />
;            <TEST type="ANSWER_DETECTION_MG"    />
;            <TEST type="SPEECH_DTMF_MGCP"       />
;            <TEST type="SPEECH_DTMF_LB_MGCP"    />
;            <TEST type="COT_LB_MGCP"    />
;		</MGCP_ENDPOINT>


rm -f test.txt
for ((i=201;i<=264;i++))
do
echo "    <SIP_ENDPOINT no=\"$i\" responder=\"true\">                   " >> test.txt
echo "        <TEST type=\"RING_DETECTION_SIP\" responder=\"true\"/>    " >> test.txt
echo "         <TEST type=\"ANSWER_DETECTION_SIP\" responder=\"true\"/> " >> test.txt
echo "         <TEST type=\"SPEECH_DTMF_SIP\" responder=\"true\"/>      " >> test.txt
echo "         <TEST type=\"SPEECH_DTMF_LB_SIP\" responder=\"true\"/>   " >> test.txt
echo "         <TEST type=\"BIVQ_SIP\"  responder=\"true\"/>            " >> test.txt
echo "         <TEST type=\"COT_LB_SIP\"/>                              " >> test.txt
echo "    </SIP_ENDPOINT>		                                            " >> test.txt
done

;		<SIP_ENDPOINT no="34" responder="true">
;		    <TEST type="RING_DETECTION_SIP" responder="true"     />
;	      <TEST type="ANSWER_DETECTION_SIP" responder="true"    />
;	      <TEST type="SPEECH_DTMF_SIP" responder="true"      />
;	      <TEST type="SPEECH_DTMF_LB_SIP" responder="true"      />
;       <TEST type="BIVQ_SIP"  responder="true"     />
;       <TEST type="COT_LB_SIP" />
;		</SIP_ENDPOINT>			