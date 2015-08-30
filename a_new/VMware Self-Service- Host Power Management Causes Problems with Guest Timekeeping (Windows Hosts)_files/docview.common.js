function openDocumentLink(externalId, languageId) {
	h=window.open( contextPath + "/documentLink.do?popup=true&externalID="+externalId+'&languageId='+languageId, '_blank', 'toolbar=no,height=480,width=800,directories=no,status=no,scrollbars=yes,resizable=yes,menubar=no');
}
function openConsole(docId, attachmentId, name) {
	h=window.open(contextPath + "/viewAttachment.do?attachID="+encodeURIComponent(attachmentId)+"&documentID="+docId, name, 'toolbar=no,height=480,width=800,directories=no,status=no,scrollbars=yes,resizable=yes,menubar=no');
	h.focus();
}	 
function openWnd(theURL, theName, pWidth, pHeight, pResize, pMenu, pScroll, pStatus){
	var wTop = (screen.height - pHeight) / 2;
	var wLeft = (screen.width - pWidth) / 2;
	var theParam = 'height='+pHeight+',width='+pWidth+',left='+wLeft+',top='+wTop+',resizable='+pResize+',scrollbars='+pScroll+',menubar='+pMenu+',status='+pStatus;
	var winPop = window.open(theURL, theName, theParam);
	if (parseInt(navigator.appVersion) >= 4) {winPop.window.focus();}
	return winPop;
}
function emailDoc(externalId,sliceId,jsTitle,cpplayer,bbid) {
	var linkUrl =  contextPath + "/nonthreadedkc/email.do?COMMAND=SHOWEMAILDOC&";	
	if (externalId != ''){
		linkUrl += "ExternalID=" + externalId + "&threadtitle=" + jsTitle + "&sliceID=" + sliceId ;
	}
	else {
		linkUrl +="bbId=" + bbid ;
	}
	if (cpplayer) linkUrl += "&cpplayer=true";
	newWin = openWnd(linkUrl,'newWin', 500, 600, 'no', 'no', 'yes', 'no');   		   	
}
function addBookmark(url,title) {
	//get rid of highlight binding if there
	var regEx = new RegExp('&highlight=on', 'gi');
	var newUrl = url.replace(regEx, '');

	if(getBrowserName() == CONST_SAFARI) {
		alert('You need to press Command/Cmd + D to bookmark this page.');
	} else if (window.sidebar) {
		window.sidebar.addPanel(title, newUrl,"");
	} else if( document.all ) {
		window.external.AddFavorite(newUrl,title);
	} else if( window.opera && window.print ) {
		return true;
	}
}