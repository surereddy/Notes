function checkFeedbackForm() {
	if (document.getElementById("submit1").disabled) {
		alert('Please wait, your request is being processed');
		return false;
	}
	document.getElementById("submit1").disabled=true;
	if (!executeCheckForm()) {
		document.getElementById("submit1").disabled=false;
		return false;
	}	
	return true;
}
function executeCheckForm() {
	if ((!document.feedback.r1[0].checked) && (!document.feedback.r1[1].checked) && (!document.feedback.r1[2].checked)) {
		alert('Please tell us if this article helped you.');
		return false;
	}
	if(document.feedback.SRID.value!="") {
		strValue = new String(document.feedback.SRID.value);
		finalValue = "";
		for(i=0; i<strValue.length; i++)
		{
			chrCode = strValue.charCodeAt(i);
			if(chrCode>47 && chrCode<58)
			{
				finalValue = finalValue + strValue.charAt(i);
			}
			else
			{
				alert("Please enter only numeric values for SR ID.");
				document.feedback.SRID.value = finalValue;
				document.feedback.SRID.focus();		
				return false;
			}
		}
	}
	if(document.feedback.SRID.value!="" && parseInt(document.feedback.SRID.value)==0) {
		alert("Please provide a non-zero SR ID");
		document.feedback.SRID.value = "";
		document.feedback.SRID.focus();
		return false;
	}
	document.feedback.action = contextPath + "/common/saveFeedback.jsp";
	sendFeedbackEmail();

}
function checkFieldLength(object, fieldLength) {
	if (object.value.length > fieldLength)
	{ 
		alert("You entered more than "+fieldLength+" characters. Your text will be trimmed to the first "+fieldLength+" characters.");
		object.value = object.value.substring(0, fieldLength); 
		window.status = object.value.length + " characters.";
		object.refresh;
	}
}
function checkFieldContent(object) {
	strValue = new String(object.value);
	finalValue = "";
	for(i=0; i<strValue.length; i++)
	{
		chrCode = strValue.charCodeAt(i);
		if(chrCode>47 && chrCode<58)
		{
			finalValue = finalValue + strValue.charAt(i);
		}
	}

	object.value = finalValue;
}
//<eVergance>
function sendFeedbackEmailComplete(returnVal) {
	
}
var sentemail = false;
function sendFeedbackEmail() {
	//blank user name (first param) signals to not send email to submitter
	if (typeof(author) != 'undefined' && author!=''){
	// <eVergance LSF 10.16.08 Info - Fix for firefox bug>
		 setInterval( function() {
			if (!sentemail)
			{
				//alert(jsTitle);
				CommonUtils.sendFeedbackSubmittedEmails('',author, jsTitle, '', getRdoRateValue(), 'NA', document.feedback.TEXTAREA1.value, extId, sliceId,sendFeedbackEmailComplete);
				sentemail=true;
			}
		   }
			, 10 );
	// </eVergance>
	}
	//document.feedback.submit();
	if (window.XMLHttpRequest) {
		req = new XMLHttpRequest();
	// branch for IE/Windows ActiveX version
	} else if (window.ActiveXObject) {
		req = new ActiveXObject("Microsoft.XMLHTTP");
	}
	if (req) {
		req.open('POST', contextPath + "/common/saveFeedback.jsp", false);
		req.setRequestHeader("Content-Type","application/x-www-form-urlencoded; charset=UTF-8");

		//which r1 is checked
		var r1=null;
		for (var i=0;i<document.forms['feedback'].elements['r1'].length;i++){
			if (document.forms['feedback'].elements['r1'][i].checked) {
				r1 = document.forms['feedback'].elements['r1'][i].value;
				break;
			}
		}
		if (r1 == null) return;
		var obj = "r1="+ r1 +
			"&SRID="+ document.forms['feedback'].SRID.value +
			"&TEXTAREA1="+ document.forms['feedback'].TEXTAREA1.value +
			"&userName="  + userName + 
			"&ENV=" + ENV +
			"&externalId=" + extId +
			"&sliceId=" + sliceId +
			"&documentTitle=" + jsTitle;
			//alert(obj);
			res = req.send(obj);
			document.getElementById('feedbackform').style.display='none';
			document.getElementById('feedbackmsg').style.visibility='visible';
			document.getElementById('feedbackmsg').innerHTML = req.responseText;
	}
}
function getRdoRateValue() {
	if (document.feedback.r1[0].checked)
	{
		return 1;
	}	
	if (document.feedback.r1[1].checked)
	{
		return 2;
	}	
	if (document.feedback.r1[2].checked)
	{
		return 3;
	}	
}