// JavaScript library for common purpose
var popupPathToCommon = findPopupPath();
// center Pop-up window
function centerPopUp (theURL, theName, pWidth, pHeight) {
    var wTop = (screen.height - pHeight) / 2;
    var wLeft = (screen.width - pWidth) / 2;
    var theParam = 'height='+pHeight+',width='+pWidth+',left='+wLeft+',top='+wTop+',resizable=1';
    winPop = window.open(theURL, theName, theParam);
    if (parseInt(navigator.appVersion) >= 4) {winPop.window.focus();}
}

function centerPopUpModal(theURL, theWindow, pWidth, pHeight)
{
	var wTop = (screen.height-pHeight)/2;
	var wLeft = (screen.width-pWidth)/2;
	openWindow(theURL,theWindow,pWidth,pHeight,wLeft,wTop);
}

// get inner browser dimensions
function getInnerDim () {
    var dim=new Array(2)
    //if browser supports window.innerWidth
    if (window.innerWidth) {
        dim[0] = window.innerWidth;
        dim[1] = window.innerHeight;
    }
    //else if browser supports document.all (IE 4+)
    else if (document.all) {
        dim[0] = document.body.clientWidth;
        dim[1] = document.body.clientHeight;
    }
    return dim;
}

var CONST_FIREFOX = "FIREFOX";
var CONST_IE = "MSIE";
var CONST_SAFARI = "SAFARI";
var CONST_MAC = "MAC";
var CONST_WINCE = "WINDOWS CE";
var CONST_OPERA = "OPERA";

function getBrowserName()
{
    var browserName = "";
    if (navigator.userAgent.toUpperCase().indexOf(CONST_FIREFOX) > -1) {
        browserName = CONST_FIREFOX;
    } else  if (navigator.userAgent.toUpperCase().indexOf(CONST_IE) > -1) {
        browserName = CONST_IE;
    } else if (navigator.userAgent.toUpperCase().indexOf(CONST_SAFARI) > -1) {
        browserName = CONST_SAFARI;
    } else if (navigator.userAgent.toUpperCase().indexOf(CONST_MAC) > -1) {
        browserName = CONST_MAC;
    } else if (navigator.userAgent.toUpperCase().indexOf(CONST_WINCE) > -1) {
        browserName = CONST_WINCE;
    } else if (navigator.userAgent.toUpperCase().indexOf(CONST_OPERA) > -1) {
        browserName = CONST_OPERA;
    }
    return browserName;
}


// load 2 frames with one click
function loadFrames(frame1,page1,frame2,page2) {
eval(frame1+".location='"+page1+"'");
eval(frame2+".location='"+page2+"'");
}

function show_props(obj, obj_name) {
   var result = "";
   for (var i in obj)
      result += obj_name + "." + i + " = " + obj[i] + ' ;  ';
   return result;
}

function addOption(ctrl,value,text){
   if (ctrl.options) {
           oOpt=document.createElement("OPTION");
           oOpt.value = value;
           oOpt.text = text;
           ctrl.options[ctrl.options.length] = oOpt;

           //ctrl.add(oOpt);
           //ctrl.options[ctrl.options.length-1].value=value;
           //ctrl.options[ctrl.options.length-1].text=text;
   }
}

function delOption(ctrl,ind){
   if (ctrl.options && ind>-1 && ind<ctrl.options.length) {
        ctrl.options[ind] = null;
   }
}

function findOption (ctrl,str, isCaseInsens){
  if(ctrl && ctrl.options && str && str.length>0){
    var len=ctrl.options.length
    for(ind=0;ind<len;ind++){
      if(isCaseInsens) {
        if (ctrl.options[ind].value.toLowerCase()==str.toLowerCase()) return ind;
      } else {
        if (ctrl.options[ind].value==str) return ind;
      }
    }
  }
  return -1;
}

function moveOptions(ctrl1,ctrl2){
        var len=ctrl1.options.length
        for(ind=0;ind<len;ind++){
                if(ctrl1.options[ind].selected){
                       addOption(ctrl2,ctrl1.options[ind].value,ctrl1.options[ind].text)
                       delOption(ctrl1,ind)
                       len=ctrl1.options.length
                       ind--
                }
         }
}

function moveAllOptions(ctrl1,ctrl2){
        var len=ctrl1.options.length
        for(ind=0;ind<len;ind++){
                       addOption(ctrl2,ctrl1.options[ind].value,ctrl1.options[ind].text)
                       delOption(ctrl1,ind)
                       len=ctrl1.options.length
                       ind--
        }
}

function copyAllOptions(ctrl1,ctrl2){
        var len=ctrl1.options.length
        for(ind=0;ind<len;ind++){
                       addOption(ctrl2,ctrl1.options[ind].value,ctrl1.options[ind].text)
        }
}

function delAllOptions(ctrl1){
        var len=ctrl1.options.length
        for(ind=0;ind<len;ind++){
                       delOption(ctrl1,ind)
                       len=ctrl1.options.length
                       ind--
        }
}


function moveOption(ctrl,ind1,ind2){
        if(ind1>-1 && ind2>-1){
                var opt=ctrl.options[ind1]
                delOption(ctrl,ind1)
                if(ind2>ctrl.options.length) ind2=ctrl.options.length
                if(ind2<0) ind2=0
                ctrl.add(opt,ind2);
        }
}

/*
Sort options of select control
sc - select control
*/
function sortOptions(sc)
{
    var opt = sc.options;
    if (!opt || opt.length<2) return;
    for (i = 0; i< opt.length-1; i++){
    	for (y = i+1; y < opt.length; y++){
            if (opt[i].text.toLowerCase()>opt[y].text.toLowerCase()) {
				var obj=new Array(opt[i].text,opt[i].value,opt[i].selected,opt[i].disabled,opt[i].className);
				opt[i].text=opt[y].text;
				opt[i].value=opt[y].value;
				opt[i].selected=opt[y].selected;
				opt[i].disabled=opt[y].disabled;
				opt[i].className=opt[y].className;
				//i -> y
				opt[y].text=obj[0];
				opt[y].value=obj[1];
				opt[y].selected=obj[2];
				opt[y].disabled=obj[3];
				opt[y].className=obj[4];
            }
        }
    }
}

function selectSort(obj) {
 sortOptions(obj);
}



var isTextArea=false;
function setTextAreaLength(ctrltextarea,ctrltext,maxnum){
   if (isTextArea) return;
   isTextArea = true;
   var v = ctrltextarea.value;
   var currLength=v.length;
   if (currLength>maxnum-1 && v.substring(maxnum, maxnum+1) =="\n")
   {
        ctrltextarea.value = v.substring(0, maxnum-1);
        currLength=maxnum-1;
   } else if(currLength>maxnum){
        ctrltextarea.value=v.substring(0,maxnum);
        currLength=maxnum;
   }
   if( ctrltext ) {
      ctrltext.value=currLength;
   }
   isTextArea = false;
}

function setTextAreaLen500(ctrltextarea,maxnum){
   var v = ctrltextarea.value;
   var currLength=v.length;
   if (currLength>maxnum-1 && v.substring(maxnum, maxnum+1) =="\n")
   {
        ctrltextarea.value = v.substring(0, maxnum-1);
        currLength=maxnum-1;
        return false;
   } else if(currLength>maxnum){
        ctrltextarea.value=v.substring(0,maxnum);
        currLength=maxnum;
        return false;
   }
   return true;
}

function selectOption(ctrl,val){
		var isFound = false;
        if(ctrl && ctrl.options && val && val.length>0){
                var len=ctrl.options.length
                for(ind=0;ind<len;ind++){
                        if (ctrl.options[ind].value==val) {
                            ctrl.options[ind].selected=true;
														isFound = true;
                        }
                }
        }
		return isFound;
}
function uncheckEmptySelection( ctrl ) {
    var len = ctrl.options.length;
    var count = 0;
    for ( ind=0; ind<len; ind++ ) {
        if ( ctrl.options[ind].selected )
            count ++;
    }
    if ( ctrl.options[0].selected && count > 1 )
        ctrl.options[0].selected = false;
}


var selectWithNonBlank = new Array(0);

function onChangeSelect( ctrl ) {
    var isBlankSelected = ctrl.options[ 0 ].selected;
    var count = 0;
    for ( var ind=1; ind<ctrl.options.length; ind++ ) {
        if ( ctrl.options[ind].selected )
            count ++;
    }

    var indexOfSelect = -1;
    for( var ind = 0; ind < selectWithNonBlank.length; ind++ ) {
        if( ctrl == selectWithNonBlank[ ind ] ) {
            indexOfSelect = ind;
            break;
        }
    }

    if( indexOfSelect == -1 ) {
        // Nothing was selected.
        if( count == 0 )
            return;
        else if( isBlankSelected ) {
            // Blank was selected previously
            // Do: uncheck all non-blank
            for( var ind = 1; ind < ctrl.options.length; ind++ )
                ctrl.options[ ind ].selected = false;
        }
      else
            // Non-blank is selected.
            selectWithNonBlank[ selectWithNonBlank.length ] = ctrl;
    }
    else {
        // Non-blank was selected.
        if( count == 0 )
            selectWithNonBlank.splice( indexOfSelect, 1 );
        else if( isBlankSelected )
            ctrl.options[ 0 ].selected = 0;
    }
}

function removeSelectListeners( document ) {
    var i = 0;
    while( i < selectWithNonBlank.length ) {
        if( selectWithNonBlank[ i ].document == document ) {
            selectWithNonBlank.splice( i, 1 );
        }
        else
            i++;
    }
}

function processTAChange(tArea, event, maxlen){

    if (tArea.value.length > maxlen && (event.keyCode != 8 && event.keyCode != 46)){

        event.returnValue = false;
        return;
    }
}

function getPositionTop (oElement){
     var retVal = 0;
     if (oElement.offsetParent) {
        retVal += getPositionTop (oElement.offsetParent);
        retVal-=oElement.scrollTop;
     }
     retVal += oElement.offsetTop;
     return retVal;
}

function getPositionLeft (oElement){
     var retVal = 0;
     if (oElement.offsetParent) {
        retVal += getPositionLeft (oElement.offsetParent);
        retVal-=oElement.scrollLeft;
     }
     retVal += oElement.offsetLeft;
     return retVal;
}

// hide element
function hideElement(el) {
    if (!el) return;
    el.style.visibility = "hidden";
}
// show element
function showElement(el) {
    if (!el) return;
    el.style.visibility = "inherit";
}

// hide/show via style.display, value=true/false
// In contrast to the visibility property, display = reserves no space for the object on the screen.
function setDisplay(el, value) {
    if (!el) return;
    if (value)
        el.style.display = "inline";
    else
        el.style.display = "none";
}

// deselect radiobuttons
function deselectRadioButton(radioGroup) {
    if (!radioGroup) return;
    if (radioGroup.length) { // radioGroup is a collection
        for (var radIndex = 0 ; radIndex < radioGroup.length; radIndex++) {
            if (radioGroup[radIndex].checked) {
                radioGroup[radIndex].checked = false;
            }
        }
    } else { // radioGroup is a single radio
        if (radioGroup.checked)
            radioGroup.checked=false;
    }
}

function isDigit(e) {
    if (e.which) {
        // Firefox
        if ((e.which<48 || e.which>57) && e.which != 8) return false;
    }
    if (!e.which) {
        // IE
        if (e.keyCode<48 || e.keyCode>57 ) return false;
    }
    return true;
}

  function lTrim(text) {
    if(text==null){
      text=''
    } else {
      var first = text.charAt(0);
      while(first==' ' || first=='\r' || first=='\n' || first=='\t'){
        text = text.substring(1,text.length);
        first  = text.charAt(0);
      }
    }
    return text;
  }

function allTrim(text) {
    if(text==null || text.length<1) return "";
    text = lTrim(text);
    var pos = text.length - 1;
    while(text.charAt(pos)==' ' || text.charAt(pos)=='\r' || text.charAt(pos)=='\n' || text.charAt(pos)=='\t') {
      text = text.substring(0,pos);
      pos--;
    }
    return text;
}

/*
  This function shows select UM dialog
  Parameters:
    formUMDialog - form with all parameters (see design doc for more info)
*/
function showUMDialog(formUMDialog, isBuildIn) {
    actionName="selectUMDialog.do";
    paramsStr = "";
    if (formUMDialog != null) {
        elements = formUMDialog.elements;
        for ( var i=0; i<elements.length; i++ ) {
            if (elements[i].name != "pathToCommon") {
                if ( paramsStr.indexOf('?') < 0 )
                    paramsStr +="?"+elements[i].name+"="
                else
                    paramsStr +="&"+elements[i].name+"=";
                paramsStr += elements[i].value;
            } else {
                pathToCommon = elements[i].value;
            }
        }
    }

    if (paramsStr.length >0)
        paramsStr +="&pathToCommon=../common"
    else
        paramsStr +="?pathToCommon=../common"


    if (!pathToCommon) pathToCommon = '';
    var url = pathToCommon + actionName + paramsStr;

	if (isBuildIn) {
        var umpaglet = document.getElementById('UMPAGELET');
        if (umpaglet!=null) return;


        var oldPathToCommon = formUMDialog.elements.namedItem('pathToCommon').value;
		formUMDialog.elements.namedItem('pathToCommon').value = "../common";
		formUMDialog.action = pathToCommon + actionName;

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

        url += "&popoverMode=true&treeAndSearchDivHeight=" + (dlgy-255);
        formUMDialog.action += "?popoverMode=true&treeAndSearchDivHeight=" + (dlgy-255)

		//var umpaglet = document.getElementById('UMPAGELET');
		if (umpaglet==null) {
			if( document.all )
				umpaglet = document.createElement('<IFRAME name="UMPAGELET"'+ ' src='+pathToCommon+'"blank.jsp">');
			else {
				umpaglet = document.createElement('IFRAME');
				umpaglet.setAttribute('name', 'UMPAGELET');
				umpaglet.setAttribute('src', pathToCommon+'blank.jsp');
			}
			
			umpaglet.setAttribute('id', 'UMPAGELET');

			umpaglet.style.position = 'absolute';
			umpaglet.style.top =  dy;
			umpaglet.style.left =  dx;
			umpaglet.setAttribute('width', dlgx);
			umpaglet.setAttribute('height', dlgy);
			umpaglet.setAttribute('scrolling', 'no');
			umpaglet.setAttribute('onblur', 'closeUMDialog()');

			document.body.appendChild(umpaglet);
			formUMDialog.target = 'UMPAGELET';
			formUMDialog.method = "POST";
			formUMDialog.submit();
			formUMDialog.elements.namedItem('pathToCommon').value = oldPathToCommon;
		}
	} else {
	    var dlgw = 660;
	    var dlgh = 723;
	    var dx = (screen.availWidth - dlgw) / 2;
	    var dy = (screen.availHeight - dlgh) / 2;
	    if( url.length < 2000 && window.showModalDialog) {
	        window.showModalDialog(
	            url,
	            window,
	            "status:0;dialogWidth:"+dlgw+"px;dialogHeight:"+dlgh+"px;dialogLeft:" + dx + "px;dialogTop:" + dy + "px;edge:sunken;scroll=1;help=0;resizable=0");
	    } else {
					var oldPathToCommon = formUMDialog.elements.namedItem('pathToCommon').value;
					formUMDialog.elements.namedItem('pathToCommon').value = "../common";
					formUMDialog.action = pathToCommon + actionName;
					formUMDialog.action += "?popoverMode=false";
	        window.open( pathToCommon + "blank.jsp",
	            "selDlg",
	            'height=' + dlgh + ',width=' + dlgw + ',left=' + dx + ',top=' + dy + ',toolbar=no,directories=no,status=no,menubar=no,scrollbars=yes,resizable=no,modal=yes');
					formUMDialog.target = "selDlg";
					formUMDialog.method = "POST";
					formUMDialog.submit();
					formUMDialog.elements.namedItem('pathToCommon').value = oldPathToCommon;
	    }
	}
}

function closeUMDialog() {
	var umpaglet = document.getElementById('UMPAGELET');
	if (umpaglet!=null) {
		document.body.removeChild(umpaglet);
	}
}


function showUserOrGroupDialog(formSUOG, pathToCommon) {
	if (!pathToCommon) pathToCommon = '';
    var url = pathToCommon + actionName;
	var dlgw = 380;
	var dlgh = 690;
	var dx = (screen.availWidth - dlgw) / 2;
	var dy = (screen.availHeight - dlgh) / 2;


	window.open( pathToCommon + "blank.jsp",
			"selUserOrGroup",
			'height=' + dlgh + ',width=' + dlgw + ',left=' + dx + ',top=' + dy + ',toolbar=no,directories=no,status=no,menubar=no,scrollbars=yes,resizable=no,modal=yes');
	var actionName="AddUsersOrGroups.do";
	formSUOG.action = pathToCommon + actionName;
	formSUOG.target = "selUserOrGroup";
	formSUOG.method = "POST";
	formSUOG.submit();
}

function showSelectUserDialog(formSUser, pathToCommon) {
	if (!pathToCommon) pathToCommon = '';
	var url = pathToCommon + actionName;
	var dlgw = 380;
	var dlgh = 450;
	var dx = (screen.availWidth - dlgw) / 2;
	var dy = (screen.availHeight - dlgh) / 2;


	window.open(pathToCommon + "blank.jsp",
			"selUserDialog",
			'height=' + dlgh + ',width=' + dlgw + ',left=' + dx + ',top=' + dy + ',toolbar=no,directories=no,status=no,menubar=no,scrollbars=yes,resizable=no,modal=yes');
	var actionName = "selectUserWithPermission.do";
	formSUser.action = pathToCommon + actionName;
	formSUser.target = "selUserDialog";
	formSUser.method = "POST";
	formSUser.submit();
}


/*
  This function shows select segments dialog
  Parameters:
    selectedSegments - segments that must be selected initially
    pathToCommon - relative path to "defaultroot/common/" folder

  You must define function setSelSegmentsResults(selectedSegmentsIds,selectedSegmentsNames,segmentsSegmTypesIDs,segmentsSegmTypesNames) at parent page
  to retrieve results of the diallog
  The results will be:
    Array of selected segments IDs,
    Array of selected segments Names,
    Array of selected segments segm types IDs,
    Array of selected segments segm types Names
*/
function showSegmentsDialog( selectedSegments, pathToCommon, checkAttribute, language, isForWrite ) {
    action = 'selectSegmentsDialog.do';
    if ( checkAttribute )
        action += '?checkAttribute='+checkAttribute;
    if ( language )
        action += formParamName(action,'language')+language;
    if(isForWrite)
        action += formParamName(action,'forwrite')+'1';
    show2Select1ReturnDialog(action, selectedSegments, pathToCommon);
}

/*
  This function shows select languages dialog
  Parameters:
    selectedLanguages - languages that must be selected initially
    pathToCommon - relative path to "defaultroot/common/" folder

  You must define function setSelLanguagesResults(selectedLangIds,selectedLangNames) at parent page
  to retrieve dialog results
  The results will be:
    Array of selected Languages IDs,
*/
function showLanguagesDialog( selectedLanguages, pathToCommon,isForWrite ) {
    show2Select1ReturnDialog('selectLanguageDialog.do'+(isForWrite?"?forwrite=1":""), selectedLanguages, pathToCommon);
}

/*
  This function shows select products dialog
  Parameters:
    selectedProducts - product IDs that must be selected initially
    pathToCommon - relative path to "defaultroot/common/" folder

  You must define function setSelProductsResults(selectedProdIds,selectedProductsNames) at parent page
  to retrieve dialog results
  The results will be:
    Array of selected products IDs,
    Array of selected products Names
*/
function showProductsDialog( selectedProducts, pathToCommon,isForWrite,isForUser) {
    separator="?";
    isForWrite?separator="&":separator="?";
    show2Select1ReturnDialog('selectProductsDialog.do'+(isForWrite?"?forwrite=1":"")+(isForUser? separator+"none=true":separator+"none=false"), selectedProducts, pathToCommon);
}

/*
  This function shows select SAL dialog
  Parameters:
    selectedSALs - Array sal IDs that must be selected initially
    pathToCommon - relative path to "defaultroot/common/" folder
    selectFromIds - Array of IDs of levels we can choose only (from can be passed)
    windowId - identifier of window will be retuired

  You must define function setSelSALResults(selectedSALIds,selectedSALNames) at parent page
  to retrieve dialog results
  The results will be:
    Array of selected SAL IDs,
    Array of selected SAL Names
    windowId - identifier of window will be retuired
*/
function showSAL_Dialog( selectedSALs, pathToCommon, selectFromIds, windowId, moveParentsNodes, isForWrite, language, hideDashes ) {
    action = 'selectSALDialog.do';
    if (moveParentsNodes) {
        action += "?moveParentsVersion=true";
    } else
        action += "?moveParentsVersion=false";
    if(isForWrite)
        action += formParamName(action,'forwrite')+'1';
    if ( language )
        action += formParamName(action,'language')+language;

    if ( hideDashes )
        action += formParamName(action,'hideDashes')+hideDashes;

    show2Select1ReturnDialog(action, selectedSALs, pathToCommon, selectFromIds, windowId);
}
/*
  This function shows select Unified Templates dialog
  Parametrs:
      selectedUnifiedTempates - Array sal IDs that must be selected initially
      pathToCommon - relative path to "defaultroot/common/" folder

      type - type templates (1 - authoring templates; 2 - case response; null or othere number - all templates)
*/

function showUnifiedTemplatesDialog(selectedUnifiedTempates, pathToCommon, type) {
    action = 'selectUnifiedTemplatesDialog.do';
    if (type == 1) {
        action += "?type=1";
    } else if(2) {
        action += "?type=2"
    }
    show2Select1ReturnDialog(action ,selectedUnifiedTempates, pathToCommon);
}

function formParamName(actionName, paramName) {
    if ( actionName.indexOf('?') < 0 )
        return "?"+paramName+"="
     else
        return "&"+paramName+"=";
}

function show2Select1ReturnDialog( actionName, selectedItems, pathToCommon, selectFromIds, windowId ) {
    paramsStr = "";
    if (selectedItems) {
        paramsStr = formParamName(actionName, "selected");
        for (var i=0;i<selectedItems.length;i++)
            paramsStr += selectedItems[i]+",";
    }

    if (selectFromIds) {
        paramsStr += formParamName(actionName+paramsStr,"chooseFrom");
        for (var i=0;i<selectFromIds.length;i++)
            paramsStr += selectFromIds[i]+",";
    }

    if (windowId) {
        paramsStr += formParamName(actionName+paramsStr,"wid") + windowId;
    }

    var dlgw = 590;
    var dlgh = 365;
    var dx = (screen.availWidth - dlgw) / 2;
    var dy = (screen.availHeight - dlgh) / 2;

    if (!pathToCommon) pathToCommon = '';

    var url = pathToCommon + actionName + paramsStr;
    openWindow(url,window,dlgw,dlgh,dx,dy);
}

function openWindow(url,window,dlgw,dlgh,dx,dy) {
    if (window.showModalDialog) {
        window.showModalDialog(
            url,
            window,
            "status:0;dialogWidth:"+dlgw+"px;dialogHeight:"+dlgh+"px;dialogLeft:" + dx + "px;dialogTop:" + dy + "px;edge:sunken;scroll=0;help=0");
    } else {
        window.open(
            url,
            'selDlg',
            'height=' + dlgh + ',width=' + dlgw + ',left=' + dx + ',top=' + dy + ',toolbar=no,directories=no,status=no,menubar=no,scrollbars=no,resizable=no,modal=yes');
    }
}

function getOffset() {
    var clientDate = new Date();
	return clientDate.getTimezoneOffset();
}

function unselectDisabledOptions(ctrl){
	for(i=0;i<ctrl.options.length;i++){
		if(ctrl.options[i].disabled){
		   ctrl.options[i].selected=false;
		}
	}
	return true;
}

function addDisabledOptionsToString(ctrl){
    var str='';
	for(i=0;i<ctrl.options.length;i++){
		if(ctrl.options[i].disabled && ctrl.options[i].value && ctrl.options[i].value.length>0){
		   str=str+ctrl.options[i].value+',';
		}
	}
	if(str.length>1) str=str.substring(0,str.length-1);
	return str;
}

function replace(str, c, target)
{
	var res="";
	var from = 0;
	var i = str.indexOf(c);
	while(i >=0)
	{
		res+=str.substring(from,i);
		res+=target;
		from = i+c.length;
		i = str.indexOf(c,from);
	}
	res+=str.substring(from);
	return res;
}

// Checking valid url
function checkUrl(url)
{
	var re = /(http|ftp|https):\/\/[\w]+(.[\w]+)([\w\-\.,@?^=%&:\/~\+#]*[\w\-\@?^=%&\/~\+#])?/i;
	
	if (re.test(url) == true) return true;
	else return false;
}

//Used in Workflow
function checkSpecialSymbols(paramValue, specSymbols) {
    //check for symbols "\\(\\)<>@,;:=_`~#%&.'-/\\\\\\\"\\[\\]\\?\\^\\{\\}\\|\\$\\!\\+\\*";
    var validChars="\[^" + specSymbols+ "\]";
        var atom=validChars + '+';
        var word="(" + atom + "|" + ")";
    var userPat=new RegExp("^" + word + "(\\." + word + ")*$");
    if( paramValue.match(userPat)==null)
    {
        return false;
    }
    return true;
}
//Used in RF
function hasInvalidCharacters(str) {
	var strlen = str.length;
	var i;
	for (i = 0; i < strlen; i++) {
		var ithChar = str.charAt(i);
		if (ithChar < '0' && ithChar != '-' && ithChar != ' ' && ithChar != "'") {
			return true;
		}
		if (ithChar > '9' && ithChar < 'A') {
			return true;
		}
		if (ithChar > 'Z' && ithChar < 'a' && ithChar != '_') {
			return true;
		}
	}
	return false;
}


function openModalDialog (theURL, theName, pWidth, pHeight, pOther){ //theName is used for Netscape
    var theParam;
    if (window.showModalDialog) {
        theParam = 'dialogHeight:'+pHeight+'px; dialogWidth:'+pWidth+'px; status:no; center:yes; resizable:no; scroll:no; help:no;';
        win = window.showModalDialog(theURL, window, theParam); //theName is replaced with the window object window
    } else {
        // this is mainly for Nescape (opens a window in the middle of the screen)
        // add the following to the body tag of the pop-up window: onload="focus();"
        var wTop = (screen.height - pHeight) / 2;
        var wLeft = (screen.width - pWidth) / 2;
        theParam = 'height='+pHeight+',width='+pWidth+',left='+wLeft+',top='+wTop+',resizable=no,'+pOther;
        win = window.open(theURL, theName, theParam);
    }
    return win;
}

function showMessageBox(text,btn,cx,cy, path){
  var url=(path ? path : "") + "messageBox.jsp?text=" + encodeURIComponent(text) +
        "&name=" + encodeURIComponent(btn);    
  if( !cx ) cx = 360;
  if( !cy ) cy = 180;
  return openModalDialog(url,"", cx,cy);
}

function show2ButtonModalDialog(text, btn1, btn2, action1, action2, def, cx, cy, path) {
    var url = (path ? path : "") + "question2b.jsp?text=" + encodeURIComponent(text) +
              "&action1=" + action1 + "&action2=" + action2 +
              "&name1=" + btn1 + "&name2=" + btn2 +
              "&default=" + def;
    if (!cx) cx = 360;
    if (!cy) cy = 180;
    return openModalDialog(url, "", cx, cy);
}
function show3ButtonModalDialog(text, btn1, btn2, btn3, action1, action2, action3, def, cx, cy, path) {
    var url = (path ? path : "") + "question3b.jsp?text=" + text +
              "&action1=" + action1 + "&action2=" + action2 + "&action3=" + action3 +
              "&name1=" + btn1 + "&name2=" + btn2 + "&name3=" + btn3 +
              "&default=" + def;
    if (!cx) cx = 360;
    if (!cy) cy = 180;
    return openModalDialog(url, "", cx, cy, "");
}


function toJavaScript(str) {

    str = str.replace(/'/g, "\\'");
    str = str.replace(/"/g, '\\"');
    str = str.replace(/\n/g, "\\n");
    str = str.replace(/\f/g, "\\f");
    str = str.replace(/\t/g, "\\t");

  return str;

}

function htmlEscape(strInput) {
    return xml_escape(strInput)
}

function xml_escape(strInput) {
    var output = "";
    
    for (var i=0;i<strInput.length;i++) {
        mychar = strInput.charCodeAt(i);
        // <
        if (mychar == 38 ) { output= output + "&amp;";}
        else if (mychar == 60 ) { output= output + "&lt;"; }
        else if (mychar == 62 ) { output= output + "&gt;";}
        else if (mychar == 34 ) { output= output + "&quot;";}
        else if (mychar == 39 ) { output = output + "&#39;"; }
        else {
            output = output+ strInput.charAt(i);
        }
    }
    return output;
}

function xml_unescape(strInput) {
    strInput = strInput.replace(/\&amp;/, '&');
    strInput = strInput.replace(/\&lt;/, '<');
    strInput = strInput.replace(/\&gt;/, '>');
    strInput = strInput.replace(/\&quot;/, '\"');
    strInput = strInput.replace(/\&apos;/, '\'');
    return strInput;
}


function findPopupPath(){
    var url = window.location.pathname;
    var result = url.substring(0,url.indexOf('/',1)) + '/common/';	
    return result;
}

// prepares comma-separated string for SELECTED_ITEMS attribute
// ids - comma-separated list of ids
// typeid - type id
function getSelectedItems(ids, typeid) {
	if (ids==null) {
		return "";
	}
	
	var idsArray = ids.split(",");
	var result = "";
	for (var i=0; i<idsArray.length; i++) {
		if (result.length>0) {
			result += ";";
		}
		result += idsArray[i]+","+typeid;
	}
	return result;
}

// returns comma-separated string of ids from array of UM items
// items - array of um_item
function getIds(items) {
	if (items==null){
		return "";
	}
	
	var itemIds = "";
	for (var i=0; i<items.length; i++) {
		var umItemId = items[i].id;
		if (itemIds.length==0) {
			itemIds += umItemId;
		} else {
			itemIds += ',' + umItemId;
		}
		}
	return itemIds;
}

// returns comma-separated string of names from array of UM items
// items - array of um_item
function getNames(items) {
	if (items==null){
		return "";
	}

	var itemNames = "";
	for (var i=0; i<items.length; i++) {
		var umItemName = items[i].name;
		if (itemNames.length==0) {
			itemNames += umItemName;
		} else {
			itemNames += ', ' + umItemName;
		}
		}
	return itemNames;
}

function getCommaSeparatedString(arr) {
	var result = "";
	for (var i=0; i<arr.length; i++) {
		if (result.length>0) {
			result += ",";
		}
		result += arr[i];
	}
	return result;
}

function assignURL(url) {
    if (parent.openDocFromDocView) {
        parent.openDocFromDocView(url,true);
    } else {
        window.location.assign(url);
    }
}

function replaceURL(url) {
    if (parent.openDocFromDocView) {
        parent.openDocFromDocView(url,false);
    } else {
        top.location.replace(url);
    }
}

