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
    $("#version").text("1.2.0")
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
        
        //Requisition Definition Manager
        $("#main_menu_select").append($('<option>',
        {
            value: "req_manage",
            text : "Requisition Definition Manager"
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
            case "oef_manage":	OEFManage();
                                    break;
            case "announcement":	
                                    break;
            case "location_manage":	LocationManage();
                                    break;
            case "req_manage":	ReqDefinitionManage();
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
    locHTML.push('<select id="loc_manage_selection"></select>');
    locHTML.push('</td>');
    locHTML.push('</tr>');
    locHTML.push('</table>')
    locHTML.push('<div id="division_loc_menu" class="division_loc_menu"></div>');
    locHTML.push('<div id="loc_manage_section" class="loc_manage_section"></div>');
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
    locHTML.push('<div id="loc_jstree"></div>');
	locHTML.push('<div id="loc_detail" class="loc_detail"></div>');
    locHTML.push('</div>');
    
    $("#tool_content").html(locHTML.join(''))
    $("#loc_manage_section").html("")
    $("#loc_search").hide();
    $("#loc_req_loading").hide()
    $("#loc_search_loading").hide()
        
    //division_loc_menu
    $("#division_loc_menu").css('height','20px')

    $("#loc_manage_selection").append($('<option>',
        {
            value: "",
            text : "Select Location Management Tool"
        }));

    $("#loc_manage_selection").append($('<option>',
        {
            value: "loc_manage_activation",
            text : "Location Activation"
        }));

    $("#loc_manage_selection").append($('<option>',
        {
            value: "loc_manage_details",
            text : "Location Options"
        }));

    $("#loc_manage_selection").change(function() {
            var selected_loc = $("#loc_manage_selection").val();
            var selected_loc_text = $("#loc_manage_selection option:selected").text();

            console.log("--- loc_manage_selection selected="+selected_loc_text+":"+selected_loc);

            switch (selected_loc)	{
                case "loc_manage_activation":   LocationActivation();		
                                                break;
                case "loc_manage_details":	    LocationDetails();
                                                break;
                default: 	
                                        break;
            } 
    });

	function LocationDetails()	{

        $("#loc_search").hide();
        $("#loc_req_loading").hide()
        $("#loc_search_loading").hide()

		var locDetailRequest = window.external.XMLCclRequest();						
        locDetailRequest.open("GET","rm_location_manager",true);
        locDetailRequest.send("~MINE~")
        console.log("---- rm_location_manager params="+"~MINE~")
		locDetailRequest.onreadystatechange = function () {
            if (locDetailRequest.readyState == 4 && locDetailRequest.status == 200) {
                console.log("----- rm_location_manager finished")
                var jsonlocDetailRequest = JSON.parse(locDetailRequest.responseText);
                var locDetailResponse = jsonlocDetailRequest.RECORD_DATA;
				locDetailHTML = [];
				
				console.log("----- locDetailResponse.LOC_LIST.length="+locDetailResponse.LOC_LIST.length)
                locDetailHTML.push("<table>");
                for (var i = 0; i < locDetailResponse.LOC_LIST.length; i++) {
                    for (var j = 0; j < locDetailResponse.LOC_LIST[i].UNIT_QUAL.length; j++)	{
						if (locDetailResponse.LOC_LIST[i].UNIT_QUAL[j].CODE_VALUE > 0) {
							locDetailHTML.push("<tr>");
							locDetailHTML.push("<td>");
							locDetailHTML.push(locDetailResponse.LOC_LIST[i].FACILITY_NAME)
							locDetailHTML.push("</td>");
							locDetailHTML.push("<td>");
							locDetailHTML.push(locDetailResponse.LOC_LIST[i].UNIT_QUAL[j].UNIT_NAME)
							locDetailHTML.push("</td>");
							locDetailHTML.push("<td>");
							
							var unit_cd = locDetailResponse.LOC_LIST[i].UNIT_QUAL[j].UNIT_CD;
							var button_display = "iPPDF Only";

							if (locDetailResponse.LOC_LIST[i].UNIT_QUAL[j].IPPDF_ONLY == 0)	{
								var button_display = "Requisition Manager";
							}

							locDetailHTML.push("<input type=button class='locDetailBtn' value='"+button_display+"' id='"+unit_cd+"'></input>");
							locDetailHTML.push("</td>");
							locDetailHTML.push("</tr>");
						}
					}
				}
				locDetailHTML.push("</table>");
				$("#loc_manage_section").html(locDetailHTML.join(''))

				$('.locDetailBtn').click(function() {
					if (this.value == "Requisition Manager")	{
                        var newCDFMeaning = "iPPDF Only"
					}	else {
						var newCDFMeaning = "Requisition Manager"
					}
                    $(this).prop('value', newCDFMeaning);
                    console.log("------ locDetailBtn clicked")
                    console.log("------- this.value="+this.value)
                    console.log("------- this.id="+this.id)
                    console.log("------- newCDFMeaning="+newCDFMeaning)

                    var param_set = []
                    param_set.push("~MINE~")
                    param_set.push("~"+this.id+"~")
                    param_set.push("~"+newCDFMeaning+"~")
                    console.log("------- param_set="+param_set.join(','))
                        
                    var locUpdate = window.external.XMLCclRequest();						
                    locUpdate.open("GET","rm_location_manager",false);
                	locUpdate.send(param_set.join(','));
                    if (locUpdate.readyState == 4 && locUpdate.status == 200) {
                        console.log("-------- request processed")
						var jsonlocUpdateResponse = JSON.parse(locUpdate.responseText);
                		var locUpdateResponse = jsonlocUpdateResponse.RECORD_DATA;
						console.log("-------- locUpdateResponse="+JSON.stringify(locUpdateResponse))
                    } else {
                    	console.log("-------- request failed readyState="+locUpdate.readyState+" locUpdate.status="+locUpdate.status)
                    }
				});
			}
		}
	}

    function LocationActivation()	{
		
		$("#loc_manage_section").html('')
		$('#loc_jstree').jstree('destroy');
        
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
                        treeHTML.push(" id='"+locResponse.LOC_LIST[i].UNIT_QUAL[j].UNIT_CD+"'")
                        treeHTML.push(" value='"+locResponse.LOC_LIST[i].UNIT_QUAL[j].CODE_VALUE+"'>")
                        treeHTML.push(locResponse.LOC_LIST[i].UNIT_QUAL[j].UNIT_NAME)
						treeHTML.push(" ["+locResponse.LOC_LIST[i].UNIT_QUAL[j].CODE_VALUE+"]")
                        if (locResponse.LOC_LIST[i].UNIT_QUAL[j].IPPDF_ONLY == 1)   {
                            treeHTML.push(" (Print to PDF Only)")
                        }
                        treeHTML.push("</li></ul>")
                    }
                    treeHTML.push("</li></ul>")
                }

                $("#loc_jstree").html(treeHTML.join(''))
                
                $("#loc_jstree").hide()
                
                $('#loc_jstree').jstree({
                    "core" : {
                        "multiple" : true,
                        "animation" : 0,
                        "check_callback" : false
                    },

                    "plugins" : [ "wholerow", "checkbox", "search" ],

                    "checkbox" : {
                        "keep_selected_style" : false,
                        "whole_node": true,
                        "three_state": false,
                        "tie_selection" : true
                        },

                    "search" : {
                        "show_only_matches" : true,
                        },
                })

                $('#loc_jstree').on("deselect_node.jstree select_node.jstree", function(event, data){
                    console.log("------ location checked or unchecked")
                    console.log("------- data.id="+data.node.li_attr.id)
                    console.log("------- data.value="+data.node.li_attr.value)
                    console.log("------- data.selected="+data.node.state.selected)
                    console.log("------- data="+JSON.stringify(data.node))

                    if (data.node.li_attr.id == false)  {
                        console.log("------- not a valid location selection")
                    }

                    
                    var param_set = []
                    param_set.push("~MINE~")
                    param_set.push("~"+data.node.li_attr.id+"~")
                    param_set.push("~"+data.node.state.selected+"~")
                    console.log("------- param_set="+param_set.join(','))
                        
                    var locUpdate = window.external.XMLCclRequest();						
                    locUpdate.open("GET","rm_location_manager",false);
                	locUpdate.send(param_set.join(','));
                    if (locUpdate.readyState == 4 && locUpdate.status == 200) {
                        console.log("-------- request processed")
						var jsonlocUpdateResponse = JSON.parse(locUpdate.responseText);
                		var locUpdateResponse = jsonlocUpdateResponse.RECORD_DATA;
						console.log("-------- locUpdateResponse="+JSON.stringify(locUpdateResponse))
                    } else {
                    	console.log("-------- request failed readyState="+locUpdate.readyState+" locUpdate.status="+locUpdate.status)
                    }
                    
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
            }
        }

    };

    console.log("LocationManage ended");
}

function ReqDefinitionManage()	{
    console.log("ReqDefinitionManage started");
    
    ReqDefHTML = [];
    ReqDefHTML.push('<div id="reqdef_manage_content">');
        ReqDefHTML.push('<table id="reqdef_manage_table">');
            ReqDefHTML.push('<tr>');
            ReqDefHTML.push('<td>');
            ReqDefHTML.push('</td>');
            ReqDefHTML.push('<td><div id="reqdef_req_loading" class="reqdef_req_loading"></div>');
            ReqDefHTML.push('</td>');
            ReqDefHTML.push('</tr>');
        ReqDefHTML.push('</table>');
        ReqDefHTML.push('<div id="reqdef_search">')
            ReqDefHTML.push('<table>')
                ReqDefHTML.push('<tr>')
                ReqDefHTML.push('<td>')
                ReqDefHTML.push('<input id="search-input" class="search-input" default="Filter List"/>')
                ReqDefHTML.push('</td>')
                ReqDefHTML.push('<td>')
                ReqDefHTML.push('<div id="reqdef_search_loading" class="reqdef_search_loading"></div>');
                ReqDefHTML.push('</td>')
                ReqDefHTML.push('</tr>')
            ReqDefHTML.push('</table>')
            ReqDefHTML.push('</div>');
        ReqDefHTML.push('<div id="division_reqdef_menu" class="division_reqdef_menu"></div>');
        ReqDefHTML.push('<div id="reqdef_table"></div>');

    ReqDefHTML.push('</div>');
    
    $("#tool_content").html(ReqDefHTML.join(''))
    
    $("#search-input").attr("placeholder", "Type here to filter");
    $("#reqdef_search").hide();
    $("#reqdef_req_loading").show()
    $("#reqdef_search_loading").hide()
    
    
    var ReqDefRequest = window.external.XMLCclRequest();						
    ReqDefRequest.open("GET","rm_req_manager",true);
    ReqDefRequest.send("~MINE~")
    console.log("---- rm_req_manager params="+"~MINE~")
    ReqDefRequest.onreadystatechange = function () {
        if (ReqDefRequest.readyState == 4 && ReqDefRequest.status == 200) {
            console.log("----- rm_req_manager finished")
            var jsonReqDefResponse = JSON.parse(ReqDefRequest.responseText);
            
            var ReqDefResponse = jsonReqDefResponse.RECORD_DATA;
            ReqDefRespHTML = [];
            console.log("----- ReqDefResponse.req_list.length="+ReqDefResponse.REQ_LIST.length)
            ReqDefRespHTML.push('<table id="filter_reqdef_table" class="filter_reqdef_table">')
            ReqDefRespHTML.push('<th>Requsition Format Code</th>')
            ReqDefRespHTML.push('<th>Requsition Format Name</th>')
            ReqDefRespHTML.push('<th>Requsition Format Script</th>')
            ReqDefRespHTML.push('<th>iPPDF Requisition Title</th>')
            ReqDefRespHTML.push('<th>iPPDF Requisition Executable</th>')
            ReqDefRespHTML.push('<th>Orders Per Req</th>')
            ReqDefRespHTML.push('<th>Priority Group Order</th>')
            ReqDefRespHTML.push('<th>Priority OEF</th>')
            ReqDefRespHTML.push('<th>Priority Grouping</th>')
            ReqDefRespHTML.push('<th>Scheduling Location</th>')
            for (var i = 0; i < ReqDefResponse.REQ_LIST.length; i++) {
                if (ReqDefResponse.REQ_LIST[i].CODE_VALUE > 0.0)    {
                    var pdf_defined = 1
                } else {
                    var pdf_defined = 0
                }
                ReqDefRespHTML.push("<tr>")
                ReqDefRespHTML.push("<div class=reqdef_req_entry>")
                ReqDefRespHTML.push("<div class=reqdef_json_index>"+i+"</div>")
                ReqDefRespHTML.push("<td>"+ReqDefResponse.REQ_LIST[i].REQUISITION_FORMAT_CD+"</td>")
                ReqDefRespHTML.push("<td><div class='reqdef_item'>"+ReqDefResponse.REQ_LIST[i].REQUISITION_FORMAT_TITLE)
                ReqDefRespHTML.push("<input type=hidden class=reqdef_requisition_format_cd value='"+ReqDefResponse.REQ_LIST[i].REQUISITION_FORMAT_CD+"'></input>")
                ReqDefRespHTML.push("</div></td>")
                
                ReqDefRespHTML.push("<td>"+ReqDefResponse.REQ_LIST[i].DESCRIPTION+"</td>")
                
                ReqDefRespHTML.push("<td>")
                if (pdf_defined == 1) {ReqDefRespHTML.push("<input value='"+ReqDefResponse.REQ_LIST[i].DISPLAY+"'></input>")}
                ReqDefRespHTML.push("</td>")
                
                ReqDefRespHTML.push("<td>")
                if (pdf_defined == 1) {ReqDefRespHTML.push("<input value='"+ReqDefResponse.REQ_LIST[i].DEFINITION+"'></input>")}
                ReqDefRespHTML.push("</td>")

                ReqDefRespHTML.push("<td>")
                if (pdf_defined == 1) {

                    if (ReqDefResponse.REQ_LIST[i].ORDERS_PER_REQ_IND == 1) {
                        var single_checked = ' selected';
                        var multiple_checked = '';
                    } else { 
                        var single_checked = '';
                        var multiple_checked = ' selected';
                    }

                    ReqDefRespHTML.push("<select id='orders_per_req_ind'>")
                    ReqDefRespHTML.push("<option value=1 "+single_checked+">Single</option>")
                    ReqDefRespHTML.push("<option value=2 "+multiple_checked+">Multiple</option>")
                    ReqDefRespHTML.push("</select>")
                }
                ReqDefRespHTML.push("</td>")

                ReqDefRespHTML.push("<td>")
                if (pdf_defined == 1) {ReqDefRespHTML.push("<input value='"+ReqDefResponse.REQ_LIST[i].RM_PRIORITY_GROUP+"'></input>")}
                ReqDefRespHTML.push("</td>")

                ReqDefRespHTML.push("<td>")
                if (pdf_defined == 1) {ReqDefRespHTML.push("<input value='"+ReqDefResponse.REQ_LIST[i].RM_PRIORITY_OEM+"'></input>")}
                ReqDefRespHTML.push("</td>")
                
                ReqDefRespHTML.push("<td>")
                if (pdf_defined == 1) {ReqDefRespHTML.push("<input value='"+ReqDefResponse.REQ_LIST[i].RM_TYPE_DISPLAY+"'></input>")}
                ReqDefRespHTML.push("</td>")

                ReqDefRespHTML.push("<td>")
                if (pdf_defined == 1) {
                    if (ReqDefResponse.REQ_LIST[i].SCHED_LOC_CHECK == 1) {
                        var sched_loc_checked = ' checked';
                    } else { 
                        var sched_loc_checked = '';
                    }
                    
                    ReqDefRespHTML.push("<input type=checkbox id=sched_loc_check "+sched_loc_checked+"></input>")
                   
                }
                ReqDefRespHTML.push("</td>")
                
                ReqDefRespHTML.push("<div class=reqdef_req_entry>")
                ReqDefRespHTML.push("</tr>")
            }
            ReqDefRespHTML.push('</table>')
            $("#reqdef_table").html(ReqDefRespHTML.join(''))
            $("#reqdef_req_loading").hide()

            $('.reqdef_item').click(function () {
                var reqdef_requisition_format_cd = $(this).find('input.reqdef_requisition_format_cd').val()
                var param_set = []
                param_set.push("~MINE~")
                param_set.push(reqdef_requisition_format_cd)
                console.log("------- param_set="+param_set.join(','))
                        
                    var ReqDefUpdate = window.external.XMLCclRequest();						
                    ReqDefUpdate.open("GET","rm_req_manager",false);
                	ReqDefUpdate.send(param_set.join(','));
                    if (ReqDefUpdate.readyState == 4 && ReqDefUpdate.status == 200) {
                        console.log("-------- request processed")
						var jsonReqDefUpdateResponse = JSON.parse(ReqDefUpdate.responseText);
                		var ReqDefUpdateResponse = jsonReqDefUpdateResponse.RECORD_DATA;
						console.log("-------- ReqDefUpdateResponse="+JSON.stringify(ReqDefUpdateResponse))
                    } else {
                    	console.log("-------- request failed readyState="+ReqDefUpdate.readyState+" ReqDefUpdate.status="+ReqDefUpdate.status)
                    }
                ReqDefinitionManage();
            });
        }
    
    }
    
    function ActivateReqDef()   {
        alert(this)
    }
    
    console.log("ReqDefinitionManage ended");
}

function FilterManage()	{
    console.log("FilterManage started");
    
    filterHTML = [];
    filterHTML.push('<div id="filter_manage_content">');
        filterHTML.push('<table id="filter_manage_table">');
            filterHTML.push('<tr>');
            filterHTML.push('<td>');
            filterHTML.push('</td>');
            filterHTML.push('<td><div id="filter_req_loading" class="filter_req_loading"></div>');
            filterHTML.push('</td>');
            filterHTML.push('</tr>');
        filterHTML.push('</table>');
        filterHTML.push('<div id="filter_search">')
            filterHTML.push('<table>')
                filterHTML.push('<tr>')
                filterHTML.push('<td>')
                filterHTML.push('<input id="search-input" class="search-input" default="Filter List"/>')
                filterHTML.push('</td>')
                filterHTML.push('<td>')
                filterHTML.push('<div id="filter_search_loading" class="filter_search_loading"></div>');
                filterHTML.push('</td>')
                filterHTML.push('</tr>')
            filterHTML.push('</table>')
            filterHTML.push('</div>');
        filterHTML.push('<div id="division_filter_menu" class="division_filter_menu"></div>');
        filterHTML.push('<div id="filter_table"></div>');

    filterHTML.push('</div>');
    
    $("#tool_content").html(filterHTML.join(''))
    
    $("#search-input").attr("placeholder", "Type here to filter");
    $("#filter_search").hide();
    $("#filter_req_loading").show()
    $("#filter_search_loading").hide()
    
    
    var filterRequest = window.external.XMLCclRequest();						
    filterRequest.open("GET","rm_filter_manager",true);
    filterRequest.send("~MINE~")
    console.log("---- rm_filter_manager params="+"~MINE~")
    filterRequest.onreadystatechange = function () {
        if (filterRequest.readyState == 4 && filterRequest.status == 200) {
            console.log("----- rm_filter_manager finished")
            var jsonfilterResponse = JSON.parse(filterRequest.responseText);
            var filterResponse = jsonfilterResponse.RECORD_DATA;
            filterRespHTML = [];
            console.log("----- filterResponse.prsnl_qual.length="+filterResponse.PRSNL_QUAL.length)
            filterRespHTML.push('<table id="filter_prsnl_table">')
            filterRespHTML.push('<th>Position</th>')
            filterRespHTML.push('<th>Personnel</th>')
            filterRespHTML.push('<th>Current Default</th>')
            for (var i = 0; i < filterResponse.PRSNL_QUAL.length; i++) {
                filterRespHTML.push("<tr>")
                filterRespHTML.push("<td>"+filterResponse.PRSNL_QUAL[i].PRSNL_POSITION+"</td>")
                filterRespHTML.push("<td>"+filterResponse.PRSNL_QUAL[i].PRSNL_NAME+"</td>")
                filterRespHTML.push("<td>"+filterResponse.PRSNL_QUAL[i].DEFAULT_FILTER+"</td>")
                console.log("------ filterResponse.prsnl_qual.PRSNL_NAME="+filterResponse.PRSNL_QUAL[i].PRSNL_NAME)
                /*for (var j = 0; j < locResponse.LOC_LIST[i].UNIT_QUAL.length; j++)	{
                    filterRespHTML.push("<ul>")
                    if (locResponse.LOC_LIST[i].UNIT_QUAL[j].CODE_VALUE > 0) {
                        filterRespHTML.push("<li data-jstree='{\"opened\":true,\"selected\":true}'")
                    } else {
                        filterRespHTML.push("<li")
                    }
                    filterRespHTML.push(" id='"+locResponse.LOC_LIST[i].UNIT_QUAL[j].UNIT_CD+"'>")
                    filterRespHTML.push(locResponse.LOC_LIST[i].UNIT_QUAL[j].UNIT_NAME)
                    filterRespHTML.push("</li></ul>")
                }
                */
                filterRespHTML.push("</tr>")
            }
            filterRespHTML.push('</table>')
            $("#filter_table").html(filterRespHTML.join(''))
            $("#filter_req_loading").hide()
        }
    
    }
    
    console.log("FilterManage ended");
}