

var clicked=false;
var mruListCount=0;
var extraOp='';var supportedSites=[];var currentSiteIndex=0;var avlCatalogs=[];var currentCatSelIndx=-1;var optContainer=null;var isIE6=false;var prevElement=null;
function arrow_over(mousein){if(mousein){if(clicked){$("#arrowimg").get(0).src=arrowImage["hotup"];}else{$("#arrowimg").get(0).src=arrowImage["hotdown"];}}else{if(clicked){$("#arrowimg").get(0).src=arrowImage["up"];}else{$("#arrowimg").get(0).src=arrowImage["down"];}}}
function showOrHideSearchDetails(fromButton){if($("#SearchDetails").get(0).style.display=="block"){$("#showhide").get(0).innerHTML=showoptions;if(fromButton){$("#arrowimg").get(0).src=arrowImage["hotdown"];}else{$("#arrowimg").get(0).src=arrowImage["down"];}$("#SearchDetails").get(0).style.display="none";clicked=false;}else{$("#showhide").get(0).innerHTML=hideoptions;if(fromButton){$("#arrowimg").get(0).src=arrowImage["hotup"];}else{$("#arrowimg").get(0).src=arrowImage["up"];}$("#SearchDetails").get(0).style.display="block";clicked=true;
 try{$('#frmaSrch').get(0).mode.value="a"}catch(e){}}}function submitSimpleSearch(url,query){if(!url||url.length==0){url=GetCurrentUrl();}if($("#frmsrch").attr('action').indexOf(url)>-1){srch_setcookieval("lquery",UnicodeFixup(escape(jQuery.trim(query))));StatsDotNet.eventCollectionId=SetLogCollectionBit(StatsDotNet.eventCollectionId,6);$("#frmsrch").submit();return;}StatsDotNet.OptionCollectionId=SetLogCollectionBit(StatsDotNet.OptionCollectionId,33);StatsDotNet.targetUrl=url+query;if(window.encodeURIComponent){query=encodeURIComponent(query);}else{query=OutputEncoder_EncodeUrl(query);}document.location.href=url+query;}
function SubmitSearch(frm){
 if($('#spidbox').get(0)&&$('#spidbox').get(0).selectedIndex<mruListCount){logOptionId(34);}elem=$('#frmaSrch').get(0).query;srch_setcookieval("lquery",UnicodeFixup(escape(jQuery.trim(elem.value))));var pName="";prdelem=$('#spidbox').get(0);if(prdelem&&prdelem.options){var pvalue=prdelem.options[prdelem.selectedIndex].value;if(pvalue!=""&&pvalue!="global"&&pvalue!="myprod"){pName=" "+prdelem.options[prdelem.selectedIndex].text;srch_setcookieval("gssSPID",pvalue);}}if($('[name=catalog]').get(0)!=null){for(s=0;s<$('[name=catalog]').length;s++){if($('[name=catalog]').get(s).type!="select-one"){if($('[name=catalog]').get(s).checked){var msurl;var qry=frm.query.value+pName;qry=jQuery.trim(qry);if(window.encodeURIComponent){qry=encodeURIComponent(qry);}else{qry=OutputEncoder_EncodeUrl(qry);}if($('[name=catalog]').get(s).value=='msc'){StatsDotNet.OptionCollectionId=SetLogCollectionBit(StatsDotNet.OptionCollectionId,33);msurl=mscomurl+qry;document.location.href=msurl;return false;}else if($('[name=catalog]').get(s).value=='msn'){StatsDotNet.OptionCollectionId=SetLogCollectionBit(StatsDotNet.OptionCollectionId,33);msurl=msnurl+qry;StatsDotNet.targetUrl=msurl;document.location.href=msurl;return false;}else{srch_setcookieval('adcatalog',escape($('[name=catalog]').get(s).value));}}}else{var catalogList=$('[name=catalog]');if(catalogList&&catalogList.options){var pvalue=catalogList.options[catalogList.selectedIndex].value;if(pvalue!=""){srch_setcookieval('adcatalog',pvalue);}}}}}else{
 var catalogList=$('#catalog').get(0);if(catalogList&&catalogList.options){var pvalue=catalogList.options[catalogList.selectedIndex].value;if(pvalue!=""){srch_setcookieval('adcatalog',pvalue);}}}SaveSrchState(true);StatsDotNet.eventCollectionId=SetLogCollectionBit(StatsDotNet.eventCollectionId,7);PageSubmit=1;}function SaveSrchState(saveQuery){if(PageSubmit=='1'){return;}var elem;
 if(saveQuery===true){elem=$('#frmaSrch').get(0).query;srch_setcookieval("lquery",UnicodeFixup(escape(jQuery.trim(elem.value))));}
 elem=$('[name=catalog]');
 if(elem&&elem.length&&elem.type!="select-one"){SaveRadioState(elem,"catalog");}
 elem=$('#frmaSrch').get(0).res;SaveSelectState(elem,"res");var optcookie="";var optresource="";
 if(document.getElementsByName){elem=document.getElementsByName("ast");for(i=0;i<elem.length;i++){var optrow=$('#'+elem[i].value+'row').get(0);if(optrow&&(optrow.style.display=="block"||optrow.style.display=="")){if(elem[i].checked){optcookie+="ad"+elem[i].value+"=1|";optresource+=elem[i].value+",";}else{optcookie+="ad"+elem[i].value+"=0|";}}else{elem[i].value="";}}}if(optElems){options=optElems.split('|');if(options!=null){for(i=0;i<options.length;i++){elem=$('#'+options[i].toString()).get(0);if(elem){var radioCatalog=$('#'+elem.attributes['_parentid'].value).get(0);if(radioCatalog.checked){if(elem.checked){optcookie+="ad"+options[i]+"=1|";optresource+=options[i]+",";}else{optcookie+="ad"+options[i]+"=0|";}}}}}}srch_setcookieval("adresource",optresource);srch_setcookieval("adopt",optcookie);}function InitSrch(){if(null==$('#catalog').get(0)){
 
 var el=document.createElement('span');el.innerHTML="<input type='hidden' id='catalog' name='catalog' />";var frm=$('#frmsrch').get(0);frm.appendChild(el);}
 var el=$('#gsfx_bsrch_query').get(0);tval=fetchcookieval("lquery");if(tval&&tval!==''&&tval!=='blank'){if($(el).hasClass('siteseltxt')){$(el).removeClass('siteseltxt');}el.value=unescape(UnicodeFixup(jQuery.trim(tval)));setKeyBit(el);}else{
 $(el).bind("keypress paste",setKeyBit);SetInitText(el);}if(avlCatalogs.length==0)
 return;
 var cats=$('#gsfx_bsrch_catsel a');tval=fetchcookieval("adcatalog");if(tval){
 tval=unescape(tval);var i=0
 for(;i<avlCatalogs.length;i++){if(avlCatalogs[i].Value==tval){$('#gsfx_cat_sel_div'+i).click();break;}}if(i==avlCatalogs.length){ChangeCatSel(0);}}else{ChangeCatSel(0);}}function SaveSimpleSearch(url){var f=$('#frmsrch').get(0);
 var el=f.query;if($(el).hasClass('siteseltxt')){$(el).val('');}submitSimpleSearch(url,$(el).val());return false;}
function FillProductList(lcidprodlist,lcidmyprodlist,myprod){var elem=$("#productfilter").get(0);if(elem){var producthtml='<select name="spid" id="spidbox" onchange="ProductChanged(this);">';if(myprod=='false'||myprod=='False'){if(extraOp&&extraOp!='')producthtml+=extraOp;if(lcidprodlist&&lcidprodlist!='')producthtml+=lcidprodlist;}else{if(lcidmyprodlist&&lcidmyprodlist!='')producthtml+=lcidmyprodlist;}producthtml+="</select>";elem.innerHTML=producthtml;}var prd=$('#spidbox').get(0);if(!prd){var advforms=$('#frmaSrch').get(0);if(advforms.length>=2){InitSelect($('#spidbox').get(0),"SPID","gss");}}if(prd&&prd.options&&prd.options.length>0){InitSelect(prd,"SPID","gss");var value=prd.options[prd.selectedIndex].value
 DisplayProductFilter(value);}}function InitASrch(){var el;var f=$('#frmaSrch').get(0);var qstr=(queryString['query'])? queryString['query'] : '';if(qstr==''){
 el=f.query;var tval=fetchcookieval("lquery");if(tval){el.value=unescape(UnicodeFixup(jQuery.trim(tval)));setKeyBit(el);}else{$(el).bind("keypress paste",setKeyBit);}}
 multicatalog=false;el=f.catalog;if(el!=null){if(el.length&&el.type!="select-one"){InitRadio(el,"catalog");multicatalog=true;}else{InitSelect(el,"catalog","ad");}var alreadyChecked=false;for(i=0;i<el.length;i++){if(el[i].checked){alreadyChecked=true;}}if(!alreadyChecked){el[0].checked=true;}}
 InitSelect(f.res,"res","ad");
 var optcookie=new OptionCookie();if(document.getElementsByName){el=document.getElementsByName("ast");for(j=0;j<el.length;j++){tval=optcookie["ad"+el[j].value];if(tval){if(tval=='0')el[j].checked=false;else el[j].checked=true;}}}if(optElems){opt=optElems.split('|');for(j=0;j<opt.length;j++){el=$('#'+opt[j].toString()).get(0);if(el){el._prevvalue=null;tval=optcookie["ad"+opt[j]];if(tval){if(tval=='0')el.checked=false;else el.checked=true;}}}}}function InitSelect(elem,name,prefix,isScanned){if(elem!=null){tval=fetchcookieval(prefix+name);if(name=="SPID"){if(!tval)tval="global";}if(tval){for(i=0;i<elem.options.length;i++){if(elem.options[i].value==unescape(tval)){elem.selectedIndex=i;break;}}}}}
function ProductChanged(elem){var value=elem.options[elem.selectedIndex].value;DisplayProductFilter(value);if(value.indexOf("more_")>-1){var url="/selectindex/default.aspx?target=search&sreg="+value.substr(5)+"&adv=1";var fr=queryString['fr'];if(fr==null)
 fr=queryString['FR'];if(fr=='1')
 url+='&fr=1';document.location.href=url;}}
function SelectRadio(elem,tval){if(tval){for(i=0;i<elem.length;i++){if(elem[i].value==unescape(tval)){elem[i].checked=true;elem[i].click();break;}}}}
function GetSelectedValue(elem){for(i=0;i<elem.length;i++){if(elem[i].checked){return escape(elem[i].value);}}return '';}
function InitRadioEx(elem,name){tval=fetchcookieval("ad"+name);if(tval){for(i=0;i<elem.length;i++){if(elem[i].value==unescape(tval)){if(!elem[i].disabled){elem[i].checked=true;elem[i].click();break;}}}}}var personalizelink='';
function EnableSrchOptions(enable){if(enable){enableAll($('#divResourceItems').get(0));$('#res').get(0).disabled=false;}else{disableAll($('#divResourceItems').get(0));$('#res').get(0).disabled=true;}}
function disableAll(elem){if(elem==null||elem=='undefined'||elem.tagName==null||elem.tagName=='undefined')
 return;elem.disabled=true;for(var i=0;i<elem.childNodes.length;i++){disableAll(elem.childNodes[i]);}}
function enableAll(elem){if(elem==null||elem=='undefined'||elem.tagName==null||elem.tagName=='undefined')
 return;elem.disabled=false;for(var i=0;i<elem.childNodes.length;i++){enableAll(elem.childNodes[i]);}}
function SearchLiveCatalog(frm,catalog){if(catalog==1)
 StatsDotNet.OptionCollectionId=SetLogCollectionBit(StatsDotNet.OptionCollectionId,53);if(catalog==2)
 StatsDotNet.OptionCollectionId=SetLogCollectionBit(StatsDotNet.OptionCollectionId,54);$('#lsc').get(0).value=catalog;if(catalog==2){
 var catalogList=$('#catalog').get(0);if(catalogList&&catalogList.options){var pvalue=catalogList.options[catalogList.selectedIndex].value;if(pvalue!=""){srch_setcookieval('adcatalog',pvalue);}}var msurl,qry;var elem=$('#frmaSrch').get(0).query;qry=$('#frmaSrch').get(0).query.value;qry=jQuery.trim(qry);if(window.encodeURIComponent){qry=encodeURIComponent(qry);}else{qry=OutputEncoder_EncodeUrl(qry);}msurl=msnurl+qry;document.location.href=msurl;return false;}SubmitSearch(frm);$('#frmaSrch').get(0).submit();}
function ddlCatalog_change(ddlCatalog,acEnabled){var changeCatalogSel=false;var divVisibleCatalog=null;for(var i=0;i<ddlCatalog.length;i++){var lcid=ddlCatalog[i].value.substring(5);var div=$('#div'+lcid).get(0);if(div!=null){if(ddlCatalog.value==ddlCatalog[i].value){divVisibleCatalog=div;div.style.display='block';var inputs=div.getElementsByTagName('input');for(var j=0;j<inputs.length;j++){if(inputs[j].type=='checkbox'){if(inputs[j]._prevvalue!=null)
 inputs[j].checked=(inputs[j]._prevvalue=='true');}}}else{var inputs=div.getElementsByTagName('input');for(var j=0;j<inputs.length;j++){if(inputs[j].type=='radio'){if(inputs[j].checked)
 changeCatalogSel=true;}else if((inputs[j].type=='checkbox')&&(div.style.display=='block')){
 
 inputs[j]._prevvalue=(inputs[j].checked ? 'true' : 'false');inputs[j].checked=false;}}div.style.display='none';}}}if(acEnabled){
 changeLcidForSelect(ddlCatalog,'query',ddlCatalog.value,ddlCatalog.selectedIndex+'');}if((divVisibleCatalog!=null)&&changeCatalogSel){
 var radio=divVisibleCatalog.getElementsByTagName('input')[0];radio.checked=true;radio.onclick();}}function gsfx_bsrch_changeCatSelection(index){ChangeCatSel(index);srch_setcookieval('adcatalog',escape(avlCatalogs[index].Value));}function ChangeCatSel(index){$('#catalog').get(0).value=avlCatalogs[index].Value;if(index==currentCatSelIndx)
 return;$('#gsfx_cat_sel_div'+index).css({'font-weight': 'bold','cursor': 'default'});$('#gsfx_cat_sel_img'+index).css({'display': 'block'});$('#gsfx_cat_sel_div'+currentCatSelIndx).css({'font-weight': 'normal','cursor': 'pointer'});$('#gsfx_cat_sel_img'+currentCatSelIndx).css({'display': 'none'});currentCatSelIndx=index;}function selectDropDownItem(ddl,value,func){for(var ii=0;ii<ddl.length;ii++){if(ddl[ii].value==value){ddl[ii].selected=true;if(func!=null)
 func(ddl);return ii;}}return -1;}
function CatalogOption_click(src,scopeLCID,enableScopeOptions){try{DisplayScopeOptions('adv',scopeLCID);EnableSrchOptions(enableScopeOptions);
 var catalogOptions=$('input');for(var i=0;i<catalogOptions.length;i++){var parentid=catalogOptions[i].attributes["_parentid"];
 if((parentid!=null)&&(parentid!='undefined')&&(parentid!='')){if(parentid.value==src.id){
 catalogOptions[i].disabled=false;var hrefs=catalogOptions[i].parentNode.getElementsByTagName('a');for(var index=0;index<hrefs.length;index++)
 enable_link(hrefs[index]);}else{
 catalogOptions[i].disabled=true;var hrefs=catalogOptions[i].parentNode.getElementsByTagName('a');for(var index=0;index<hrefs.length;index++)
 disable_link(hrefs[index]);}}}}catch(e){}}function DisplayScopeOptions(mode,lcid){if(mode=="adv"){var cat=$('#frmaSrch').find('[name=catalog]');var selected=0;for(i=0;i<cat.length;i++){if(cat[i].checked){selected=i;break;}}var exclude=cat[selected].getAttribute("exclude");if(optElems){var x=optElems.split('|');for(i=0;i<x.length;i++){var optionrow=$('#'+x[i]+"row").get(0);if(optionrow){optionrow.style.display="block";}}}if(exclude!=null&&exclude!='undefined'){x=exclude.split('|');for(i=0;i<x.length;i++){var optionrow=$('#'+x[i]+"row").get(0);if(optionrow){optionrow.style.display="none";}}}}if((lcid!='')&&(lcid!=null)){FillProductList(lcid,null,'false');}
 var show=false;var divs=$('#divResourceItems div');for(i=0;i<divs.length;i++){if('none'!=divs[i].style.display){show=true;break;}}$('#divresources').get(0).style.display=(show ? 'block' : 'none');}

function disable_link(elem){if((elem.style.visibility=='visible')||(elem.style.visibility=='')){var span=document.createElement('span');span.name="span_placeholder";span.innerHTML=elem.innerHTML;span.style.color="gray";elem.parentNode.insertBefore(span,elem);elem.style.visibility='hidden';}}function enable_link(elem){if(elem.style.visibility=='hidden'){var spans=elem.parentNode.getElementsByTagName('span');for(var i=0;i<spans.length;i++)
 if(spans[i].name='span_placeholder')
 elem.parentNode.removeChild(spans[i]);elem.style.visibility='visible';}}function SaveRadioState(elem,name){for(i=0;i<elem.length;i++){if(elem[i].checked){srch_setcookieval('ad'+name,escape(elem[i].value));}}}function SaveSelectState(elem,name){if(elem&&elem.options){srch_setcookieval('ad'+name,escape(elem.options[elem.selectedIndex].value));}}
function DisplayProductFilter(value){var prdcol=$("#pwtcol").get(0);var prdcol1=$("#pwtcol1").get(0);var prdimg=$("#pwtimg").get(0);if(prdcol&&prdcol1&&prdimg){if(value==""||value=="global"){prdcol.style.display="none";prdcol1.style.display="none";prdimg.style.display="none";}else{if(prdcol.style.display!="block"&&prdcol.style.display!=""){prdcol.style.display="";prdcol1.style.display="";prdimg.style.display="";}}}
 var elem=$('#spidbox').get(0);$('#topbarvalue').get(0).innerHTML=elem[elem.selectedIndex].innerHTML;}function Site(name,url,selected){var retVal={Name : name,Url : url,Selected : selected};return retVal;}function Catalog(name,value,selected){var retVal={Name: name,Value: value,Selected: selected};return retVal;}function GetCurrentUrl(){if(supportedSites&&supportedSites.length>0){return supportedSites[currentSiteIndex].Url;}}function CreateSearchOptions(id,acWidth){optContainer=document.createElement('DIV');optContainer.id='gsfx_bsrch_options';var optSubContainer=document.createElement('DIV');optSubContainer.id='gsfx_bsrch_options_subcntr';var optCol1_temp=document.createElement('DIV');optCol1_temp.className='gsfx_srchoptimg_cotnr'

 var optCol_temp=document.createElement('DIV');optCol_temp.className='gsfx_optsub_cotnr'
 
 var optCol2_temp=document.createElement('DIV');optCol2_temp.id='gsfx_srchsitename_div';optCol2_temp.className='gsfx_srchsitename_cotnr';var imgCheck=document.createElement('IMG');imgCheck.id='gsfx_bsrch_sitesel_img';imgCheck.src='/library/images/support/cn/ss_check.png';imgCheck.className='gsfx_bsrch_chkimg';for(var i=0;i<supportedSites.length;i++){var optCol2=optCol2_temp.cloneNode(true);optCol2.id+=i;optCol2.innerHTML=supportedSites[i].Name

 var optCol1=optCol1_temp.cloneNode(true);var imgEl=imgCheck.cloneNode(true);imgEl.id+=i;optCol1.appendChild(imgEl);var opt=optCol_temp.cloneNode(true);var localIndex=i;$(opt).bind("click",{index: localIndex},ChangeSiteSelection);if(supportedSites[i].Selected){imgEl.style.display='block';optCol2.style.fontWeight='bold';opt.style.cursor='default';}opt.appendChild(optCol1);opt.appendChild(optCol2);optSubContainer.appendChild(opt);}$(optSubContainer).width($('#gsfx_bsrch_divQuery').get(0).offsetWidth+2);optContainer.appendChild(optSubContainer);var isRTL=$('html').css('direction')=='rtl';var ie6BgDiv=$('#gsfx_bsrch_bg_ie6').get(0);isIE6=$('#gsfx_bsrch_bg_ie6').length>0;if(isIE6){if(isRTL){ie6BgDiv.style.left=$('#gsfx_bsrch_bg').get(0).offsetLeft+4;}else{ie6BgDiv.style.left=$('#gsfx_bsrch_bg').get(0).offsetLeft - 2;}ie6BgDiv.style.display='block';}var acDiv=$('#'+id).get(0);if(acDiv){acDiv.appendChild(optContainer);$('#'+id+' > :first-child').css({'border-top':'0px','border-bottom':'0px','border-color':'#336b95','margin-top':'0px'});if(isRTL){$('#'+id+' > :first-child').css({'background': '#ffffff url(\'/library/images/support/cn/ss_section3.png\') right top no-repeat','margin-right': '-1px'});}else{$('#'+id+' > :first-child').css({'background': '#ffffff url(\'/library/images/support/cn/ss_section2.png\') left top no-repeat'});}$('#'+id).css({'margin-left': '-1px','height': '0px'});var acObj=MS.Support.AC ? MS.Support.AC.ACArrayEl('gsfx_bsrch_query'): null;if(acObj){acObj.options.handleResize=ResizeSiteOpts;acObj.options.acMinWidth=acWidth;}}else{$(optContainer).insertBefore('#gsfx_bsrch_query');if(isRTL){$(optContainer).css({'position':'relative','top': $('#gsfx_bsrch_divQuery').get(0).offsetHeight+'px','float': 'right'});}else{$(optContainer).css({'top': $('#gsfx_bsrch_divQuery').get(0).offsetHeight+'px','left': '-1px'});}}$('#gsfx_bsrch_query').bind('focus',function(event){HandleQueryFocus(event);});$('#gsfx_bsrch_query').bind('click.srchsiteopts',function(event){HandleQueryFocus(event);$('#gsfx_bsrch_query').unbind('click.srchsiteopts');});$('#gsfx_bsrch_query').bind('blur',function(event){HandleQueryBlur(event);});$('#gsfx_bsrch_query').bind('keydown.srchsiteopts',function(event){HandleKeydown(event);});$(document).bind('click.srchsiteopts',function(event){SimpleSearchClickHandler(event);});}function SimpleSearchClickHandler(event){if(!event||!event.target){return;}var targetEl=event.target;if($(targetEl).hasClass('gsfx_img_png')){return;}var searchContainer=$('#gsfx_bsrch_divQuery').get(0);var isSearchElement=(targetEl==searchContainer);if(!isSearchElement)
 isSearchElement=IsChild(targetEl,searchContainer);if(isSearchElement){HideLangSel();$(optContainer).css({'display': 'block'});}else{$(optContainer).css({'display': 'none'});}if(avlCatalogs.length==0){return;}if(targetEl==$('#gsfx_cat_sel').get(0)){return;}var isCatSelChild=IsChild(targetEl,$('#gsfx_cat_sel').get(0),3);if(!isCatSelChild){HideLangSel();}}function IsChild(targetEl,parentEl,nestingLimit){if(!targetEl){return false;}var isChildElement=false;if(!nestingLimit)
 nestingLimit=6;var parent=targetEl.parentNode;var level=0;var isSearchElement=false;while(parent&&nestingLimit>level){if(parent==parentEl){isChildElement=true;break;}parent=$(parent).parent().get(0);level++;}return isChildElement;}function ResizeSiteOpts(listDiv){if(listDiv.style.visibility!='hidden'&&listDiv.childNodes.length>0){optContainer.style.top=$(listDiv).get(0).clientHeight;}else{optContainer.style.top=0;}if(listDiv.style.visibility!='hidden')
 $(optContainer).css({'display': 'block'});else if($(document).get(0).activeElement!=$('#gsfx_bsrch_query').get(0))
 $(optContainer).css({'display': 'none'});}function HandleKeydown(event){if(event.keyCode==9){if($(optContainer).prev().get(0)==null||$(optContainer).prev().css('visibility')=='hidden'){$(optContainer).css({'display': 'none'});return;}}if(event.keyCode==13)return;HandleQueryFocus(event);}function HandleQueryFocus(event){if(event.type=='focus'&&prevElement==event.target){return;}if($(event.target).hasClass('siteseltxt')){$(event.target).removeClass('siteseltxt')
 $(event.target).val('');}HideLangSel();$(optContainer).css({'display': 'block'});}function HandleQueryBlur(event){prevElement=document.activeElement;SetInitText(event.target);}function SetInitText(element){if(jQuery.trim($(element).val()).length==0||jQuery.trim($(element).val()).length>0&&$(element).hasClass('siteseltxt')){$(element).addClass('siteseltxt');$(element).val(supportedSites[currentSiteIndex].Name);}else{$(element).removeClass('siteseltxt');}}function ChangeSiteSelection(event){var index=event.data.index;if(supportedSites[index].Selected){return;}$('#gsfx_bsrch_sitesel_img'+index).css({'display': 'block'});$('#gsfx_srchsitename_div'+index).css({'font-weight':'bold'});$('#gsfx_srchsitename_div'+index).parent().css({'cursor': 'default'});$('#gsfx_bsrch_sitesel_img'+currentSiteIndex).css({'display': 'none'});$('#gsfx_srchsitename_div'+currentSiteIndex).css({'font-weight': 'normal'});$('#gsfx_srchsitename_div'+currentSiteIndex).parent().css({'cursor': 'pointer'});supportedSites[currentSiteIndex].Selected=false;supportedSites[index].Selected=true;currentSiteIndex=index;if($('#gsfx_bsrch_query').hasClass('siteseltxt')){$('#gsfx_bsrch_query').val(supportedSites[index].Name)}}function ChangeBackground(element,isMouseOver){var hoverImgPath='/library/images/support/cn/';if(isMouseOver){hoverImgPath+="ss_dd_select2.png";}else{hoverImgPath+="ss_dd_select1.png";}if(isIE6){$('#gsfx_cat_sel_ie6').css({'filter': 'progid:DXImageTransform.Microsoft.AlphaImageLoader(src=\''+hoverImgPath+'\''});}else{$(element).css({'background-image': 'url('+hoverImgPath+')'});}}function SetCatLangPos(){if(avlCatalogs.length==0){return;}$('#gsfx_cat_sel_cntnr').get(0).style.top=$('#gsfx_cat_sel').height()- 5;$('#gsfx_cat_sel_cntnr').width(($('#gsfx_bsrch_query').parent().width()/ 2)+$('#gsfx_cat_sel').width()+15);}function ShowHideLangSel(event){var targetEl=!(event.target)? event.srcElement : event.target;if(targetEl!=$('#gsfx_cat_sel').get(0)){return;}if($('#gsfx_cat_sel_cntnr').css('display')=='none'){$(optContainer).css({'display': 'none'});$('#gsfx_cat_sel_cntnr').css({'display': 'block'});}else{HideLangSel();}}function HideLangSel(){if(avlCatalogs.length==0){return;}$('#gsfx_cat_sel_cntnr').css({'display': 'none'});}function CallWebSearch(searchHomeUrl,searchResultsUrl){var f=$('#frmsrch').get(0);
 var el=f.query;if($(el).hasClass('siteseltxt')||jQuery.trim($(el).val()).length==0){StatsDotNet.OptionCollectionId=SetLogCollectionBit(StatsDotNet.OptionCollectionId,33);StatsDotNet.targetUrl=searchHomeUrl;document.location.href=searchHomeUrl;return;}SaveSimpleSearch(searchResultsUrl);}