
function getXMLRequest() {
	var req = null;
	if (window.XMLHttpRequest) {
		req = new XMLHttpRequest();
	} else  {
		req = new ActiveXObject("Microsoft.XMLHTTP");
	}
	return req;
}


function showFeedbackDlgPopup(pathToCommon) {
    var popup = window.open(pathToCommon+"/blank.jsp", 'feedbackWindow', 'toolbar=no,height=420,width=550,directories=no,status=no,scrollbars=yes,resizable=yes,menubar=no');
    popup.focus();
    feedbackDlg.target = "feedbackWindow";
    feedbackDlg.popup.value = "true";
    feedbackDlg.submit();
}

function showFeedbackDlgPopover(pathToCommon) {

	var oldPathToCommon = "";//formUMDialog.elements.namedItem('pathToCommon').value;
    var feedbackDlg = document.getElementById("feedbackDlgForm");
    feedbackDlg.elements.namedItem('pathToCommon').value = "../common";

	var clientx, clienty;
	if (document.body) { // other Explorers
		clientx = document.body.clientWidth;
		clienty = document.body.clientHeight
	} else if (document.documentElement && document.documentElement.clientHeight) { // Explorer 6 Strict Mode
		clientx = document.documentElement.clientWidth;
		clienty = document.documentElement.clientHeight;
	} else if (self.innerHeight) {// all except Explorer
		clientx = self.innerWidth;
		clienty = self.innerHeight;
	}

	var xOffset,yOffset;
	if (document.body) { // all other Explorers
		xOffset = document.body.scrollLeft;
		yOffset = document.body.scrollTop;
	} else 	if (self.pageYOffset) {// all except Explorer
		xOffset = self.pageXOffset;
		yOffset = self.pageYOffset;
	} else if (document.documentElement && document.documentElement.scrollTop) { // Explorer 6 Strict
		xOffset = document.documentElement.scrollLeft;
		yOffset = document.documentElement.scrollTop;
	}

	var dlgx = clientx*0.8;
	var dlgy = clienty*0.8;
	var dx = (clientx - dlgx) / 2;
	var dy = (clienty - dlgy) / 2;
	dx += xOffset;
	dy += yOffset;

	feedbackDlg.action += "?popoverMode=true&treeAndSearchDivHeight=" + (dlgy-255)

    try {
        doc = top.frames.Doc.document;
    } catch (e) {
        doc = top.document;
    }

    var feedback = doc.getElementById('FEEDBACK');
    if (feedback == null) {
		if (document.all)
			feedback = doc.createElement('<IFRAME id="FEEDBACK" name="FEEDBACK"'+ ' src='+pathToCommon+'"blank.jsp">');
		else {
            feedback = doc.createElement('IFRAME');
			feedback.setAttribute('name', 'FEEDBACK');
			feedback.setAttribute('src', pathToCommon+'blank.html');
		}

        feedback.setAttribute('id', 'FEEDBACK');
		feedback.style.position = 'absolute';
		feedback.style.top =  dy;
		feedback.style.left =  dx;
		feedback.setAttribute('width', 550);
		feedback.setAttribute('height', 430);
		feedback.setAttribute('scrolling', 'no');
		feedback.setAttribute('onblur', 'closeDialog()');

		doc.body.appendChild(feedback);

        var feedbackForm = doc.createElement('FORM');
        feedbackForm.name = "feedbackDlg";
        feedbackForm.id = "feedbackDlg";
        feedbackForm.method = 'post';
		feedbackForm.action = feedbackDlg.action;
		feedbackForm.target = "FEEDBACK";

        for(index = 0; index < feedbackDlg.elements.length; index++){

            var input = doc.createElement('INPUT');
            input.type = "hidden";
			input.name = feedbackDlg.elements[index].name;
			input.value = feedbackDlg.elements[index].value;
			feedbackForm.appendChild(input);
		}

        doc.body.appendChild(feedbackForm);

		doc.getElementById("feedbackDlg").submit();
		feedbackDlg.elements.namedItem('pathToCommon').value = oldPathToCommon;
	}
}

function getDocumentWindow() {
    if (parent.isDocViewWindow)
        return parent;
    else
        return window;
}

function getDocumentFrameset() {
    return getDocumentWindow().frames;
}

function getFeedbackFrame() {
    return getDocumentFrameset().Feedback;
}

function getDocFrame() {
    return getDocumentFrameset().Doc;
}

function getHeaderFrame() {
    return getDocumentFrameset().Header;
}

function getAboutFrame() {
    return getDocumentFrameset().About;
}
