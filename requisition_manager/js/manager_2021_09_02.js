/*Custom Scripting*/
//console.log = function(msg){alert(msg); }

/*Returns unique values in an array*/
$.extend({
	distinct: function (anArray) {
		var result = [];
		$.each(anArray, function (i, v) {
			if ($.inArray(v, result) == -1) result.push(v);
		});
		return result;
	}
});

//PWX Mpage Framework

//render page
var patient_alert = 0;
var data_changed = 0;
var pwx_task_header_id = "";
var pwx_task_sort_ind = "0";
var pwx_all_show_clicked = "0";
var pwx_task_get_type = "0";
var pwx_task_get_type_str = "All";
var pwx_global_statusArr = new Array;
var pwx_global_ClerStatusArr = new Array;
var pwx_global_typeArr = new Array;
var pwx_global_subtypeArr = new Array;
var pwx_global_priorityArr = new Array;
var pwx_global_orderprovArr = new Array;
var pwx_global_orderprovFiltered = 0;
var pwx_global_expanded = 0;
var pwx_current_set_location = 0;
var pwx_task_global_from_date = "0";
var pwx_task_global_to_date = "0";
var pwx_task_submenu_clicked_task_id = "0";
var pwx_task_submenu_clicked_order_id = "0";
var pwx_task_submenu_clicked_person_id = "0";
var pwx_task_submenu_clicked_task_type_ind = 0;
var pwx_task_submenu_clicked_row_elem;
var reschedule_TaskIds = '';
var start_page_load_timer = new Date();
var ccl_timer = 0;
var filterbar_timer = 0;
var delegate_event_timer = 0;
var json_task_end_number = 0;
var json_task_start_number = 0;
var json_task_page_start_numbersAr = [];
var task_list_curpage = 1;
var pwx_task_counter = 0;
var pwx_task_qualifier = 0;
var current_from_date = '';
var current_to_date = '';
var current_location_id = 0;
var pwx_task_load_counter = 0;
var filter_is_set = 0;
var maxreq = 2000;
var pwxstoreddata;
var pwxstorefilterdata
var requestAsync  = XMLHttpRequest(); 
var cammStore  = XMLHttpRequest();
var cammGet  = XMLHttpRequest();
var camm_store_url = 'http://phsacdea.cerncd.com/camm/p0783.phsa_cd.cerncd.com/service/PDF_REQUISITION/store'
var camm_get_url = 'http://phsacdea.cerncd.com/camm/p0783.phsa_cd.cerncd.com/service/mediaContent/'

function RenderPWxFrame() {
	json_task_end_number = 0;
	json_task_start_number = 0;
	json_task_page_start_numbersAr = [];
	task_list_curpage = 1;

	//gather data 
	var js_criterion = JSON.parse(m_criterionJSON);
	
	$('#pwx_frame_filter_content').empty();
	
	generateFilterSets();
	
	var pwx_current_filter_set = $("#task_filterset").val();
	updateFilterbar(pwx_current_filter_set);

	
	/* auto get data enabled */
	//GetRequisitionsData('auto reun from page generatoin');
	
	function UpdateFilterSets(filter_set_name)	{
	
		var filterSetsElem = $('#task_filterset')
		var filterSetsHTML = [];
		filterSetsHTML.push('');
		filterSetsHTML.push('<span style="vertical-align:30%;">','Filter(s)',': </span><select id="task_filterset" name="task_filterset" class="pwx_task_filterset_box" size="5">');
	
		var sendArr = [	"^MINE^"
						,js_criterion.CRITERION.PRSNL_ID + ".0"
						,"^"+filter_set_name+"^"
						,"0.0"];

		PWX_CCL_Request("req_cust_mp_filter_sets", sendArr, false, function () {
		
			if (this.FILTER_SETS.length > 0) 	{
				for (var i = 0; i < this.FILTER_SETS.length; i++) {
					filterSetsHTML.push('<option ');
					if (this.FILTER_SETS[i].SELECTED == 1) {
						filterSetsHTML.push('selected ');
						filter_is_set = 1;
					}
				filterSetsHTML.push('value="', this.FILTER_SETS[i].FILTER_SET_NAME, '">', this.FILTER_SETS[i].FILTER_SET_NAME, '</option>');
			}
		}
		});
		filterSetsHTML.push('<option value="_blank"></option>');
		filterSetsHTML.push('</select>');

		$(filterSetsElem).html(filterSetsHTML.join(""))	
	}		
	function generateFilterSets()	{
		var headelement = document.getElementById('pwx_frame_head');
				
		var pwxheadHTML = [];
		pwxheadHTML.push('<div id="pwx_frame_toolbar">');
		
		pwxheadHTML.push('<dt id="pwx_task_filter_sets"></dt>');
		pwxheadHTML.push('<dt class="pwx_fcr_remove_set_dt_icon pwx_pointer_cursor" id="pwx_remove_filter_set_dt"></dt>');
		pwxheadHTML.push('<dt class="pwx_fcr_remove_set_dt_icon pwx_pointer_cursor" id="pwx_clear_filter_set_dt"></dt>');
		pwxheadHTML.push('<dt id="pwx_task_new_filter_set">');
		pwxheadHTML.push('<input type=text class="pwx_fcr_input_new_set_dt" id="pwx_new_task_filter_set" placeholder="Enter Filter Name" maxlength="27"></input>');
		pwxheadHTML.push('<dt class="pwx_fcr_input_new_set_dt_icon pwx_pointer_cursor" id="pwx_new_filter_set_dt"></dt>');
		pwxheadHTML.push('</dt>');
		pwxheadHTML.push('<br><br>');
		pwxheadHTML.push('</div>'); //pwx_frame_toolbar
		headelement.innerHTML = pwxheadHTML.join("");
		
		var filterSetsElem = $('#pwx_task_filter_sets')
		var filterSetsHTML = [];
		filterSetsHTML.push('');
		filterSetsHTML.push('<span style="vertical-align:30%;">','Filter(s)',': </span><select id="task_filterset" name="task_filterset" class="pwx_task_filterset_box">');
		filter_set_name = "";
	
		var sendArr = [	"^MINE^"
						,js_criterion.CRITERION.PRSNL_ID + ".0"
						,"^"+filter_set_name+"^"
						,"0.0"];
		
		PWX_CCL_Request("req_cust_mp_filter_sets", sendArr, false, function () {
			
			if (this.FILTER_SETS.length > 0) 	{
				for (var i = 0; i < this.FILTER_SETS.length; i++) {
					filterSetsHTML.push('<option ');
					if (this.FILTER_SETS[i].SELECTED == 1) {
						filterSetsHTML.push('selected ');
						filter_is_set = 1;
					}
				filterSetsHTML.push('value="', this.FILTER_SETS[i].FILTER_SET_NAME, '">', this.FILTER_SETS[i].FILTER_SET_NAME, '</option>');
			}
		}
		});
		filterSetsHTML.push('<option value="_blank"></option>');
		filterSetsHTML.push('</select>');
		$(filterSetsElem).html(filterSetsHTML.join(""))	
		
		$('#pwx_new_filter_set_dt').html('<span id="pwx_new_filter_set" title="' + amb_i18n.SAVE_TASK_TYPE_TOOLTIP + '" class="pwx_save_new_filter_set">Save Filter</span>')
		$('#pwx_new_filter_set_dt').append('&nbsp;<span id="pwx_cancel_new_filter_set" title="' + 'Cancel New Filter Set' + '" class="pwx_cancel_new_filter_set">Cancel</span>')
		$('#pwx_remove_filter_set_dt').html('<span id="pwx_remove_filter_set" title="' + 'Delete Filter Set' + '" class="pwx_remove_new_filter_set">Delete Filter</span>')
		$('#pwx_clear_filter_set_dt').html('<span id="pwx_clear_filter_set" title="' + 'Clear Filter' + '" class="pwx_remove_new_filter_set">Clear Filter</span>')
		$('.pwx_fcr_remove_set_dt_icon').css('display','inline-block');
		$('.pwx_fcr_input_new_set_dt_icon').css('display','inline-block');
		$('#pwx_task_new_filter_set').css('display','inline-block');
		$('#pwx_clear_filter_set_dt').css('display','inline-block');
		
		/*
		$('#task_filterset').multiselect({
		height: "100",
		classes: "pwx_select_box",
		header: false,
		multiple: false,
		noneSelectedText: "",
		selectedList: 1
		});
		*/
		
		$("#task_filterset").on("change", function (event) {
			pwx_task_load_counter = 0;
			var pwx_current_filter_set = $("#task_filterset").val();
			updateFilterbar(pwx_current_filter_set);
		});
		
		//save new filter set
		$('#pwx_new_filter_set').on('click', function (event) {
		
			var incoming_filter_set = document.getElementById("pwx_new_task_filter_set").value;
			var temp_filter_set = incoming_filter_set.replace(/[&\/\\#,+()$~%.'";:*?_|<>{}@!\[\]\-\=]/g, ' ');
			let parser = new DOMParser()
			let doc = parser.parseFromString(temp_filter_set, "text/html")
			
			var new_filter_set = doc.body.textContent;
			
			if (new_filter_set == "Default") {
				alert("The name Default is a reserved name.  Please choose a different name for this filter.")
				$("#pwx_new_task_filter_set").val("");
			} else if (new_filter_set == "") {
				alert("Please enter a name for the filter before saving.")
				$("#pwx_new_task_filter_set").val("");
			} else {
			
			var js_criterion = JSON.parse(m_criterionJSON);
			
			//filter sets
			var array_of_task_filterset_values = $("#task_filterset").multiselect("getChecked").map(function () {
				return this.value;
			}).get();
			
			//print status	
			var array_of_task_status_values = $("#task_status").multiselect("getChecked").map(function () {
				return this.value;
			}).get();
			
			
			//requisition status 
			var array_of_clerical_status_values = $("#clerical_status").multiselect("getChecked").map(function () {
				return this.value;
			}).get();
				
			
			//requisition type
			var array_of_task_type_values = $("#task_type").multiselect("getChecked").map(function () {
				return this.value;
			}).get();
				
			
			//subtype
			var array_of_task_subtype_values = $("#task_subtype").multiselect("getChecked").map(function () {
				return this.value;
			}).get();
				
			
			//priority
			var array_of_task_priority_values = $("#task_priority").multiselect("getChecked").map(function () {
				return this.value;
			}).get();
				
			
			//patient list
			var array_of_task_patient_values = $("#task_patient").multiselect("getChecked").map(function () {
				return this.value;
			}).get();
				
			
			//provider list
			var array_of_task_provider_values = $("#task_provider").multiselect("getChecked").map(function () {
				return this.value;
			}).get();
				
			
			//location list
			var array_of_task_location_values = $("#task_location").multiselect("getChecked").map(function () {
				return this.value;
			}).get();
				
			
			var value_of_taskreportrange = $('#taskreportrange_hidden').text();
			var value_of_requestedreportrange = $('#requestedreportrange_hidden').text();
			
			var taskreportrange_date_range = $('#taskreportrange span').text();
			var requestedreportrange_date_range = $('#requestedreportrange span').text();

			if (value_of_taskreportrange == "Custom Range") {
				var value_of_taskreportrange = [value_of_taskreportrange,taskreportrange_date_range].join(",");
			}

			if (value_of_requestedreportrange == "Custom Range") {
				var value_of_requestedreportrange = [value_of_requestedreportrange,requestedreportrange_date_range].join(",");
			}

							
			//prompt("dates",value_of_taskreportrange+","+value_of_requestedreportrange );
			
			var filter_params = [array_of_task_status_values, 
								 array_of_clerical_status_values, 
								 array_of_task_type_values, 
								 array_of_task_subtype_values, 
								 array_of_task_priority_values, 
								 array_of_task_patient_values, 
								 array_of_task_provider_values, 
								 array_of_task_location_values,
								 value_of_taskreportrange,
								 value_of_requestedreportrange,
								 pwx_task_header_id,
								 pwx_task_sort_ind].join("|")
								 
								 
			var sendArr = [	"^MINE^"
							,js_criterion.CRITERION.PRSNL_ID + ".0"
							,"^"+new_filter_set+"^"
							,"^"+filter_params+"^"];
	
			PWX_CCL_Request("req_cust_mp_add_filter_set", sendArr, false, function () {
				var new_entry = '<option selected="selected" value="'+this.FILTER_SET_NAME+'">'+new_filter_set+'</option>'
				$("#pwx_new_task_filter_set").val("");
				$('#task_filterset').append(new_entry);
				$('#task_filterset').change();
				UpdateFilterSets(this.FILTER_SET_NAME);
			});
			
			}
			
		}); //save new filter set end
		
		$('#pwx_remove_filter_set').on('click', function (event) {
			var remove_entry = $('#task_filterset').val()
			
			if  (remove_entry == 'Default' || remove_entry == '_blank') {
				alert("The Default filter cannot be removed");
			} else {
				var sendArr = [	"^MINE^"
								,js_criterion.CRITERION.PRSNL_ID + ".0"
								,"^"+remove_entry+"^"];
				var yes_result = confirm("Delete the filter named "+remove_entry+"?");
				if (yes_result) {
					PWX_CCL_Request("req_cust_mp_del_filter_set", sendArr, false, function () {
					$('#task_filterset option[value="'+remove_entry+'"]').remove();
					$('#task_filterset').multiselect("refresh");
					$('#task_filterset').change();
					});
				}
			}
		});
		
		$('#pwx_cancel_new_filter_set').on('click', function (event) {
			$("#pwx_new_task_filter_set").val("");
		});
		
		$('#pwx_clear_filter_set_dt').on('click', function (event) {
			$("#pwx_new_task_filter_set").val("");
			$('#pwx_frame_filter_content').empty();
			$("#task_filterset option:selected").removeAttr("selected");
			$('#task_filterset').multiselect("refresh");
			$('#task_filterset').change();
			
		});
		
	} //generateFilterSets end
	
		
	function updateFilterbar(filter_set_name)	{
		if (filter_set_name === undefined) {
			filter_set_name = "";
		}
				
		var sendArr = [	"^MINE^"
						,js_criterion.CRITERION.PRSNL_ID + ".0"
						,"^"+filter_set_name+"^"
						,"0.0"];
		
		PWX_CCL_Request("req_cust_mp_filter_sets", sendArr, false, function () {
			GenerateFilterBar(this);
		});
		pwx_current_filter_set = $("#task_filterset").val();
			//alert("updateFilterbar generating data");
			GetRequisitionsData('from update filterbar');
	}
	
	
	function GenerateFilterBar(filterdata)	{
	//build the filter bar
	
	var start_filterbar_timer = new Date();
	$('#pwx_frame_filter_content').empty();
	
	pwx_task_header_id = filterdata.FINAL_TASK_HEADER_SORT
	pwx_task_sort_ind = filterdata.FINAL_TASK_HEADER_SORT_IND
	
	var filterelement = document.getElementById('pwx_frame_filter_content');
	var pwxfilterbarHTML = [];
	pwxfilterbarHTML.push('<div id="pwx_frame_filter_bar">');
	pwxfilterbarHTML.push('<div id="pwx_frame_filter_bar_container">')
	
	pwxfilterbarHTML.push('<dl>');
	
	pwxfilterbarHTML.push('<dt id="pwx_date_picker">');
	pwxfilterbarHTML.push('<span id="taskreportrange_hidden" class="taskreportrange_hidden">Today</span>');
	pwxfilterbarHTML.push('<span style="vertical-align:0%;">',amb_i18n.TASK_DATE,': </span>');
	pwxfilterbarHTML.push('<span id="taskreportrange" style="display:inline-block;background: #fff; cursor: pointer; padding: 5px 5px; border: 1px solid #ccc; width: 125px;font:9px Tahoma">');
	pwxfilterbarHTML.push('<i class="fa fa-calendar"></i>&nbsp;');
	pwxfilterbarHTML.push('<span></span>');
	pwxfilterbarHTML.push('<i class="fa fa-caret-down"></i>');
	pwxfilterbarHTML.push('</span>');
	pwxfilterbarHTML.push('</dt>');
	
	pwxfilterbarHTML.push('<dt id="pwx_req_date_picker">');
	pwxfilterbarHTML.push('<span id="requestedreportrange_hidden" class="requestedreportrange_hidden">Any Date</span>');
	pwxfilterbarHTML.push('<span style="vertical-align:0%;">',amb_i18n.REQUESTED_DATE,': </span>');
	pwxfilterbarHTML.push('<span id="requestedreportrange" style="display:inline-block;background: #fff; cursor: pointer; padding: 5px 5px; border: 1px solid #ccc; width:125px;font:9px Tahoma">');
	pwxfilterbarHTML.push('<i class="fa fa-calendar"></i>&nbsp;');
	pwxfilterbarHTML.push('<span></span>');
	pwxfilterbarHTML.push('<i class="fa fa-caret-down"></i>');
	pwxfilterbarHTML.push('</span>');
	pwxfilterbarHTML.push('</dt>');
			
	pwxfilterbarHTML.push('<dt id="pwx_location_list">');
	if (filterdata.LOC_LIST.length > 0) {
		pwxfilterbarHTML.push('<select id="task_location" name="task_location" multiple style="width:260px;" data-placeholder="No Locations(s) Selected">'); //added multiple to location
		var loc_height = 50;
		for (var i = 0; i < filterdata.LOC_LIST.length; i++) {
			pwxfilterbarHTML.push('<optgroup class="" label="'+filterdata.LOC_LIST[i].ORG_NAME+'">');
			loc_height += 26;
			for (var j = 0; j < filterdata.LOC_LIST[i].UNIT.length; j++) {				
				if (filterdata.LOC_LIST[i].UNIT[j].SELECTED == 1) { 
					
					pwxfilterbarHTML.push('<option value="', filterdata.LOC_LIST[i].UNIT[j].UNIT_ID, '" selected="selected">', filterdata.LOC_LIST[i].UNIT[j].UNIT_NAME, '</option>');
				}
				else {
					pwxfilterbarHTML.push('<option value="', filterdata.LOC_LIST[i].UNIT[j].UNIT_ID, '">', filterdata.LOC_LIST[i].UNIT[j].UNIT_NAME, '</option>');
				}
			} 
			pwxfilterbarHTML.push('</optgroup>');
		}
		if (loc_height > 300) { loc_height = 300; }
		pwxfilterbarHTML.push('</select>');
		
	}
	else {
		pwxfilterbarHTML.push(amb_i18n.NO_RELATED_LOC);
	}
	pwxfilterbarHTML.push('</dt>');
	
	pwxfilterbarHTML.push('<dt id="pwx_patient_list">');
	pwxfilterbarHTML.push('<select id="task_patient" name="task_patient" multiple style="width:200px;" placeholder="No Patient(s) Selected">');
	for (var i = 0; i < filterdata.PATIENT_LIST.length; i++) {
		if (filterdata.PATIENT_LIST[i].SELECTED == 1) { 
			pwxfilterbarHTML.push('<option value="', filterdata.PATIENT_LIST[i].PERSON_ID, '" selected="selected">', filterdata.PATIENT_LIST[i].NAME, '</option>');
		}
		else {
			pwxfilterbarHTML.push('<option value="', filterdata.PATIENT_LIST[i].PERSON_ID, '">', filterdata.PATIENT_LIST[i].NAME, '</option>');
		}
	}
	pwxfilterbarHTML.push('</select>');
	pwxfilterbarHTML.push('<a onClick="pwx_pat_search_launch();"><span class="pwx-patient_search-icon" id="pwx-patient_search-icon"></span></a>')
	pwxfilterbarHTML.push('</dt>');
		
	pwxfilterbarHTML.push('<dt id="pwx_provider_list">');
	pwxfilterbarHTML.push('<select id="task_provider" name="task_provider" multiple style="width:200px;" placeholder="No Provider(s) Selected">');
	for (var i = 0; i < filterdata.PROVIDER_LIST.length; i++) {
		if (filterdata.PROVIDER_LIST[i].SELECTED == 1) { 
			pwxfilterbarHTML.push('<option value="', filterdata.PROVIDER_LIST[i].PERSON_ID, '" selected="selected">', filterdata.PROVIDER_LIST[i].NAME, '</option>');
		}
		else {
			pwxfilterbarHTML.push('<option value="', filterdata.PROVIDER_LIST[i].PERSON_ID, '">', filterdata.PROVIDER_LIST[i].NAME, '</option>');
		}
	}
	pwxfilterbarHTML.push('</select>');
	pwxfilterbarHTML.push('<a onClick="pwx_prov_search_launch();"><span class="pwx-patient_search-icon" id="pwx-patient_search-icon"></span></a>')
	pwxfilterbarHTML.push('</dt>');

	pwxfilterbarHTML.push('</dl>');

	pwxfilterbarHTML.push('<div id="pwx_frame_advanced_filters_container" style="display:inline-block;">') 
	pwxfilterbarHTML.push('<dl>');
	
	pwxfilterbarHTML.push('<dt id="pwx_task_status_filter"></dt>');
	pwxfilterbarHTML.push('<dt id="pwx_clerical_status_filter"></dt>');
	pwxfilterbarHTML.push('<br><br>');
	pwxfilterbarHTML.push('<dt id="pwx_task_type_filter"></dt>');
	pwxfilterbarHTML.push('<dt id="pwx_task_subtype_filter"></dt>');
	pwxfilterbarHTML.push('<dt id="pwx_task_priority_filter"></dt>');
	
	pwxfilterbarHTML.push('</div>') //pwx_frame_advanced_filters_container
	pwxfilterbarHTML.push('</dl>');
	pwxfilterbarHTML.push('</div>'); //pwx_frame_filter_bar_container
	
	pwxfilterbarHTML.push('<dl><dt>');
	pwxfilterbarHTML.push('<div id="pwx_frame_filter_refresh_container" style="display:inline-block;">') 
	pwxfilterbarHTML.push('<table class="pwx_frame_filter_refresh_table" width=100%>');
	pwxfilterbarHTML.push('<tr>');
	pwxfilterbarHTML.push('<td width=120px>');
	pwxfilterbarHTML.push('<div id="pwx_task_pagingbar_printall" class="pwx_grey"></div>');
	pwxfilterbarHTML.push('</td>');
	pwxfilterbarHTML.push('<td></td>');
	pwxfilterbarHTML.push('<td width=150px align=center>');
	pwxfilterbarHTML.push('<div id="pwx_task_count"></div>');
	pwxfilterbarHTML.push('</td>');
	pwxfilterbarHTML.push('<td width=120px align=center>');
	
	pwxfilterbarHTML.push('<div id="pwx_task_filterbar_page_prev" class="pwx_task_pagingbar_page_icons"></div>');
	pwxfilterbarHTML.push('<div id="pwx_task_pagingbar_cur_page" class=""></div>');
	pwxfilterbarHTML.push('<div id="pwx_task_filterbar_page_next" class="pwx_task_pagingbar_page_icons"></div>');
	
	pwxfilterbarHTML.push('</td>');
	
	pwxfilterbarHTML.push('<td width=80px>');
	pwxfilterbarHTML.push('<div id="pwx_task_list_refresh_data" class="pwx_filter_refresh_data"></div>');	
	pwxfilterbarHTML.push('</td>');

	pwxfilterbarHTML.push('</tr>');
	pwxfilterbarHTML.push('</table>');
	pwxfilterbarHTML.push('</div>'); //pwx_frame_filter_refresh_container
	
	pwxfilterbarHTML.push('</dt></dl>');	
	pwxfilterbarHTML.push('<dl>');
	pwxfilterbarHTML.push('<dt id="pwx_frame_filter_bar_bottom_pad"></dt>');
	pwxfilterbarHTML.push('</dl>');
	pwxfilterbarHTML.push('</div>'); //pwx_frame_paging_bar_container
	pwxfilterbarHTML.push('</div>'); //pwx_frame_filter_bar

	filterelement.innerHTML = pwxfilterbarHTML.join("");
	
	var statusElem = $('#pwx_task_status_filter')
	var ClerStatusElem = $('#pwx_clerical_status_filter')
	var typeElem = $('#pwx_task_type_filter')
	var subtypeElem = $('#pwx_task_subtype_filter')
	var priorityElem = $('#pwx_task_priority_filter')
	var orderprovElem = $('#pwx_task_orderprov_filter')
	var framecontentElem =  $('#pwx_frame_content')
	
	var pwx_global_statusArr = [];
	var statusHTML = [];
	if (pwx_global_statusArr.length > 0) {
		if (filterdata.STATUS_LIST.length > 0) {
			statusHTML.push('<span style="vertical-align:30%;">',amb_i18n.REQUISITION_STATUS,': </span><select id="task_status" name="task_status" multiple="multiple">');
			for (var i = 0; i < filterdata.STATUS_LIST.length; i++) {
				var status_match = 0;
				for (var y = 0; y < pwx_global_statusArr.length; y++) {
					if (pwx_global_statusArr[y] == filterdata.STATUS_LIST[i].STATUS) {
						status_match = 1;
						break;
					}
				}
				if (status_match == 1) {
					statusHTML.push('<option selected="selected" value="', filterdata.STATUS_LIST[i].STATUS, '">', filterdata.STATUS_LIST[i].STATUS, '</option>');
				}
				else {
					statusHTML.push('<option value="', filterdata.STATUS_LIST[i].STATUS + '">', filterdata.STATUS_LIST[i].STATUS, '</option>');
				}
			}
			statusHTML.push('</select>');
		}
	}
	else {
		if (filterdata.STATUS_LIST.length > 0) {
			statusHTML.push('<span style="vertical-align:30%;">',amb_i18n.REQUISITION_STATUS,': </span><select id="task_status" name="task_status" multiple="multiple">');
			for (var i = 0; i < filterdata.STATUS_LIST.length; i++) {
				if (filterdata.STATUS_LIST[i].SELECTED == 1) {
					statusHTML.push('<option selected="selected" value="', filterdata.STATUS_LIST[i].STATUS, '">', filterdata.STATUS_LIST[i].STATUS, '</option>');
				}
				else {
					statusHTML.push('<option value="', filterdata.STATUS_LIST[i].STATUS, '">', filterdata.STATUS_LIST[i].STATUS, '</option>');
				}
			}
			statusHTML.push('</select>');
		}
	}
	$(statusElem).html(statusHTML.join(""))
	
	//clerical status 
	var pwx_global_ClerStatusArr = [];
	var ClerStatusHTML = [];
	if (pwx_global_ClerStatusArr.length > 0) {
		if (filterdata.CLER_STATUS_LIST.length > 0) {
			ClerStatusHTML.push('<span style="vertical-align:30%;">',amb_i18n.CLERICAL_STATUS,': </span><select id="clerical_status" name="clerical_status" multiple="multiple">');
			for (var i = 0; i < filterdata.CLER_STATUS_LIST.length; i++) {
				var status_match = 0;
				for (var y = 0; y < pwx_global_ClerStatusArr.length; y++) {
					if (pwx_global_ClerStatusArr[y] == filterdata.CLER_STATUS_LIST[i].STATUS) {
						status_match = 1;
						break;
					}
				}
				if (status_match == 1) {
					ClerStatusHTML.push('<option selected="selected" value="', filterdata.CLER_STATUS_LIST[i].STATUS, '">', filterdata.CLER_STATUS_LIST[i].STATUS, '</option>');
				}
				else {
					ClerStatusHTML.push('<option value="', filterdata.CLER_STATUS_LIST[i].STATUS + '">', filterdata.CLER_STATUS_LIST[i].STATUS, '</option>');
				}
			}
			ClerStatusHTML.push('</select>');
		}
	}
	else {
		if (filterdata.CLER_STATUS_LIST.length > 0) {
			ClerStatusHTML.push('<span style="vertical-align:30%;">',amb_i18n.CLERICAL_STATUS,': </span><select id="clerical_status" name="clerical_status" multiple="multiple">');
			for (var i = 0; i < filterdata.CLER_STATUS_LIST.length; i++) {
				if (filterdata.CLER_STATUS_LIST[i].SELECTED == 1) {
					ClerStatusHTML.push('<option selected="selected" value="', filterdata.CLER_STATUS_LIST[i].STATUS, '">', filterdata.CLER_STATUS_LIST[i].STATUS, '</option>');
				}
				else {
					ClerStatusHTML.push('<option value="', filterdata.CLER_STATUS_LIST[i].STATUS, '">', filterdata.CLER_STATUS_LIST[i].STATUS, '</option>');
				}
			}
			ClerStatusHTML.push('</select>');
		}
	}
	$(ClerStatusElem).html(ClerStatusHTML.join(""))
	
	var typeHTML = [];
	var pwx_global_typeArr = [];
	if (pwx_global_typeArr.length > 0) {
		if (filterdata.TYPE_LIST.length > 0) {
			typeHTML.push('<span style="vertical-align:30%;">',amb_i18n.TYPE,': </span><select id="task_type" name="task_type" multiple="multiple">');
			for (var i = 0; i < filterdata.TYPE_LIST.length; i++) {
				var type_match = 0;
				for (var y = 0; y < pwx_global_typeArr.length; y++) {
					if (pwx_global_typeArr[y] == filterdata.TYPE_LIST[i].TYPE) {
						type_match = 1;
						break;
					}
				}
				if (type_match == 1) {
					typeHTML.push('<option selected="selected" value="', filterdata.TYPE_LIST[i].TYPE, '">', filterdata.TYPE_LIST[i].TYPE, '</option>');
				}
				else {
					typeHTML.push('<option value="', filterdata.TYPE_LIST[i].TYPE, '">', filterdata.TYPE_LIST[i].TYPE, '</option>');
				}
			}
			typeHTML.push('</select>');
		}
	}
	else {
		if (filterdata.TYPE_LIST.length > 0) {
			typeHTML.push('<span style="vertical-align:30%;">',amb_i18n.TYPE,': </span><select id="task_type" name="task_type" multiple="multiple">');
			for (var i = 0; i < filterdata.TYPE_LIST.length; i++) {
				if (filterdata.TYPE_LIST[i].SELECTED == 1) {
					typeHTML.push('<option selected="selected" value="', filterdata.TYPE_LIST[i].TYPE, '">', filterdata.TYPE_LIST[i].TYPE, '</option>');
				}
				else {
					typeHTML.push('<option value="', filterdata.TYPE_LIST[i].TYPE, '">', filterdata.TYPE_LIST[i].TYPE, '</option>');
				}
			}
			typeHTML.push('</select></dt>');
		}
	}
	$(typeElem).html(typeHTML.join(""))
	
	
	var subtypeHTML = [];
	var pwx_global_subtypeArr = [];
	subtypeHTML.push('<span style="vertical-align:30%;">',amb_i18n.SUBTYPE,': </span><select id="task_subtype" name="task_subtype" multiple="multiple">');
	if (pwx_global_subtypeArr.length > 0) {
		if (filterdata.GSUBTYPE_LIST.length > 0) {
			for (var j=0; j < filterdata.GSUBTYPE_LIST.length; j++) {
				for (var i = 0; i < filterdata.GSUBTYPE_LIST[j].GROUP.length; i++) {
					var type_match = 0;
					for (var y = 0; y < pwx_global_subtypeArr.length; y++) {
						if (pwx_global_subtypeArr[y] == filterdata.GSUBTYPE_LIST[j].GROUP[i].TYPE) {
							type_match = 1;
							break;
						}
					}
				}
				if (type_match == 1) {
					subtypeHTML.push('<option selected="selected" value="', filterdata.GSUBTYPE_LIST[j].GROUP[i].TYPE, '">', filterdata.GSUBTYPE_LIST[j].GROUP[i].TYPE, '</option>');
				}
				else {
					subtypeHTML.push('<option value="', filterdata.GSUBTYPE_LIST[j].GROUP[i].TYPE, '">', filterdata.GSUBTYPE_LIST[j].GROUP[i].TYPE, '</option>');
				}
			}
			subtypeHTML.push('</select>');
		}
	}
	else {
		if (filterdata.GSUBTYPE_LIST.length > 0) {
			
			for (var j=0; j < filterdata.GSUBTYPE_LIST.length; j++) {
				subtypeHTML.push('<optgroup class="" label="'+filterdata.GSUBTYPE_LIST[j].GROUP_NAME+'">');
				for (var i = 0; i < filterdata.GSUBTYPE_LIST[j].GROUP.length; i++) {
					if (filterdata.GSUBTYPE_LIST[j].GROUP[i].SELECTED == 1) {
						subtypeHTML.push('<option selected="selected" value="', filterdata.GSUBTYPE_LIST[j].GROUP[i].TYPE, '">', filterdata.GSUBTYPE_LIST[j].GROUP[i].TYPE, '</option>');
					}
					else {
						subtypeHTML.push('<option value="', filterdata.GSUBTYPE_LIST[j].GROUP[i].TYPE, '">', filterdata.GSUBTYPE_LIST[j].GROUP[i].TYPE, '</option>');
					}
				}
				subtypeHTML.push('</optgroup>');
			}
			
		}
	}
	subtypeHTML.push('</select>');
	$(subtypeElem).html(subtypeHTML.join(""))
	
	var priorityHTML = [];
	var pwx_global_priorityArr = [];
	priorityHTML.push('<span style="vertical-align:30%;">',amb_i18n.PRIORITY,': </span><select id="task_priority" name="task_priority" multiple="multiple">');
	if (pwx_global_priorityArr.length > 0) {
		if (filterdata.PRIORITY_LIST.length > 0) {
			for (var j=0; j < filterdata.PRIORITY_LIST.length; j++) {
				for (var i = 0; i < filterdata.PRIORITY_LIST[j].GROUP.length; i++) {
					var type_match = 0;
					for (var y = 0; y < pwx_global_priorityArr.length; y++) {
						if (pwx_global_priorityArr[y] == filterdata.PRIORITY_LIST[j].GROUP[i].PRIORITY) {
							type_match = 1;
							break;
						}
					}
				}
				if (type_match == 1) {
					priorityHTML.push('<option selected="selected" value="', filterdata.PRIORITY_LIST[j].GROUP[i].PRIORITY, '">', filterdata.PRIORITY_LIST[j].GROUP[i].PRIORITY, '</option>');
				}
				else {
					priorityHTML.push('<option value="', filterdata.PRIORITY_LIST[j].GROUP[i].PRIORITY, '">', filterdata.PRIORITY_LIST[j].GROUP[i].PRIORITY, '</option>');
				}
			}
			priorityHTML.push('</select>');
		}
	}
	else {
		if (filterdata.PRIORITY_LIST.length > 0) {
			
			for (var j=0; j < filterdata.PRIORITY_LIST.length; j++) {
				priorityHTML.push('<optgroup class="" label="'+filterdata.PRIORITY_LIST[j].GROUP_NAME+'">');
				for (var i = 0; i < filterdata.PRIORITY_LIST[j].GROUP.length; i++) {
					if (filterdata.PRIORITY_LIST[j].GROUP[i].SELECTED == 1) {
						priorityHTML.push('<option selected="selected" value="', filterdata.PRIORITY_LIST[j].GROUP[i].PRIORITY, '">', filterdata.PRIORITY_LIST[j].GROUP[i].PRIORITY, '</option>');
					}
					else {
						priorityHTML.push('<option value="', filterdata.PRIORITY_LIST[j].GROUP[i].PRIORITY, '">', filterdata.PRIORITY_LIST[j].GROUP[i].PRIORITY, '</option>');
					}
				}
				priorityHTML.push('</optgroup>');
			}
			
		}
	}
	priorityHTML.push('</select>');
	$(priorityElem).html(priorityHTML.join(""))
	
	$('#pwx_task_pagingbar_printall').text('Print Selected');
	$("#pwx_task_list_refresh_data").text('Refresh');
	
	
	$("#task_status").multiselect({
		height: "200",
		classes: "pwx_select_box",
		noneSelectedText: "Select Status",
		selectedList: 4
	});
	
	$("#clerical_status").multiselect({
		height: "200",
		classes: "pwx_select_box",
		noneSelectedText: "Select Status",
		selectedList: 12,
		selectedText: function(numChecked, numTotal, checkedItems){
			return numChecked + ' of ' + numTotal + ' Selected';
		}
	});
	$("#task_type").multiselect({
		height: "300",
		minWidth: 250,
		classes: "pwx_select_type",
		noneSelectedText: "Select Type",
		selectedList: 0,
		selectedText: function(numChecked, numTotal, checkedItems){
			return numChecked + ' of ' + numTotal + ' Selected';
		}
	});
	$("#task_subtype").multiselect({
		height: "300",
		classes: "pwx_select_box",
		noneSelectedText: "Select Subtype",
		selectedList: 2,
		selectedText: function(numChecked, numTotal, checkedItems){
			return numChecked + ' of ' + numTotal + ' Selected';
		}
	});
	$("#task_priority").multiselect({
		height: "300",
		classes: "pwx_select_box",
		noneSelectedText: "Select Priority",
		selectedList: 2,
		selectedText: function(numChecked, numTotal, checkedItems){
			return numChecked + ' of ' + numTotal + ' Selected';
		}
	});
	$('#task_patient').multiselect({
		height: "200",
		minWidth: 200,
		classes: "pwx_patient_box",
		header: false,
		multiple: true,
		noneSelectedText: "No Patient(s) Selected",
		selectedList: 1,
		selectedText: function(numChecked, numTotal, checkedItems){
			return numChecked + ' of ' + numTotal + ' Patient(s) Selected';
			}
	});
	
	$('#task_provider').multiselect({
		height: "200",
		minWidth: 200,
		classes: "pwx_provider_box",
		header: false,
		multiple: true,
		noneSelectedText: "No Ordering Providers(s) Selected",
		selectedList: 1,
		selectedText: function(numChecked, numTotal, checkedItems){
			return numChecked + ' of ' + numTotal + ' Ordering Provider(s) Selected';
			}
	});

	$('#task_location').multiselect({
		height: "300",
		minWidth: 250,
		classes: "pwx_location_box",
		header: true,
		multiple: true,
		noneSelectedText: "No Location(s) Selected",
		selectedList: 1,
		selectedText: function(numChecked, numTotal, checkedItems){
			if (numChecked == numTotal) {
					return 'All Locations Selected';
				} else {
					return numChecked + ' of ' + numTotal + ' Locations Selected';
				}
			}
		}).multiselectfilter({
			autoReset: true,
			label: "Search",
			placeholder: "Search"
		});
		
	
	$('#pwx_task_list_refresh_data').on('click', function () {
		GetRequisitionsData('run from refresh icon');
	});
	
	//set the date range datepickers
	$(function() {
		var start = moment('2100-12-31');
		var end = moment('2100-12-31');
		function cb(start, end) {
			
			var taskreportrange_label = $('#taskreportrange').data('daterangepicker').chosenLabel
			if (taskreportrange_label == "Custom Range") {
				$('#taskreportrange span').html(start.format('DD-MMM-YYYY') + ' to ' + end.format('DD-MMM-YYYY'));
				$('#taskreportrange_hidden').text(taskreportrange_label);
			} else {
				$('#taskreportrange span').html(taskreportrange_label);
				if (typeof taskreportrange_label !== 'undefined') {
					$('#taskreportrange_hidden').text(taskreportrange_label);
				}
			}
		}
		$('#taskreportrange').daterangepicker({
			startDate: start,
			endDate: end,
			alwaysShowCalendars: true,
			autoApply: false,
			locale: { cancelLabel: 'Cancel' } ,
			ranges: {
			   'Any Date': [moment('1900-01-01'), moment('1900-01-01')],
			   'Today': [moment(), moment()],
			   'Yesterday': [moment().subtract(1, 'days'), moment().subtract(1, 'days')],
			   'Last 7 Days': [moment().subtract(6, 'days'), moment()],
			   'This Month': [moment().startOf('month'), moment().endOf('month')],
			   'Last Month': [moment().subtract(1, 'month').startOf('month'), moment().subtract(1, 'month').endOf('month')]
			}
		}, cb);
		cb(start, end);
	});
	
	if (filterdata.ORDERED_DATE_LABEL.length > 0)	{
		var taskreportrange_label 	= filterdata.ORDERED_DATE_LABEL;
		var taskreportrange_start 	= filterdata.FINAL_ORDERED_DATE_START;
		var taskreportrange_end 	= filterdata.FINAL_ORDERED_DATE_END;
		var taskreportrange_display 	= filterdata.FINAL_ORDERED_DATE_RANGE;
		var start = moment(taskreportrange_start, "DD-MMM-YYYY");
		var end = moment(taskreportrange_end, "DD-MMM-YYYY");

		if  (taskreportrange_label != "Custom Range") {
			var taskreportrange_display = taskreportrange_label
		}
	} else {
		var taskreportrange_label = "Today";
		var taskreportrange_display = taskreportrange_label;
	};
	
	$('#taskreportrange_hidden').text(taskreportrange_label);
	$('#taskreportrange span').html(taskreportrange_display);
	

	//$('#taskreportrange span').html(start.format('DD-MMM-YYYY') + ' to ' + end.format('DD-MMM-YYYY'));
	
	var taskreportrange = $('#taskreportrange').data('daterangepicker')
	

	switch(taskreportrange_label){
		case "Any Date":  taskreportrange.setStartDate(moment('1900-01-01'));
						  taskreportrange.setEndDate(moment('1900-01-01'));
						  break;
		case "Today":  	  taskreportrange.setStartDate(moment());
						  taskreportrange.setEndDate(moment());
						  break;
		case "Yesterday":  	  taskreportrange.setStartDate(moment().subtract(1, 'days'));
						  taskreportrange.setEndDate(moment().subtract(1, 'days'));
						  break;
		case "Last 7 Days":  	  taskreportrange.setStartDate(moment().subtract(6, 'days'));
						  taskreportrange.setEndDate(moment());
						  break;
		
		case "This Month":  	  taskreportrange.setStartDate(moment().startOf('month'));
						  taskreportrange.setEndDate(moment().endOf('month'));
						  break;
		
		case "Last Month":  taskreportrange.setStartDate(moment().subtract(1, 'month').startOf('month'));
						  taskreportrange.setEndDate(moment().subtract(1, 'month').endOf('month'));
						  break;
		case "Custom Range":  taskreportrange.setStartDate(start);
						  taskreportrange.setEndDate(end);
						  break;
						  
	}
	
	$(function() {
		var start = moment();
		var end = moment();
		function cb(start, end) {
			
			var requestedreportrange_label = $('#requestedreportrange').data('daterangepicker').chosenLabel
			$('#requestedreportrange span').html(requestedreportrange_label);
			if (requestedreportrange_label == "Custom Range") {
				$('#requestedreportrange span').html(start.format('DD-MMM-YYYY') + ' to ' + end.format('DD-MMM-YYYY'));		
				$('#requestedreportrange_hidden').text(requestedreportrange_label);
			} else {
				if (typeof requestedreportrange_label !== 'undefined') {
					$('#requestedreportrange_hidden').text(requestedreportrange_label);
				}
			}
			
		}
		$('#requestedreportrange').daterangepicker({
			startDate: start,
			endDate: end,
			alwaysShowCalendars: true,
			autoApply: false,
			locale: { cancelLabel: 'Cancel' } ,
			ranges: {
			   'Any Date': [moment('1900-01-01'), moment('1900-01-01')],
			   'Today': [moment(), moment()],
			   'Yesterday': [moment().subtract(1, 'days'), moment().subtract(1, 'days')],
			   'Next 7 Days': [moment(),moment().add(6, 'days')],
			   'Next Month': [moment().add(1, 'month').startOf('month'), moment().add(1, 'month').endOf('month')],
			   'Next Year': [moment().add(1, 'year').startOf('year'), moment().add(1, 'year').endOf('year')],
			   'All Past Dates': [moment('1900-01-01'), moment().subtract(1, 'days')]
			}
		}, cb);
		cb(start, end);
	});
	
	if (filterdata.REQUESTED_DATE_LABEL.length > 0)	{
		var requestedreportrange_label = filterdata.REQUESTED_DATE_LABEL;
		var requestedreportrange_start 	= filterdata.FINAL_REQUESTED_DATE_START;
		var requestedreportrange_end 	= filterdata.FINAL_REQUESTED_DATE_END;
		var requestedreportrange_display 	= filterdata.FINAL_REQUESTED_DATE_RANGE;
		var req_start = moment(requestedreportrange_start, "DD-MMM-YYYY");
		var req_end = moment(requestedreportrange_end, "DD-MMM-YYYY");
		if  (requestedreportrange_label != "Custom Range") {
			var requestedreportrange_display = requestedreportrange_label
		}
	} else {
		var requestedreportrange_label = "Any Date";
		var requestedreportrange_display = requestedreportrange_label
		
	};	
	$('#requestedreportrange_hidden').text(requestedreportrange_label);
	$('#requestedreportrange span').html(requestedreportrange_display);

	//$('#requestedreportrange span').html(start.format('DD-MMM-YYYY') + ' to ' + end.format('DD-MMM-YYYY'));
	
	var requestedreportrange = $('#requestedreportrange').data('daterangepicker')
	switch(requestedreportrange_label){
		case "Any Date":  requestedreportrange.setStartDate(moment('1900-01-01'));
						  requestedreportrange.setEndDate(moment('1900-01-01'));
						  break;
		case "Today":  	  requestedreportrange.setStartDate(moment());
						  requestedreportrange.setEndDate(moment());
						  break;
		case "Yesterday":  requestedreportrange.setStartDate(moment().subtract(1, 'days'));
						  requestedreportrange.setEndDate(moment().subtract(1, 'days'));
						  break;
		case "Next 7 Days":  requestedreportrange.setStartDate(moment());
						  requestedreportrange.setEndDate(moment().add(6, 'days'));
						  break;
		case "Next Month":  requestedreportrange.setStartDate(moment().add(1, 'month').startOf('month'));
						  requestedreportrange.setEndDate(moment().add(1, 'month').endOf('month'));
						  break;
		case "Next Year":  requestedreportrange.setStartDate(moment().add(1, 'year').startOf('year'));
						  requestedreportrange.setEndDate(moment().add(1, 'year').endOf('year'));
						  break;
		case "All Past Dates":  requestedreportrange.setStartDate(moment('1900-01-01'));
						  requestedreportrange.setEndDate(moment());
						  break;
		case "Custom Range":  requestedreportrange.setStartDate(req_start);
						  requestedreportrange.setEndDate(req_end);
						  break;
	}
	
	pwxstorefilterdata = filterdata
	
	
	RefreshOn();
	
	$("#task_status, #clerical_status, #task_type, #task_subtype, #task_priority, #task_patient, #task_provider, #task_location").on("change", function (event, ui) {
		$("#pwx_new_task_filter_set").val("");
		$("#task_filterset option[value='_blank']").attr('selected', 'selected');
		$('#task_filterset').multiselect('refresh')
	});
	
	$('#taskreportrange,#requestedreportrange').on('apply.daterangepicker', function(ev, picker) {
		$("#pwx_new_task_filter_set").val("");
		$("#task_filterset option[value='_blank']").attr('selected', 'selected');
		$('#task_filterset').multiselect('refresh')
	});
	var end_filterbar_timer = new Date();
	filterbar_timer = (end_filterbar_timer - start_filterbar_timer) / 1000
	}
	
	function RefreshOff() {
		var refreshBtn = $("#pwx_task_list_refresh_data");
		refreshBtn.off();
		refreshBtn.css('opacity','.2');
		refreshBtn.css('cursor','none');
	}
	
	function RefreshOn() {
		var refreshBtn = $("#pwx_task_list_refresh_data")
		refreshBtn.css('cursor','pointer');
		refreshBtn.css('opacity','1');
		refreshBtn.on('click', function () {
			GetRequisitionsData('run from refresh');
			//window.external.MPAGESOVERRIDEREFRESH("alert('This refresh function has been disabled.  Please use the Print Selected option in Requisition Manager');");
			//window.external.MPAGESOVERRIDEPRINT("alert('This Print function has been disabled.  Please use the Refresh option in Requisition Manager');");
		});
	}
	
	function GetRequisitionsData(actionVal) {
		//alert(actionVal)
		RefreshOff();
		var current_order_from_date = $('#taskreportrange').data('daterangepicker').startDate.format('DD-MMM-YYYY');
		var current_order_to_date = $('#taskreportrange').data('daterangepicker').endDate.format('DD-MMM-YYYY');
		var current_requested_from_date = $('#requestedreportrange').data('daterangepicker').startDate.format('DD-MMM-YYYY');
		var current_requested_to_date = $('#requestedreportrange').data('daterangepicker').endDate.format('DD-MMM-YYYY');
		
		//location list
		var array_of_task_location_values = $("#task_location").multiselect("getChecked").map(function () {
			return this.value;
		}).get();
		if (array_of_task_location_values === undefined || array_of_task_location_values.length == 0) {
			array_of_task_location_values = 0;
		}
		
		//patient list
		var array_of_task_patient_values = $("#task_patient").multiselect("getChecked").map(function () {
			return this.value;
		}).get();
		if (array_of_task_patient_values === undefined || array_of_task_patient_values.length == 0) {
			array_of_task_patient_values = 0;
		}
		
		//provider list
		var array_of_task_provider_values = $("#task_provider").multiselect("getChecked").map(function () {
			return this.value;
		}).get();
		if (array_of_task_provider_values === undefined || array_of_task_provider_values.length == 0) {
			array_of_task_provider_values = 0;
		}
		
		var value_of_taskreportrange = $('#taskreportrange_hidden').text();
		var value_of_requestedreportrange = $('#requestedreportrange_hidden').text();
		
		var sendArr = [	"^MINE^", 
						js_criterion.CRITERION.PRSNL_ID + ".0", 
						js_criterion.CRITERION.POSITION_CD + ".0"
						, "^" + current_order_from_date + "^"
						, "^" + current_order_to_date + "^"
						, "^" + current_requested_from_date + "^"
						, "^" + current_requested_to_date + "^"
						, "value(" + array_of_task_location_values + ")" 
						, "value(" + array_of_task_patient_values + ")"
						, "value(" + array_of_task_provider_values + ")"
						, "^" + value_of_taskreportrange + "^"
						, "^" + value_of_requestedreportrange + "^"];
	
		
		$('#pwx_frame_content').empty();
		$('#pwx_frame_content').html('<div id="pwx_loading_div"><span class="pwx_loading-spinner"></span><br/><span id="pwx_loading_div_time">0 ' + amb_i18n.SEC + '</span></div>');
		
		start_pwx_timer()
		var start_ccl_timer = new Date();
		
		PWX_CCL_Request("req_cust_mp_req_by_loc_dt", sendArr, true, function () {

			pwx_global_orderprovArr = []
		
			var end_ccl_timer = new Date();
			ccl_timer = (end_ccl_timer - start_ccl_timer) / 1000
			start_page_load_timer = new Date();
			switch (pwx_task_header_id) {
           case 'pwx_fcr_header_schdate_dt':
               this.TLIST.sort(pwx_sort_by_task_date)
               break;
           case 'pwx_fcr_header_orderby_dt':
               this.TLIST.sort(pwx_sort_by_order_by)
               break;
           case 'pwx_fcr_header_task_dt':
               this.TLIST.sort(pwx_sort_by_task)
               break;
           case 'pwx_fcr_header_personname_dt':
               this.TLIST.sort(pwx_sort_by_personname)
               break;
           case 'pwx_fcr_header_requesteddate_dt':
               this.TLIST.sort(pwx_sort_by_requesteddate)
               break;
           case 'pwx_fcr_header_type_dt':
               this.TLIST.sort(pwx_sort_by_task_type)
               break;
			case 'pwx_fcr_header_reqmodality_dt':
				this.TLIST.sort(pws_sort_by_reqmodality)
				   break;
			case 'pwx_fcr_header_reqpriority_dt':
				this.TLIST.sort(pws_sort_by_priority)
				   break;
			case 'pwx_fcr_header_reqstatus_dt':
				this.TLIST.sort(pws_sort_by_status)
				   break;
			case 'pwx_fcr_header_clerkstatus_dt':
				this.TLIST.sort(pws_sort_by_clerkstatus)
				   break;
			case 'pwx_fcr_header_clerkcomment_dt':
				this.TLIST.sort(pws_sort_by_comment)
			}
			if (pwx_task_sort_ind == 1) {
				this.TLIST.reverse();
			}
			//pwx_task_sort(this, pwx_task_header_id)
			//this.TLIST.sort(pwx_sort_by_task_date);
			//this.TLIST.reverse();
			//pwx_task_header_id = 'pwx_fcr_header_schdate_dt';
			//pwx_task_sort_ind = 1;
			pwx_task_load_counter += 1;
			filterbar_timer = 0
			json_task_start_number = 0;
			json_task_end_number = 0;
			json_task_page_start_numbersAr = [];
			task_list_curpage = 1;
			pwx_task_qualifier = 0
			pwxstoreddata = this;
			RenderTaskListContent(this)
			
			RefreshOn();
		//$('#pwx_stats').text(this.TIMER_FINAL)
		});	
	} //GetRequisitionsData end
}

function RenderTaskListContent(pwxdata) {
	var refresh_req_ind = 'Yes';
	var framecontentElem =  $('#pwx_frame_content')

	
	var js_criterion = JSON.parse(m_criterionJSON);
	var start_content_timer = new Date();

	framecontentElem.off()
	$('#pwx_task_pagingbar_printall').off()
	
	$('#pwx_task_filterbar_page_prev').html("")
	$('#pwx_task_filterbar_page_prev').off()
	$('#pwx_task_filterbar_page_next').html("")
	$('#pwx_task_filterbar_page_next').off()
	
	
	//Printed Status
	var array_of_checked_values = $("#task_status").multiselect("getChecked").map(function () {
		return this.value;
	}).get();
	pwx_global_statusArr = jQuery.makeArray(array_of_checked_values);
	
	//Clerical Status
	var array_of_checked_values = $("#clerical_status").multiselect("getChecked").map(function () {
		return this.value;
	}).get();
	pwx_global_ClerStatusArr = jQuery.makeArray(array_of_checked_values);
	
	//Requisition type
	var array_of_checked_values = $("#task_type").multiselect("getChecked").map(function () {
		return this.value;
	}).get();
	pwx_global_typeArr = jQuery.makeArray(array_of_checked_values);
	
	//Requisition subtype
	var array_of_checked_values = $("#task_subtype").multiselect("getChecked").map(function () {
		return this.value;
	}).get();
	pwx_global_subtypeArr = jQuery.makeArray(array_of_checked_values);
	
	//Priority
	var array_of_checked_values = $("#task_priority").multiselect("getChecked").map(function () {
		return this.value;
	}).get();
	pwx_global_priorityArr = jQuery.makeArray(array_of_checked_values);
	
	var pwxcontentHTML = [];

	if (pwxdata.TLIST.length > 0) {
		//icon type
		if (pwx_task_sort_ind == '1') {
			var sort_icon = 'pwx-sort_up-icon';
		}
		else {
			var sort_icon = 'pwx-sort_down-icon';
		}

	//make the header
	pwxcontentHTML.push('<div id="pwx_frame_content_rows_header"><dl id="pwx_frame_rows_header_dl">');

	//checkbox column
	pwxcontentHTML.push('<dt id="pwx_fcr_header_type_icon_dt">');
	pwxcontentHTML.push('<input type=checkbox name="check_all_requisitions" id="check_all_requisitions" onclick="toggle(this);">');
	pwxcontentHTML.push('');
	pwxcontentHTML.push('</dt>');
	
	
	//PATIENT
	if (pwx_task_header_id == 'pwx_fcr_header_personname_dt') {
		pwxcontentHTML.push('<dt id="pwx_fcr_header_personname_dt">',amb_i18n.PATIENT,'<span id="task_sort_tgl" class="', sort_icon, '" >&nbsp;</span></dt>');
	}
	else {
		pwxcontentHTML.push('<dt id="pwx_fcr_header_personname_dt">',amb_i18n.PATIENT,'</dt>');
	}

	//ORDER DATE DATE
	if (pwx_task_header_id == 'pwx_fcr_header_schdate_dt') {
			pwxcontentHTML.push('<dt id="pwx_fcr_header_schdate_dt">',amb_i18n.TASK_DATE,'<span id="task_sort_tgl" class="', sort_icon, '" >&nbsp;</span></dt>');
		}
		else {
			pwxcontentHTML.push('<dt id="pwx_fcr_header_schdate_dt">',amb_i18n.TASK_DATE,'</dt>');
		}
	
	//REQUESTED DATED
		if (pwx_task_header_id == 'pwx_fcr_header_requesteddate_dt') {
			pwxcontentHTML.push('<dt id="pwx_fcr_header_requesteddate_dt">',amb_i18n.REQUESTED_DATE,'<span id="task_sort_tgl" class="', sort_icon, '" >&nbsp;</span></dt>');
		}
		else {
			pwxcontentHTML.push('<dt id="pwx_fcr_header_requesteddate_dt">',amb_i18n.REQUESTED_DATE,'</dt>');
		}

	//REQUISITION TYPE
		if (pwx_task_header_id == 'pwx_fcr_header_type_dt') {
			pwxcontentHTML.push('<dt id="pwx_fcr_header_type_dt">',amb_i18n.TYPE,'<span id="task_sort_tgl" class="', sort_icon, '" >&nbsp;</span></dt>');
		}
		else {
			pwxcontentHTML.push('<dt id="pwx_fcr_header_type_dt">',amb_i18n.TYPE,'</dt>');
		}

	//REQUISITION SUBTYPE (MODALITY)
		if (pwx_task_header_id == 'pwx_fcr_header_reqmodality_dt') {
			pwxcontentHTML.push('<dt id="pwx_fcr_header_reqmodality_dt">',amb_i18n.SUBTYPE,'<span id="task_sort_tgl" class="', sort_icon, '" >&nbsp;</span></dt>');
		}
		else {
			pwxcontentHTML.push('<dt id="pwx_fcr_header_reqmodality_dt">',amb_i18n.SUBTYPE,'</dt>');
		}

	//REQUISITION PRIORITY
		if (pwx_task_header_id == 'pwx_fcr_header_reqpriority_dt') {
			pwxcontentHTML.push('<dt id="pwx_fcr_header_reqpriority_dt">',amb_i18n.PRIORITY,'<span id="task_sort_tgl" class="', sort_icon, '" >&nbsp;</span></dt>');
		}
		else {
			pwxcontentHTML.push('<dt id="pwx_fcr_header_reqpriority_dt">',amb_i18n.PRIORITY,'</dt>');
		}

	//REQUISITION TITLE
	if (pwx_task_header_id == 'pwx_fcr_header_task_dt') {
			pwxcontentHTML.push('<dt id="pwx_fcr_header_task_dt">',amb_i18n.TASK_ORDER,'<span id="task_sort_tgl" class="', sort_icon, '" >&nbsp;</span></dt>');
		}
		else {
			pwxcontentHTML.push('<dt id="pwx_fcr_header_task_dt">',amb_i18n.TASK_ORDER,'</dt>');
		}

	
	//REQUISITION STATUS
	if (pwx_task_header_id == 'pwx_fcr_header_reqstatus_dt') {
			pwxcontentHTML.push('<dt id="pwx_fcr_header_reqstatus_dt">',amb_i18n.REQUISITION_STATUS,'<span id="task_sort_tgl" class="', sort_icon, '" >&nbsp;</span></dt>');
		}
		else {
			pwxcontentHTML.push('<dt id="pwx_fcr_header_reqstatus_dt">',amb_i18n.REQUISITION_STATUS,'</dt>');
		}


	//CLERK STATUS
	if (pwx_task_header_id == 'pwx_fcr_header_clerkstatus_dt') {
			pwxcontentHTML.push('<dt id="pwx_fcr_header_clerkstatus_dt">',amb_i18n.CLERICAL_STATUS,'<span id="task_sort_tgl" class="', sort_icon, '" >&nbsp;</span></dt>');
		}
		else {
			pwxcontentHTML.push('<dt id="pwx_fcr_header_clerkstatus_dt">',amb_i18n.CLERICAL_STATUS,'</dt>');
		}

	//COMMENT
		if (pwx_task_header_id == 'pwx_fcr_header_clerkcomment_dt') {
			pwxcontentHTML.push('<dt id="pwx_fcr_header_clerkcomment_dt">',amb_i18n.COMMENT,'<span id="task_sort_tgl" class="', sort_icon, '" >&nbsp;</span></dt>');
		}
		else {
			pwxcontentHTML.push('<dt id="pwx_fcr_header_clerkcomment_dt">',amb_i18n.COMMENT,'</dt>');
		}

	//ORDERING PROVIDER
		if (pwx_task_header_id == 'pwx_fcr_header_orderby_dt') {
			pwxcontentHTML.push('<dt id="pwx_fcr_header_orderby_dt">',amb_i18n.ORDERING_PROV,'<span id="task_sort_tgl" class="', sort_icon, '" >&nbsp;</span></dt>');
		}
		else {
			pwxcontentHTML.push('<dt id="pwx_fcr_header_orderby_dt">',amb_i18n.ORDERING_PROV,'</dt>');
		}

	pwxcontentHTML.push('</dl></div>');
			
	pwxcontentHTML.push('<div id="pwx_frame_content_rows">');
	var pwx_row_color = ''
	var row_cnt = 0;
	var pagin_active = 0;
	var end_of_task_list = 0;
	json_task_start_number = json_task_end_number;
	if (task_list_curpage > json_task_page_start_numbersAr.length) {
		json_task_page_start_numbersAr.push(json_task_start_number)
	}
	
	//finding all matches for counter
	var pwx_task_counter = 0;
	for (var i = 0; i < pwxdata.TLIST.length; i++) {
		var status_match = 0
		for (var cc = 0; cc < pwx_global_statusArr.length; cc++) {
			if (pwx_global_statusArr[cc] == pwxdata.TLIST[i].TASK_STATUS) {
				status_match = 1;
				break;
			}
		}
		var type_match = 0
		for (var cc = 0; cc < pwx_global_typeArr.length; cc++) {
			if (pwx_global_typeArr[cc] == pwxdata.TLIST[i].TASK_TYPE) {
				type_match = 1;
				break;
			}
		}
		var subtype_match = 0
		for (var cc = 0; cc < pwx_global_subtypeArr .length; cc++) {
			if (pwx_global_subtypeArr[cc] == pwxdata.TLIST[i].SUB_ACTIVITY_TYPE) {
				subtype_match = 1;
				break;
			}
		}
		var priority_match = 0
		for (var cc = 0; cc < pwx_global_priorityArr  .length; cc++) {
			if (pwx_global_priorityArr [cc] == pwxdata.TLIST[i].PRIORITY) {
				priority_match = 1;
				break;
			}
		}	
		
		var cler_status_match = 0
		var sel_status = new Array();
		sel_status = pwxdata.TLIST[i].LATEST_STATUS.split(',');
		for (a in sel_status) {
			for (var cc = 0; cc < pwx_global_ClerStatusArr  .length; cc++) {
				if (sel_status[a] == pwx_global_ClerStatusArr [cc])	{
							cler_status_match = 1
							break;
				}
			}
		}
		
		if (status_match == 1 && type_match == 1 && subtype_match == 1 && priority_match == 1 && cler_status_match == 1) {
			pwx_task_counter += 1;
		}
	}
	
	
	if (pwx_task_counter > maxreq) {
		if (task_list_curpage == 1) {
			alert("Your search has returned over "+maxreq+" requisitions and only the first "+maxreq+" have been returned. Please apply a date range, patient and/or provider filter to narrow your search.")
			pwx_task_qualifier = 0;
		}
		pwx_task_counter = maxreq;
	}

	for (var i = json_task_end_number; i < pwxdata.TLIST.length; i++) {
		//do the filtering
		var status_match = 0
		for (var cc = 0; cc < pwx_global_statusArr.length; cc++) {
			if (pwx_global_statusArr[cc] == pwxdata.TLIST[i].TASK_STATUS) {
				status_match = 1;
				break;
			}
		}
		var type_match = 0
		for (var cc = 0; cc < pwx_global_typeArr.length; cc++) {
			if (pwx_global_typeArr[cc] == pwxdata.TLIST[i].TASK_TYPE) {
				type_match = 1;
				break;
			}
		}
		var subtype_match = 0
		for (var cc = 0; cc < pwx_global_subtypeArr .length; cc++) {
			if (pwx_global_subtypeArr[cc] == pwxdata.TLIST[i].SUB_ACTIVITY_TYPE) {
				subtype_match = 1;
				break;
			}
		}
		var priority_match = 0
		for (var cc = 0; cc < pwx_global_priorityArr  .length; cc++) {
			if (pwx_global_priorityArr [cc] == pwxdata.TLIST[i].PRIORITY) {
				priority_match = 1;
				break;
			}
		}	
		
		var cler_status_match = 0
		var sel_status = new Array();
		sel_status = pwxdata.TLIST[i].LATEST_STATUS.split(',');
		for (a in sel_status) {
			for (var cc = 0; cc < pwx_global_ClerStatusArr  .length; cc++) {
				if (sel_status[a] == pwx_global_ClerStatusArr [cc])	{
							cler_status_match = 1
							break;
				}
			}
		}

		var task_row_visable = '';
		var task_row_zebra_type = '';
		
		if (status_match == 1 && type_match == 1 && subtype_match == 1 && priority_match == 1 && cler_status_match == 1) {
			//pwx_task_counter += 1;
			pwx_task_qualifier += 1;
			//alert(pwx_task_qualifier);
			//setup single or multiple line (currently multiple)
			var task_row_lines = '<br />&nbsp;';
			//var task_row_lines = '&nbsp;';
			if (task_row_lines == '<br />&nbsp;') { 
				var lineheightVar = 17 
			} 
			else { 
				var lineheightVar = 16 
			};
			
			if (pwx_isOdd(row_cnt) == 1) {
				task_row_zebra_type = " pwx_zebra_dark "
			}
			else {
				task_row_zebra_type = " pwx_zebra_light "
			}
			row_cnt++
		
			var grey_text = '';
			pwxcontentHTML.push('<dl class="pwx_content_row', grey_text, task_row_zebra_type, '">');
			pwxcontentHTML.push('<dt class="pwx_person_id_hidden">', pwxdata.TLIST[i].PERSON_ID, '</dt>');
			pwxcontentHTML.push('<dt class="pwx_encounter_id_hidden">', pwxdata.TLIST[i].ENCOUNTER_ID, '</dt>');
			pwxcontentHTML.push('<dt class="pwx_person_name_hidden">', pwxdata.TLIST[i].PERSON_NAME, '</dt>');
			pwxcontentHTML.push('<dt class="pwx_task_order_id_hidden">', pwxdata.TLIST[i].ORDER_ID, '</dt>');
			
			//checkbox column
			pwxcontentHTML.push('<dt class="pwx_fcr_content_type_icon_dt">');
			pwxcontentHTML.push('<div class="pwx_fcr_content_action_bar"></div>');
			pwxcontentHTML.push('<input type=checkbox name="print_requisition" id="print_requisition" value="'+i+','+pwxdata.TLIST[i].TASK_ID+'">');
			//pwxcontentHTML.push('<input type=checkbox name="print_requisition" id="print_requisition" value="'+i+'">');
			pwxcontentHTML.push('');
			pwxcontentHTML.push('</input>');
			pwxcontentHTML.push('</dt>');
			//build the task column now to see if more that one line
			var task_colHTML = [];

			//Requisition Name Column
			task_colHTML.push('<dt class="pwx_fcr_content_task_dt">');
			task_colHTML.push('<span class="pwx_task_id_hidden">', pwxdata.TLIST[i].TASK_ID, '</span>');
			task_colHTML.push('<span class="pwx_task_json_index_hidden">', i, '</span>');
			task_colHTML.push('<span class="pwx_fcr_content_type_name_dt">');
			task_colHTML.push('<a title="Open Requisition" class="pwx_result_link_bold">');
			task_colHTML.push(pwxdata.TLIST[i].TASK_DISPLAY);
			task_colHTML.push('</a>');
			task_colHTML.push('</span>');

			task_colHTML.push('<span class="pwx_fcr_content_type_detail_icon_dt" title="',amb_i18n.VIEW_TASK_DETAILS,'">');
			task_colHTML.push('<span class="pwx_task_json_index_hidden">', i, '</span>');
			task_colHTML.push('<span class="ui-icon ui-icon-carat-1-e"></span>');
			task_colHTML.push('</span>');
			task_colHTML.push('</dt>');
			
			//Patient Name
			var task_row_lines = '<br /><br />';
			pwxcontentHTML.push('<dt class="pwx_fcr_content_person_dt"><span class="pwx_fcr_content_type_personname_dt"><a title="',amb_i18n.OPEN_PT_CHART,'" class="pwx_result_link_bold">',
			pwxdata.TLIST[i].PERSON_NAME, '</a>', task_row_lines ,' ', pwxdata.TLIST[i].AGE, ' ', pwxdata.TLIST[i].GENDER_CHAR, ' ');		
			pwxcontentHTML.push('MRN:',pwxdata.TLIST[i].MRN,' PHN:',pwxdata.TLIST[i].PHN,'</span></span>');
			//pwxcontentHTML.push(pwxdata.TLIST[i].MRN,'</span></span>');
			//pwxcontentHTML.push('<span class="pwx_fcr_content_type_person_icon_dt" title="',amb_i18n.VIEW_PT_DETAILS,'"><span class="pwx_task_json_index_hidden">', i, '</span>');
			pwxcontentHTML.push('<span style="line-height:' + lineheightVar + 'px;">', task_row_lines, '</span></dt>');
			
			var task_row_lines = '';
			//Document Date
			pwxcontentHTML.push('<dt class="pwx_fcr_content_schdate_dt"><span style="padding-bottom:2px;">', pwxdata.TLIST[i].TASK_DT_TM_UTC, '</span></dt>');

			//Requested Date
			if (pwxdata.TLIST[i].MULTIPLE_ORDER_DATES_IND == 1)	{
				pwxcontentHTML.push('<dt class="pwx_fcr_content_requesteddate_dt"><span style="padding-bottom:2px;">', pwxdata.TLIST[i].VISIT_DATE,'*</span></dt>');
			} else {
				pwxcontentHTML.push('<dt class="pwx_fcr_content_requesteddate_dt"><span style="padding-bottom:2px;">', pwxdata.TLIST[i].VISIT_DATE,'</span></dt>');
			}
			
	
			//Requisition Type
			pwxcontentHTML.push('<dt class="pwx_fcr_content_type_dt"><span style="padding-bottom:2px;">', pwxdata.TLIST[i].TASK_TYPE, ' ', task_row_lines, '</span></dt>');
	
			//Requisition SubType
			pwxcontentHTML.push('<dt class="pwx_fcr_content_reqmodality_dt"><span style="padding-bottom:2px;">', pwxdata.TLIST[i].SUB_ACTIVITY_TYPE, ' ', task_row_lines, '</span></dt>');

			//Requisition Priority
			pwxcontentHTML.push('<dt class="pwx_fcr_content_reqpriority_dt"><span style="padding-bottom:2px;">', pwxdata.TLIST[i].PRIORITY, ' ', task_row_lines, '</span></dt>');
			
			//insert the task column here
			pwxcontentHTML.push(task_colHTML.join(""));
	
			//Requisition Status
			pwxcontentHTML.push('<dt class="pwx_fcr_content_reqstatus_dt">');
			pwxcontentHTML.push('<span style="padding-bottom:2px;" id="reqstatus-'+i+'">');
			if (pwxdata.TLIST[i].TASK_STATUS == 'Printed') {
				pwxcontentHTML.push('<i>');
			}
			pwxcontentHTML.push(pwxdata.TLIST[i].TASK_STATUS);
			if (pwxdata.TLIST[i].TASK_STATUS == 'Printed') {
				pwxcontentHTML.push('</i>');
			}
			
			pwxcontentHTML.push('</dt>');

			//Clerical Status
			var indClerStatusHTML = [];
			if (pwxstorefilterdata.CLER_STATUS_LIST.length > 0) {
				indClerStatusHTML.push('<select multiple id="clerical_status_req-'+i+'" ');
				indClerStatusHTML.push('name="clerical_status_req-'+i+'" ');
				indClerStatusHTML.push('class="clerical_status_ind"');
				indClerStatusHTML.push('>');
				var sel_status = new Array();
				sel_status = pwxdata.TLIST[i].LATEST_STATUS.split(',');
				for (var ij = 0; ij < pwxstorefilterdata.CLER_STATUS_LIST.length; ij++) {
					indClerStatusHTML.push('<option value="', pwxstorefilterdata.CLER_STATUS_LIST[ij].STATUS,'"'); 
					for (a in sel_status) {
						if (sel_status[a] == pwxstorefilterdata.CLER_STATUS_LIST[ij].STATUS)	{
							indClerStatusHTML.push(' selected ');
						}
					}	
					indClerStatusHTML.push('>', pwxstorefilterdata.CLER_STATUS_LIST[ij].STATUS, '</option>');
					}
				indClerStatusHTML.push('</select>');
			}
			
			pwxcontentHTML.push('<dt class="pwx_fcr_content_clerkstatus_dt">');
			pwxcontentHTML.push('<span class="pwx_parent_event_id_hidden">', pwxdata.TLIST[i].PARENT_EVENT_ID, '</span>');
			pwxcontentHTML.push('<span class="pwx_current_status_hidden">', pwxdata.TLIST[i].LATEST_STATUS, '</span>');
			pwxcontentHTML.push('<span class="pwx_task_json_index_hidden">', i, '</span>');
			pwxcontentHTML.push('<span style="padding-bottom:2px;">');
			//pwxcontentHTML.push(pwxdata.TLIST[i].CLERK_STATUS);
			pwxcontentHTML.push(indClerStatusHTML.join(""));
			pwxcontentHTML.push('<span class="pwx_fcr_status_type_detail_icon_dt" title="',amb_i18n.VIEW_STATUS_DETAILS,'">');
			pwxcontentHTML.push('<span class="pwx_task_json_index_hidden">', i, '</span>');
			pwxcontentHTML.push('<span class="ui-icon ui-icon-carat-1-e"></span>');
			pwxcontentHTML.push('</span>');
			//pwxcontentHTML.push(task_row_lines);
			pwxcontentHTML.push('</span>');
			pwxcontentHTML.push('</dt>');
			
			//Comment       
			pwxcontentHTML.push('<dt class="pwx_fcr_content_clerkcomment_dt">');
			pwxcontentHTML.push('<span class="pwx_parent_event_id_hidden">', pwxdata.TLIST[i].PARENT_EVENT_ID, '</span>');
			pwxcontentHTML.push('<span class="pwx_task_json_index_hidden">', i, '</span>');
			pwxcontentHTML.push('<table class="pwx_fcr_content_clerkcomment_table">');
			pwxcontentHTML.push('<tr>');
			pwxcontentHTML.push('<td>');
			pwxcontentHTML.push('<div contenteditable="true" max="255" class="pwx_fcr_input_clerkcomment_dt" id="pwx_fcr_input_clerkcomment_dt-'+i+'" ');
			pwxcontentHTML.push('" title="');
			pwxcontentHTML.push(pwxdata.TLIST[i].LATEST_COMMENT);
			pwxcontentHTML.push('">');
			pwxcontentHTML.push(pwxdata.TLIST[i].LATEST_COMMENT);
			pwxcontentHTML.push('</div>');
			pwxcontentHTML.push('</td><td>');
			pwxcontentHTML.push('<span class="pwx_fcr_comment_type_detail_icon_dt" title="',amb_i18n.VIEW_COMMENT_DETAILS,'">');
			pwxcontentHTML.push('<span class="pwx_task_json_index_hidden">', i, '</span>');
			pwxcontentHTML.push('<span class="ui-icon ui-icon-carat-1-e"></span>');
			pwxcontentHTML.push('</span>');
			pwxcontentHTML.push(task_row_lines);
			pwxcontentHTML.push('</span>');
			pwxcontentHTML.push('</td>');
			pwxcontentHTML.push('</tr>');
			pwxcontentHTML.push('</table>');
			//Ordering Provider         
			pwxcontentHTML.push('<dt class="pwx_fcr_content_orderby_dt">', pwxdata.TLIST[i].ORDERING_PROVIDER, task_row_lines, '</dt>');
			
			//END COLUMN FOR TESTING
			
			pwxcontentHTML.push('</dl>');
		}
			if (i + 1 == pwxdata.TLIST.length) {
				end_of_task_list = 1;
			}
			if (row_cnt == 50) {
				json_task_end_number = i + 1; //add one to start on next one not displayed
				pagin_active = 1;
				break;
			}
		}
		if (row_cnt == 0) {
			pwxcontentHTML.push('<dl class="pwx_content_noresfilter_row"><span class="pwx_noresult_text">',amb_i18n.SELECTED_FILTERS_NO_TASKS,'</span></dl>');
		}
	}
	else {
		pwxcontentHTML.push('<div id="pwx_frame_content_rows_header"></div><div id="pwx_frame_content_rows"><dl class="pwx_content_nores_row"><span class="pwx_noresult_text">',amb_i18n.NO_RESULTS,'</span></dl>');
	}
	
	
	pwxcontentHTML.push('</div>');
	pwxcontentHTML.push('<div id="pwx_frame_stats" class="pwx_stats"><div class="pwx_stats" id="pwx_stats"></div></div>');
	framecontentElem.html(pwxcontentHTML.join(""))

	var end_content_timer = new Date();
	var start_event_timer = new Date();
	
	/*
	$(".clerical_status_ind").multiselect({
				height: "200",
				buttonWidth: "50",
				classes: "pwx_select_status",
				header: false,
				multiple: true,
				selectedList: 12
			});
			*/
	$(".clerical_status_ind").chosen({
		display_selected_options: false,
		hide_results_on_select: false
	});
	$('.clerical_status_ind').trigger('chosen:updated');
	$('.pwx_select_status').css('width', '125px');

	$('.pwx_fcr_input_clerkcomment_dt').on("keypress paste", function (e) {
		var new_comment_length = $(this).text().length;
		var new_comment_max = this.getAttribute("max")
        if (new_comment_length > (new_comment_max-1)) {
            e.preventDefault();
            return false;
        }
    });
	
	$('.pwx_fcr_input_clerkcomment_dt').on('focusout', function () {
		var new_comment_length = $(this).text().length;
		if (new_comment_length > 0) {
			var new_comment_max = this.getAttribute("max")
			let parser = new DOMParser()
			
			let doc = parser.parseFromString($(this).text(), "text/html")
			var itemp_comment = doc.body.textContent;
			var temp_comment = itemp_comment.replace(/\^/g, " ");
			
			if (new_comment_length > new_comment_max) {
				alert("This comment is "+new_comment_length+" characters long. Please keep your comments under "+new_comment_max+" characters.  The current comment will be reduced match the limit.");
				new_comment = temp_comment.substring(0,new_comment_max);
			} else {
				var new_comment = temp_comment;
			}
		} else {
			var new_comment = "";
		}
		var parentelement = $(this).parents('dt.pwx_fcr_content_clerkcomment_dt');
		var parenttaskid = $(parentelement).children('.pwx_parent_event_id_hidden').text();
		var json_index = $(parentelement).children('.pwx_task_json_index_hidden').text()
		if (parenttaskid > 0) {
			pwxdata.TLIST[json_index].LATEST_COMMENT = new_comment;
			var sendArr = ["^MINE^", parenttaskid + ".0", "^"+new_comment+"^"];
			$('#pwx_fcr_input_clerkcomment_dt-'+json_index).attr('title', new_comment);
			$('#pwx_fcr_input_clerkcomment_dt-'+json_index).text(new_comment);
			PWX_CCL_Request("bc_all_mp_add_req_comment", sendArr, false, function () {
				
			});
		}
	});
	
	$('.clerical_status_ind').on('change', function (e, params) {
		var cur_selection = this.name;
		var parentelement = $(this).parents('dt.pwx_fcr_content_clerkstatus_dt');
		var parenttaskid = $(parentelement).children('.pwx_parent_event_id_hidden').text();
		var current_status = $(parentelement).children('.pwx_current_status_hidden').text();
		var json_index = $(parentelement).children('.pwx_task_json_index_hidden').text()
		var array_of_task_status_values = $("#"+cur_selection).chosen().val();
		//alert(array_of_task_status_values);
		if (array_of_task_status_values === null) {
			alert('At least one requisition status is required. Click on the status name and select the next status desired before removing the existing status.')
			$("#"+cur_selection).val(current_status);
			$("#"+cur_selection).trigger("chosen:updated");
		} else {
		if (parenttaskid > 0) {
			pwxdata.TLIST[json_index].LATEST_STATUS = array_of_task_status_values.join(',');
			var sendArr = ["^MINE^", parenttaskid + ".0", "^"+array_of_task_status_values+"^"];
			PWX_CCL_Request("bc_all_mp_add_req_status", sendArr, true, function () {
					$(parentelement).children('.pwx_current_status_hidden').text(array_of_task_status_values.join(','));
			});
		}
		}
	});
	
	//Ordered Date
	$('#pwx_fcr_header_schdate_dt').on('click', function () {
		pwx_task_sort(pwxdata, 'pwx_fcr_header_schdate_dt')
	});
	
	//Ordering Provider
	$('#pwx_fcr_header_orderby_dt').on('click', function () {
		pwx_task_sort(pwxdata, 'pwx_fcr_header_orderby_dt')
	});
	
	//Requisition Title
	$('#pwx_fcr_header_task_dt').on('click', function () {
		pwx_task_sort(pwxdata, 'pwx_fcr_header_task_dt')
	});
	
	//Patient Name
	$('#pwx_fcr_header_personname_dt').on('click', function () {
		pwx_task_sort(pwxdata, 'pwx_fcr_header_personname_dt')
	});
	
	//Requested Date
	$('#pwx_fcr_header_requesteddate_dt').on('click', function () {
		pwx_task_sort(pwxdata, 'pwx_fcr_header_requesteddate_dt')
	});
	
	//Requisition Type
	$('#pwx_fcr_header_type_dt').on('click', function () {
		pwx_task_sort(pwxdata, 'pwx_fcr_header_type_dt')
	});
	
	//Requisition Subtype
	$('#pwx_fcr_header_reqmodality_dt').on('click', function () {
		pwx_task_sort(pwxdata, 'pwx_fcr_header_reqmodality_dt')
	});

	//Requisition Priority
	$('#pwx_fcr_header_reqpriority_dt').on('click', function () {
		pwx_task_sort(pwxdata, 'pwx_fcr_header_reqpriority_dt')
	});

	//Requisition Print Status
	$('#pwx_fcr_header_reqstatus_dt').on('click', function () {
		pwx_task_sort(pwxdata, 'pwx_fcr_header_reqstatus_dt')
	});

	//Requisition Requsition Status
	$('#pwx_fcr_header_clerkstatus_dt').on('click', function () {
		pwx_task_sort(pwxdata, 'pwx_fcr_header_clerkstatus_dt')
	});

	//Requisition Comment
	$('#pwx_fcr_header_clerkcomment_dt').on('click', function () {
		pwx_task_sort(pwxdata, 'pwx_fcr_header_clerkcomment_dt')
	});	
	$('#pwx_task_pagingbar_cur_page').text(amb_i18n.PAGE + ': ' + task_list_curpage)


	//setup next paging button
	if (pagin_active == 1 && end_of_task_list != 1) {
		if (pwx_task_qualifier < maxreq) {
		$('#pwx_task_filterbar_page_next').html('<span class="pwx-nextpage-icon"></span>')
		$('#pwx_task_filterbar_page_next').on('click', function () {
			framecontentElem.empty();
			framecontentElem.html('<div id="pwx_loading_div"><span class="pwx_loading-spinner"></span><br/><span id="pwx_loading_div_time">0 ' + amb_i18n.SEC + '</span></div>');
			start_pwx_timer()
			start_page_load_timer = new Date();
			window.scrollTo(0, 0);
			task_list_curpage++
			RenderTaskListContent(pwxdata);
		});
		}
	}
	else {
		$('#pwx_task_filterbar_page_next').html('<span class="pwx-nextpage_grey-icon"></span>')
	}
	//setup prev paging button
	if (json_task_start_number > 0) {
		$('#pwx_task_filterbar_page_prev').html('<span class="pwx-prevpage-icon"></span>')
		$('#pwx_task_filterbar_page_prev').on('click', function () {
			task_list_curpage--
			json_task_end_number = json_task_page_start_numbersAr[task_list_curpage - 1]
			framecontentElem.empty();
			framecontentElem.html('<div id="pwx_loading_div"><span class="pwx_loading-spinner"></span><br/><span id="pwx_loading_div_time">0 ' + amb_i18n.SEC + '</span></div>');
			start_pwx_timer()
			start_page_load_timer = new Date();
			window.scrollTo(0, 0);
			RenderTaskListContent(pwxdata);
		});
	}
	else {
		$('#pwx_task_filterbar_page_prev').html('<span class="pwx-prevpage_grey-icon"></span>')
	}
	if (json_task_start_number > 0 || (pagin_active == 1 && end_of_task_list != 1)) {
		$('#pwx_frame_paging_bar_container').css('display', 'inline-block')
		$('#pwx_task_filterbar_page_next').css('display', 'inline-block')
		$('#pwx_task_filterbar_page_prev').css('display', 'inline-block')
	}
	else {
		$('#pwx_frame_paging_bar_container').css('display', 'inline-block')
		$('#pwx_task_filterbar_page_next').css('display', 'none')
		$('#pwx_task_filterbar_page_prev').css('display', 'none')
	}

	$('span.pwx_fcr_content_type_name_dt, span.pwx_fcr_content_type_ordname_dt, dt.pwx_fcr_content_orderby_dt').each(function (index) {
		if (this.clientWidth < this.scrollWidth) {
			var titleText = $(this).text()
			$(this).attr("title", titleText)
		}
	});
	
	//patient chart open function
	framecontentElem.on('click', 'span.pwx_fcr_content_type_personname_dt a', function () {
		var parentelement = $(this).parents('dt.pwx_fcr_content_person_dt')
		var parentpersonid = $(parentelement).siblings('.pwx_person_id_hidden').text()
		var parentencntridid = $(parentelement).siblings('.pwx_encounter_id_hidden').text()
		//var parameter_person_launch = '/PERSONID=' + parentpersonid + ' /ENCNTRID=' + parentencntridid + ' /FIRSTTAB=^Print to PDF^'
		var parameter_person_launch = '/PERSONID=' + parentpersonid + ' /ENCNTRID=' + parentencntridid
		APPLINK(0, "$APP_APPNAME$", parameter_person_launch)
	});

	//print all selected
	$('#pwx_task_pagingbar_printall').on('click', function () {
		var iarray = []
		var array = []
		var undo_print_ind = 0;
		var checkboxes = document.querySelectorAll('input[name=print_requisition]:checked')
		var event_id = 0;
		var valid_req = 0;
		var missing_req = 0;
		if (checkboxes.length > 50) {
			alert("Please select 50 or fewer requisitions to print at one time");
		} else {
			if (checkboxes.length > 0) {
				for (var i = 0; i < checkboxes.length; i++) {
					var entry = checkboxes[i].value.split(',');
					iarray[i] = entry
				}
				
				var task_detailText = [];
				var urls = [];
				task_detailText.push('<table class="requisition_viewer">');
				task_detailText.push('<tr><td><br></td></tr>');
				task_detailText.push('<tr>');
				task_detailText.push('<td width=25% align=left><div id="printbutton"><button id="print_all" class="print_req_btn">Generating '+iarray.length+' Requisition(s)</button></div></div>');
				task_detailText.push('<td width=25% align=center><div id="printing_status"></div></td></div>');
				task_detailText.push('<td width=25% align=right><div id="printing_undostatus"></div></td></div>');
				task_detailText.push('<td width=25% align=right><div id="printing_reference"></div></td></div>');
				task_detailText.push('</tr>');
				task_detailText.push('<tr><td><br></td></tr>');
				
				for (let i = 0; i < iarray.length; i++) {
					var sendArr = [	"^MINE^"
							,iarray[i][1] + ".0"
							];
					PWX_CCL_Request("dev_all_mp_pdf_url", sendArr, false, function () {
						if (this.VALID_IND == 1) {
							if (this.PRINTED_STATUS == "Printed") {
								undo_print_ind = 1
							}
							task_detailText.push('<tr><td colspan=4>');
							task_detailText.push('<div id="PDFDivURL-'+iarray[i][0]+'" style="display:none">'+this.CMV_URL+'</div>');
							task_detailText.push('</td></tr>');
							task_detailText.push('<tr><td colspan=4>');
							task_detailText.push('<div id="PDFDiv"></div>');
							task_detailText.push('</td></tr>');
							urls.push(this.CMV_URL);
							array[valid_req]=iarray[i];
							valid_req += 1;
						} else {
							task_detailText.push('<tr><td colspan=4>');
							//task_detailText.push('All of the orders for a selected requsition have been canceled or activated. This requisition is no longer valid and will not be displayed or printed.');
							task_detailText.push('</td></tr>');
							task_detailText.push('<tr><td colspan=3>&nbsp');
							task_detailText.push('</td></tr>');
							missing_req += 1;
						}
					});
				}
				task_detailText.push('<tr><td colspan=4>');
				task_detailText.push('<div id="embPDFDiv"><iframe style="display:none" id="iframe" src=""></iframe></div>');
				task_detailText.push('</td></tr>');
				task_detailText.push('</table>');

				
				MP_ModalDialog.deleteModalDialogObject("TaskDetailModal")
				MP_ModalDialog.deleteModalDialogObject("PrintAllModal")
				var PrintAllModal = new ModalDialog("PrintAllModal")
				 .setHeaderTitle("Display Multiple Requisitions")
				 .setTopMarginPercentage(10)
				 .setRightMarginPercentage(10)
				 .setBottomMarginPercentage(10)
				 .setLeftMarginPercentage(10)
				 .setIsBodySizeFixed(true)
				 .setHasGrayBackground(true)
				 .setIsFooterAlwaysShown(true);
				PrintAllModal.setBodyDataFunction(
				 function (modalObj) {
					 modalObj.setBodyHTML('<div class="pwx_task_detail">' + task_detailText.join("") + '</div>');
				 });
				var closebtn = new ModalButton("addCancel");
				closebtn.setText(amb_i18n.CLOSE).setCloseOnClick(true);
				PrintAllModal.addFooterButton(closebtn)
				MP_ModalDialog.addModalDialogObject(PrintAllModal);
				MP_ModalDialog.showModalDialog("PrintAllModal")
					
				if (missing_req > 0) {
					var missing_text = "You selected "+missing_req+" requisition(s) that are no longer valid for printing and have therefore been removed.  Please consider refreshing Requisition Manager for the most current list of requisitions."
					$('#printing_status').text(missing_text)
					$('#printing_status').css("color","red")
					alert(missing_text)
				}
				
				document.getElementById("print_all").disabled = true
				
				if (valid_req > 0) {
					var url = document.getElementById('PDFDivURL-'+array[0][0]).innerHTML;
					requestAsync.open("GET",url,false);   
					window.location = "javascript:MPAGES_SVC_AUTH(requestAsync)";                           
					requestAsync.send();

					var loadedCount = 0;
					var pdfDocs = []
					current = {}
					totalPageCount = 0
					pageNum = 1
					pageRendering = false
					pageNumPending = null
					scale = 1.3
					divCount = 0
					
					pdfjsLib.disableWorker = true;
					var r = document.getElementById("printing_reference");
					r.innerHTML = "<button id='open_separate_multi'>View all in Separate Window</button>"
					
					var d = document.getElementById("print_all");
					d.innerText = 'Generating '+valid_req+' Requisition(s)';
					
					var s = document.getElementById("printing_undostatus");
					s.innerHTML = "<button id='undo_print' class='print_req_btn'>Revert Status to Pending</button>"
					if (undo_print_ind == 1) {
						s.disabled = false
					} else {
						s.disabled = true
					}
					
					$('#undo_print').on('click', function(){
					if (checkboxes.length > 0) {
						for (var i = 0; i < checkboxes.length; i++) {
							var entry = checkboxes[i].value.split(',');
							array[i] = entry
						}
						for (let i = 0; i < array.length; i++) {
							var json_idx = array[i][0]
							var event_id = array[i][1]
							
							var sendArr = ["^MINE^", event_id + ".0","^REMOVE^"];
							
							var removeCEAction = window.external.XMLCclRequest();
							removeCEAction.open("GET", "dev_all_mp_add_print_status", false);
							removeCEAction.send(sendArr.join(","));
							
							if (removeCEAction.readyState == 4 && removeCEAction.status == 200) {
								//alert("inside");
								document.getElementById("undo_print").disabled = true;
								//document.getElementById("print_all").disabled = true;
								var y = document.getElementById('reqstatus-'+json_idx);
								y.innerHTML = "Pending"
								pwxdata.TLIST[json_idx].TASK_STATUS = "Pending"
								//toggle('print_requisition');
							}
							removeCEAction.cleanup();
						}	
					}
					});
					
					loadpdfurl();
					
					
				}
				
				
				$('#open_separate_multi').on('click', function () {
				
					if (array.length > 0) {
						var fwObj = window.external.DiscernObjectFactory("PVFRAMEWORKLINK");
						var open_var_array_of_event_ids = '';
						var open_cclParams = '^MINE^,';
						for (let i = 0; i < array.length; i++) {
							if (i > 0) {
								open_var_array_of_event_ids += ',';
							}
							open_var_array_of_event_ids += array[i][1]+'.0';
						}
						open_cclParams += 'value('+open_var_array_of_event_ids+')';
						fwObj.SetPopupStringProp("REPORT_NAME","bc_all_mp_multi_pdf_viewer");
						fwObj.SetPopupStringProp("REPORT_PARAM",open_cclParams);
						fwObj.SetPopupBoolProp("SHOW_BUTTONS",0);
						fwObj.SetPopupBoolProp("MODAL",0);
						fwObj.SetPopupDoubleProp("WIDTH",600);
						fwObj.SetPopupDoubleProp("HEIGHT",500);
						fwObj.LaunchPopup();
					}
				});
				
				$('#print_all').on('mousedown', function(){$('#printing_status').text("Gathering Document(s), this may take a few moments");}).on('mouseup', function (event) {
					$('#printing_status').text("Gathering Document(s)")
					var doc = new jsPDF('p','in','letter',true);
					var options = {};
					doc.autoPrint({variant: 'non-conform'});
					canvas = document.getElementsByClassName("final_pdf")
					for (var i=0, len=canvas.length|0; i<len; i=i+1|0) {
						if (i>0) {
							doc.addPage()
							$('#printing_status').text("Added Document "+i)
						}
						var png = canvas[i].toDataURL();
						doc.addImage(png,'PNG',0,0,undefined,undefined,undefined,'FAST');
					}
					var completed_pdf = doc.output('blob'); 
					var post_url = camm_store_url+'?mimeType=application/pdf';
					cammStore.open("POST",post_url,true); 
					window.location = "javascript:MPAGES_SVC_AUTH(cammStore)";
				
					$('#printing_status').text("Preparing Document(s)")				
				
					cammStore.onreadystatechange = function() {
						if (this.readyState == 4 && this.status == 200) {
							var camm_identifier = this.responseText
							var get_url = camm_get_url+camm_identifier;
							$('#iframe').attr("src", get_url);
							$('#iframe').css('display','none');
					
							$('#printing_status').text("Document(s) ready, please wait for the print window")

						}
					}
					cammStore.send(completed_pdf);
					var checkboxes = document.querySelectorAll('input[name=print_requisition]:checked')
					if (checkboxes.length > 0) {
						for (var i = 0; i < checkboxes.length; i++) {
							var entry = checkboxes[i].value.split(',');
							array[i] = entry
						}
						for (let i = 0; i < array.length; i++) {
							var json_idx = array[i][0]
							var event_id = array[i][1]
							var y = document.getElementById('reqstatus-'+json_idx);
							y.innerHTML = "<i>Printed</i>"
							pwxdata.TLIST[json_idx].TASK_STATUS = "Printed"
							toggle('print_requisition');
							var sendArr = ["^MINE^", event_id + ".0"];
									
							var addCEAction = window.external.XMLCclRequest();
							addCEAction.open("GET", "bc_all_mp_add_print_status", false);
							addCEAction.send(sendArr.join(","));
						}
					}
				});
				

				function loadpdfurl() {
					var container = document.getElementById("PDFDiv");
					pdfjsLib.getDocument(urls[loadedCount]).promise.then(function(pdfDoc_) {
						pdfDocs.push(pdfDoc_);
						loadedCount++;
						if (loadedCount !== urls.length) {
						  return loadpdfurl();
						} else {
							a = document.getElementById("print_all")
							a.disabled = false
							a.innerText = 'Print '+array.length+' Requisition(s)';
						}
						
						for (var docIdx = 0; docIdx < pdfDocs.length; docIdx++) {
							totalPageCount = pdfDocs[docIdx].numPages;
							for (var pageIdx = 0; pageIdx < totalPageCount; pageIdx++) {
								var div = document.createElement("div");
								div.setAttribute("id", "page-" + divCount);
								div.setAttribute("style", "position: relative");
								container.appendChild(div);
								
								var icanvas = document.createElement("canvas");
								icanvas.setAttribute("id", "canvas-" + divCount)
								icanvas.setAttribute("class", "final_pdf")
								icanvas.setAttribute("style", "align: center");
								icanvas.setAttribute("style", "border: 1px solid black");
								div.appendChild(icanvas);
								singlerenderPage(docIdx,pageIdx,icanvas);
							} 
						}
					}); 
				}
				function singlerenderPage(doc,num,icanvas) {	
					ipageRendering = true;
					pdfDocs[doc].getPage(num+1).then(function(page) {

						var viewport = page.getViewport({ scale: scale });
			 
						icanvas.height = viewport.height;
						icanvas.width = viewport.width;
						ictx = icanvas.getContext("2d");
			 
						var irenderContext = {
							canvasContext: ictx,
							viewport: viewport,
						};
					
						var irenderTask = page.render(irenderContext);
			
					});
				}
			}
		}
		//add uncheck all here to clear check marks when clicked.
	});
		
	//open inline requisition viewer
	framecontentElem.on('click', 'span.pwx_fcr_content_type_name_dt a', function () {
		var parentelement = $(this).parents('dt.pwx_fcr_content_task_dt') 
		var parenttaskid = $(parentelement).children('.pwx_task_id_hidden').text()
		var fwObj = window.external.DiscernObjectFactory("PVFRAMEWORKLINK");
		var cclParams = '"MINE",'+parenttaskid;
		var valid_req = 0;
		var json_index = $(parentelement).children('.pwx_task_json_index_hidden').text()
		var task_detailText = [];
		//task_detailText.push('<div class="pwx_modal_person_banner">');
		task_detailText.push('<div id=banner_bar>');
		task_detailText.push('<div id=banner_bar_font>');
		task_detailText.push('<table width=100% border=0>');
		task_detailText.push('<tr>');
		task_detailText.push('<td rowspan=3>');
		task_detailText.push('<b><span id=patient_name>'+pwxdata.TLIST[json_index].PERSON_NAME+'</span></b>');
		task_detailText.push('</td>');
		task_detailText.push('<td align=left>');
		task_detailText.push('DOB:<span id=patient_dob>'+pwxdata.TLIST[json_index].DOB+'</span>');
		task_detailText.push('<td align=left>');
		task_detailText.push('MRN:<span id=patient_mrn>'+pwxdata.TLIST[json_index].MRN+'</span>');
		task_detailText.push('</td>');
		task_detailText.push('<td align=left>');
		task_detailText.push('Location:<span id=patient_loc_unit>'+pwxdata.TLIST[json_index].UNIT+'</span>');
		if (pwxdata.TLIST[json_index].ROOM_BED > " ") {
			task_detailText.push(';&nbsp<span id=patient_loc_room_bed>'+pwxdata.TLIST[json_index].ROOM_BED+'</span>');
		}
		task_detailText.push('</td>');
		task_detailText.push('</tr>');
		task_detailText.push('<tr>');
		task_detailText.push('<td align=left>');
		task_detailText.push('Age:<span id=patient_age>'+pwxdata.TLIST[json_index].AGE_LONG+'</span>');
		task_detailText.push('</td>');
		task_detailText.push('<td align=left>');
		task_detailText.push('Enc:<span id=patient_fin>'+pwxdata.TLIST[json_index].FIN+'</span>');
		task_detailText.push('</td>');
		task_detailText.push('<td align=left>');
		task_detailText.push('<span id=patient_encntr_type>Enc Type:'+pwxdata.TLIST[json_index].ENCNTR_TYPE+'</span>;&nbsp;'+pwxdata.TLIST[json_index].ENCNTR_STATUS);
		task_detailText.push('</td>');
		task_detailText.push('</tr>');
		task_detailText.push('<tr>');
		task_detailText.push('<td align=left>');
		task_detailText.push('Gender:<span id=patient_sex>'+pwxdata.TLIST[json_index].GENDER+'</span>');
		task_detailText.push('</td>');
		task_detailText.push('<td align=left>');
		task_detailText.push('PHN:<span id=patient_sex>'+pwxdata.TLIST[json_index].PHN+'</span>');
		task_detailText.push('</td>');
		task_detailText.push('</tr>');
		task_detailText.push('</table>');
		task_detailText.push('</div>');
		//task_detailText.push('</div>');
		task_detailText.push('</div></br>');
		task_detailText.push('<table class="requisition_viewer">');
		task_detailText.push('<tr>');
		task_detailText.push('<td width=25% align=left><div id="printbutton"><button id="print_all" class="print_req_btn">Print Requisition</button></div>');
		task_detailText.push('<td width=25% align=center><div id="printing_status"></div></td></div>');
		task_detailText.push('<td width=25% align=right><div id="printing_undostatus"></div></td></div>');
		task_detailText.push('<td width=25% align=right><div id="printing_reference"></div></td></div>');
		task_detailText.push('</tr>');
		task_detailText.push('<tr><td><br></td></tr>');

		var sendArr = [	"^MINE^"
						,pwxdata.TLIST[json_index].TASK_ID + ".0"
						];
		PWX_CCL_Request("dev_all_mp_pdf_url", sendArr, false, function () {
			if (this.VALID_IND == 1) {
				task_detailText.push('<tr><td colspan=4>');
				task_detailText.push('<div id="PDFDivURL" style="display:none">'+this.CMV_URL+'</div>');
				task_detailText.push('</td></tr>');
				task_detailText.push('<tr><td colspan=4 align=center>');
				task_detailText.push('<div id="PDFDiv"></div>');
				task_detailText.push('</td></tr>');
				task_detailText.push('<tr><td colspan=4>');
				task_detailText.push('<div id="embPDFDiv"><iframe style="display:none" id="iframe" src=""></iframe></div>');
				task_detailText.push('</td></tr>');
				valid_req = 1;
			} else {
				task_detailText.push('<tr><td colspan=4>');
				task_detailText.push('You selected 1 or more requisitions that are no longer valid for printing and have therefore been removed. Please consider refreshing Requisition Manager for the most current list of requisitions.');
				task_detailText.push('</td></tr>');
				task_detailText.push('<tr><td colspan=4>&nbsp');
				task_detailText.push('</td></tr>');
			}
		});

		task_detailText.push('<tr><td colspan=4 valign=top>');
		task_detailText.push('<table class="action_list">');
		task_detailText.push('<thead><tr>');
		task_detailText.push('<th id="thDate">Action Date</th>');
		task_detailText.push('<th id="thAction">Action</th>');
		task_detailText.push('<th id="thPerformedBy">Performed By</th>');
		task_detailText.push('<th id="thPosition">Position</th>');
		task_detailText.push('</tr></thead>');
		var sendArr = [	"^MINE^"
						,pwxdata.TLIST[json_index].PARENT_EVENT_ID + ".0"
						];
		PWX_CCL_Request("dev_cust_mp_get_comment_hist", sendArr, false, function () {
			task_detailText.push('<tr><td colspan=6>'+this.ACTION_HISTORY+'</td></tr>');
		});
		task_detailText.push('</table>')
		task_detailText.push('</td></tr>');
		task_detailText.push('</table>');
		
		MP_ModalDialog.deleteModalDialogObject("TaskDetailModal")
		var TaskDetailModal = new ModalDialog("TaskDetailModal")
			 .setHeaderTitle("Viewing Requisition")
			 .setTopMarginPercentage(10)
			 .setRightMarginPercentage(10)
			 .setBottomMarginPercentage(10)
			 .setLeftMarginPercentage(10)
			 .setIsBodySizeFixed(true)
			 .setHasGrayBackground(true)
			 .setIsFooterAlwaysShown(true);
		TaskDetailModal.setBodyDataFunction(
			 function (modalObj) {
				 modalObj.setBodyHTML('<div class="pwx_task_detail">' + task_detailText.join("") + '</div>');
			 });
		
		var closebtn = new ModalButton("addCancel");
		closebtn.setText(amb_i18n.CLOSE).setCloseOnClick(true);
		TaskDetailModal.addFooterButton(closebtn)
		MP_ModalDialog.addModalDialogObject(TaskDetailModal);
		MP_ModalDialog.showModalDialog("TaskDetailModal")
		
		document.getElementById("print_all").disabled = true

		if (valid_req == 1) {
			var url = document.getElementById('PDFDivURL').innerHTML;
			var PDFurl = url+'#toolbar=0&navpanes=0&scrollbar=1&view=FitH,top'
			
			requestAsync.open("GET",url,false);   
			window.location = "javascript:MPAGES_SVC_AUTH(requestAsync)";                           
			requestAsync.send();
			
			var fwObj = window.external.DiscernObjectFactory("PVFRAMEWORKLINK");
			//blob = new Blob([requestAsync.response], { type: 'application/octet-stream' });	
			//var pathStr = fwObj.SaveStringToTempFile('document.pdf',blob);
			
			var loadedCount = 0;
			var pdfDocs = []
			current = {}
			totalPageCount = 0
			pageNum = 1
			ipageRendering = false
			pageNumPending = null
			scale = 1.3
			divCount = 0
			urls = [url]
			var p = document.getElementById("printing_status");
			var r = document.getElementById("printing_reference");
			var s = document.getElementById("printing_undostatus");
			
			s.innerHTML = "<button id='undo_print' class='print_req_btn'>Revert Status to Pending</button>"
			r.innerHTML = "<button onclick='javascript:OpenSingleRequisition("+parenttaskid+")'>View in Separate Window</button>"
			
			document.getElementById("undo_print").disabled = true
			
			$('#undo_print').on('click', function(){
					var sendArr = ["^MINE^", pwxdata.TLIST[json_index].TASK_ID + ".0","^REMOVE^"];
				
					var removeCEAction = window.external.XMLCclRequest();
					removeCEAction.open("GET", "dev_all_mp_add_print_status", false);
					removeCEAction.send(sendArr.join(","));
					//alert(sendArr)
					if (removeCEAction.readyState == 4 && removeCEAction.status == 200) {
						document.getElementById("undo_print").disabled = true;
						var y = document.getElementById('reqstatus-'+json_index);
						y.innerHTML = "Pending"
						pwxdata.TLIST[json_index].TASK_STATUS = "Pending"
						toggle('print_requisition');
						document.getElementById("undo_print").disabled = true
					}
				});
				
			if (pwxdata.TLIST[json_index].TASK_STATUS == "Printed") {
				document.getElementById("undo_print").disabled = false
			}
			pdfjsLib.disableWorker = true;
			loadpdfurl();
		}
		
		function loadpdfurl() {
			 pdfjsLib.getDocument(urls[loadedCount]).promise.then(function(pdfDoc_) {
				pdfDocs.push(pdfDoc_);
				loadedCount++;
				if (loadedCount !== urls.length) {
				  return loadpdfurl();
				} else {
					document.getElementById("print_all").disabled = false
				}
				for (var docIdx = 0; docIdx < pdfDocs.length; docIdx++) {
					totalPageCount = pdfDocs[docIdx].numPages;
					for (var pageIdx = 0; pageIdx < totalPageCount; pageIdx++) {
						singlerenderPage(docIdx,pageIdx); 
					}
				}
			});
			
			$('#print_all').on('mousedown', function(){
				$('#printing_status').text("Gathering Document, this may take a few moments");
			}).on('mouseup', function (event) {
				$('#printing_status').text("Gathering Document")
				var doc = new jsPDF('p','in','letter',true);
				doc.internal.scaleFactor = 30;
				var options = {};
				doc.autoPrint({variant: 'non-conform'});
				canvas = document.getElementsByClassName("final_pdf")
				for (var i=0, len=canvas.length|0; i<len; i=i+1|0) {
					if (i>0) {
						doc.addPage()
					}
					var png = canvas[i].toDataURL();
					doc.addImage(png,'PNG',0,0,8.5,11,undefined,'SLOW');
				}
				
				var completed_pdf = doc.output('blob'); 
				var post_url = camm_store_url+'?mimeType=application/pdf';
				cammStore.open("POST",post_url,true); 
				window.location = "javascript:MPAGES_SVC_AUTH(cammStore)";
				
				$('#printing_status').text("Preparing Document")				
				
				cammStore.onreadystatechange = function() {
				if (this.readyState == 4 && this.status == 200) {
					var camm_identifier = this.responseText
					var get_url = camm_get_url+camm_identifier;
					
					$('#iframe').attr("src", get_url);
					$('#iframe').css('display','none');
					
					$('#printing_status').text("Document ready, please wait for the print window")
					
					}
				}
				
				cammStore.send(completed_pdf);

				var y = document.getElementById('reqstatus-'+json_index);
				y.innerHTML = "<i>Printed</i>"
				pwxdata.TLIST[json_index].TASK_STATUS = "Printed"
				toggle('print_requisition');
				var sendArr = ["^MINE^", pwxdata.TLIST[json_index].TASK_ID + ".0"];
				
				var addCEAction = window.external.XMLCclRequest();
				addCEAction.open("GET", "dev_all_mp_add_print_status", false);
				addCEAction.send(sendArr.join(","));
				if (addCEAction.readyState == 4 && addCEAction.status == 200) {				
					document.getElementById("undo_print").disabled = false
				}
			})
		}//end loadpdfurl()
		
		function singlerenderPage(doc,num) {	
			ipageRendering = true;
			pdfDocs[doc].getPage(num+1).then(function(page) {
				divCount += 1;
				var container = document.getElementById("PDFDiv");
				var div = document.createElement("div");
				div.setAttribute("id", "page-" + divCount);
				div.setAttribute("style", "position: relative; margin:0 auto;");
				
				container.appendChild(div);
				var icanvas = document.createElement("canvas");
				
				icanvas.setAttribute("id", "canvas-" + divCount)
				icanvas.setAttribute("class", "final_pdf")
				icanvas.setAttribute("style", "align: center");
				icanvas.setAttribute("style", "border: 1px solid black");
				div.appendChild(icanvas);
	 
				var viewport = page.getViewport({ scale: scale });
	 
				icanvas.height = viewport.height;
				icanvas.width = viewport.width;
				ictx = icanvas.getContext("2d");
	 
				var irenderContext = {
					canvasContext: ictx,
					viewport: viewport,
				};
				
				//var irenderTask = page.render(irenderContext);
				page.render(irenderContext).promise.then(function() {
					ipageRendering = false;
					
				});

			});
		}
	});
	
	//action history
	framecontentElem.on('click', 'span.pwx_fcr_content_type_detail_icon_dt', function (e) {
		//$(this).parents('dl.pwx_content_row').removeClass('pwx_row_selected').addClass('pwx_row_selected');
		var json_index = $(this).children('span.pwx_task_json_index_hidden').text()
		
		var task_detailText = [];
		task_detailText.push('<div id=banner_bar>');
		task_detailText.push('<div id=banner_bar_font>');
		task_detailText.push('<table width=100% border=0>');
		task_detailText.push('<tr>');
		task_detailText.push('<td rowspan=3>');
		task_detailText.push('<b><span id=patient_name>'+pwxdata.TLIST[json_index].PERSON_NAME+'</span></b>');
		task_detailText.push('</td>');
		task_detailText.push('<td align=left>');
		task_detailText.push('DOB:<span id=patient_dob>'+pwxdata.TLIST[json_index].DOB+'</span>');
		task_detailText.push('<td align=left>');
		task_detailText.push('MRN:<span id=patient_mrn>'+pwxdata.TLIST[json_index].MRN+'</span>');
		task_detailText.push('</td>');
		task_detailText.push('<td align=left>');
		task_detailText.push('Location:<span id=patient_loc_unit>'+pwxdata.TLIST[json_index].UNIT+'</span>');
		if (pwxdata.TLIST[json_index].ROOM_BED > " ") {
			task_detailText.push(';&nbsp<span id=patient_loc_room_bed>'+pwxdata.TLIST[json_index].ROOM_BED+'</span>');
		}
		task_detailText.push('</td>');
		task_detailText.push('</tr>');
		task_detailText.push('<tr>');
		task_detailText.push('<td align=left>');
		task_detailText.push('Age:<span id=patient_age>'+pwxdata.TLIST[json_index].AGE_LONG+'</span>');
		task_detailText.push('</td>');
		task_detailText.push('<td align=left>');
		task_detailText.push('Enc:<span id=patient_fin>'+pwxdata.TLIST[json_index].FIN+'</span>');
		task_detailText.push('</td>');
		task_detailText.push('<td align=left>');
		task_detailText.push('<span id=patient_encntr_type>Enc Type:'+pwxdata.TLIST[json_index].ENCNTR_TYPE+'</span>;&nbsp;'+pwxdata.TLIST[json_index].ENCNTR_STATUS);
		task_detailText.push('</td>');
		task_detailText.push('</tr>');
		task_detailText.push('<tr>');
		task_detailText.push('<td align=left>');
		task_detailText.push('Gender:<span id=patient_sex>'+pwxdata.TLIST[json_index].GENDER+'</span>');
		task_detailText.push('</td>');
		task_detailText.push('<td align=left>');
		task_detailText.push('PHN:<span id=patient_sex>'+pwxdata.TLIST[json_index].PHN+'</span>');
		task_detailText.push('</td>');
		task_detailText.push('</tr>');
		task_detailText.push('</table>');
		task_detailText.push('</div>');
		//task_detailText.push('</div>');
		task_detailText.push('</div></br>');
		
		task_detailText.push('<table class="action_list">');
		task_detailText.push('<thead><tr>');
		task_detailText.push('<th id="thDate">Action Date</th>');
		task_detailText.push('<th id="thAction">Action</th>');
		task_detailText.push('<th id="thPerformedBy">Performed By</th>');
		task_detailText.push('<th id="thPosition">Position</th>');
		task_detailText.push('</tr></thead>');
		
		var sendArr = [	"^MINE^"
						,pwxdata.TLIST[json_index].PARENT_EVENT_ID + ".0"
						];
		PWX_CCL_Request("dev_cust_mp_get_comment_hist", sendArr, false, function () {
			task_detailText.push('<tr><td colspan=6>'+this.ACTION_HISTORY+'</td></tr>');
		});
		task_detailText.push('</table>');
	
	   
		MP_ModalDialog.deleteModalDialogObject("TaskDetailModal")
		var TaskDetailModal = new ModalDialog("TaskDetailModal")
			 .setHeaderTitle(amb_i18n.TASK_DETAILS)
			 .setTopMarginPercentage(10)
			 .setRightMarginPercentage(10)
			 .setBottomMarginPercentage(10)
			 .setLeftMarginPercentage(10)
			 .setIsBodySizeFixed(true)
			 .setHasGrayBackground(true)
			 .setIsFooterAlwaysShown(true);
		TaskDetailModal.setBodyDataFunction(
			 function (modalObj) {
				 modalObj.setBodyHTML('<div class="pwx_task_detail">' + task_detailText.join("") + '</div>');
			 });
		var closebtn = new ModalButton("addCancel");
		closebtn.setText(amb_i18n.CLOSE).setCloseOnClick(true);
		TaskDetailModal.addFooterButton(closebtn)
		MP_ModalDialog.addModalDialogObject(TaskDetailModal);
		MP_ModalDialog.showModalDialog("TaskDetailModal")
		
	  });
	
	
	//comment history
	framecontentElem.on('click', 'span.pwx_fcr_comment_type_detail_icon_dt', function (e) {
		//$(this).parents('dl.pwx_content_row').removeClass('pwx_row_selected').addClass('pwx_row_selected');
		var json_index = $(this).children('span.pwx_task_json_index_hidden').text()
		var task_detailText = [];
		task_detailText.push('<div id=banner_bar>');
		task_detailText.push('<div id=banner_bar_font>');
		task_detailText.push('<table width=100% border=0>');
		task_detailText.push('<tr>');
		task_detailText.push('<td rowspan=3>');
		task_detailText.push('<b><span id=patient_name>'+pwxdata.TLIST[json_index].PERSON_NAME+'</span></b>');
		task_detailText.push('</td>');
		task_detailText.push('<td align=left>');
		task_detailText.push('DOB:<span id=patient_dob>'+pwxdata.TLIST[json_index].DOB+'</span>');
		task_detailText.push('<td align=left>');
		task_detailText.push('MRN:<span id=patient_mrn>'+pwxdata.TLIST[json_index].MRN+'</span>');
		task_detailText.push('</td>');
		task_detailText.push('<td align=left>');
		task_detailText.push('Location:<span id=patient_loc_unit>'+pwxdata.TLIST[json_index].UNIT+'</span>');
		if (pwxdata.TLIST[json_index].ROOM_BED > " ") {
			task_detailText.push(';&nbsp<span id=patient_loc_room_bed>'+pwxdata.TLIST[json_index].ROOM_BED+'</span>');
		}
		task_detailText.push('</td>');
		task_detailText.push('</tr>');
		task_detailText.push('<tr>');
		task_detailText.push('<td align=left>');
		task_detailText.push('Age:<span id=patient_age>'+pwxdata.TLIST[json_index].AGE_LONG+'</span>');
		task_detailText.push('</td>');
		task_detailText.push('<td align=left>');
		task_detailText.push('Enc:<span id=patient_fin>'+pwxdata.TLIST[json_index].FIN+'</span>');
		task_detailText.push('</td>');
		task_detailText.push('<td align=left>');
		task_detailText.push('<span id=patient_encntr_type>Enc Type:'+pwxdata.TLIST[json_index].ENCNTR_TYPE+'</span>;&nbsp;'+pwxdata.TLIST[json_index].ENCNTR_STATUS);
		task_detailText.push('</td>');
		task_detailText.push('</tr>');
		task_detailText.push('<tr>');
		task_detailText.push('<td align=left>');
		task_detailText.push('Gender:<span id=patient_sex>'+pwxdata.TLIST[json_index].GENDER+'</span>');
		task_detailText.push('</td>');
		task_detailText.push('<td align=left>');
		task_detailText.push('PHN:<span id=patient_sex>'+pwxdata.TLIST[json_index].PHN+'</span>');
		task_detailText.push('</td>');
		task_detailText.push('</tr>');
		task_detailText.push('</table>');
		task_detailText.push('</div>');
		//task_detailText.push('</div>');
		task_detailText.push('</div></br>');
		task_detailText.push('<table class="action_list"><thead><tr><th id="thDate">Action Date</th><th id="thAction">Comment</th><th id="thPerformedBy">Performed By</th><th id="thPosition">Position</th></tr></thead>');
		var sendArr = [	"^MINE^"
						,pwxdata.TLIST[json_index].PARENT_EVENT_ID + ".0"
						];
		PWX_CCL_Request("dev_cust_mp_get_comment_hist", sendArr, false, function () {
			task_detailText.push('<tr><td colspan=6>'+this.COMMENT_HISTORY+'</td></tr>');
		});
		task_detailText.push('</table>');
	   
		MP_ModalDialog.deleteModalDialogObject("CommentDetailModal")
		var CommentDetailModal = new ModalDialog("CommentDetailModal")
			 .setHeaderTitle(amb_i18n.TASK_COMMENT_DETAILS)
			 .setTopMarginPercentage(10)
			 .setRightMarginPercentage(10)
			 .setBottomMarginPercentage(10)
			 .setLeftMarginPercentage(10)
			 .setIsBodySizeFixed(true)
			 .setHasGrayBackground(true)
			 .setIsFooterAlwaysShown(true);
		CommentDetailModal.setBodyDataFunction(
			 function (modalObj) {
				 modalObj.setBodyHTML('<div class="pwx_task_detail">' + task_detailText.join("") + '</div>');
			 });
		var closebtn = new ModalButton("addCancel");
		closebtn.setText(amb_i18n.CLOSE).setCloseOnClick(true);
		CommentDetailModal.addFooterButton(closebtn)
		MP_ModalDialog.addModalDialogObject(CommentDetailModal);
		MP_ModalDialog.showModalDialog("CommentDetailModal")
	});
	
	//Requisition status history
	framecontentElem.on('click', 'span.pwx_fcr_status_type_detail_icon_dt', function (e) {
		//$(this).parents('dl.pwx_content_row').removeClass('pwx_row_selected').addClass('pwx_row_selected');
		var json_index = $(this).children('span.pwx_task_json_index_hidden').text()
		var task_detailText = [];
		task_detailText.push('<div id=banner_bar>');
		task_detailText.push('<div id=banner_bar_font>');
		task_detailText.push('<table width=100% border=0>');
		task_detailText.push('<tr>');
		task_detailText.push('<td rowspan=3>');
		task_detailText.push('<b><span id=patient_name>'+pwxdata.TLIST[json_index].PERSON_NAME+'</span></b>');
		task_detailText.push('</td>');
		task_detailText.push('<td align=left>');
		task_detailText.push('DOB:<span id=patient_dob>'+pwxdata.TLIST[json_index].DOB+'</span>');
		task_detailText.push('<td align=left>');
		task_detailText.push('MRN:<span id=patient_mrn>'+pwxdata.TLIST[json_index].MRN+'</span>');
		task_detailText.push('</td>');
		task_detailText.push('<td align=left>');
		task_detailText.push('Location:<span id=patient_loc_unit>'+pwxdata.TLIST[json_index].UNIT+'</span>');
		if (pwxdata.TLIST[json_index].ROOM_BED > " ") {
			task_detailText.push(';&nbsp<span id=patient_loc_room_bed>'+pwxdata.TLIST[json_index].ROOM_BED+'</span>');
		}
		task_detailText.push('</td>');
		task_detailText.push('</tr>');
		task_detailText.push('<tr>');
		task_detailText.push('<td align=left>');
		task_detailText.push('Age:<span id=patient_age>'+pwxdata.TLIST[json_index].AGE_LONG+'</span>');
		task_detailText.push('</td>');
		task_detailText.push('<td align=left>');
		task_detailText.push('Enc:<span id=patient_fin>'+pwxdata.TLIST[json_index].FIN+'</span>');
		task_detailText.push('</td>');
		task_detailText.push('<td align=left>');
		task_detailText.push('<span id=patient_encntr_type>Enc Type:'+pwxdata.TLIST[json_index].ENCNTR_TYPE+'</span>;&nbsp;'+pwxdata.TLIST[json_index].ENCNTR_STATUS);
		task_detailText.push('</td>');
		task_detailText.push('</tr>');
		task_detailText.push('<tr>');
		task_detailText.push('<td align=left>');
		task_detailText.push('Gender:<span id=patient_sex>'+pwxdata.TLIST[json_index].GENDER+'</span>');
		task_detailText.push('</td>');
		task_detailText.push('<td align=left>');
		task_detailText.push('PHN:<span id=patient_sex>'+pwxdata.TLIST[json_index].PHN+'</span>');
		task_detailText.push('</td>');
		task_detailText.push('</tr>');
		task_detailText.push('</table>');
		task_detailText.push('</div>');
		//task_detailText.push('</div>');
		task_detailText.push('</div></br>');
		task_detailText.push('<table class="action_list"><thead><tr>');
		task_detailText.push('<th id="thDate">Action Date</th>');
		
		task_detailText.push('<th id="thAction">Action</th>');
		task_detailText.push('<th id="thStatus">Status</th>');
		task_detailText.push('<th id="thSummary">Summary</th>');
		task_detailText.push('<th id="thPerformedBy">Performed By</th>');
		task_detailText.push('<th id="thPosition">Position</th>');
		task_detailText.push('</tr></thead>');
		var sendArr = [	"^MINE^"
						,pwxdata.TLIST[json_index].PARENT_EVENT_ID + ".0"
						];
		PWX_CCL_Request("dev_cust_mp_get_comment_hist", sendArr, false, function () {
			task_detailText.push('<tr><td colspan=6>'+this.STATUS_HISTORY+'</td></tr>');
		});
		task_detailText.push('</table>');
	   
		MP_ModalDialog.deleteModalDialogObject("TaskStatusModal")
		var TaskStatusModal = new ModalDialog("TaskStatusModal")
			 .setHeaderTitle(amb_i18n.TASK_STATUS_DETAILS)
			 .setTopMarginPercentage(10)
			 .setRightMarginPercentage(10)
			 .setBottomMarginPercentage(10)
			 .setLeftMarginPercentage(10)
			 .setIsBodySizeFixed(true)
			 .setHasGrayBackground(true)
			 .setIsFooterAlwaysShown(true);
		TaskStatusModal.setBodyDataFunction(
			 function (modalObj) {
				 modalObj.setBodyHTML('<div class="pwx_task_detail">' + task_detailText.join("") + '</div>');
			 });
		var closebtn = new ModalButton("addCancel");
		closebtn.setText(amb_i18n.CLOSE).setCloseOnClick(true);
		TaskStatusModal.addFooterButton(closebtn)
		MP_ModalDialog.addModalDialogObject(TaskStatusModal);
		MP_ModalDialog.showModalDialog("TaskStatusModal")
	});

   
	//adjust heights based on screen size
	var toolbarH = $('#pwx_frame_toolbar').height() + 6;
	$('#pwx_frame_filter_bar').css('top', toolbarH + 'px');
	
	var filterbarH = $('#pwx_frame_filter_bar').height() + toolbarH;
	$('#pwx_frame_content_rows_header').css('top', filterbarH + 'px');
	var contentrowsH = filterbarH + 19;
	$('#pwx_frame_content_rows').css('top', contentrowsH + 'px');
	
	$("#clerical_status").off("multiselectclose")
	$("#task_status").off("multiselectclose")
	$("#task_type").off("multiselectclose")
	$("#task_subtype").off("multiselectclose")
	$("#task_priority").off("multiselectclose")

    if (pwx_task_counter === undefined) {
		var pwx_task_counter = 0
	}
	$("#pwx_task_count").text('Requisition Count: '+pwx_task_counter)
	
	
	var comment_width = $('#pwx_fcr_header_clerkcomment_dt').width();
	if (comment_width > 150) {
		$('.pwx_fcr_input_clerkcomment_dt').css('max-width', (comment_width-10)+'px');
	} else {
		$('.pwx_fcr_input_clerkcomment_dt').css('max-width', '120px');
	}
		
	$(window).resize(function() {
		var comment_width = $('#pwx_fcr_header_clerkcomment_dt').width();
		//alert(comment_width);
		if (comment_width > 150) {
			$('.pwx_fcr_input_clerkcomment_dt').css('max-width', (comment_width-10)+'px');
		} else {
			$('.pwx_fcr_input_clerkcomment_dt').css('max-width', '120px');
		}
	});
	
	window.scrollTo(0,0);
	//timers!!
	var end_event_timer = new Date();
	var end_page_load_timer = new Date();
	var event_timer = (end_event_timer - start_event_timer) / 1000
	var content_timer = (end_content_timer - start_content_timer) / 1000
	var program_timer = (end_page_load_timer - start_page_load_timer) / 1000
	stop_pwx_timer()
	//$('#pwx_frame_content_rows').append('<dl id="pwx_list_timers_row" class="pwx_extra_small_text"><dt>CCL Timer: ' + ccl_timer + ' Page Load Timer: ' + program_timer + '</dt></dl>')
	
	if (js_criterion.CRITERION.POSITION == "DBA" || js_criterion.CRITERION.POSITION == "DBC - PowerChart") {
		$('#pwx_frame_content_rows').append('<dl id="pwx_list_timers_row" class="pwx_extra_small_text_white"><dt><span class="pwx_extra_small_text_black"><a href="#" onclick="javascript:OpenSupportTools()">Support Tools ('+js_criterion.CRITERION.POSITION+')</a></span></dt></dl>')
	} else {
		$('#pwx_frame_content_rows').append('<dl id="pwx_list_timers_row" class="pwx_extra_small_text_white"><dt><span class="pwx_extra_small_text_white">CCL Timer: ' + ccl_timer + ' Page Load Timer: ' + program_timer + '</span></dt></dl>')
	}
}

