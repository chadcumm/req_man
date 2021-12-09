function toggle(source) {
    var checkboxes = document.querySelectorAll('input[name="print_requisition"]');
    for (var i = 0; i < checkboxes.length; i++) {
        if (checkboxes[i] != source)
            checkboxes[i].checked = source.checked;
    }
}



//create the patient search launch function
pwx_pat_search_launch = function () {
	
	if (patient_alert == 0) {
		patient_alert = 1;
		alert("Important: Requisitions displayed will NOT be limited to the patient encounter selected.");
    };
	
	var patientSearch = window.external.DiscernObjectFactory("PVPATIENTSEARCHMPAGE"); //creates patient search object
    var searchResult = patientSearch.SearchForPatientAndEncounter(); //launches patient search dialog and assigns the returned object to a variable when the dialog closes.
	if (searchResult.PersonId > 0) {
		//alert(searchResult.PersonId);
		var sendArr = ["^MINE^", searchResult.PersonId + ".0"];
		//alert(sendArr);
			PWX_CCL_Request("req_cust_mp_get_person", sendArr, true, function () {
				var new_entry = '<option selected="selected" value="'+this.PATIENT_PERSON_ID+'">'+this.PATIENT_NAME+'</option>';
				//alert(new_entry);
				$('#task_patient').append(new_entry);
				$("#task_patient").multiselect("refresh");
				$("#task_patient").change();
				//$("#task_patient").trigger("chosen:updated");
			});
	}
	//alert("The selection you made will not be encounter specific.");
}

//create the provider search launch function
pwx_prov_search_launch = function (e) {
    var providerSearch = window.external.DiscernObjectFactory("DOCUTILSHELPER"); //creates provider search object
    var providerResult = providerSearch.getProviderJson(e);
	//alert(providerResult);
	var provResult = JSON.parse(providerResult);
	if (provResult.name) {
		var new_entry = '<option selected="selected" value="'+provResult.id+'">'+provResult.name+'</option>'
		$('#task_provider').append(new_entry);
		$('#task_provider').multiselect("refresh");
		$('#task_provider').change();
		//$("#task_provider").trigger("chosen:updated");
	};
}

//create the form launch function
pwx_form_launch = function (persId, encntrId, formId, activityId, chartMode) {
    var pwxFormObj = window.external.DiscernObjectFactory('POWERFORM');
    pwxFormObj.OpenForm(persId, encntrId, formId, activityId, chartMode);
}

//create the task label print launch function
pwx_task_label_print_launch = function (persId, taskId) {
    var collection = window.external.DiscernObjectFactory("INDEXEDDOUBLECOLLECTION");  //creates indexed double collection
    var taskArr = taskId.split(',');
    for (var i = 0; i < taskArr.length; i++) {  //loops through standard javascript array to extract each taskId.
        collection.Add(taskArr[i]);  //adds each task id to the indexed double collection
    }
    var pwxTaskObj = window.external.DiscernObjectFactory("TASKDOC");
    var success = pwxTaskObj.PrintLabels(persId, collection);
    return success;
}



//set patient focus
pwx_set_patient_focus = function (persId, encntrId, personName) {
	var m_pvPatientFocusObj = window.external.DiscernObjectFactory("PVPATIENTFOCUS");
	if(m_pvPatientFocusObj && typeof ClearPatientFocus !== undefined && typeof SetPatientFocus !== undefined){
		m_pvPatientFocusObj.SetPatientFocus(persId,encntrId,personName);
	}
}
//clear patient focus
pwx_clear_patient_focus = function () {
	var m_pvPatientFocusObj = window.external.DiscernObjectFactory("PVPATIENTFOCUS");
	if(m_pvPatientFocusObj && typeof ClearPatientFocus !== undefined && typeof SetPatientFocus !== undefined){
		m_pvPatientFocusObj.ClearPatientFocus();
	}
}

pwx_get_selected = function (class_name) {
    var selectedElems = new Array(8);
    selectedElems[0] = new Array()
    selectedElems[1] = new Array()
    selectedElems[2] = new Array()
    selectedElems[3] = new Array()
    selectedElems[4] = new Array()
    selectedElems[5] = new Array()
    selectedElems[6] = new Array()
    selectedElems[7] = new Array()
    $(class_name).each(function (index) {
        selectedElems[0].length = index + 1
        selectedElems[1].length = index + 1
        selectedElems[2].length = index + 1
        selectedElems[3].length = index + 1
        selectedElems[4].length = index + 1
        selectedElems[5].length = index + 1
        selectedElems[6].length = index + 1
        selectedElems[7].length = index + 1
        selectedElems[0][index] = $(this).children('span.pwx_task_id_hidden').text() + ".0";
        selectedElems[1][index] = $(this).children('dt.pwx_task_type_ind_hidden').text()
        selectedElems[2][index] = $(this).children('dt.pwx_fcr_content_status_dt').text()
        selectedElems[3][index] = $(this).children('dt.pwx_task_canchart_hidden').text()
        selectedElems[4][index] = $(this).children('dt.pwx_person_id_hidden').text() + ".0";
        selectedElems[5][index] = $(this).children('dt.pwx_encounter_id_hidden').text() + ".0";
        selectedElems[6][index] = $(this)
        selectedElems[7][index] = $(this).children('dt.pwx_task_order_id_hidden').text() + ".0";
    });
    return selectedElems;
}
pwx_get_selected_order_id = function (class_name) {
    //var taskAr = $('.pwx_row_selected').children('.pwx_task_id_hidden').text();
    var taskObj = $(class_name).children('dt.pwx_task_order_id_hidden').map(function () { return $(this).text() + ".0"; });
    var orderAr = jQuery.makeArray(taskObj);
    return orderAr;
}
pwx_get_selected_resched_time_limit = function (class_name) {
    var resched_detailsArr = new Array(2);
    resched_detailsArr[0] = $(class_name).children('dt.pwx_task_resched_time_hidden').text();
    resched_detailsArr[1] = $(class_name).children('dt.pwx_fcr_content_schdate_dt').text();
    return resched_detailsArr;
}
pwx_get_selected_task_comment = function (class_name) {
    var task_comment = '';
    task_comment = $(class_name).children('dt.pwx_task_comment_hidden').text();
    return task_comment;
}
pwx_get_selected_unchart_data = function (class_name) {
    //var taskAr = $('.pwx_row_selected').children('.pwx_task_id_hidden').text();
    var unchartTaskArr = new Array();
    $(class_name).children('dt.pwx_fcr_content_task_dt').children('div.pwx_task_lab_container_hidden').each(function (index) {
        var ar_cnt = unchartTaskArr.length
        unchartTaskArr.length = ar_cnt + 1
        unchartTaskArr[ar_cnt] = new Array(2);
        unchartTaskArr[ar_cnt][0] = $(this).children('span.pwx_task_lab_line_text_hidden').text();
        unchartTaskArr[ar_cnt][1] = $(this).children('span.pwx_task_lab_taskid_hidden').text() + ".0";
    });
    return unchartTaskArr;
}

function pwx_isOdd(num) { return num % 2; }

function pwx_select_all(class_name) {
    $('dl.pwx_content_row').removeClass(class_name).addClass(class_name);
}
function pwx_deselect_all(class_name) {
    $('dl.pwx_content_row').removeClass(class_name);
}

function callCCLLINK(ccllinkparams) {
    window.location = "javascript:CCLLINK('pwx_rpt_driver_to_mpage','" + ccllinkparams + "',0)";
}

function pwx_timer_display() {
    pwx_task_count += 1;
    $('#pwx_loading_div_time').text(pwx_task_count + ' ' + amb_i18n.SEC)
}
function start_pwx_timer() {
    pwx_task_count = 0;
    pwx_task_counter = 0;
    pwx_task_counter = setInterval("pwx_timer_display()", 1000);
}

function stop_pwx_timer() {
    clearInterval(pwx_task_counter)
}

//function to take date/times and sort and then reload the Task
function pwx_sort_by_task_date(a, b) {
    if (a.TASK_DT_TM_NUM < b.TASK_DT_TM_NUM)
        return -1
    if (a.TASK_DT_TM_NUM > b.TASK_DT_TM_NUM)
        return 1
    return 0 //default return value (no sorting)
}
function pwx_sort_view_prefs(a, b) {
    if (a.VIEW_SEQ < b.VIEW_SEQ)
        return -1
    if (a.VIEW_SEQ > b.VIEW_SEQ)
        return 1
    return 0 //default return value (no sorting)
}
function pwx_sort_by_task(a, b) {
    var nameA = a.TASK_DISPLAY.toLowerCase(), nameB = b.TASK_DISPLAY.toLowerCase()
    if (nameA < nameB) //sort string ascending
        return -1
    if (nameA > nameB)
        return 1
    return 0 //default return value (no sorting)
}
function pwx_sort_by_personname(a, b) {
    var nameA = a.PERSON_NAME.toLowerCase(), nameB = b.PERSON_NAME.toLowerCase()
    if (nameA < nameB) //sort string ascending
        return -1
    if (nameA > nameB)
        return 1
    return 0 //default return value (no sorting)
}
function pwx_sort_by_requesteddate(a, b) {
    if (a.VISIT_DT_TM_NUM < b.VISIT_DT_TM_NUM)
        return -1
    if (a.VISIT_DT_TM_NUM > b.VISIT_DT_TM_NUM)
        return 1
    return 0 //default return value (no sorting)
}
function pwx_sort_form_name(a, b) {
    var nameA = a.FORM_NAME.toLowerCase(), nameB = b.FORM_NAME.toLowerCase()
    if (nameA < nameB) //sort string ascending
        return -1
    if (nameA > nameB)
        return 1
    return 0 //default return value (no sorting)
}
function pwx_sort_by_task_type(a, b) {
    var nameA = a.TASK_TYPE.toLowerCase(), nameB = b.TASK_TYPE.toLowerCase()
    if (nameA < nameB) //sort string ascending
        return -1
    if (nameA > nameB)
        return 1
    return 0 //default return value (no sorting)
}
function pwx_sort_by_order_by(a, b) {
    var nameA = a.ORDERING_PROVIDER.toLowerCase(), nameB = b.ORDERING_PROVIDER.toLowerCase()
    if (nameA < nameB) //sort string ascending
        return -1
    if (nameA > nameB)
        return 1
    return 0 //default return value (no sorting)
}
function pwx_sort_by_status(a, b) {
    var nameA = a.TASK_STATUS.toLowerCase(), nameB = b.TASK_STATUS.toLowerCase()
    if (nameA < nameB) //sort string ascending
        return -1
    if (nameA > nameB)
        return 1
    return 0 //default return value (no sorting)
}

function pws_sort_by_reqmodality(a, b) {
    var nameA = a.SUB_ACTIVITY_TYPE.toLowerCase(), nameB = b.SUB_ACTIVITY_TYPE.toLowerCase()
    if (nameA < nameB) //sort string ascending
        return -1
    if (nameA > nameB)
        return 1
    return 0 //default return value (no sorting)
}

function pws_sort_by_priority(a, b) {
    var nameA = a.PRIORITY.toLowerCase(), nameB = b.PRIORITY.toLowerCase()
    if (nameA < nameB) //sort string ascending
        return -1
    if (nameA > nameB)
        return 1
    return 0 //default return value (no sorting)
}

function pws_sort_by_status(a, b) {
    var nameA = a.TASK_STATUS.toLowerCase(), nameB = b.TASK_STATUS.toLowerCase()
    if (nameA < nameB) //sort string ascending
        return -1
    if (nameA > nameB)
        return 1
    return 0 //default return value (no sorting)
}
function pws_sort_by_clerkstatus(a, b) {
    var nameA = a.LATEST_STATUS.toLowerCase(), nameB = b.LATEST_STATUS.toLowerCase()
    if (nameA < nameB) //sort string ascending
        return -1
    if (nameA > nameB)
        return 1
    return 0 //default return value (no sorting)
}
function pws_sort_by_comment(a, b) {
    var nameA = a.LATEST_COMMENT.toLowerCase(), nameB = b.LATEST_COMMENT.toLowerCase()
    if (nameA < nameB) //sort string ascending
        return -1
    if (nameA > nameB)
        return 1
    return 0 //default return value (no sorting)
}

function pwx_task_sort(pwxObj, clicked_header_id) {
    $('#pwx_frame_content').empty();
    $('#pwx_frame_content').html('<div id="pwx_loading_div"><span class="pwx_loading-spinner"></span><br/><span id="pwx_loading_div_time">0 ' + amb_i18n.SEC + '</span></div>');
    start_pwx_timer()
    start_page_load_timer = new Date();
	$('#pwx_task_pagingbar_printall').off();
    json_task_start_number = 0;
    json_task_end_number = 0;
    json_task_page_start_numbersAr = [];
    task_list_curpage = 1;
    if (clicked_header_id == pwx_task_header_id) {
        if (pwx_task_sort_ind == '0') {
            var sort_ind = '1'
        }
        else {
            var sort_ind = '0'
        }
        pwxObj.TLIST.reverse()
        pwx_task_header_id = clicked_header_id
        pwx_task_sort_ind = sort_ind
        RenderTaskListContent(pwxObj);
    }
    else {
        switch (clicked_header_id) {
            case 'pwx_fcr_header_schdate_dt':
                pwxObj.TLIST.sort(pwx_sort_by_task_date)
                pwx_task_header_id = clicked_header_id
                pwx_task_sort_ind = '0'
                RenderTaskListContent(pwxObj);
                break;
            case 'pwx_fcr_header_orderby_dt':
                pwxObj.TLIST.sort(pwx_sort_by_order_by)
                pwx_task_header_id = clicked_header_id
                pwx_task_sort_ind = '0'
                RenderTaskListContent(pwxObj);
                break;
            case 'pwx_fcr_header_task_dt':
                pwxObj.TLIST.sort(pwx_sort_by_task)
                pwx_task_header_id = clicked_header_id
                pwx_task_sort_ind = '0'
                RenderTaskListContent(pwxObj);
                break;
            case 'pwx_fcr_header_personname_dt':
                pwxObj.TLIST.sort(pwx_sort_by_personname)
                pwx_task_header_id = clicked_header_id
                pwx_task_sort_ind = '0'
                RenderTaskListContent(pwxObj);
                break;
            case 'pwx_fcr_header_requesteddate_dt':
                pwxObj.TLIST.sort(pwx_sort_by_requesteddate)
                pwx_task_header_id = clicked_header_id
                pwx_task_sort_ind = '0'
                RenderTaskListContent(pwxObj);
                break;
            case 'pwx_fcr_header_type_dt':
                pwxObj.TLIST.sort(pwx_sort_by_task_type)
                pwx_task_header_id = clicked_header_id
                pwx_task_sort_ind = '0'
                RenderTaskListContent(pwxObj);
                break;
			case 'pwx_fcr_header_reqmodality_dt':
				pwxObj.TLIST.sort(pws_sort_by_reqmodality)
                pwx_task_header_id = clicked_header_id
                pwx_task_sort_ind = '0'
                RenderTaskListContent(pwxObj);
                break;
			case 'pwx_fcr_header_reqpriority_dt':
				pwxObj.TLIST.sort(pws_sort_by_priority)
                pwx_task_header_id = clicked_header_id
                pwx_task_sort_ind = '0'
                RenderTaskListContent(pwxObj);
                break;
			case 'pwx_fcr_header_reqstatus_dt':
				pwxObj.TLIST.sort(pws_sort_by_status)
                pwx_task_header_id = clicked_header_id
                pwx_task_sort_ind = '0'
                RenderTaskListContent(pwxObj);
                break;
			case 'pwx_fcr_header_clerkstatus_dt':
				pwxObj.TLIST.sort(pws_sort_by_clerkstatus)
                pwx_task_header_id = clicked_header_id
                pwx_task_sort_ind = '0'
                RenderTaskListContent(pwxObj);
                break;
			case 'pwx_fcr_header_clerkcomment_dt':
				pwxObj.TLIST.sort(pws_sort_by_comment)
                pwx_task_header_id = clicked_header_id
                pwx_task_sort_ind = '0'
                RenderTaskListContent(pwxObj);
                break;			
        }
    }
}

function PWX_CCL_Request_User_Pref(program, param1, param2, param3, async) {
	var info = new XMLCclRequest();
	info.onreadystatechange = function () {
		if (info.readyState == 4 && info.status == 200) {
			var jsonEval = JSON.parse(this.responseText);
			var recordData = jsonEval.JSON_RETURN;
			if (recordData.STATUS_DATA.STATUS != "S") {
				var error_text = amb_i18n.STATUS + ": " + this.status + " " + amb_i18n.REQUEST_TEXT + ": " + this.requestText;
				MP_ModalDialog.deleteModalDialogObject("TaskActionFail")
				var taskFailModal = new ModalDialog("TaskActionFail")
					.setHeaderTitle('<span class="pwx_alert">' + amb_i18n.ERROR + '!</span>')
					.setTopMarginPercentage(20)
					.setRightMarginPercentage(35)
					.setBottomMarginPercentage(30)
					.setLeftMarginPercentage(35)
					.setIsBodySizeFixed(true)
					.setHasGrayBackground(true)
					.setIsFooterAlwaysShown(true);
				taskFailModal.setBodyDataFunction(
				function (modalObj) {
					modalObj.setBodyHTML('<div style="padding-top:10px;"><p class="pwx_small_text">' + error_text + '</p></div>');
				});
				var closebtn = new ModalButton("addCancel");
				closebtn.setText(amb_i18n.OK).setCloseOnClick(true);
				taskFailModal.addFooterButton(closebtn)
				MP_ModalDialog.addModalDialogObject(taskFailModal);
				MP_ModalDialog.showModalDialog("TaskActionFail")
			}
		}
	};
	var sendArr = ["^MINE^", param1 + ".0", "^" + param2 + "^", "^" + param3 + "^"];
	info.open('GET', program, async);
	info.send(sendArr.join(","));
}

function PWX_CCL_Request(program, paramAr, async, callback) {
	var info = new XMLCclRequest();
	info.onreadystatechange = function () {
		if (info.readyState == 4 && info.status == 200) {
			var jsonEval = JSON.parse(this.responseText);
			var recordData = jsonEval.RECORD_DATA;
			if (recordData.STATUS_DATA.STATUS === "S") {
				callback.call(recordData);
			}
			else {
				callback.call(recordData);
				//alert(amb_i18n.STATUS + ": ", this.status, "<br />" + amb_i18n.REQUEST_TEXT + ": ", this.requestText);
				alert(recordData.ERROR_MESSAGE)
			}
		}
	};
	info.open('GET', program, async);
	info.send(paramAr.join(","));
}
//open requisition viewer
function OpenSingleRequisition(parenttaskid) {
		//var parentelement = $(this).parents('dt.pwx_fcr_content_task_dt') 
		//var parenttaskid = $(parentelement).children('.pwx_task_id_hidden').text()
		var fwObj = window.external.DiscernObjectFactory("PVFRAMEWORKLINK");
		var cclParams = '"MINE",'+parenttaskid;
		fwObj.SetPopupStringProp("REPORT_NAME","rm_all_mp_pdf_viewer");
		fwObj.SetPopupStringProp("REPORT_PARAM",cclParams);
		fwObj.SetPopupBoolProp("SHOW_BUTTONS",0);
		fwObj.SetPopupBoolProp("MODAL",0);
		fwObj.SetPopupDoubleProp("WIDTH",600);
		fwObj.SetPopupDoubleProp("HEIGHT",500);
		fwObj.LaunchPopup();
	};

//open requisition manager support tools
function OpenSupportTools() {
		//var parentelement = $(this).parents('dt.pwx_fcr_content_task_dt') 
		//var parenttaskid = $(parentelement).children('.pwx_task_id_hidden').text()
		var fwObj = window.external.DiscernObjectFactory("PVFRAMEWORKLINK");
		var cclParams = '"MINE","1.1.0",0'
		fwObj.SetPopupStringProp("REPORT_NAME","rm_support_tools");
		fwObj.SetPopupStringProp("REPORT_PARAM",cclParams);
		fwObj.SetPopupBoolProp("SHOW_BUTTONS",0);
		fwObj.SetPopupBoolProp("MODAL",0);
		fwObj.SetPopupDoubleProp("WIDTH",800);
		fwObj.SetPopupDoubleProp("HEIGHT",900);
		fwObj.LaunchPopup();
	};