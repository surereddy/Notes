// NEW  FUNCTIONS
function checkRequired(formctrl){
	if(formctrl  && requiredcontrols.length>0){
		var mess="";
		for(var i=0;i<requiredcontrols.length;i++){
	   		var ctrl=formctrl[requiredcontrols[i]];
               if(ctrl){
                var isen=true;
                if(ctrl.options){
                    isen=ctrl.selectedIndex>-1 && ctrl.value.length>0 && ctrl.value!='any' && ctrl.value!='noselection';
	   		   	} else if(ctrl.value){
                    isen=ctrl.value && ctrl.value.length>0;
	   		   	}else if( !ctrl.value ) isen=false;
	   		   	if(!isen){
                    var label=requiredcontrollabels[i];
	   		   	    if(label && label.length>0){
	   		   	    	var ind=label.lastIndexOf(':');
	   		   	    	if(ind>0) label=label.substring(0,ind);
	   		   	    }
    				mess=mess+label+', ';
	   		   	}
	   		}
	   	}
		if(mess.length>0){
			mess=mess.substring(0,mess.length-2);
			alert(requiredAlert+mess)
			return false;
		} else {
			return true;
		}
    	//searchbtn.disabled=!isen;
	}
	return true;
}

function clearAll(formnum){
	clearForm(document.forms['expertForm'+formnum]);
	clearForm(document.forms['searchForm'+formnum]);
    clearUMData();
	clearDateFilters(document);
	clearRadioFocusChoices(document);
    // for lfc additional dates
	if(window.getDates && window.setDates){
		var adates = getDates();
		for( var i=0; i< adates.length; i++ ){
			var adate = adates[i];
			adate[1]='';
			adate[2]='';
		}
		setDates(adates);
	}
}
//TW 37509: Start
//In advanced search in KCC, the clear search functionality does not reset the search fields to the default values
	function clearRadioFocusChoices(document){
		var radioButtons = document.getElementsByName("showFocusChoices");
		if (radioButtons != null) {
			for( var i=0; i< radioButtons.length; i++ ){
				var button = radioButtons[i];
				button.checked = button.value == "on";
			}
		}
	}
	function clearDateFilters(document){
		for( var i=1; i<= datefilternum; i++ ){
			var ctrl = document.getElementById("datefilters_" + i );
			if(ctrl){
				if(ctrl.options){
					for (var ctrlOptionsIndex =0 ;ctrlOptionsIndex < ctrl.options.length; ctrlOptionsIndex++) {
						var ctrlOption = ctrl.options[ctrlOptionsIndex];
						ctrlOption.selected = ctrlOptionsIndex == 0;
					}
				}
			}
		}
	}
//TW 37509: End

function contains(a, el) {
    if (typeof(a)=='object') {
        for (var i = 0; i < a.length; i++)
            if (a[i] == el) return true;
        return false;
    } else {
        return a == el;
    }
}

function clearForm(formctrl){
	if(formctrl){
		if(formctrl.searchString && formctrl.searchString.type!='hidden') formctrl.searchString.value="";
		if(clearedcontrols.length>0){
		    var els=formctrl.elements;
            for(var i=0;i<clearedcontrols.length;i++){
		   		var ctrl=els[clearedcontrols[i]];
		   		if(ctrl){
					if(ctrl.options){
						for (var ix =0 ;ix < ctrl.options.length; ix++) {
							var ctrlOption = ctrl.options[ix];
							ctrlOption.selected = contains(ctrlDefaultValues[clearedcontrols[i]], ctrlOption.value);
						}
		   		   	} else if(ctrl.value){
                        if (eval("formctrl.radionone"+ctrl.name)) {
                            var rn = eval("formctrl.radionone"+ctrl.name);
                            if (ctrlDefaultValues[ctrl.name]) {
                                if (ctrlDefaultValues[ctrl.name]=="none") {
                                    if (rn.value!="none") setRadioNone(ctrl.name, rn.value);
                                } else {
                                    if (rn.value=="none") setRadioNone(ctrl.name, rn.value);
                                    ctrl.value = ctrlDefaultValues[ctrl.name];
                                }
                            } else {
                                if (rn.value=="none") setRadioNone(ctrl.name, rn.value);
                                ctrl.value = '';
                            }
                        } else {
    		   		   	    if (ctrlDefaultValues[ctrl.name]) ctrl.value = ctrlDefaultValues[ctrl.name];
    		   		   		else ctrl.value = '';
		   		   		}

						if (ctrl.type == 'hidden') {
							var selDivCtrl = document.getElementsByName("selected_div_"+ctrl.name);
							if (selDivCtrl != null && selDivCtrl.length > 0) {
								try {
									eval("setSelected_"+ctrl.name+"(\"\")");
								} catch (e) {
									//
								}
							}
						}
		   		   	}
		   		}
		   	}
		}
	}
}

function clearUMData(){
    if(clearumcontrols.length>0){
        for(var i=0;i<clearumcontrols.length;i++){
            eval( "if(window.clear_" + clearumcontrols[i] + ") window.clear_" + clearumcontrols[i] + "();" );
        }
    }
    if( window.clearSelectedUMsList)
        window.clearSelectedUMsList();
}

// OLD  FUNCTIONS
function performSearch( searchForm ) {
	//<eVergance>
	if (documentOnSubmitAction)
	{
		documentOnSubmitAction(null);
	}
	//</eVergance>

	if(validateForm( searchForm )) submitForm( searchForm );
}

function validateForm(searchForm) {
    var isValidated = true;
	isValidated = checkDates( searchForm );
	
	if( isValidated && window.checkRequired ) isValidated = checkRequired(searchForm);
	if( isValidated && window.addHiddenDatesFields ) window.addHiddenDatesFields( searchForm );
	
 	return isValidated;		
}

var isGuidedSearchActive = true;

function getIsGuidedSearchActive() {
    return isGuidedSearchActive;
}

function showGuidedSearch(guided, expert)
{
  document.getElementById(guided).style.display="block";
  document.getElementById(expert).style.display="none";
  isGuidedSearchActive = true;
  afterChangeMode();
}

function showExpertSearch(guided, expert)
{
  document.getElementById(guided).style.display="none";
  document.getElementById(expert).style.display="block";
  isGuidedSearchActive = false;
  afterChangeMode();
}

function popSearch(url, searchName) {
	searchWin = window.open(url, "searchWindow"+searchName,'toolbar=no,status=yes,height=425,width=520,scrollbars=yes,resizable=yes');
	searchWin.focus();
}

function callSaveSearch()
{
	if(document.FavoriteSearch){
	    document.FavoriteSearch.target = 'saveThisDialog';
    	var wTop = (screen.height - 227) / 2;
    	var wLeft = (screen.width - 355) / 2;
        window.open("../common/blank.jsp",'saveThisDialog','top=' + wTop + ',left=' + wLeft + ',toolbar=0,location=no,directories=0,status=0,menubar=0,scrollbars=0,resizable=0,width=355,height=227').focus();
        //alert('blank.jsp');
	    document.forms['FavoriteSearch'].submit();
    }
}

function callSaveSearchForum()
{
	if(document.FavoriteSearch){
	    document.FavoriteSearch.target = 'saveThisDialog';
    	var wTop = (screen.height - 227) / 2;
    	var wLeft = (screen.width - 355) / 2;
        window.open("common/blank.jsp",'saveThisDialog','top=' + wTop + ',left=' + wLeft + ',toolbar=0,location=no,directories=0,status=0,menubar=0,scrollbars=0,resizable=0,width=355,height=227').focus();
        //alert('blank.jsp');
	    document.forms['FavoriteSearch'].submit();
    }
}


function dragCtrls( dragcontrols, current, next ){
	var currentForm = document.forms[current];
	var nextForm = document.forms[next];
	if( !currentForm || !nextForm || !dragcontrols || dragcontrols.length == 0 ) return;
	nextForm.reset();
	for(var i=0;i<dragcontrols.length;i++){
		var currentCtrl=currentForm[dragcontrols[i]];
		var nextCtrl=nextForm[dragcontrols[i]];	  
		if(!currentCtrl || !nextCtrl ) continue;
		if((currentCtrl.type == "text" && nextCtrl.type== "text") || (currentCtrl.type == "hidden" && nextCtrl.type== "hidden") ){
   	  		nextCtrl.value = currentCtrl.value;	   		
		}
		else if(currentCtrl.options && nextCtrl.options ){
			var selected = false;		
			for( var j=0; j< nextCtrl.options.length; j++  ){
				var nextctrlValue = nextCtrl.options[j].value;
				if(  nextctrlValue != null ){
					for( var k=0; k< currentCtrl.options.length; k++  ){
						var currentctrlValue = currentCtrl.options[k].value;
						if( currentctrlValue != null && ( currentctrlValue == nextctrlValue ) ){
							selected  = currentCtrl.options[k].selected;
							continue;
						}
					}	
				}
				nextCtrl.options[j].selected = selected;
   		   	}
   		}
   	}
}

function afterChangeMode() {
    if (document.getElementById("umPagelet") || document.getElementById("umPageletAM")) {
        list = getSelectedUMsList();
        if (list) checkUMSelected(list);
    }
}

function checkUMSelected(selectedItems) {
    old = "umPageletAM";
	pageletFrameId = "umPagelet"
    if (!getIsGuidedSearchActive()) { 
        old = "umPagelet";
        pageletFrameId = "umPageletAM"
    }

    destFrame = window.frames[pageletFrameId];
    srcFrame = window.frames[old];

    if ( srcFrame && srcFrame.selectedUMItems ) { // both modes are configured
        destFrame.selectedUMItems = srcFrame.selectedUMItems;

        delAllOptions(destFrame.elemById("selectedUM"));
        moveAllOptions(srcFrame.elemById("selectedUM"), destFrame.elemById("selectedUM"));

        if (destFrame.selectedUMItems.length>0) { // copy to hidden parameter
            typeId = destFrame.selectedUMItems[0].typeId;
            umValue = getSelectedUMsStr(typeId);
            if (umValue==null) return;

            paramName = typeIdToNameId[typeId];

            var hiddenctrl=getHiddenUM(paramName);
            if (hiddenctrl)
                hiddenctrl.value=umValue;
        }
    }
}


function checkCtrl( ctrl ){
	if( !ctrl.options ) return;
	var index = -1;
	for( var i=0; i< ctrl.options.length; i++ ){
		var option = ctrl.options[i];
		if( option.selected && ( option.value.length == 0 || option.value == "none" ) ){
			index = i;
  			break;   				
		}	
		else if( option.selected && option.value == "any" ){
			 index = i;	
  		}	
	}
	if( index != -1 )
		for( var i=0; i< ctrl.options.length; i++ )
   			ctrl.options[i].selected = ( i == index );
}	

function checkNumber( ctrl ){
	if(!ctrl) return;	
   	var ValidChars = "0123456789";
   	var IsNumber=true;
   	var strvalue = ctrl.value;
   	var newvalue="";
   	if( !strvalue || strvalue.length == 0 ) return;

   	for ( var i = 0; i < strvalue.length; i++){ 
    	var ch = strvalue.charAt(i); 
      	if (ValidChars.indexOf(ch) != -1) newvalue += ch;
   	}  
    if(newvalue != strvalue )ctrl.value = newvalue;
}

function checkDates(formctrl){
	var dates;
	if( window.getSearchDates ) dates = getSearchDates();
	if( !dates ) return true;
	for(var i=0; i<dates.length; i++){
   		var ctrl=formctrl[ dates[i][0] ];
	   	if(ctrl ){
	   		var ctrlvalue = allTrim(ctrl.value);
	   		var ctrlname = dates[i][1];
	   		if( ctrlname && ctrlname.length > 0 && ctrlname.substring( ctrlname.length-1, ctrlname.length ) != ":" ){
	   			ctrlname += ":";
	   		}
	   		if( ctrlvalue.length > 0 && !isDate( ctrlvalue, dateformat )  ){
	   			alert( ctrlname + " " + dateformatAlert );
	   			return false;
	   		}else{
	   			if( dates[i][0].indexOf( "from" ) == 0  ){
	   				var toctrlname = "to" + dates[i][0].substring(4, dates[i][0].length );
	   				var toctrl = formctrl[ toctrlname ];
	   				if( toctrl ){
	   					var toctrlvalue = allTrim(toctrl.value);
		   				if( toctrlvalue.length >0 && !isDate( toctrlvalue, dateformat ) ){
			   				alert( ctrlname + " " + dateformatAlert );
		   					return false;
		   				}else{
		   					if( ctrlvalue.length > 0 && toctrlvalue.length > 0 && ( compareDates( ctrlvalue, dateformat, toctrlvalue, dateformat ) == 1 )  ){
	   							alert( ctrlname + " " + wrongintervaldatesAlert );
	   							return false;
		   					}
		   				}
		   			}	
	   			}
	   		}
	   	}
	}
	return true;
}
