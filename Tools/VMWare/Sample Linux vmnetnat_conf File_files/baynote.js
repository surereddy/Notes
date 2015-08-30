if(typeof(baynote_globals)=="undefined")var baynote_globals=new Object();function BNLog(){this.timeBase=new Date().getTime();this.lines=new Array();this.lastLine="";this.repCount=0;}
BNLog.prototype.log=function(str){if(str==this.lastLine){++this.repCount;return;}
if(this.repCount>0){this.lines.push("___ ABOVE REPEATED "+this.repCount+" TIME"+((this.repCount>1)?"S":""));}
this.lastLine=str;this.repCount=0;var elapsed=new Date().getTime()-this.timeBase
this.lines.push(elapsed+": "+str);}
BNLog.prototype.toString=function(){if(this.repCount>0){this.lines.push("___ ABOVE REPEATED "+this.repCount+" TIME"
+((this.repCount>1)?"S":""));this.lastLine="";this.repCount=0;}
return this.lines.join("\n");}
if(typeof(bnLog)=="undefined"){var bnLog=new BNLog();}
function BNCriticalSectionQueue(){this.waitList=new Object();this.lastId=0;}
BNCriticalSectionQueue.prototype.issueId=function(){return++this.lastId;}
BNCriticalSectionQueue.prototype.enqueue=function(id,item){this.waitList[id]=item;}
BNCriticalSectionQueue.prototype.getWaiter=function(id){return(id==null)?null:this.waitList[id];}
BNCriticalSectionQueue.prototype.firstWaiter=function(){return this.getWaiter(this.nextWaiterKeyAfter(null));}
BNCriticalSectionQueue.prototype.nextWaiterAfter=function(id){return this.getWaiter(this.nextWaiterKeyAfter(id));}
BNCriticalSectionQueue.prototype.nextWaiterKeyAfter=function(id){for(currKey in this.waitList){if(id==null)return currKey;if(id==currKey)id=null;}
return null;}
BNCriticalSectionQueue.prototype.nextPredecessor=function(target,start){for(var currWaiter=start;currWaiter!=null;currWaiter=this.nextWaiterAfter(currWaiter.id)){if(currWaiter.enter||(currWaiter.number!=0&&(currWaiter.number<target.number||(currWaiter.number==target.number&&currWaiter.id<target.id)))){return currWaiter;}}
return null;}
function BNCriticalSection(csQueue){this.csQueue=csQueue;this.debug=1;}
BNCriticalSection.prototype.enter=function(enterFunc){this.enterFunc=enterFunc;this.id=this.csQueue.issueId();this.csQueue.enqueue(this.id,this);this.enter=true;this.number=(new Date()).getTime();this.enter=false;this.attempt(this.csQueue.firstWaiter());}
BNCriticalSection.prototype.leave=function(){if(this.debug)bnLog.log("LEAVE "+this.id);this.number=0;}
BNCriticalSection.prototype.attempt=function(start){var nextReady=this.csQueue.nextPredecessor(this,start);if(nextReady!=null){if(this.debug)bnLog.log("WAIT "+this.id);var me=this;return setTimeout(function(){me.attempt(nextReady);},50);}
if(this.debug)bnLog.log("ENTER "+this.id);this.enterFunc();}
function BNResourceManager(){this.csQueue=new BNCriticalSectionQueue();this.critSec=null;this.debug=1;this.resources=new Object();this.waiting=new Object();}
BNResourceManager.prototype.getResource=function(rId){return this.resources[rId];}
BNResourceManager.prototype.loadResource=function(rId,rAddress,rType){if(typeof(this.resources[rId])!="undefined")return;this.resources[rId]=null;var critSec=new BNCriticalSection(this.csQueue);critSec.enter(function(){bnResourceManager.inject(rId,rAddress,rType,critSec);});}
BNResourceManager.prototype.inject=function(rId,rAddress,rType,critSec){this.critSec=critSec;if(this.debug)bnLog.log("INJECT "+this.critSec.id+" ("+rId+")");if(!rType||rType=="script"){var scriptTag1=document.createElement("script");scriptTag1.language="javascript";scriptTag1.src=rAddress;var head=document.getElementsByTagName("head");head[0].appendChild(scriptTag1);}
else if(rType=="img"){var img=document.createElement("IMG");var handler=function(){bnResourceManager.registerAndAddResource(rId,img);};if(img.addEventListener)img.addEventListener("load",handler,false);else if(img.attachEvent)img.attachEvent("onload",handler);else img["onload"]=handler;img.src=rAddress;}
else alert("Unexpected resource type to loadResource: "+rType);}
BNResourceManager.prototype.waitForResource=function(rId,callbackCode,rAddress,rType){with(this){if(getResource(rId)){this.runCallback(callbackCode);}
else{if(typeof(waiting[rId])=="undefined")waiting[rId]=new Array();var waitingList=waiting[rId];waitingList[waitingList.length]=callbackCode;if(rAddress)this.loadResource(rId,rAddress,rType);}}}
BNResourceManager.prototype.wakeUpWaiting=function(rId){with(this){var waitingList=waiting[rId];if(!waitingList)return;for(var i=0;i<waitingList.length;i++){if(waitingList[i]){var codeToEval=waitingList[i];waitingList[i]=null;if(this.debug&&codeToEval)bnLog.log("CALLBACK "+rId+": "+codeToEval);this.runCallback(codeToEval);}}}}
BNResourceManager.prototype.registerAndAddResource=function(rId,resource){if(this.debug)bnLog.log("REGISTER "+this.critSec.id+" ("+rId+")");this.resources[rId]=resource;this.wakeUpWaiting(rId);this.critSec.leave();setTimeout("bnResourceManager.wakeUpWaiting('"+rId+"')",5000);}
BNResourceManager.prototype.registerResource=function(rId){this.registerAndAddResource(rId,true);}
BNResourceManager.prototype.runCallback=function(callback){if(typeof(callback)=="string")eval(callback);else if(typeof(callback)=="function")callback();else alert("Invalid callback, type="+typeof(callback));}
if(typeof(bnResourceManager)=="undefined"){var bnResourceManager=new BNResourceManager();}
function BNSystem(){this.testServer=null;}
BNSystem.prototype.getCookieValue=function(cookieName){var cookieValue=document.cookie;var cookieStartsAt=cookieValue.indexOf(" "+cookieName+"=");if(cookieStartsAt==-1)cookieStartsAt=cookieValue.indexOf(cookieName+"=");if(cookieStartsAt==-1)cookieValue=null;else{cookieStartsAt=cookieValue.indexOf("=",cookieStartsAt)+1;var cookieEndsAt=cookieValue.indexOf(";",cookieStartsAt);if(cookieEndsAt==-1)cookieEndsAt=cookieValue.length;cookieValue=unescape(cookieValue.substring(cookieStartsAt,cookieEndsAt));}
return cookieValue;}
BNSystem.prototype.setCookie=function(cookieName,cookieValue,cookiePath,cookieExpires,cookieDomain){cookieValue=escape(cookieValue);if(cookieExpires=="NEVER"){var nowDate=new Date();nowDate.setFullYear(nowDate.getFullYear()+500);cookieExpires=nowDate.toGMTString();}
else if(cookieExpires=="SESSION")cookieExpires="";if(cookiePath!="")cookiePath=";Path="+cookiePath;if(cookieExpires!="")cookieExpires=";expires="+cookieExpires;if(!cookieDomain)cookieDomain=(baynote_globals.cookieDomain)?baynote_globals.cookieDomain:"";if(cookieDomain!="")cookieDomain=";domain="+cookieDomain;var cookieStr=cookieName+"="+cookieValue+cookieExpires+cookiePath+cookieDomain;if(cookieStr.length>4096)return false;document.cookie=cookieStr;return true;}
BNSystem.prototype.removeCookie=function(cookieName,cookieDomain){this.setCookie(cookieName,"","/","Mon, 1 Jan 1990 00:00:00",cookieDomain);}
BNSystem.prototype.getURLParam=function(name,url){if(!url)var url=window.location.href;var regex=new RegExp("[\\?&]"+name+"=([^&#]*)");var match=regex.exec(url);if(!match)return null;else return match[1];}
BNSystem.prototype.getTestServer=function(){if(this.testServer!=null)return this.testServer;var testServer=this.getURLParam("bn_test");if(testServer)this.setCookie("bn_test",testServer,"/","SESSION");else if(testServer=="")this.removeCookie("bn_test");else{testServer=this.getCookieValue("bn_test");if(!testServer)testServer="";}
this.testServer=testServer;return testServer;}
if(typeof(bnSystem)=="undefined"){var bnSystem=new BNSystem();}
function BNTag(previousTag){if(previousTag){this.id=previousTag.id+1;this.server=previousTag.server;this.customerId=previousTag.customerId;this.code=previousTag.code;}
else this.id=0;this.attrs=new Object();this.css=new Object();}
BNTag.prototype.getCommonResourceId=function(){return"Common";}
BNTag.prototype.getCommonResourceAddress=function(tag){return(this.server+"/baynote/tags2/common.js");}
BNTag.prototype.getFailsafeResourceId=function(){return"Failsafe";}
BNTag.prototype.getFailsafeResourceAddress=function(){return(this.server+"/baynote/customerstatus2?customerId="+this.customerId+"&code="+this.code+"&x="+this.id+(new Date().getTime()));}
BNTag.prototype.show=function(parentElemId){if(this.id==0)document.write("<span id='bn_placeholder_global'></span>");this.placeHolderId="bn_placeholder"+this.id;var placeHolderType;if(this.placeHolderElement)placeHolderType=this.placeHolderElement;else placeHolderType=this.popup?"span":"div";if(parentElemId){var placeHolder=document.createElement(placeHolderType);placeHolder.id=this.placeholderId;document.getElementById(parentElemId).appendChild(placeHolder);}
else document.write("<"+placeHolderType+" id='"+this.placeHolderId+"'></"+placeHolderType+">");window["bn_tags"][this.id]=this;var testServer=bnSystem.getTestServer();if(testServer){var reValidTestServer=new RegExp("^https?://[^/]*\.baynote\.(com|net)(:\d+)?(/.*)?");if(reValidTestServer.test(testServer))this.server=testServer;else alert("Ignoring invalid test server \""+testServer+"\"");}
this.showWhenReady(this);baynote_tag=new BNTag(this);}
BNTag.prototype.showWhenReady=function(tag){var failsafeId=this.getFailsafeResourceId();if(!bnResourceManager.getResource(failsafeId)){bnResourceManager.waitForResource(failsafeId,function(){tag.showWhenReady(tag);},this.getFailsafeResourceAddress(),"img");return;}
var commonId=this.getCommonResourceId();if(!bnResourceManager.getResource(commonId)){bnResourceManager.waitForResource(commonId,function(){tag.showWhenReady(tag);},this.getCommonResourceAddress(),"script");return;}
bnTagManager.show(tag.id);}
BNTag.prototype.noshow=function(){window["bn_tags"][this.id]=this;baynote_tag=new BNTag(this);}
BNTag.prototype.getParam=function(name,defaultValue){var value=this[name];if(typeof(value)=="undefined"||value==null)return defaultValue;else return value;}
if(typeof(baynote_tag)=="undefined"){window["bn_tags"]=new Array();var baynote_tag=new BNTag(null);}

// Baynote Observer code

baynote_globals.cookieDomain = "vmware.com";
baynote_tag.customerId = "vmware";

if (document.location.href.match("/cn/"))
  {baynote_tag.code="cn";}
else if (document.location.href.match("/de/"))
  {baynote_tag.code="de";}
else if (document.location.href.match("/es/") || document.location.href.match("/lasp/"))
  {baynote_tag.code="es";}
else if (document.location.href.match("/fr/"))
  {baynote_tag.code="fr";}
else if (document.location.href.match("/jp/") || document.location.href.match("/ja/"))
  {baynote_tag.code="jp";}
else
  {baynote_tag.code="www";}
  
var bn_location_href = window.location.href;

if (bn_location_href.indexOf("https://") == 0) {
	baynote_tag.server = "https://" + baynote_tag.customerId + "-" + 
						baynote_tag.code + ".baynote.net";
} else {
	baynote_tag.server = "http://" + baynote_tag.customerId + "-" + 
						baynote_tag.code + ".baynote.net";
}

if(bn_location_href.indexOf("http://kb.vmware.com/selfservice/search.do") != -1 || bn_location_href.indexOf("http://kb.vmware.com/selfservice/microsites/searchEntry.do") != -1){
	baynote_tag.query = baynote_getQueryFromInput("searchString");
}

if(bn_location_href.indexOf("http://kb.vmware.com") == 0){
	tmpTitle = baynote_getQueryFromInput("documentTitle");
	if(baynote_isNotEmpty(tmpTitle))
		baynote_tag.title = tmpTitle;
}

baynote_globals.cookieSubDomain = baynote_tag.code;
baynote_tag.type="baynoteObserver";
baynote_tag.summary=baynote_getSummaryFromParagraph();
baynote_tag.show();

function baynote_getQueryFromInput(inputName){
	var inputs = document.getElementsByTagName("input");
	if(!inputs) return;
	for (var i = 0; i < inputs.length; i++) {
		if (!inputs[i]) return;
		if (inputs[i].name == inputName) {
			return inputs[i].value;
		}
	}
}

/**
 *	baynote_getSummaryFromParagraphs()
 *
 *	Get a usable summary from <p> tags in a page.  It will build a 
 *	summary at of between 80 and 180 characters.  All HTML will be
 *	stripped out.
 *
 */
function baynote_getSummaryFromParagraph() {
	var summary = "";
	var paragraphs = document.getElementsByTagName("p");
	if (!paragraphs) return "";
	
	for (var i = 0; i < paragraphs.length; i++) {
		if (!paragraphs[i]) return "";
		if (paragraphs[i].innerHTML != "") {
			if (summary != "") summary = summary + " ";
			summary = summary + baynote_removeHtml(paragraphs[i].innerHTML);
			if (summary.length > 180) summary = summary.substring(0,180);
		}
		if (summary.length > 80) return summary;
	}
	return summary;
}

/**
 *	baynote_removeHtml(raw)
 *
 *	Clean up a string by removing any HTML or patial HTML, new lines,
 *	and spaces from both ends.
 *
 */
function baynote_removeHtml(raw) {
	if (!raw) return;
	raw = raw.replace(/\<[^>]*\>/g, "");
	raw = raw.replace(/\<.*/, "");
	raw = raw.replace(/\&nbsp;/g, " ");
	raw = raw.replace(/^\s+/, "");
	raw = raw.replace(/\s+$/, "");
	raw = raw.replace(/\n/g, " ");
	return raw;
}

function baynote_isNotEmpty(checkVar) {
	return (typeof(checkVar) != "undefined") && (checkVar != null) && (checkVar != "");
}
