/*****************************************************************************
******************************************************************************
 
  Author:             Chad Cummings
  Date Written:       03/01/2019
  Solution:
  Source file name:   req_cust_mp_filter_sets.prg
  Object name:        req_cust_mp_filter_sets
  Request #:
 
  Program purpose:
 
  Executing from:
 
  Special Notes:
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod   Mod Date    Developer              Comment
---   ----------  --------------------  --------------------------------------
000   01/20/2020  Chad Cummings			REMOVE OR UPDATE AFTER POC
001   07/16/2020  Chad Cummings			Added specific custom label dates
002   11/01/2021  Chad Cummings			Added Loose Requisition filters
******************************************************************************/
DROP PROGRAM req_cust_mp_filter_sets GO
CREATE PROGRAM req_cust_mp_filter_sets
 prompt
	"Output to File/Printer/MINE" = "MINE"
	, "User ID:" = 0.0
	, "FILTER_SET_NAME" = "0"
	, "FILTER_SET_ID" = 0
 
with OUTDEV, USER_ID, FILTER_SET_NAME, FILTER_SET_ID
 
call echo(build("loading script:",curprog))
declare nologvar = i2 with noconstant(1)	;do not create log = 1		, create log = 0
declare debug_ind = i2 with noconstant(0)	;0 = no debug, 1=basic debug with echo, 2=msgview debug ;000
declare rec_to_file = i2 with noconstant(0)
 
select into "nl:"
from
	 code_value_set cvs
	,code_value cv
plan cvs
	where cvs.definition = "PRINTTOPDF"
	and   cvs.code_set > 0.0
join cv
	where cv.code_set = cvs.code_set
	and   cv.active_ind 	= 1
	and   cv.cdf_meaning	= "LOGGING"
order by
	 cv.begin_effective_dt_tm desc
	,cv.cdf_meaning
head report
	stat = 0
head cv.cdf_meaning
	if (cnvtint(cv.definition) > 0)
		rec_to_file = 1
		nologvar = 0
	endif
with nocounter
 
%i cust_script:bc_play_routines.inc
%i cust_script:bc_play_req.inc
%i cust_script:req_cust_mp_task_by_loc_dt.inc
 
call bc_custom_code_set(0)
 
 
 
FREE RECORD record_data
RECORD record_data (
  1 prsnl_id = f8
  1 filter_set_name = vc
  1 filter_set_id = f8
  1 filter_set_pref = vc
  1 filter_set_string = vc
  1 filter_set
	2 task_status_values			= vc
	2 clerical_status_values     	= vc
	2 task_type_values           	= vc
	2 task_subtype_values        	= vc
	2 task_priority_values       	= vc
	2 task_patient_values        	= vc
	2 task_provider_values       	= vc
	2 task_location_values       	= vc
	2 requested_date_range			= vc
	2 requested_date_range_dates	= vc ;001
	2 requested_date_start			= vc ;001
	2 requested_date_end			= vc ;001
	2 ordered_date_range_dates		= vc
	2 ordered_date_range			= vc ;001
	2 ordered_date_start			= vc ;001
	2 ordered_date_end				= vc ;001
	2 task_header_sort				= vc
	2 task_header_sort_ind			= vc
  	2 task_status_qual[*]
		3 value = vc
	2 clerical_status_qual[*]
		3 value = vc
	2 task_type_qual[*]
		3 value = vc
	2 task_subtype_qual[*]
		3 value = vc
	2 task_priority_qual[*]
		3 value = vc
	2 task_patient_qual[*]
		3 value_id = f8
		3 value = vc
	2 task_provider_qual[*]
		3 value_id = f8
		3 value = vc
	2 task_location_qual[*]
		3 value_id = f8
  1 status_list [* ]
    2 status = vc
    2 selected = i2
  1 cler_status_list [* ]
    2 status = vc
    2 selected = i2
  1 type_pref_found = i2
  1 type_list [* ]
    2 type = vc
    2 selected = i2
  1 subtype_pref_found = i2
  1 subtype_list [* ]
    2 type = vc
    2 selected = i2
  1 gsubtype_pref_found = i2
  1 gsubtype_list [* ]
   2 group_name = vc
   2 group[*]
    3 type = vc
    3 selected = i2
  1 priority_pref_found = i2
  1 priority_list [* ]
   2 group_name = vc
   2 group[*]
    3 priority = vc
    3 selected = i2
  1 loc_list [* ]
     2 org_name = vc
     2 org_id = f8
     2 unit[*]
      3 unit_name = vc
      3 unit_id = f8
      3 selected = i2
  1 patient_list[*]
   	2 person_id = f8
    2 name = vc
    2 selected = i2
  1 provider_list[*]
   2 person_id = f8
   2 name = vc
   2 selected = i2
  /* start 002 */
  1 loose_list[*]
	2 command = vc
	2 display = vc
	2 definition = vc
	2 code_value = f8
	2 loose_req_loc = vc
	2 loose_apt_loc = vc
	2 valid_ind = i2
	2 selected = i2
  /* end 002 */
  1 ordered_date_label = vc
  1 requested_date_label = vc
  1 final_ordered_date_range = vc		;001
  1 final_ordered_date_start = vc		;001
  1 final_requested_date_range = vc	;001
  1 final_requested_date_start = vc	;001
  1 final_ordered_date_end = vc		;001
  1 final_requested_date_end = vc		;001
  1 final_task_header_sort = vc
  1 final_task_header_sort_ind = vc
  1 application_number = i4
  1 final_default_filter_set_pref = vc
  1 final_filter_set_name = vc
  1 filter_sets_cnt = i2
  1 filter_sets[*]
   2 filter_set_name = vc
   2 pvc_name = vc
   2 selected = i2
  1 filter_sets_pref = vc
  1 default_filter_set = vc
  1 error_message = vc
  1 status_data
    2 status = c1
    2 subeventstatus [1 ]
      3 operationname = c25
      3 operationstatus = c1
      3 targetobjectname = c25
      3 targetobjectvalue = vc
)
 
 
/* start 002 */
 
select into "nl:"
from
	 code_value cv
	,code_value_extension cve
plan cv
	where cv.code_set = bc_common->code_set
	and   cv.cdf_meaning = "LOOSE_REPORT"
	and   cv.active_ind = 1
join cve
	where cve.code_value = cv.code_value
	and   cve.code_set = cv.code_set
	and   cve.field_name in(
								 "LOOSE_APT_LOC"
								,"LOOSE_REQ_LOC"
							)
order by
	 cv.code_value
head report
	cnt = 0
head cv.code_value
	cnt = (cnt + 1)
	stat = alterlist(record_data->loose_list,cnt)
	record_data->loose_list[cnt].display			= cv.display
	record_data->loose_list[cnt].definition		= cv.definition
	record_data->loose_list[cnt].code_value		= cv.code_value
detail
	case (cve.field_name)
		of "LOOSE_REQ_LOC":	record_data->loose_list[cnt].loose_req_loc = cve.field_value
		of "LOOSE_APT_LOC":	record_data->loose_list[cnt].loose_apt_loc = cve.field_value
	endcase
foot cv.code_value
	if ((record_data->loose_list[cnt].loose_req_loc > " ") and (record_data->loose_list[cnt].loose_apt_loc > " "))
		record_data->loose_list[cnt].valid_ind = 1
		record_data->loose_list[cnt].command = build2(
									 				^execute BC_ALL_SCH_LOOSE_ORD ^
													,^"nl:",^
													,record_data->loose_list[cnt].loose_req_loc,^,^
													,record_data->loose_list[cnt].loose_apt_loc,^ go^)
	endif
foot report
	null
with nocounter
/* end 002 */
 
declare selected_var = i2 with protect ,noconstant (0 )
declare selected_true = i2 with protect, constant(1)
declare selected_false = i2 with protect, constant(0)
DECLARE temp_string = vc
 
 
DECLARE log_program_name = vc WITH protect ,noconstant ("" )
DECLARE log_override_ind = i2 WITH protect ,noconstant (0 )
SET log_program_name = curprog
SET log_override_ind = 1
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
IF ((((logical ("MP_LOGGING_ALL" ) > " " ) ) OR ((logical (concat ("MP_LOGGING_" ,log_program_name) ) > " " ) )) )
 SET log_override_ind = 1
ENDIF
DECLARE log_message ((logmsg = vc ) ,(loglvl = i4 ) ) = null
DECLARE getencntrreltn ((dencntr_id = f8 ) ,(dreltn_cd = f8 ) ,(dprov_id = f8 ) ) = null
DECLARE validatefxreltn ((dencntr_id = f8 ) ,(dprov_id = f8 ) ) = f8
DECLARE validatefx2reltn ((dencntr_id = f8 ) ,(dprov_id = f8 ) ) = f8
DECLARE validatecustomsettings ((codeset = f8 ) ,(encntrid = f8 ) ,(cve_fieldparse = vc ) ) = vc
DECLARE subroutine_status = f8 WITH noconstant (0 ) ,protect
IF ((validate (89_powerchart ,- (99 ) ) = - (99 ) ) )
 DECLARE 89_powerchart = f8 WITH public ,constant (uar_get_code_by ("MEANING" ,89 ,"POWERCHART" ) )
ENDIF
IF ((validate (48_inactive ,- (99 ) ) = - (99 ) ) )
 DECLARE 48_inactive = f8 WITH public ,constant (uar_get_code_by ("MEANING" ,48 ,"INACTIVE" ) )
ENDIF
IF ((validate (48_active ,- (99 ) ) = - (99 ) ) )
 DECLARE 48_active = f8 WITH public ,constant (uar_get_code_by ("MEANING" ,48 ,"ACTIVE" ) )
ENDIF
 
SET log_program_name = "REQ_CUST_MP_TASK_BY_LOC_DT"
DECLARE breakstring ((p1 = vc (val ) ) ,(p2 = vc (ref ) ) ,(p3 = vc (val ) ) ) = null WITH protect
DECLARE gathercomponentsettings ((parentid = f8 ) ) = null WITH protect ,copy
DECLARE gatherpagecomponentsettings ((parentid = f8 ) ) = null WITH protect ,copy
DECLARE gathertasksbylocdt (dummy ) = null WITH protect ,copy
DECLARE gatherlocations ((persid = f8 ) ) = null WITH protect ,copy
 
DECLARE gatherlabsbylocdt (dummy ) = null WITH protect ,copy
DECLARE gatherorderdiags (dummy ) = null WITH protect ,copy
DECLARE gatherenctrorgsecurity ((persid = f8 ) ,(userid = f8 ) ) = null WITH protect ,copy
DECLARE gathertasktypes (dummy ) = null WITH protect ,copy
DECLARE gatheruserprefs ((prsnl_id = f8 ) ,(pref_id = vc ) ) = null WITH protect ,copy
DECLARE gatherpowerformname (dummy ) = null WITH protect ,copy
DECLARE gatheruserlockedchartsaccess ((userid = f8 ) ) = null WITH protect ,copy
DECLARE gatherclericalstatus (dummy ) = null WITH protect ,copy
DECLARE gathernotdonereason ((resultid = f8 ) ) = null WITH protect ,copy
DECLARE gatherchartedforms ((eventid = f8 ) ) = null WITH protect ,copy
DECLARE current_date_time = dq8 WITH constant (cnvtdatetime (curdate ,curtime3 ) ) ,protect
DECLARE 6025_cont = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.CODEVALUE!3243" ) )
DECLARE 6000_meds = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.CODEVALUE!3079" ) )
DECLARE 6000_eandm = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.CODEVALUE!10700" ) )
DECLARE 6000_charge = f8 WITH public ,constant (uar_get_code_by ("DISPLAYKEY" ,6000 ,"CHARGES" ) )
DECLARE deleted = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.CODEVALUE!17013" ) )
DECLARE completed = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.CODEVALUE!2791" ) )
DECLARE inprocess = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.CODEVALUE!2792" ) )
DECLARE 222_fac = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.CODEVALUE!2844" ) )
DECLARE order_comment = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.CODEVALUE!3944" ) )
DECLARE task_note = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.CODEVALUE!2936879" ) )
DECLARE not_done = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.CODEVALUE!17619" ) )
DECLARE ocfcomp_cd = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,120 ,"OCFCOMP" ) )
DECLARE rtf_cd = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,23 ,"RTF" ) )
DECLARE inerror = f8 WITH public ,constant (uar_get_code_by ("MEANING" ,8 ,"INERROR" ) )
DECLARE 27113_mednec = f8 WITH public ,constant (uar_get_code_by ("MEANING" ,27113 ,"MEDNEC" ) )
DECLARE 27112_required = f8 WITH public ,constant (uar_get_code_by ("MEANING" ,27112 ,"REQUIRED" ))
DECLARE abn_status_meaning = vc WITH constant ("ABNSTATUS" )
DECLARE start_parser = vc WITH public ,noconstant ("0" )
DECLARE end_parser = vc WITH public ,noconstant ("0" )
declare notfnd = vc with constant("<not found>")
DECLARE location_parser = vc WITH public ,noconstant ("" )
DECLARE encntr_location_parser = vc WITH public ,noconstant ("1=1" )
DECLARE task_type_parser = vc WITH public ,noconstant ("1=1" )
DECLARE task_type_cv_parser = vc WITH public ,noconstant ("1=1" )
DECLARE encntr_type_parser = vc WITH public ,noconstant ("1=1" )
DECLARE not_done_reason = vc WITH public ,noconstant ("" )
DECLARE not_done_reason_comm = vc WITH public ,noconstant ("" )
DECLARE charted_form_id = f8 WITH public ,noconstant (0.0 )
DECLARE position_bedrock_settings = i2
DECLARE user_pref_string = vc
DECLARE user_pref_found = i2
DECLARE tasks_back = i4
DECLARE task_max = i4
declare k = i2
declare i = i2
DECLARE tcnt = i2
DECLARE lcnt = i2
declare pos = i2
DECLARE ignore_data = i2
SET tasks_back = 200
DECLARE confid_ind = i2
DECLARE confid_level = i2
DECLARE confid_security_parser = vc WITH public ,noconstant ("1=1" )
DECLARE indx_type = i4 WITH protect ,noconstant (0 )
DECLARE logging = i4 WITH protect ,noconstant (0 )
declare replace_string = vc with protect, noconstant("")
declare temp_string = vc with protect, noconstant("")
 
record 500525request (
  1 application_number = i4
  1 position_cd = f8
  1 prsnl_id = f8
  1 www_flag = i2
  1 preftool_ind = i2
  1 top_view_list_cnt = i4
  1 top_view_list [*]
    2 frame_type = c20
)
 
RECORD 500525reply (
   1 app
     2 application_number = i4
     2 position_cd = f8
     2 prsnl_id = f8
     2 nv_cnt = i4
     2 nv [* ]
       3 name_value_prefs_id = f8
       3 nv_type_flag = i2
       3 pvc_name = c32
       3 pvc_value = vc
       3 sequence = i2
       3 merge_id = f8
       3 merge_name = vc
       3 updt_cnt = i4
   1 view_level_flag = i2
   1 view_cnt = i4
   1 pview [* ]
     2 view_prefs_id = f8
     2 application_number = i4
     2 position_cd = f8
     2 prsnl_id = f8
     2 frame_type = c12
     2 view_name = c12
     2 view_seq = i4
     2 updt_cnt = i4
     2 nv_cnt = i4
     2 nv [* ]
       3 name_value_prefs_id = f8
       3 nv_type_flag = i2
       3 pvc_name = c32
       3 pvc_value = vc
       3 sequence = i2
       3 merge_id = f8
       3 merge_name = vc
       3 updt_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus [1 ]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 
 
 
CALL log_message (concat ("Begin script: " ,log_program_name ) ,log_level_debug )
SET record_data->status_data.status = "F"
set record_data->error_message = "Start"
 
set record_data->prsnl_id = $USER_ID
set record_data->filter_set_name = $FILTER_SET_NAME
set record_data->filter_set_id = $FILTER_SET_ID
set record_data->filter_set_pref = "TEST_"
set record_data->application_number = 600005;reqinfo->updt_app
set record_data->final_default_filter_set_pref = concat(
													 trim(record_data->filter_set_pref)
													,trim("DEFAULT_FILTER_SET")
												)
set record_data->final_filter_set_name = concat(record_data->filter_set_pref,record_data->filter_set_name)
 
set record_data->error_message = concat(record_data->error_message,":",record_data->filter_set_name)
 
SELECT INTO "nl:"
	pvc_name = cnvtupper(n.pvc_name)
   FROM (app_prefs a ),
    (name_value_prefs n )
   PLAN (a
    WHERE (a.prsnl_id = record_data->prsnl_id )
     AND (a.application_number = 600005 ) )
    JOIN (n
    WHERE (n.parent_entity_id = a.app_prefs_id )
    AND (n.parent_entity_name = "APP_PREFS" )
    AND (n.pvc_name = "TEST_*" ) )
   ORDER BY pvc_name,n.sequence
   head report
   	record_data->filter_sets_cnt = (record_data->filter_sets_cnt + 1)
   	stat = alterlist(record_data->filter_sets,record_data->filter_sets_cnt)
   	record_data->filter_sets[record_data->filter_sets_cnt].pvc_name = concat(record_data->filter_set_pref,"Default")
   head pvc_name
   call echo(build("pvc_name=",n.pvc_name))
   call echo(build("pvc_value=",n.pvc_value))
   if (n.pvc_name != "*DEFAULT_FILTER_SET")
   	record_data->filter_sets_cnt = (record_data->filter_sets_cnt + 1)
   	stat = alterlist(record_data->filter_sets,record_data->filter_sets_cnt)
   	record_data->filter_sets[record_data->filter_sets_cnt].pvc_name = n.pvc_name
   elseif (n.pvc_name = "*DEFAULT_FILTER_SET")
   	record_data->default_filter_set = replace(
 		n.pvc_value,
 		record_data->filter_set_pref,"")
   endif
   foot report
   	if (record_data->default_filter_set = "")
   		record_data->default_filter_set = concat(record_data->filter_set_pref,"Default")
   	endif
   WITH nocounter,nullreport
 
 for (i=1 to record_data->filter_sets_cnt)
 	set record_data->filter_sets[i].filter_set_name = replace(
 		record_data->filter_sets[i].pvc_name,
 		record_data->filter_set_pref,"")
 	if (record_data->filter_sets[i].filter_set_name = record_data->default_filter_set)
 		set record_data->filter_sets[i].selected = 1
 	endif
 endfor
 
if (record_data->filter_set_name > " ")
	set 500525request->application_number =             600005;   reqinfo->updt_app
	set 500525request->prsnl_id = record_data->prsnl_id
	EXECUTE dcp_get_app_view_prefs WITH replace ("REQUEST" ,"500525REQUEST" ) , replace ("REPLY" ,"500525REPLY" )
	call echo(build("500525reply->status_data.status=",500525reply->status_data.status))
	if (500525reply->status_data.status = "S")
		select into "nl:"
			pvc_seq = 500525reply->app.nv[d1.seq].sequence
		from
			(dummyt d1 with seq=500525reply->app.nv_cnt)
		plan d1
			where 500525reply->app.nv[d1.seq].pvc_name = concat(record_data->filter_set_pref,record_data->filter_set_name)
		order by
			pvc_seq
		head report
			i = 0
		detail
			i = (i + 1)
			if (i > 1)
				record_data->filter_set_string = concat(record_data->filter_set_string,500525reply->app.nv[d1.seq].pvc_value)
			else
				record_data->filter_set_string = 500525reply->app.nv[d1.seq].pvc_value
			endif
			record_data->filter_set_id = i
		with nocounter
 
		set record_data->error_message = build(record_data->error_message,":",record_data->filter_set_id)
 
		set record_data->filter_set.task_status_values 		= piece(record_data->filter_set_string,"|",1,^^)
		set record_data->filter_set.clerical_status_values 	= piece(record_data->filter_set_string,"|",2,^^)
		set record_data->filter_set.task_type_values 		= piece(record_data->filter_set_string,"|",3,^^)
		set record_data->filter_set.task_subtype_values 	= piece(record_data->filter_set_string,"|",4,^^)
		set record_data->filter_set.task_priority_values 	= piece(record_data->filter_set_string,"|",5,^^)
		set record_data->filter_set.task_patient_values 	= piece(record_data->filter_set_string,"|",6,^^)
		set record_data->filter_set.task_provider_values 	= piece(record_data->filter_set_string,"|",7,^^)
		set record_data->filter_set.task_location_values 	= piece(record_data->filter_set_string,"|",8,^^)
		set record_data->filter_set.ordered_date_range 		= piece(record_data->filter_set_string,"|",9,^^)
		set record_data->filter_set.requested_date_range 	= piece(record_data->filter_set_string,"|",10,^^)
		set record_data->filter_set.task_header_sort	 	= piece(record_data->filter_set_string,"|",11,^^)
		set record_data->filter_set.task_header_sort_ind 	= piece(record_data->filter_set_string,"|",12,^^)
 
		call echo("default sort")
		if (record_data->filter_set.task_header_sort >" ")
			set record_data->task_header_sort = record_data->filter_set.task_header_sort
		endif
 
		call echo("default sort order")
		if (record_data->filter_set.task_header_sort_ind >" ")
			set record_data->final_task_header_sort_ind = record_data->filter_set.task_header_sort_ind
		endif
 
		call echo("ordered_date_range")
		if (record_data->filter_set.ordered_date_range > " ")
			/*start 001 */
			if (substring(1,7,record_data->filter_set.ordered_date_range) = "Custom")
				set record_data->ordered_date_label = piece(record_data->filter_set.ordered_date_range,",",1,^^)
 
				set record_data->filter_set.ordered_date_range_dates = piece(record_data->filter_set.ordered_date_range,",",2,^^)
 
				set record_data->filter_set.ordered_date_start = substring(1,12,record_data->filter_set.ordered_date_range_dates)
				set record_data->filter_set.ordered_date_end = substring(16,26,record_data->filter_set.ordered_date_range_dates)
 
				set record_data->final_ordered_date_start = record_data->filter_set.ordered_date_start
				set record_data->final_ordered_date_end = record_data->filter_set.ordered_date_end
				set record_data->final_ordered_date_range = record_data->filter_set.ordered_date_range_dates
			else
				set record_data->ordered_date_label = record_data->filter_set.ordered_date_range
			endif
			/*end 001 */
		endif
 
		call echo("requested_date_range")
		if (record_data->filter_set.requested_date_range > " ")
			/*start 001*/
			if (substring(1,7,record_data->filter_set.requested_date_range) = "Custom")
				set record_data->requested_date_label = piece(record_data->filter_set.requested_date_range,",",1,^^)
 
				set record_data->filter_set.requested_date_range_dates = piece(record_data->filter_set.requested_date_range,",",2,^^)
 
				set record_data->filter_set.requested_date_start = substring(1,12,record_data->filter_set.requested_date_range_dates)
				set record_data->filter_set.requested_date_end = substring(16,26,record_data->filter_set.requested_date_range_dates)
 
				set record_data->final_requested_date_start = record_data->filter_set.requested_date_start
				set record_data->final_requested_date_end = record_data->filter_set.requested_date_end
				set record_data->final_requested_date_range = record_data->filter_set.requested_date_range_dates
			else
				set record_data->requested_date_label = record_data->filter_set.requested_date_range
			endif
			/*end 001*/
 
		endif
 
		call echo("task_location_values")
		if (record_data->filter_set.task_location_values > " ")
			set k = 1
			set temp_string = piece(record_data->filter_set.task_location_values,",",k,notfnd)
			while (temp_string != notfnd)
				set temp_string = piece(record_data->filter_set.task_location_values,",",k,notfnd)
				if (temp_string != notfnd)
					set stat = alterlist(record_data->filter_set.task_location_qual,k)
					set record_data->filter_set.task_location_qual[k].value_id = cnvtreal(temp_string)
				endif
				set k = (k + 1)
			endwhile
		endif
 
		call echo("task_provider_values")
		if (record_data->filter_set.task_provider_values > " ")
			set k = 1
			set temp_string = piece(record_data->filter_set.task_provider_values,",",k,notfnd)
			while (temp_string != notfnd)
				set temp_string = piece(record_data->filter_set.task_provider_values,",",k,notfnd)
				if (temp_string != notfnd)
					set stat = alterlist(record_data->filter_set.task_provider_qual,k)
					set record_data->filter_set.task_provider_qual[k].value_id = cnvtreal(temp_string)
				endif
				set k = (k + 1)
			endwhile
			if (size(record_data->filter_set.task_provider_qual,5) > 0)
				select into "nl:"
				from
					 (dummyt d1 with seq=size(record_data->filter_set.task_provider_qual,5))
					,prsnl p
				plan d1
					where record_data->filter_set.task_provider_qual[d1.seq].value_id > 0.0
				join p
					where p.person_id = record_data->filter_set.task_provider_qual[d1.seq].value_id
				detail
					record_data->filter_set.task_provider_qual[d1.seq].value = p.name_full_formatted
				with nocounter
			endif
		endif
 
		call echo("task_patient_values")
		if (record_data->filter_set.task_patient_values > " ")
			set k = 1
			set temp_string = piece(record_data->filter_set.task_patient_values,",",k,notfnd)
			while (temp_string != notfnd)
				set temp_string = piece(record_data->filter_set.task_patient_values,",",k,notfnd)
				if (temp_string != notfnd)
					set stat = alterlist(record_data->filter_set.task_patient_qual,k)
					set record_data->filter_set.task_patient_qual[k].value_id = cnvtreal(temp_string)
				endif
				set k = (k + 1)
			endwhile
			if (size(record_data->filter_set.task_patient_qual,5) > 0)
				select into "nl:"
				from
					 (dummyt d1 with seq=size(record_data->filter_set.task_patient_qual,5))
					,person p
				plan d1
					where record_data->filter_set.task_patient_qual[d1.seq].value_id > 0.0
				join p
					where p.person_id = record_data->filter_set.task_patient_qual[d1.seq].value_id
				detail
					record_data->filter_set.task_patient_qual[d1.seq].value = p.name_full_formatted
				with nocounter
			endif
		endif
 
		call echo("task_priority_values")
		if (record_data->filter_set.task_priority_values > " ")
			set k = 1
			set temp_string = piece(record_data->filter_set.task_priority_values,",",k,notfnd)
			while (temp_string != notfnd)
				set temp_string = piece(record_data->filter_set.task_priority_values,",",k,notfnd)
				if (temp_string != notfnd)
					set stat = alterlist(record_data->filter_set.task_priority_qual,k)
					set record_data->filter_set.task_priority_qual[k].value = temp_string
				endif
				set k = (k + 1)
			endwhile
		endif
 
		if (record_data->filter_set.task_subtype_values > " ")
			set k = 1
			set temp_string = piece(record_data->filter_set.task_subtype_values,",",k,notfnd)
			while (temp_string != notfnd)
				set temp_string = piece(record_data->filter_set.task_subtype_values,",",k,notfnd)
				if (temp_string != notfnd)
					set stat = alterlist(record_data->filter_set.task_subtype_qual,k)
					set record_data->filter_set.task_subtype_qual[k].value = temp_string
				endif
				set k = (k + 1)
			endwhile
		endif
 
		if (record_data->filter_set.task_type_values > " ")
			set k = 1
			set temp_string = piece(record_data->filter_set.task_type_values,",",k,notfnd)
			while (temp_string != notfnd)
				set temp_string = piece(record_data->filter_set.task_type_values,",",k,notfnd)
				if (temp_string != notfnd)
					set stat = alterlist(record_data->filter_set.task_type_qual,k)
					set record_data->filter_set.task_type_qual[k].value = temp_string
				endif
				set k = (k + 1)
			endwhile
		endif
 
		if (record_data->filter_set.clerical_status_values > " ")
			set k = 1
			set temp_string = piece(record_data->filter_set.clerical_status_values,",",k,notfnd)
			while (temp_string != notfnd)
				set temp_string = piece(record_data->filter_set.clerical_status_values,",",k,notfnd)
				if (temp_string != notfnd)
					set stat = alterlist(record_data->filter_set.clerical_status_qual,k)
					set record_data->filter_set.clerical_status_qual[k].value = temp_string
				endif
				set k = (k + 1)
			endwhile
		endif
 
		if (record_data->filter_set.task_status_values > " ")
			set k = 1
			set temp_string = piece(record_data->filter_set.task_status_values,",",k,notfnd)
			while (temp_string != notfnd)
				set temp_string = piece(record_data->filter_set.task_status_values,",",k,notfnd)
				if (temp_string != notfnd)
					set stat = alterlist(record_data->filter_set.task_status_qual,k)
					set record_data->filter_set.task_status_qual[k].value = temp_string
				endif
				set k = (k + 1)
			endwhile
		endif
	endif
endif
 
SET stat = alterlist (record_data->status_list ,2 )
SET record_data->status_list[1 ].status = "Pending"
SET record_data->status_list[2 ].status = "Printed"
 
CALL gathertasktypes (0 )
CALL gatherclericalstatus (0 )
call gatherlocations($USER_ID)
 
/* example to parse values for selection
IF ((user_pref_found = 1 ) )
	SET record_data->type_pref_found = 1
	FOR (tseq = 1 TO size (record_data->type_list ,5 ) )
		SET record_data->type_list[tseq ].selected = 1
	ENDFOR
	DECLARE start_comma = i4 WITH protect ,noconstant (1 )
	DECLARE end_comma = i4 WITH protect ,noconstant (findstring ("|" ,user_pref_string ,start_comma ))
	DECLARE task_type_pref = vc
 
	WHILE ((start_comma > 0 ) )
		IF (NOT (end_comma ) )
			SET task_type_pref = substring ((start_comma + 1 ) ,(textlen (user_pref_string ) - start_comma ),user_pref_string )
		ELSE
			SET task_type_pref = substring ((start_comma + 1 ) ,((end_comma - start_comma ) - 1 ) ,user_pref_string )
		ENDIF
		CALL log_message (task_type_pref ,log_level_debug )
		FOR (tseq = 1 TO size (record_data->type_list ,5 ) )
			IF ((record_data->type_list[tseq ].type = task_type_pref ) )
				SET record_data->type_list[tseq ].selected = 1
			ENDIF
		ENDFOR
		SET start_comma = end_comma
		IF (start_comma )
			SET end_comma = findstring ("|" ,user_pref_string ,(start_comma + 1 ) )
		ENDIF
	ENDWHILE
ENDIF
*/
/*
 
  1 type_list [* ]
    2 type = vc
    2 selected = i2
  1 subtype_pref_found = i2
  1 subtype_list [* ]
    2 type = vc
    2 selected = i2
  1 gsubtype_pref_found = i2
  1 gsubtype_list [* ]
    2 type = vc
    2 selected = i2
  1 priority_pref_found = i2
  1 priority_list [* ]
   2 group_name = vc
   2 group[*]
    3 priority = vc
    3 selected = i2
  1 loc_list [* ]
     2 org_name = vc
     2 org_id = f8
     2 unit[*]
      3 unit_name = vc
      3 unit_id = f8
*/
 
set selected_val = selected_true
 
	for (tseq = 1 to size (record_data->status_list ,5 ) )
		if (record_data->filter_set_id = 0)
			set record_data->status_list[tseq ].selected = selected_val
		else
			for (i=1 to size(record_data->filter_set.task_status_qual,5))
				if (record_data->status_list[tseq].status = record_data->filter_set.task_status_qual[i].value)
					set record_data->status_list[tseq ].selected = selected_true
				endif
			endfor
		endif
	endfor
 
	for (tseq = 1 to size (record_data->subtype_list ,5 ) )
		if (record_data->filter_set_id = 0)
			set record_data->subtype_list[tseq ].selected = selected_val
		else
			for (i=1 to size(record_data->filter_set.task_subtype_qual,5))
				if (record_data->subtype_list[tseq].type = record_data->filter_set.task_subtype_qual[i].value)
					set record_data->subtype_list[tseq ].selected = selected_true
				endif
			endfor
		endif
	endfor
 
 
 
	for (tseq = 1 to size (record_data->filter_set.task_patient_qual ,5 ) )
		set stat = alterlist(record_data->patient_list,tseq)
		set record_data->patient_list[tseq].person_id = record_data->filter_set.task_patient_qual[tseq].value_id
		set record_data->patient_list[tseq].name = record_data->filter_set.task_patient_qual[tseq].value
		set record_data->patient_list[tseq].selected = selected_true
	endfor
 
	for (tseq = 1 to size (record_data->filter_set.task_provider_qual ,5 ) )
		set stat = alterlist(record_data->provider_list,tseq)
		set record_data->provider_list[tseq].person_id = record_data->filter_set.task_provider_qual[tseq].value_id
		set record_data->provider_list[tseq].name = record_data->filter_set.task_provider_qual[tseq].value
		set record_data->provider_list[tseq].selected = selected_true
	endfor
 
	for (tseq = 1 to size (record_data->provider_list ,5 ) )
		if (record_data->filter_set_id = 0)
			set record_data->provider_list[tseq ].selected = selected_val
		else
			set stat = 0
		endif
	endfor
 
 
	for (tseq = 1 to size (record_data->priority_list ,5 ) )
			for (kseq = 1 to size(record_data->priority_list[tseq].group,5))
				if (record_data->filter_set_id = 0)
					set record_data->priority_list[tseq].group[kseq].selected = selected_val
				else
					for (i=1 to size(record_data->filter_set.task_priority_qual,5))
						if (record_data->priority_list[tseq].group[kseq].priority = record_data->filter_set.task_priority_qual[i].value)
							set record_data->priority_list[tseq].group[kseq].selected = selected_true
						endif
					endfor
				endif
			endfor
	endfor
 
	for (tseq = 1 to size (record_data->gsubtype_list ,5 ) )
			for (kseq = 1 to size(record_data->gsubtype_list[tseq].group,5))
				if (record_data->filter_set_id = 0)
					set record_data->gsubtype_list[tseq].group[kseq].selected = selected_val
				else
					for (i=1 to size(record_data->filter_set.task_subtype_qual,5))
						if (record_data->gsubtype_list[tseq].group[kseq].type = record_data->filter_set.task_subtype_qual[i].value)
							set record_data->gsubtype_list[tseq].group[kseq].selected = selected_true
						endif
					endfor
				endif
			endfor
	endfor
 
	for (tseq = 1 to size (record_data->cler_status_list ,5 ) )
		if (record_data->filter_set_id = 0)
			set record_data->cler_status_list[tseq ].selected = selected_val
		else
			for (i=1 to size(record_data->filter_set.clerical_status_qual,5))
				if (record_data->cler_status_list[tseq].status = record_data->filter_set.clerical_status_qual[i].value)
					set record_data->cler_status_list[tseq ].selected = selected_true
				endif
			endfor
		endif
	endfor
 
	for (tseq = 1 to size (record_data->type_list ,5 ) )
		if (record_data->filter_set_id = 0)
			set record_data->type_list[tseq ].selected = selected_val
		else
			for (i=1 to size(record_data->filter_set.task_type_qual,5))
				if (record_data->type_list[tseq].type = record_data->filter_set.task_type_qual[i].value)
					set record_data->type_list[tseq ].selected = selected_true
				endif
			endfor
		endif
	endfor
 
	for (tseq = 1 to size (record_data->loc_list ,5 ) )
		for (kseq = 1 to size(record_data->loc_list[tseq].unit,5))
			if (record_data->filter_set_id = 0)
				set record_data->loc_list[tseq].unit[kseq].selected = selected_true
			else
				for (i=1 to size(record_data->filter_set.task_location_qual,5))
					if (record_data->loc_list[tseq].unit[kseq].unit_id = record_data->filter_set.task_location_qual[i].value_id)
						set record_data->loc_list[tseq].unit[kseq].selected = selected_true
					endif
				endfor
			endif
		endfor
	endfor
 
 
 
if (record_data->filter_set.task_header_sort > " ")
	set record_data->final_task_header_sort = record_data->filter_set.task_header_sort
else
	set record_data->final_task_header_sort = "pwx_fcr_header_schdate_dt"
endif
 
if (record_data->filter_set.task_header_sort_ind > " ")
	set record_data->final_task_header_sort_ind = record_data->filter_set.task_header_sort_ind
else
	set record_data->final_task_header_sort_ind = "1"
endif
 
;call echorecord(record_data)
call adddefaultfilterset(null)
 
SET record_data->status_data.status = "S"
SET modify maxvarlen 20000000
SET _memory_reply_string = cnvtrectojson (record_data )
 
SUBROUTINE  adddefaultfilterset (null )
  DECLARE begin_date_time = q8 WITH constant (cnvtdatetime (curdate ,curtime3 ) ) ,private
  RECORD dcp_reply (
    1 status_data
      2 status = c1
      2 subeventstatus [1 ]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
  RECORD dcp_add_request (
    1 application_number = i4
    1 position_cd = f8
    1 prsnl_id = f8
    1 nv [* ]
      2 pvc_name = c32
      2 pvc_value = vc
      2 sequence = i2
      2 merge_id = f8
      2 merge_name = vc
  )
 
  CALL breakstring ( value(record_data->final_filter_set_name) ,dcp_add_request,value(record_data->final_default_filter_set_pref) )
 
  SET dcp_add_request->application_number = record_data->application_number
  SET dcp_add_request->prsnl_id =  record_data->prsnl_id
 
  EXECUTE dcp_add_app_prefs WITH replace ("REQUEST" ,"DCP_ADD_REQUEST" ) , replace ("REPLY" ,"DCP_REPLY" )
  IF ((dcp_reply->status_data.status = "F" ) )
   SET record_data->status_data.status = "F"
   GO TO exit_script
  ENDIF
  IF ((validate (debug_ind ,0 ) = 1 ) )
   CALL echorecord (dcp_add_request )
   CALL echorecord (dcp_reply )
  ENDIF
  FREE RECORD dcp_reply
  FREE RECORD dcp_add_request
 
 END ;Subroutine
 SUBROUTINE  breakstring (string ,rec ,pvc_name )
 
  DECLARE begin_date_time = q8 WITH constant (cnvtdatetime (curdate ,curtime3 ) ) ,private
  DECLARE max_len = i4 WITH constant (256 ) ,protect
  DECLARE idx = i4 WITH noconstant (0 ) ,protect
  DECLARE curposition = i4 WITH noconstant (1 ) ,protect
  IF ((reqinfo->updt_app = 3202004 ) )
   IF ((validate (debug_ind ,0 ) = 1 ) )
    CALL echo ('~~~*** Replacing ^ with " ***~~~' )
   ENDIF
   SET string = replace (string ,"^" ,'"' ,0 )
  ENDIF
  SET totalstringsize = size (string )
  WHILE ((curposition <= totalstringsize ) )
   SET idx = (idx + 1 )
   SET stat = alterlist (rec->nv ,idx )
   SET rec->nv[idx ].sequence = idx
   SET rec->nv[idx ].pvc_name = pvc_name
   SET len = (totalstringsize - (curposition - 1 ) )
   IF ((len > max_len ) )
    SET len = max_len
    SET rec->nv[idx ].pvc_value = substring (curposition ,len ,string )
    SET curposition = (curposition + max_len )
   ELSE
    SET rec->nv[idx ].pvc_value = substring (curposition ,len ,string )
    SET curposition = (totalstringsize + 1 )
   ENDIF
  ENDWHILE
 END ;Subroutine
#exit_script
	call echo("exit_script")
#exit_program
 CALL log_message (concat ("Exiting script: " ,log_program_name ) ,log_level_debug )
 CALL log_message (build ("Total time in seconds:" ,
 	datetimediff (cnvtdatetime (curdate ,curtime3 ) ,current_date_time ,5 ) ) ,log_level_debug )
 call echorecord(record_data)
 ;call echorecord(500525REPLY)
 FREE RECORD record_data
END GO