;REMOVE ITEMS MARKED WITH REMOVE
DROP PROGRAM mp_requisition_manager :dba GO
CREATE PROGRAM mp_requisition_manager :dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE" ,
  "Personnel ID:" = 0.00 ,
  "Provider Position Code:" = 0.00 ,
  "Executable in Context:" = "" ,
  "Device Location:" = "" ,
  "Static Content Location:" = ""
  WITH outdev ,personnelid ,positioncode ,executableincontext ,devicelocation ,staticcontentlocation
 FREE RECORD criterion
 RECORD criterion (
   1 prsnl_id = f8
   1 support_position = vc
   1 support_tools = c1
   1 support_tools_ind = c1
   1 username = vc
   1 position = vc
   1 executable = vc
   1 static_content = vc
   1 position_cd = f8
   1 ppr_cd = f8
   1 debug_ind = i2
   1 help_file_local_ind = i2
   1 category_mean = vc
   1 locale_id = vc
   1 device_location = vc
   1 pwx_help_link = vc
   1 pwx_reflab_help_link = vc
   1 pwx_patient_summ_prg = vc
   1 pwx_task_list_disp = i2
   1 pwx_reflab_list_disp = i2
   1 pwx_tab_pref_found = i2
   1 pwx_tab_pref = vc
   1 pwx_adv_print = i2
   1 loc_pref_found = i2
   1 loc_pref_id = vc
   1 loc_list [* ]
     2 org_name = vc
     2 org_id = f8
     2 unit[*]
      3 unit_name = vc
      3 unit_id = f8
   1 vpref [* ]
     2 view_caption = vc
     2 view_seq = i2
   1 filter_sets_cnt = i2
   1 filter_sets[*]
    2 filter_set_name = vc
    2 pvc_name = vc
    2 selected = i2
   1 filter_sets_pref = vc
   1 default_filter_set = vc
   1 status_data
     2 status = c1
     2 subeventstatus [1 ]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD reportid_rec
 RECORD reportid_rec (
   1 cnt = i4
   1 qual [* ]
     2 value = f8
 )
 FREE RECORD viewpointinfo_rec
 RECORD viewpointinfo_rec (
   1 viewpoint_name = vc
   1 cnt = i4
   1 views [* ]
     2 view_name = vc
     2 view_sequence = i4
     2 view_cat_mean = vc
 )
 DECLARE current_date_time = dq8 WITH constant (cnvtdatetime (curdate ,curtime3 ) ) ,protect
 DECLARE current_time_zone = i4 WITH constant (datetimezonebyname (curtimezone ) ) ,protect
 DECLARE ending_date_time = dq8 WITH constant (cnvtdatetime ("31-DEC-2100" ) ) ,protect
 DECLARE bind_cnt = i4 WITH constant (50 ) ,protect
 DECLARE lower_bound_date = vc WITH constant ("01-JAN-1800 00:00:00.00" ) ,protect
 DECLARE upper_bound_date = vc WITH constant ("31-DEC-2100 23:59:59.99" ) ,protect
 DECLARE codelistcnt = i4 WITH noconstant (0 ) ,protect
 DECLARE prsnllistcnt = i4 WITH noconstant (0 ) ,protect
 DECLARE phonelistcnt = i4 WITH noconstant (0 ) ,protect
 DECLARE code_idx = i4 WITH noconstant (0 ) ,protect
 DECLARE prsnl_idx = i4 WITH noconstant (0 ) ,protect
 DECLARE phone_idx = i4 WITH noconstant (0 ) ,protect
 DECLARE prsnl_cnt = i4 WITH noconstant (0 ) ,protect
 DECLARE mpc_ap_type_cd = f8 WITH protect ,noconstant (0.0 )
 DECLARE mpc_doc_type_cd = f8 WITH protect ,noconstant (0.0 )
 DECLARE mpc_mdoc_type_cd = f8 WITH protect ,noconstant (0.0 )
 DECLARE mpc_rad_type_cd = f8 WITH protect ,noconstant (0.0 )
 DECLARE mpc_txt_type_cd = f8 WITH protect ,noconstant (0.0 )
 DECLARE mpc_num_type_cd = f8 WITH protect ,noconstant (0.0 )
 DECLARE mpc_immun_type_cd = f8 WITH protect ,noconstant (0.0 )
 DECLARE mpc_med_type_cd = f8 WITH protect ,noconstant (0.0 )
 DECLARE mpc_date_type_cd = f8 WITH protect ,noconstant (0.0 )
 DECLARE mpc_done_type_cd = f8 WITH protect ,noconstant (0.0 )
 DECLARE mpc_mbo_type_cd = f8 WITH protect ,noconstant (0.0 )
 DECLARE mpc_procedure_type_cd = f8 WITH protect ,noconstant (0.0 )
 DECLARE mpc_grp_type_cd = f8 WITH protect ,noconstant (0.0 )
 DECLARE mpc_hlatyping_type_cd = f8 WITH protect ,noconstant (0.0 )
 DECLARE eventclasscdpopulated = i2 WITH protect ,noconstant (0 )
 DECLARE log_program_name = vc WITH protect ,noconstant ("" )
 DECLARE log_override_ind = i2 WITH protect ,noconstant (0 )
 SET log_program_name = curprog
 SET log_override_ind = 0
 DECLARE log_level_error = i2 WITH protect ,noconstant (0 )
 DECLARE log_level_warning = i2 WITH protect ,noconstant (1 )
 DECLARE log_level_audit = i2 WITH protect ,noconstant (2 )
 DECLARE log_level_info = i2 WITH protect ,noconstant (3 )
 DECLARE log_level_debug = i2 WITH protect ,noconstant (4 )
 DECLARE hsys = i4 WITH protect ,noconstant (0 )
 DECLARE sysstat = i4 WITH protect ,noconstant (0 )
 DECLARE serrmsg = c132 WITH protect ,noconstant (" " )
 DECLARE ierrcode = i4 WITH protect ,noconstant (error (serrmsg ,1 ) )
 DECLARE crsl_msg_default = i4 WITH protect ,noconstant (0 )
 DECLARE crsl_msg_level = i4 WITH protect ,noconstant (0 )
 EXECUTE msgrtl
 SET crsl_msg_default = uar_msgdefhandle ()
 SET crsl_msg_level = uar_msggetlevel (crsl_msg_default )
 DECLARE lcrslsubeventcnt = i4 WITH protect ,noconstant (0 )
 DECLARE icrslloggingstat = i2 WITH protect ,noconstant (0 )
 DECLARE lcrslsubeventsize = i4 WITH protect ,noconstant (0 )
 DECLARE icrslloglvloverrideind = i2 WITH protect ,noconstant (0 )
 DECLARE scrsllogtext = vc WITH protect ,noconstant ("" )
 DECLARE scrsllogevent = vc WITH protect ,noconstant ("" )
 DECLARE icrslholdloglevel = i2 WITH protect ,noconstant (0 )
 DECLARE icrslerroroccured = i2 WITH protect ,noconstant (0 )
 DECLARE lcrsluarmsgwritestat = i4 WITH protect ,noconstant (0 )
 DECLARE crsl_info_domain = vc WITH protect ,constant ("DISCERNABU SCRIPT LOGGING" )
 DECLARE crsl_logging_on = c1 WITH protect ,constant ("L" )
 IF ((((logical ("MP_LOGGING_ALL" ) > " " ) ) OR ((logical (concat ("MP_LOGGING_" ,log_program_name ) ) > " " ) )) )
  SET log_override_ind = 1
 ENDIF

%i cust_script:mp_requisition_manager.inc

 ;SET log_program_name = "AMB_CUST_ORG_TASK_DRIVER"

 DECLARE vcjsreqs = vc WITH protect ,noconstant ("" )
 declare vcjsmpage = vc WITH protect ,noconstant ("" )
 Declare vcjscore = vc with protect, noconstant("")
 Declare vcjsfoundation = vc with protect, noconstant("")
 DECLARE vcjsrenderfunc = vc WITH protect ,noconstant ("" )
 Declare vcjsmanager = vc with protect, noconstant("")
 Declare vcjsbootstrapmultiselectmin = vc with protect, noconstant("")
 Declare vcjsbootstrap = vc with protect, noconstant("")
 Declare vcjscontextmenu = vc with protect, noconstant("")
 Declare vcjsmodal = vc with protect, noconstant("")
 Declare vcjsjson = vc with protect, noconstant("")
 DECLARE vcjsdate = vc WITH protect ,noconstant ("" )
 DECLARE vcjsdaterangepicker = vc WITH protect ,noconstant ("" )
 DECLARE vcjsmoment = vc WITH protect ,noconstant ("" )
 DECLARE vcjshtmlsanitizer = vc WITH protect ,noconstant ("" )
 Declare vcjsdownload = vc with protect, noconstant("")
 DECLARE vcjsfilesaver = vc WITH protect ,noconstant ("" )
 
 DECLARE vccssreqs = vc WITH protect ,noconstant ("" )
 DECLARE vccsschzn = vc WITH protect ,noconstant ("" )
 DECLARE vccsschosen = vc WITH protect ,noconstant ("" ) 
 DECLARE vccssfoundation = vc WITH protect ,noconstant ("" )
 DECLARE vccsbootstrapmultiselectmin = vc WITH protect ,noconstant ("" )
 DECLARE vccsbootstrap = vc WITH protect ,noconstant ("" )
 DECLARE vccsdaterangepicker = vc WITH protect ,noconstant ("" )
 
 DECLARE vcjsjquery = vc WITH protect ,noconstant ("" )
 DECLARE vcjsjqueryui = vc WITH protect ,noconstant ("" )

 Declare vcjspdf = vc with protect, noconstant("")
 Declare vcjspdfobj = vc with protect, noconstant("")
 Declare vcpdfjs = vc with protect, noconstant("")
 Declare vcjspdfworker = vc with protect, noconstant("")

 DECLARE vcpagelayout = vc WITH protect ,noconstant ("" )
 DECLARE vcstaticcontent = vc WITH protect ,noconstant ("" )
 DECLARE lstat = i4 WITH protect ,noconstant (0 )
 DECLARE z = i4 WITH private ,noconstant (0 )
 DECLARE 222_fac = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.CODEVALUE!2844" ) )
 DECLARE position_bedrock_settings = i2
 DECLARE user_pref_string = vc
 DECLARE user_pref_found = i2
 DECLARE localefilename = vc WITH noconstant ("" ) ,protect
 DECLARE localeobjectname = vc WITH noconstant ("" ) ,protect
 DECLARE temp_string = vc
 
 SET criterion->prsnl_id =  $PERSONNELID
 SET criterion->executable =  $EXECUTABLEINCONTEXT
 SET criterion->position_cd =  $POSITIONCODE
 SET criterion->locale_id = ""
 SET criterion->static_content =  $STATICCONTENTLOCATION
 SET criterion->device_location =  $DEVICELOCATION
 /*
 CALL getbedrocksettings ( $POSITIONCODE )
 
 IF ((position_bedrock_settings = 0 ) )
  CALL getbedrocksettings (0.00 )
 ENDIF
 */
 
 ;CALL gatherlocations ( $PERSONNELID )
 ;CALL gatheruserprefs ( $PERSONNELID ,"TEST_" )

 select into "nl:"
 from 
 	prsnl p
 plan p
 	where p.person_id = criterion->prsnl_id
 detail
 	criterion->username = p.username
 	criterion->position = uar_get_code_display(p.position_cd)

 with nocounter

 if (criterion->position in ("DBA","DBA - PowerChart"))
 	set criterion->support_tools_ind = "1"
 	set criterion->support_position = "ADMIN"
 endif
  
 if  (criterion->prsnl_id in(      15058148.00 ;chad
 							; ,   15560939.00 ;lisa
 							; , 21549199 ;zihan
 							 ))
 	SET criterion->static_content = "I:\\WININTEL\\static_content\\custom_mpage_content\\requisition_manager_dev"
 endif
 
 set criterion->filter_sets_pref = "TEST_"
 

 
 
 SELECT INTO "nl:"
   FROM (app_prefs a ),
    (name_value_prefs n )
   PLAN (a
    WHERE (a.prsnl_id = criterion->prsnl_id ) 
     AND (a.application_number = 600005 ) )
    JOIN (n
    WHERE (n.parent_entity_id = a.app_prefs_id )
    AND (n.parent_entity_name = "APP_PREFS" )
    AND (n.pvc_name = "TEST_*" ) )
   ORDER BY n.pvc_name,n.sequence
   head n.pvc_name
   if (n.pvc_name != "*DEFAULT_FILTER_SET")
   	criterion->filter_sets_cnt = (criterion->filter_sets_cnt + 1)
   	stat = alterlist(criterion->filter_sets,criterion->filter_sets_cnt)
   	criterion->filter_sets[criterion->filter_sets_cnt].pvc_name = n.pvc_name
   elseif (n.pvc_name = "*DEFAULT_FILTER_SET")
   	criterion->default_filter_set = replace(
 		n.pvc_value,
 		criterion->filter_sets_pref,"") 
   endif
   WITH nocounter
 
 for (i=1 to criterion->filter_sets_cnt)
 	set criterion->filter_sets[i].filter_set_name = replace(
 		criterion->filter_sets[i].pvc_name,
 		criterion->filter_sets_pref,"") 
 	if (criterion->filter_sets[i].filter_set_name = criterion->default_filter_set)
 		set criterion->filter_sets[i].selected = 1
 	endif
 endfor
 
 CALL checkcriterion (null )
 CALL getlocaledata (null )
 CALL generatestaticcontentreqs (null )
 CALL generatepagehtml (null )

SUBROUTINE  generatestaticcontentreqs (null )
  CALL log_message ("In GenerateStaticContentReqs()" ,log_level_debug )
  DECLARE begin_date_time = dq8 WITH constant (cnvtdatetime (curdate ,curtime3 ) ) ,private
 
 SET vcjsreqs = build2 ('<script type="text/javascript" src="'
 	,criterion->static_content ,"/js/locale/" ,localefilename ,'.js"></script>' )
 
 set vcjsmpage = build2('<script type="text/javascript" src="'
 	,'http://104.170.114.248/discern/c0665.chs_tn.cernerasp.com/script/mpage.js"','</script>' )
 
 SET vccssreqs = build2 ('<link rel="stylesheet" type="text/css" href="'
 	,criterion->static_content,'\css\manager.css" />' )

 SET vccsschzn = build2 ('<link rel="stylesheet" type="text/css" href="'
 	,criterion->static_content,'\css\chzn.css" />' )

 SET vccsschosen = build2 ('<link rel="stylesheet" type="text/css" href="'
 	,criterion->static_content,'\css\chosen.css" />' )
 	
 SET vccssfoundation = build2 ('<link rel="stylesheet" type="text/css" href="'
 	,criterion->static_content,'\css\foundation.css" />' )
 
 set vcjsfoundation = build2('<script type="text/javascript" src="'
 	,criterion->static_content,'\js\foundation.js"></script>' )
 
 set vcjsmanager = build2('<script type="text/javascript" src="'
 	,criterion->static_content,'\js\manager.js"></script>' )
 
 set vcjsbootstrapmultiselectmin = build2('<script type="text/javascript" src="'
 	,criterion->static_content,'\js\bootstrap-multiselect.min.js"></script>' )

 set vcjsbootstrap = build2('<script type="text/javascript" src="'
 	,criterion->static_content,'\js\bootstrap.min.js"></script>' )

 set vcjscontextmenu = build2('<script type="text/javascript" src="'
 	,criterion->static_content,'\js\jquery.contextMenu.min.js"></script>' ) 	

 set vcjsdate = build2('<script type="text/javascript" src="'
 	,criterion->static_content,'\js\date.js"></script>' )	

 set vcjscore = build2('<script type="text/javascript" src="'
 	,criterion->static_content,'\js\core.js"></script>' )
 set vcjshtmlsanitizer = build2('<script type="text/javascript" src="'
 	,criterion->static_content,'\js\HtmlSanitizer.js"></script>' )
 		
 SET vccsbootstrapmultiselectmin = build2 ('<link rel="stylesheet" type="text/css" href="'
 	,criterion->static_content,'\css\bootstrap-multiselect.min.css" />' ) 	
 
 SET vccsbootstrap = build2 ('<link rel="stylesheet" type="text/css" href="'
 	,criterion->static_content,'\css\bootstrap.min.css" />' ) 

 SET vccsdaterangepicker = build2 ('<link rel="stylesheet" type="text/css" href="'
 	,criterion->static_content,'\css\daterangepicker.css" />' ) 

 set vcjsjqueryui = build2('<script type="text/javascript" src="'
 	,criterion->static_content,'\js\jquery-ui.min.js"></script>' )

 set vcjspdf = build2('<script type="text/javascript" src="'
 	,criterion->static_content,'\js\jspdf.min.js"></script>' )

 set vcjspdfobj = build2('<script type="text/javascript" src="'
 	,criterion->static_content,'\js\pdfobject.min.js"></script>' ) 	
 	
 set vcpdfjs = build2('<script type="text/javascript" src="'
 	,criterion->static_content,'\js\pdf.js"></script>' )
 	
 set vcjspdfworker = build2('<script type="text/javascript" src="'
 	,criterion->static_content,'\js\pdf.worker.js"></script>' )	 
 		
 set vcjsjquery = build2('<script type="text/javascript" src="'
 	,criterion->static_content,'\js\jquery-3.5.1.min.js"></script>' )	
 	
 set vcjsjquery =build2( ^<script src="https://code.jquery.com/jquery-1.12.4.js" ^,
 			^integrity="sha256-Qw82+bXyGq6MydymqBxNPYTaUXXq7c8v3CwiYwLLNXU=" ^,
 			^crossorigin="anonymous"></script>^)

 set vcjsmodal = build2('<script type="text/javascript" src="'
 	,criterion->static_content,'\js\modal.js"></script>' )	

 set vcjsjson = build2('<script type="text/javascript" src="'
 	,criterion->static_content,'\js\json2.js"></script>' )	

 set vcjsdaterangepicker = build2('<script type="text/javascript" src="'
 	,criterion->static_content,'\js\daterangepicker.js"></script>' )	

 set vcjsmoment = build2('<script type="text/javascript" src="'
 	,criterion->static_content,'\js\moment.min.js">'
 	,'</script>' )	
 
 set vcjsdownload = build2('<script type="text/javascript" src="'
 	,criterion->static_content,'\js\download.js"></script>' )

 set vcjsfilesaver = build2('<script type="text/javascript" src="'
 	,criterion->static_content,'\js\filesaver.js"></script>' )
 	
 SET vcjsrenderfunc = "javascript:RenderPWxFrame();"
 
  IF ((validate (debug_ind ,0 ) = 1 ) )
   CALL echo (build2 ("js requirements: " ,vcjsreqs ) )
  ENDIF
  CALL log_message (build ("Exit GenerateStaticContentReqs(), Elapsed time in seconds:" ,
    datetimediff (cnvtdatetime (curdate ,curtime3 ) ,begin_date_time ,5 ) ) ,log_level_debug )
END ;Subroutine

SUBROUTINE  generatepagehtml (null )
  CALL log_message ("In GeneratePageHTML()" ,log_level_debug )
  DECLARE begin_date_time = dq8 WITH constant (cnvtdatetime (curdate ,curtime3 ) ) ,private
  SET _memory_reply_string =
  	build2 (
	 ^<!DOCTYPE html>^
	,^<html>^ 
	,^<head>^
	;,'<META content="MPAGES_SVC_AUTH" name="discern"/>' 
	,^<meta http-equiv="x-ua-compatible" content="IE=edge" />^
	,^<meta http-equiv="Content-Type" ^
	,^content="APPLINK,CCLLINK,MPAGES_EVENT,XMLCCLREQUEST,CCLLINKPOPUP,CCLNEWSESSIONWINDOW,XMLHTTPREQUEST,MPAGES_SVC_AUTH" ^
	,^name="discern"/>^
	;,^<meta http-equiv="X-UA-Compatible" content="IE=10">^  
	;,^<script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/es6-promise/4.2.8/es6-promise.min.js"></script>^
	;,^<script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/es6-promise/4.2.8/es6-promise.auto.js"></script>^
	,vccssreqs 
	,vccssfoundation
	,vccsschzn
	,vccsschosen
	,vccsdaterangepicker
	;,vccsbootstrapmultiselectmin
	;,vccsbootstrap
	,vcjsreqs
	,vcjscore
	,vcjsjson
	,vcjsdate
	,vcjsmodal
	,vcjsfoundation
	,vcjsmoment
	,vcjsdaterangepicker
	,vcjspdf
	,vcpdfjs
	,vcjspdfworker
	,vcjspdfobj
	,vcjsdownload
	;,vcjsfilesaver
	;,vcjshtmlsanitizer
	;,vcjsjquery
	;,vcjsjqueryui
	;,vcjscontextmenu
	;,vcjsbootstrap
	;,vcjsbootstrapmultiselectmin
	,vcjsmanager
	;,^<script src="http://code.jquery.com/jquery-migrate-1.4.1.js"></script>^
	;,^<script src="https://code.jquery.com/jquery-migrate-3.3.2.js"></script>^
	,^<script type="text/javascript">^
	,^ var m_criterionJSON = '^ ,replace(cnvtrectojson (criterion),^'^ ,^\'^),^';^ 
	,^	var CERN_static_content = "^,criterion->static_content,^";^
	,^</script>^,^</head>^
	,^<body onload="^,vcjsrenderfunc ,^">^
	;,^<body>^
	,^<div style="float:right" id="pwx_pdfs"></div>^
	,^<div id="pwx_frame_head"></div>^
	,^<div id="pwx_frame_filter_content"></div>^
	,^<div id="pwx_frame_content"></div>^
	
	,^<script>^
	,^var requestAsync  = XMLHttpRequest();                                                 ^
	,^var cache_url = 'http://phsacdeanp/camm/b0783.phsa_cd.cerncd.com/service/contentTypes'; ^
	,^requestAsync.open("GET",cache_url,false);                                                ^
	,^window.location = "javascript:MPAGES_SVC_AUTH(requestAsync)";                            ^
	;,^	alert(cache_url);^
	,^requestAsync.send();                                                                     ^
	;,^if (requestAsync.status == 200) {                                                        ^
	;,^	document.getElementById("pwx_pdfs").innerHTML = requestAsync.statusText;^
	;,^}                                                                                        ^
	,^</script>^
	,^</body>^
	,^</html>^
	)
 
  CALL echo (_memory_reply_string )
  CALL log_message (build (
  							 "Exit GeneratePageHTML(), Elapsed time in seconds:" 
  							,datetimediff ( cnvtdatetime (curdate ,curtime3 ) ,begin_date_time ,5 ) 
  							) 
  					,log_level_debug )
END ;Subroutine
 
#exit_script
 IF ((validate (debug_ind ,0 ) = 1 ) )
  CALL echorecord (criterion )
 ENDIF
END GO
