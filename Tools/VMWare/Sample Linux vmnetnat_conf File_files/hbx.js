if (typeof URLobj == 'undefined') var URLobj = {};
URLobj.init = function(pathname) {
    this.pathname=(pathname)?pathname:document.location.pathname;

   /* logged in or out? */
    this.lcookie=getCookie("ObSSOCookie");
    this.prop6="";
    this.prop7=(this.lcookie && this.lcookie!="loggedout")?"Logged In":"Logged Out";  
    this.prop15="";
    
   /* international */
    this.pcookie=getCookie("pszGeoPreference");
    if (this.pcookie && this.pcookie!="") {
        if (this.pcookie.match(/^\w+$/)) {
            this.prop26=this.pcookie;
        } 
    }
    
    this.rcookie=getCookie("pszGeoPreference");
    if (this.rcookie && this.rcookie!="") {
        if (this.rcookie.match(/^\w+$/)) {
            this.prop31=this.rcookie;
        }
    }
    
    this.country=["de","fr","cn","jp","es","lasp","ru","tw","at","br","it","kr","se"];
    this.siteid=["vmwde","vmwfr","vmwcn","vmwjp","vmwes","vmwlasp","vmwru","vmwtw","vmwat","vmwbr","vmwit","vmwkr","se"];
    this.ccode="vmware";
    this.ccodeidx="undef";

   /* subdomain */
    this.host = new Array();
    this.host = document.location.host.split('.');
    if (this.host.length > 2) {
        if (this.host[1] != "vmware")
            this.subdomain=(this.host[0] != "www" && this.host[0] != "") ? this.host[1]+","+this.host[0] : this.host[1];
        else
            this.subdomain=this.host[0] || "www";
    } else if (this.host[0] != "vmware")
        this.subdomain=this.host[0];
    else
        this.subdomain="www";
        
//    this.subdomain = (this.host.length > 2) ? this.host[0]  : "www";

   /* path & pagename */
    this.pagename="";
    this.path = new Array();
    this.path = this.pathname.split('/');
    this.path.shift();
    this.file = this.path.pop() || "index.html";
    this.file = this.file.replace(/;?jsessionid.+$/i,"");	

   /* check for international site */
    for (var c=0; c<this.country.length; c++) {
        if (this.country[c]==this.path[0]) {
	    this.ccode=this.siteid[c];
	    this.ccodeidx=c;
	}
    }

    this.hier1=this.ccode+",";

   /* check for subdomain */
    if (this.subdomain && this.subdomain!="www")
        this.hier1+=this.subdomain+",";

   /* set s.heir1 */ 
    if (this.path.length > 0) {
	for (var i=0; i<this.path.length; i++) {
	    if (i==0) {
		if (this.ccodeidx!="undef" && this.country[this.ccodeidx]==this.path[i]) continue; 
		if (this.subdomain && this.subdomain==this.path[i]) continue;
	    }
	    this.hier1+=(this.path[i]+",");
        }
    } 

    this.hier1=this.hier1.replace(/,$/,"");

   /* parse query string */
    if (document.location.search) {
    	this.qs=document.location.search;
    	this.qs=this.qs.substring(1);
    	this.qspairs=new Array();
    	this.qspairs=this.qs.split('&');
    	this.qsnamevalue=new Array();
    	for (var i=0; i<this.qspairs.length; i++) {
            this.qsnamevalue=this.qspairs[i].split('=');
            this.qsnamevalue[0]=this.qsnamevalue[0].replace(/\+/, "_");
            this.qsnamevalue[0]=this.qsnamevalue[0].replace(/\./, "_");
            eval("this."+this.qsnamevalue[0]+"='"+this.qsnamevalue[1]+"';");
    	}
    }

   /* mysupport */
   if (this.pathname.match(/^\/mysupport\//)) {
   	if (this._pageLabel) 
   		this.file+=" : "+this._pageLabel;
   		
   	if (this.body_1_1_actionOverride && this.body_1_1_actionOverride.match('%2F'))
   		this.file+=" : "+this.body_1_1_actionOverride.split('%2F').pop();
   }
   
   /* licensing portal */
   if (this.pathname.match(/^\/licensing\//)) {
   	if (this.pageLabel) 
   		this.file+=" : "+this.pageLabel;
   }
   
   /* product evaluations */
    if (this.pathname.match(/^\/tryvmware\//)) {
	if (hbx.pn) {
	    hbx.pn=hbx.pn.replace(/\+/g," ");
	    this.file=hbx.pn;
        }	
    }

   /* downloads  */
    if (this.file=="download.do") {
	if (document.getElementsByName("downloadEulaForm")) {
	    if (this.downloadGroup) 
	        this.hier1+=(","+this.downloadGroup);
	    this.file="eula";
	}
    }

    if (this.file=="eula.do") {
	this.file=document.title;
    }

   /* virtual appliances */
    if (this.pathname.match("/appliances/directory/")) {
	if (this.pathname.match("/vmtn/")) this.hier1=this.hier1.replace(",vmtn","");
	if (this.pathname.match("/cat/")) 
	    this.hier1=this.ccode+",appliances,directory,cat";
	this.file=document.title;
	this.file=this.file.replace(/^Virtual Appliance Marketplace - /,"");
    }

   /* baynote internal search */
    if (this.subdomain=="search-www") {
	if (this.cc!="www") {
	    for (var i=0; i<this.country.length; i++) 
	        if (this.cc==this.country[i]) this.ccode=this.siteid[i];
	    
	    this.hier1=this.hier1.replace(/vmware/,this.ccode); 
	}

	if (this.adv==1)
            this.file="advanced search";
	else {
 	    if (this.q) 
 	    	this.prop6=this.q;
 	    
	    if (this.bn_if && this.bn_if!=0) {
	    	this.prop15=this.bn_if;
	    } else if (this.cc && this.cc!="" && this.cc!="www" && this.cc!="vmware") {
	    	this.prop15="VMware_Intl_"+this.cc;
	    } else {
	    	this.prop15="VMware_Global";
	    }
	    
	    this.file=(this.st && this.st>1)?("page "+(parseInt(this.st.charAt(0))+1)):"page 1";
        }
    }

   /* baynote internal search */
    if (this.subdomain=="search") {
    	if (this.q)
    	  this.prop6=this.q;
    	  
    	this.prop15 = (this.client && this.client!=0) ? this.client : "VMware_Global";
    	this.file=(this.st && this.st>1)?("page "+(parseInt(this.st.charAt(0))+1)):"page 1";
    }
    
   /* success stories */
    if (this.pathname.match("/a/customers/([0-9]+)?")) {
	this.hier1=this.hier1.replace(/a,customers,(\w+)(,\d+)?/,"customers,success stories,$1");
	if (this.hier1.match(/a,customers$/))
            this.hier1=this.hier1.replace(/a,customers/,"customers,success stories");
	this.file=this.file.replace(/\+/," ");	
    }

   /* customer videos */
   if (this.pathname.match("success_video.html")) {
   	this.hier1+=",success_video";
   	this.file=this.id;
   }
   
   /* investor relations */
    if (this.pathname.match("/phoenix.zhtml")) {
	if (this.p) this.hier1+=','+this.p;
	if (this.id) this.file=this.id;
    }

   /* knowledge base */
    if (this.subdomain=="kb") {
        this.hier1=this.hier1.replace(/,microsites/,"");
        if (this.externalId) {
	    this.hier1+=(","+this.file); 
	    this.file=this.externalId;
	} else if (this.pathname.match("/selfservice/(microsites/)?search(Entry)?.do") || (this.pathname.match("/selfsupport/s3portal.portal") && this._pageLabel=="s3Portal_page_knova_search")) {
            if (document.forms[0].id.match(/searchForm/)) {
                this.prop6=document.forms[0].searchString.value;
                this.prop15="Knova_Search";
             } else if(frames[0].document && frames[0].document.forms[0].searchString.value != "") {
                 this.prop6=frames[0].document.forms[0].searchString.value;
                 this.prop15="Knova_Search";
             }
        }
    }

   /* technical papers */
    if (this.pathname.match("/techresources/(cat/)?[0-9]+")) 
	this.file=document.title;

   /* vmworld2009 homepage */
   if (window.location.host.match("vmworld2009.com")&&(window.location.pathname=="/"||window.location.pathname=="/index.html"))
         this.hier1="vmware,conferences,2009";

   if (window.location.host.match("vmworld.com")) {
   	if (typeof sc-juid != "undefined")
   		this.prop43=sc-juid;
   }

   /* webcasts thank you */
   if (this.pathname.match("/a/webcasts/thankyou/recorded/(.+)$")) {
   	this.hier1 = this.hier1.replace(/,recorded$/, "");
   	this.file="recorded";
   }
   
   /* Eloqua confirmation pages */
   if (window.location.host.match(/info\.vmware\.com/)) {
   	if (typeof sc_conf_page != "undefined" && sc_conf_page == 1) {
         		this.events = "event28";
         		if (document.title == "VMWorld 2009 Pre-registration Confirmation")
         			this.file = document.title;
         }
   }

   /* Partner central */
   if ( typeof(sfPageName) != "undefined" ) {
	this.file += " : "+sfPageName;
   }
   
   /* set s.prop1-5 */
    this.hierarchy=new Array();
    this.hierarchy=this.hier1.split(",");
    for (var i=0; i<this.hierarchy.length; i++) {
       if (i <= 4)
           eval("this.prop"+(i+1)+"='"+this.hierarchy[i]+"';");
    } 

    for (var i=this.hierarchy.length; i<5; i++) {
        eval("this.prop"+(i+1)+"='"+this.hierarchy[this.hierarchy.length-1]+"';");
    }

   /* set page variables */
    this.pagename=this.hier1.replace(/,/g," : ");
    this.fullpagename=this.pagename+" : "+this.file;
    this.channel=this.prop1;
}

try {
var url = new URLobj.init();

/* You may give each page an identifying name, server, and channel on
 * the next lines. */
s.channel=url.channel
s.pageName=url.fullpagename
s.pageType=""
s.prop1=url.prop1
s.prop2=url.prop2
s.prop3=url.prop3
s.prop4=url.prop4
s.prop5=url.prop5
s.prop6=url.prop6
s.prop7=url.prop7
s.prop15=url.prop15
s.prop26=url.prop26
s.prop31=url.prop31

/* Conversion Variables */
s.campaign=""
s.events=url.events||""
/* Hierarchy Variables */
s.hier1=url.hier1
/************* DO NOT ALTER ANYTHING BELOW THIS LINE ! **************/
var s_code=s.t();if(s_code)document.write(s_code)

if(navigator.appVersion.indexOf('MSIE')>=0)document.write(unescape('%3C')+'\!-'+'-')

} catch(e) {
var sc_error = e
}

