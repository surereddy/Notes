/*********************************************************************************************************/
// Menu Dropdowns

initNav = function() {
		var navRoot = document.getElementById("primary-navigation");
		if (navRoot)
		{
		var lis = navRoot.getElementsByTagName("li");
		for (var i=0; i<lis.length; i++)
		{
			var drops = lis[i].getElementsByTagName("ul");
			if (drops.length)
			{
				lis[i].onmouseover = function()
				{
					this.className += " hover";
				}
				lis[i].onmouseout = function()
				{
					this.className = this.className.replace("hover", "");
				}
			}
		}
		}
		var navRoot = document.getElementById("language");
		if (navRoot != null)  /*for vmworld pages*/
		{
		var lis = navRoot.getElementsByTagName("li");
		for (var i=0; i<lis.length; i++)
		{
			var drops = lis[i].getElementsByTagName("ul");
			if (drops.length)
			{
				lis[i].onmouseover = function()
				{
					this.className += " hover";
				}
				lis[i].onmouseout = function()
				{
					this.className = this.className.replace("hover", "");
				}
			}
		}
		}
}

if (window.addEventListener){
	window.addEventListener("load", initNav, false);
}
else if (window.attachEvent){
	window.attachEvent("onload", initNav);
}

/*********************************************************************************************************/

function searchfield_clear() {
	if (document.f.q.value != "")
		document.f.q.value = "";
}

function searchfield_blur() {
	if (document.f.q.value == "")
		document.f.q.value = (document.gs.q.value.length) ? document.gs.q.value : "";
}

function searchglobal_clear() {            
	if (document.frmSearchGLOBAL.q.value != "")
		document.frmSearchGLOBAL.q.value = "";
}

/*********************************************************************************************************/

// Anti-spam email links by deanq.com
function vmemail(who,subject,domain,body) {
  if (!domain) var domain = "vmware.com";
  if (!subject) var subject = " ";
  if (!body) var body = " ";
  eval("location.href='mailto:" + who + "@" + domain + "?subject=" + subject + "&body=" + body + "'");
}

// General popup window function
function popup(URL,name,w,h,scroll, resize, status, buttons) {
  var featureStr = "";
  if (scroll) { scroll = 'yes'; } else { scroll = 'no'; }
  if (resize) { resize = 'yes'; } else { resize = 'no'; }
  if (status) { status = 'yes'; } else { status = 'no'; }
  if (!buttons) { buttons = 'no'; } else { buttons = 'yes'; } // This includes location bar, menubar and toolbar
  featureStr = "width=" + w + ",height=" + h + ",directories=no,location=" + buttons + ",menubar=" + buttons + ",resizable=" + resize + ",scrollbars=" + scroll + ",status=" + status + ",toolbar=" + buttons
  var newWin = window.open(URL,name,featureStr);
  newWin.focus(); // Bring window to focus (in case of updating an existing window)
}

/////////////////////////////////////////////
// Dynamic Tabs controller used in VI3 pages
//

function showLayer(lyr) {
//   makeHistory(lyr);
   document.getElementById(currentLayer).className = 'hide';
   document.getElementById(lyr).className = 'show';
   currentLayer = lyr;
//   showTab(lyr.replace("tab","t_"));
}

function showTab(lyr) {
   document.getElementById(currentTab).className = 'taboff';
   document.getElementById(lyr).className = 'tabon';
   currentTab = lyr;
}

/*****************************************************
 * Preload Dropdown Images - 08/12/07
 *****************************************************/
var image_arr = Array(
	'/files/images/tpl/arrow-dropdown-white.gif',
	'/files/images/tpl/d-link-main-left.gif',
	'/files/images/tpl/d-link-main-right.gif',
	'/files/images/tpl/d-dropdown-top.gif',
	'/files/images/tpl/d-dropdown-bottom.gif',
	'/files/images/tpl/d-gradient.gif',
	'/files/images/tpl/link-main-left.gif',
	'/files/images/tpl/link-main-right.gif',
	'/files/images/tpl/dropdown-top.gif',
	'/files/images/tpl/dropdown-bottom.gif',
	'/files/images/tpl/gradient.gif',
	'/files/images/tpl/gradient.gif',
	'/files/images/tpl/link-main-right-act.gif',
	'/files/images/tpl/link-main-active.gif',
	'/files/images/tpl/link-main-right-act.gif'
);

var j = 0;
var p = image_arr.length;
var preBuffer = new Array();

for (i = 0; i < p; i++){
   preBuffer[i] = new Image();
   preBuffer[i].src = image_arr[i];
}
/*****************************************************/

function getParameter(name) {

    var url = window.location.href;

    var paramsStart = url.indexOf("?");

    if(paramsStart != -1){

       var paramString = url.substr(paramsStart + 1);

       var tokenStart = paramString.indexOf(name);

       if(tokenStart != -1){

          paramToEnd = paramString.substr(tokenStart + name.length + 1);

          var delimiterPos = paramToEnd.indexOf("&");

          if(delimiterPos == -1){

             return paramToEnd;

          }

          else {

             return paramToEnd.substr(0, delimiterPos);

          }
       }
    }
 }
 
//Handle Duplicate Form Submissions
	function handleSubmit(frmObj){
	   	var inputElements = frmObj.getElementsByTagName('input');
	   	for (i=0; i<inputElements.length; i++) {
	       		if(inputElements[i].type.toLowerCase() == 'submit'){
	       		   inputElements[i].disabled=true;
	       		}
	     	}
	}
    
/* OnlineOpinion (S3tS v3.1) */

/* This product and other products of OpinionLab, Inc. are protected by U.S. Patent No. 6606581, 6421724, 6785717 B1 and other patents pending. */

var custom_var,_sp='%3A\\/\\/',_rp='%3A//',_poE=0.0, _poX=0.0,_sH=screen.height,_d=document,_w=window,_ht=escape(_w.location.href),_hr=_d.referrer,_tm=(new Date()).getTime(),_kp=0,_sW=screen.width;function _fC(_u){_aT=_sp+',\\/,\\.,-,_,'+_rp+',%2F,%2E,%2D,%5F';_aA=_aT.split(',');for(i=0;i<5;i++){eval('_u=_u.replace(/'+_aA[i]+'/g,_aA[i+5])')}return _u};function O_LC(){_w.open('https://secure.opinionlab.com/ccc01/comment_card.asp?time1='+_tm+'&time2='+(new Date()).getTime()+'&prev='+_fC(escape(_hr))+'&referer='+_fC(_ht)+'&height='+_sH+'&width='+_sW+'&custom_var='+custom_var,'comments','width=535,height=192,screenX='+((_sW-535)/2)+',screenY='+((_sH-192)/2)+',top='+((_sH-192)/2)+',left='+((_sW-535)/2)+',resizable=yes,copyhistory=yes,scrollbars=no')};function _fPe(){if(Math.random()>=1.0-_poE){O_LC();_poX=0.0}};function _fPx(){if(Math.random()>=1.0-_poX)O_LC()};window.onunload=_fPx;function O_GoT(_p){_d.write('<a href=\'javascript:O_LC()\'>'+_p+'</a>');_fPe()}

