function mainLoad()		{
	
	console.log("mainLoad() starting");

	var mHTML = []
	mHTML.push('<div id="page_title"></div>');
	mHTML.push('<div id="version"></div>');
	mHTML.push('<div id="division_main_menu" class="division_main_menu"></div>');
	mHTML.push('<div id="main_menu">');
		mHTML.push('<table id="main_menu_table">');
		mHTML.push('<tr>');			
		mHTML.push('<td><select id="main_menu_select">');
		mHTML.push('</select></td>');
		mHTML.push('</tr>');
		mHTML.push('<table>');
	mHTML.push('</div>');
	mHTML.push('</div>');
	
	mHTML.push('<div id="division_tool_menu" class="division_tool_menu"></div>');
	mHTML.push('<div id="tool_menu" class="tool_menu">');
		mHTML.push('<table id="tool_menu_table">');
		mHTML.push('<tr>');			
		mHTML.push('<td><span class="section-title"><div id="tool_title"></div></span></td>');
		mHTML.push('');
		mHTML.push('</tr>');
		mHTML.push('<table>');
	mHTML.push('</div>');
	mHTML.push('</div>');
	
	mHTML.push('<div id="division_tool_content"></div>');
	mHTML.push('<div id="tool_content"></div>');
	
	mHTML.push('<div id="division_bottom"></div>');
	
	mHTML.push('<div id="console_toggle">');
		mHTML.push('<table id="console_table" class="console_table">');
		mHTML.push('<tr>');
		mHTML.push('<td width=200px"><input type="checkbox" id="console_toggle_chkbox" value=1></input>Toggle Console</td>');
		mHTML.push('<td width=200px"><input type="button" class="default-button" id="console_clear_btn" value="Clear Console"></input></td>');
		mHTML.push('<td><input type="button" class="default-button" id="console_copy_btn" value="Copy Console"></input></td>');
		mHTML.push('</tr>');
		mHTML.push('<tr>');
		mHTML.push('<td colspan=3><span class="console-log"><div id="console_log"></div></span></td>');
		mHTML.push('</tr>');
		mHTML.push('<table>');
	mHTML.push('</div>');
	
	$("#main_content").html(mHTML.join(''));
	console.log("- main_content updated");
	
	//setting HTML Defaults and Entriees
	
	
	//page_title and version
	$("#page_title").text("Requisition Manager and iPPDF Support Tools")
	$("#page_title").addClass('page-title')
	$("#version").text("1.1.0")
	$("#version").addClass('version')
	
	//main_menu_select
	$("#main_menu_select").append($('<option>',
		{
			value: "",
			text : "Select a Support Tool"
		}));
		
		//Build Audits
		$("#main_menu_select").append($('<option>',
			{
				value: "build_audit",
				text : "Application Build Audits"
			}));
		
		//Filter Manager
		$("#main_menu_select").append($('<option>',
			{
				value: "filter_manager",
				text : "Filter Manager"
			}));
		
		//Location Manager
		$("#main_menu_select").append($('<option>',
			{
				value: "location_manage",
				text : "Location Manager"
			}));
			
		//OEF Manager
		$("#main_menu_select").append($('<option>',
			{
				value: "oef_manage",
				text : "OEF Options Manager"
			}));
			
		//Announcment Manager
		$("#main_menu_select").append($('<option>',
			{
				value: "announcement",
				text : "Requisition Manager Announcements"
			}));

	//division_tool_content
	$("#division_tool_content").css('height','20px')
	
	//division_bottom
	$("#division_bottom").css('height','100px')
	console.log("- main_content defaults set");
	
	//console_toggle_chkbox
	$("#console_toggle_chkbox").change(function() {
		console.log("console_toggle_chkbox clicked");
		var console_check = 0
		console_check = $("#console_toggle_chkbox").prop("checked");
		console.log("- console_check="+console_check);
		viewConsole(console_check)
	});
	
	//console_clear_btn
	$("#console_clear_btn").click(function() {
		console.log("console_clear_btn clicked");
		console.log("- console cleared");
		$("#console_log").html('');
	});
	
	//console_copy_btn
	$("#console_copy_btn").click(function() {
		console.log("console_copy_btn clicked");
		console.log("- console selected and copied");
		var currentDOM = JSON.stringify(document.body.outerHTML)
		currentDOM = currentDOM.replace(/[<>&\n]/g, function(x) {
			return {
				'<': '&lt;',
				'>': '&gt;',
				'&': '&amp;',
			   '\n': '<br />'
			}[x];
		});
		console.log("<pre>" + currentDOM + "</pre><br>")
	});
	
	//main_menu_select
	$("#main_menu_select").change(function() {
		console.log("main_menu_select changed");
		var selected_menu = $("#main_menu_select").val()
		var selected_text = $("#main_menu_select option:selected").text()
		console.log("- selected="+selected_menu+","+selected_text);
		$("#tool_title").text(selected_text); 
		$("#tool_content").off()
		$("#tool_content").html("")
		switch (selected_menu)	{
			case "build_audit":		
									break;
			case "filter_manager":	FilterManage();
									break;
			case "oef_manage":		OEFManage();
									break;
			case "announcement":	
									break;
			case "location_manage":	LocationManage();
									break;
			default: 	
									break;
		} 
		
	});
	
	console.log("- main_content events set");
	
	
	//console_toggle_chkbox
	//set the default value of the console check box 
	//which will determine if it's on by default
	$("#console_toggle_chkbox").prop("checked",false).change()
	
	console.log("mainLoad() ending");

}

function viewConsole(viewable)	{
	console.log("viewConsole started");
	$("#console_log").hide()
	$("#console_clear_btn").hide()
	$("#console_copy_btn").hide()
	if (viewable == 1) {	
		$("#console_log").show()
		$("#console_clear_btn").show()
		$("#console_copy_btn").show()
		console.log("- showig console");		
		} else {
		console.log("- hiding console");		
	}
}


(function(){
    // Save the original method in a private variable
    var _privateLog = console.log;
    // Redefine console.log method with a custom function
    console.log = function (message) {
		$("#console_log").prepend("<br/>["+Date.now()+"] "+message);
        _privateLog.apply(console, arguments);
    };
})();

function OEFManage()	{
	console.log("OEFManage started");
	
	oefHTML = [];
	oefHTML.push('<div id="oef_manage_content">');
	oefHTML.push('<table id="oef_manage_table">');
	oefHTML.push('<tr>');
	oefHTML.push('<td>');
	oefHTML.push('<select id="oef_req_selection"></select>');
	oefHTML.push('</td>');
	oefHTML.push('<td><div id="oef_req_loading" class="oef_req_loading"></div>');
	oefHTML.push('</td>');
	oefHTML.push('</tr>');
	oefHTML.push('</table>');
	oefHTML.push('<div id="oef_manage_field_division"></div>');
	oefHTML.push('<div id="oef_manage_field_rows"></div>');
	oefHTML.push('</div>');
	
	$("#tool_content").html(oefHTML.join(''))
	$("#oef_req_loading").hide()
	$("#oef_req_selection").change(function() {
		var selected_req = $("#oef_req_selection").val()
		var selected_req_text = $("#oef_req_selection option:selected").text()
		console.log("--- oef_req_selection selected="+selected_req_text+":"+selected_req)
		
		var OEFRequest = window.external.XMLCclRequest();						
		OEFRequest.open("GET","rm_oef_manager",true);
		OEFRequest.send("~MINE~,~"+selected_req+"~")
		console.log("---- rm_oef_manager params="+"~MINE~,~"+selected_req+"~")
		
		$("#oef_req_loading").show()
		$("#oef_manage_field_rows").html("")
		
		//oef_manage_field_division
		$("#oef_manage_field_division").css('height','20px')
	
		
		OEFRequest.onreadystatechange = function () {
			if (OEFRequest.readyState == 4 && OEFRequest.status == 200) {
				//console.log("----- responseText="+OEFRequest.responseText);
				var jsonOEFResponse = JSON.parse(OEFRequest.responseText);
				var OEFResponse = jsonOEFResponse.RECORD_DATA;
				$("#oef_req_loading").hide()
				headerHTML = [];
				headerHTML.push('<table id="oef_manage_fields" class="oef_manage_fields">');
				headerHTML.push("<tr>")
				headerHTML.push("<th>")
				headerHTML.push("Order Entry Format")
				headerHTML.push("</th>")
				headerHTML.push("<th align=left>")
				headerHTML.push("Order Entry Field")
				headerHTML.push("</th>")
				headerHTML.push("<th>")
				headerHTML.push("Check to Trigger Modify")
				headerHTML.push("</th>")
				headerHTML.push("<th>")
				headerHTML.push("Last Modification DT/TM")
				headerHTML.push("</th>")
				headerHTML.push("<th>")
				headerHTML.push("Last Modification by")
				headerHTML.push("</th>")
				headerHTML.push("</tr>")
				for (var i = 0; i < OEFResponse.REQUSITIONS.length; i++) {
					if (OEFResponse.REQUSITIONS[i].FORMAT_CD == selected_req)	{
						console.log("------ requisition matched");
						for (var j = 0; j < OEFResponse.REQUSITIONS[i].FORMATS.length; j++) {
							console.log("------- REQUSITIONS.FORMATS="+OEFResponse.REQUSITIONS[i].FORMATS[j].OE_FORMAT_ID+":"+OEFResponse.REQUSITIONS[i].FORMATS[j].OE_FORMAT_NAME);

							for (var k = 0; k < OEFResponse.REQUSITIONS[i].FORMATS[j].FIELDS.length; k++) {
								console.log("-------- REQUSITIONS.FIELDS="+OEFResponse.REQUSITIONS[i].FORMATS[j].FIELDS[k].OE_FIELD_ID+":"+OEFResponse.REQUSITIONS[i].FORMATS[j].FIELDS[k].OE_FIELD_DESC);
								headerHTML.push("<tr>")
								if (OEFResponse.REQUSITIONS[i].PROCESSING_TYPE == 1) {
									if (k == 0) { 
										headerHTML.push("<td valign=top rowspan="+OEFResponse.REQUSITIONS[i].FORMATS[j].FIELDS.length+">")
										headerHTML.push("All Order Entry Formats for the orders using this requsition format will follow the trigger setting for each field.")
										headerHTML.push("<br><br>[Fields are either triggers or not triggers across all Order Entry Formats]")
									}
								} else {
									if (k == 0) { 
										headerHTML.push("<td valign=top rowspan="+OEFResponse.REQUSITIONS[i].FORMATS[j].FIELDS.length+">")
										headerHTML.push(OEFResponse.REQUSITIONS[i].FORMATS[j].OE_FORMAT_NAME)
										headerHTML.push("</td>")
									}
								}
								
								var code_value = OEFResponse.REQUSITIONS[i].FORMATS[j].FIELDS[k].CODE_VALUE
								var requisition_format_cd = OEFResponse.REQUSITIONS[i].FORMAT_CD
								var oe_format_id = OEFResponse.REQUSITIONS[i].FORMATS[j].OE_FORMAT_ID
								var oe_field_id = OEFResponse.REQUSITIONS[i].FORMATS[j].FIELDS[k].OE_FIELD_ID
								var checkbox_value = requisition_format_cd+"#"+oe_format_id+"#"+oe_field_id+"#"+code_value
								console.log("--------- checkbox_value="+checkbox_value)
								
								headerHTML.push("<td>")
								headerHTML.push(OEFResponse.REQUSITIONS[i].FORMATS[j].FIELDS[k].OE_FIELD_DESC)
								headerHTML.push("</td>")
								headerHTML.push("<td align=center>")
								headerHTML.push("<input type='checkbox' class='oef_field_definition'")
								headerHTML.push("value='"+checkbox_value+"' ")
								if (OEFResponse.REQUSITIONS[i].FORMATS[j].FIELDS[k].ACTIVE_IND == 1) {
									headerHTML.push("checked ");
								}
								headerHTML.push(">")
								headerHTML.push("</input>")
								headerHTML.push("</td>")
								headerHTML.push("<td>")
								headerHTML.push(OEFResponse.REQUSITIONS[i].FORMATS[j].FIELDS[k].MODIFIED_DT_TM)
								headerHTML.push("</td>")
								headerHTML.push("<td>")
								headerHTML.push(OEFResponse.REQUSITIONS[i].FORMATS[j].FIELDS[k].MODIFIED_BY)
								headerHTML.push("</td>")
								headerHTML.push("</tr>")
							}
						}
					}
				}
				headerHTML.push('</table>');
				$("#oef_manage_field_rows").append(headerHTML.join(''))
				console.log("------ headerHTML added to oef_manage_field_rows")
				
				$('.oef_field_definition').on('change', function (e) {
					console.log("------ oef_field_definition checked or unchecked")
					console.log("------- checked="+this.checked)
					console.log("------- value="+this.value)
					var param_values = this.value.split("#");
					console.log("------- param_values="+JSON.stringify(param_values))
					
					var param_set = []
					param_set.push("~MINE~")
					param_set.push("~"+param_values[0]+"~")
					param_set.push("~"+param_values[1]+"~")
					param_set.push("~"+param_values[2]+"~")
					param_set.push("~"+this.checked+"~")
					param_set.push("~"+param_values[3]+"~")
					console.log("------- param_set="+param_set.join(','))
					
					var OEFUpdate = window.external.XMLCclRequest();						
					OEFUpdate.open("GET","rm_oef_manager",false);
					OEFUpdate.send(param_set.join(','));
					if (OEFUpdate.readyState == 4 && OEFUpdate.status == 200) {
						console.log("-------- request processed")
					} else {
						console.log("-------- request failed readyState="+OEFUpdate.readyState+" OEFUpdate.status="+OEFUpdate.status)
					}
				})
			}
		};
	});
	
	$("#oef_req_selection").append($('<option>',
		{
			value: "",
			text : "Select Requisition Format"
		}));
			
	var OEFRequest = window.external.XMLCclRequest();						
	OEFRequest.open("GET","rm_oef_manager",false);
	OEFRequest.send("~MINE~");
	if (OEFRequest.readyState == 4 && OEFRequest.status == 200) {
		console.log("- responseText="+OEFRequest.responseText);
		var jsonOEFResponse = JSON.parse(OEFRequest.responseText);
		var OEFResponse = jsonOEFResponse.RECORD_DATA;
		for (var i = 0; i < OEFResponse.REQUSITIONS.length; i++) {
			console.log("-- OEFResponse="+i+":"+OEFResponse.REQUSITIONS[i].FORMAT_CD+":"+OEFResponse.REQUSITIONS[i].FORMAT_NAME);
			$('#oef_req_selection').append( '<option value="'+OEFResponse.REQUSITIONS[i].FORMAT_CD+'">'+OEFResponse.REQUSITIONS[i].PDF_NAME+" - "+OEFResponse.REQUSITIONS[i].FORMAT_NAME+'</option>' );
		}
	}
	
	
	console.log("OEFManage ended");
}

function LocationManage()	{
	console.log("LocationManage started");
	
	locHTML = [];
	locHTML.push('<div id="loc_manage_content">');
	locHTML.push('<table id="loc_manage_table">');
	locHTML.push('<tr>');
	locHTML.push('<td>');
	locHTML.push('</td>');
	locHTML.push('<td><div id="loc_req_loading" class="loc_req_loading"></div>');
	locHTML.push('</td>');
	locHTML.push('</tr>');
	locHTML.push('</table>');
	locHTML.push('<div id="loc_search">')
	locHTML.push('<table>')
	locHTML.push('<tr>')
	locHTML.push('<td>')
	locHTML.push('<input id="search-input" class="search-input" default="Filter List"/>')
	locHTML.push('</td>')
	locHTML.push('<td>')
	locHTML.push('<div id="loc_search_loading" class="loc_search_loading"></div>');
	locHTML.push('</td>')
	locHTML.push('</tr>')
	locHTML.push('</table>')
	locHTML.push('<div id="division_loc_menu" class="division_loc_menu"></div>');
	locHTML.push('<div id="loc_jstree"></div>');
	locHTML.push('</div>');
	
	$("#tool_content").html(locHTML.join(''))
	
	$("#search-input").attr("placeholder", "Type here to filter");
	$("#loc_search").hide();
	$("#loc_req_loading").show()
	$("#loc_search_loading").hide()
	
	var locRequest = window.external.XMLCclRequest();						
	locRequest.open("GET","rm_location_manager",true);
	locRequest.send("~MINE~")
	console.log("---- rm_location_manager params="+"~MINE~")
	locRequest.onreadystatechange = function () {
		if (locRequest.readyState == 4 && locRequest.status == 200) {
			console.log("----- rm_location_manager finished")
			var jsonlocResponse = JSON.parse(locRequest.responseText);
			var locResponse = jsonlocResponse.RECORD_DATA;
			treeHTML = [];
			console.log("----- locResponse.LOC_LIST.length="+locResponse.LOC_LIST.length)
			
			for (var i = 0; i < locResponse.LOC_LIST.length; i++) {
				treeHTML.push("<ul><li class='no_checkbox'>"+locResponse.LOC_LIST[i].FACILITY_NAME)
				for (var j = 0; j < locResponse.LOC_LIST[i].UNIT_QUAL.length; j++)	{
					treeHTML.push("<ul>")
					if (locResponse.LOC_LIST[i].UNIT_QUAL[j].CODE_VALUE > 0) {
						treeHTML.push("<li data-jstree='{\"opened\":true,\"selected\":true}'")
					} else {
						treeHTML.push("<li")
					}
					treeHTML.push(" id='"+locResponse.LOC_LIST[i].UNIT_QUAL[j].UNIT_CD+"'>")
					treeHTML.push(locResponse.LOC_LIST[i].UNIT_QUAL[j].UNIT_NAME)
					treeHTML.push("</li></ul>")
				}
				treeHTML.push("</li></ul>")
			}
			$("#loc_jstree").html(treeHTML.join(''))
			
			$("#loc_jstree").hide()
			
			$(function () { $('#loc_jstree').jstree({
				  "core" : {
					"multiple" : true,
					"animation" : 0
				  },
				  "plugins" : [ "wholerow", "checkbox", "search" ],
				  "checkbox" : {
					"keep_selected_style" : false,
					"whole_node": true,
					"three_state": false
				},
				"search" : {
					"show_only_matches" : true,
				},
				}); 
			$(".no_checkbox").find('> a > .jstree-checkbox').remove()
			$("#loc_jstree").show();
			$("#loc_search").show();
			$("#loc_req_loading").hide();
			
			$(".search-input").change(function () {
                var searchString = $(this).val();
                $('#loc_jstree').jstree('search', searchString);
				$(".no_checkbox").find('> a > .jstree-checkbox').remove()
            });
			
			});
		}
	}
	console.log("LocationManage ended");
}

function FilterManage()	{
	console.log("FilterManage started");
	console.log("FilterManage started");
}