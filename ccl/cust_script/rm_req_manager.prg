/*****************************************************************************
******************************************************************************
 
  Author:             Chad Cummings
  Date Written:       12/17/2021
  Solution:
  Source file name:   rm_req_manager.prg
  Object name:        rm_req_manager
  Request #:
 
  Program purpose:
 
  Executing from:
 
  Special Notes:
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod   Mod Date    Developer              Comment
---   ----------  --------------------  --------------------------------------
000   12/17/2021  Chad Cummings			Initial Release
001   12/17/2021  Chad Cummings         CST-130820
******************************************************************************/
 
drop program rm_req_manager:dba go
create program rm_req_manager:dba
 
prompt
	"Output to File/Printer/MINE" = "MINE"
	, "REQUISITION_FORMAT_CD" = 0
	, "PARAMETERES" = ""
 
with OUTDEV, REQUISITION_FORMAT_CD, PARAMETERS
 
 
call echo(build("loading script:",curprog))
 
execute bc_all_pdf_std_routines
 
declare nologvar = i2 with noconstant(1), protect	;do not create log = 1		, create log = 0
declare debug_ind = i2 with noconstant(0), protect	;0 = no debug, 1=basic debug with echo, 2=msgview debug ;000
declare rec_to_file = i2 with noconstant(0), protect
 
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
 
set modify maxvarlen 268435456 ;increases max file size
 
%i cust_script:bc_play_routines.inc
%i cust_script:bc_play_req.inc
 
 
call bc_custom_code_set(0)
call bc_log_level(0)
call bc_check_validation(0)
call bc_pdf_event_code(0)
call bc_pdf_content_type(0)
call bc_get_single_ord_requisitions(0)
call bc_get_multiple_ord_requisitions(0)
call bc_get_oef_changes(0) ;010
call bc_get_included_locations(0)
call bc_get_scheduling_fields(0)
 
declare h = i2 with noconstant(0)
declare i = i2 with noconstant(0)
declare j = i2 with noconstant(0)
declare k = i2 with noconstant(0)
 

record 102901_request (
    1 code_value_qual = i4
    1 code_value [*]
        2 action_type = vc
        2 code_set = i4
        2 code_value = f8
        2 cdf_meaning = c12
        2 display = c40
        2 description = c60
        2 definition = c100
        2 collation_seq_ind = i2
        2 collation_seq = i4
        2 inactive_dt_tm = dq8
        2 active_ind = i2
) 

record 4171666_request (
    1 extension_list [*]   
	    2 action_type_flag = i2   
	    2 code_set = i4   
	    2 code_value = f8   
	    2 field_name = vc  
	    2 field_type = i4   
	    2 field_value = vc  
	)

record t_rec
(
	1 prompts
	    2 outdev			= vc
        2 requisition_format_cd = f8
        2 parameters = vc
    1 cons
        2 rm_code_value = f8
        2 requisition_format_cd = f8
        2 requisition_display = vc
        2 requisition_cdf_meaning = vc
        2 ippdf_code_value = f8
        2 ippdf_current_active_ind = i2
        2 ippdf_new_active_ind = i2
        2 ippdf_parameter_update = i2
        2 ippdf_display = vc
        2 ippdf_definition = vc
        2 ippdf_description = vc
        2 ippdf_subtype_processing = vc
        2 ippdf_oe_change_processing = vc
        2 new_ippdf_title = vc
        2 new_ippdf_req_script = vc
        2 new_ippdf_orders_per_req = i2
        2 new_ippdf_priority_group = vc
        2 new_ippdf_priority_oem = vc
        2 new_ippdf_type_display = vc
        2 new_ippdf_sched_loc_check = vc
        2 new_ippdf_subtype_processing = vc
        2 new_ippdf_oe_change_processing = vc
) with protect
 
free record record_data
record record_data
(
    1 prompts
        2 outdev			= vc
        2 requisition_format_cd = f8
        2 parameters = vc
    1 params
     	2 priority_group_order_max = i2
     	2 priority_cnt = i2
     	2 priority_qual[*]
     		3 value = vc
    1 req_cnt = i2
    1 req_list[*]
        2 code_value = f8
        2 display = vc
        2 description = vc
        2 definition = vc
        2 requisition_format_cd = f8
        2 requisition_format_title = vc
        2 sched_loc_check = i2
        2 orders_per_req_ind = i2
        2 rm_priority_group = i2
        2 rm_priority_oem = vc
        2 rm_type_display = vc
        2 subtype_processing = vc
        2 exclude_date_start = vc
        2 exclude_date_end = vc
        2 oe_change_processing = i2
    1 error_message = vc
    1 status_data
        2 status = c1
        2 subeventstatus [1]
            3 operationname = c25
            3 operationstatus = c1
            3 targetobjectname = c25
            3 targetobjectvalue = vc
) with protect
 
;call echorecord(bc_common)
declare temp_string = vc with noconstant("")
 
set record_data->status_data[1].status = "F"
 
set t_rec->prompts.outdev			= $OUTDEV
set t_rec->prompts.requisition_format_cd = $REQUISITION_FORMAT_CD
set t_rec->prompts.parameters	= $PARAMETERS

if (t_rec->prompts.parameters > " ")
	set t_rec->cons.ippdf_parameter_update = 1
endif

select into "nl:"
from
    code_value cv
plan cv
    where cv.code_value = t_rec->prompts.requisition_format_cd
    and   cv.active_ind = 1
detail
    t_rec->cons.requisition_format_cd = cv.code_value
    t_rec->cons.requisition_cdf_meaning = cv.cdf_meaning
    t_rec->cons.requisition_display = cv.display
with nocounter
 
if (t_rec->cons.requisition_format_cd > 0.0)
 
    select into "nl:"
    from
         code_value cv1
        ,code_value cv2
    plan cv1
        where cv1.code_value = t_rec->cons.requisition_format_cd
        and   cv1.active_ind = 1
    join cv2
        where cv2.code_set = bc_all_pdf_std_variables->code_set.printtopdf
        and   cv2.cdf_meaning = "REQUISITION"
        and   cnvtupper(cv2.description) = cnvtupper(cv1.cdf_meaning)
    detail
        t_rec->cons.ippdf_code_value = cv2.code_value
        t_rec->cons.ippdf_current_active_ind = cv2.active_ind
        t_rec->cons.ippdf_definition = cv2.definition
        t_rec->cons.ippdf_description = cv2.description
        t_rec->cons.ippdf_display = cv2.display
        if (cv2.active_ind = 1)
        	t_rec->cons.ippdf_new_active_ind = 0
        else
        	t_rec->cons.ippdf_new_active_ind = 1
        endif
    with nocounter
 
    if (t_rec->cons.ippdf_code_value > 0.0)
    	
    	if (t_rec->cons.ippdf_parameter_update = 0)
    		 update into code_value
       		 set
             	active_ind = t_rec->cons.ippdf_new_active_ind
            	,updt_dt_tm = cnvtdatetime(curdate,curtime3)
            	,updt_id = reqinfo->updt_id
            	,updt_cnt = (updt_cnt + 1)
        		where code_value = t_rec->cons.ippdf_code_value and code_value > 0.0
       		commit
    	else
    		set t_rec->cons.new_ippdf_title = piece(t_rec->prompts.parameters,~:~,1,~<not defined>~)
    		set t_rec->cons.new_ippdf_req_script = piece(t_rec->prompts.parameters,~:~,2,t_rec->cons.requisition_cdf_meaning)
    		set t_rec->cons.new_ippdf_orders_per_req = cnvtint(piece(t_rec->prompts.parameters,~:~,3,"1"))
    		set t_rec->cons.new_ippdf_priority_group = piece(t_rec->prompts.parameters,~:~,4,"1")
    		set t_rec->cons.new_ippdf_priority_oem = piece(t_rec->prompts.parameters,~:~,5,"Priority")
    		set t_rec->cons.new_ippdf_type_display = piece(t_rec->prompts.parameters,~:~,6,"Lab, MI, Cardiology")
    		set t_rec->cons.new_ippdf_sched_loc_check = piece(t_rec->prompts.parameters,~:~,7,"0")
            set t_rec->cons.new_ippdf_subtype_processing = piece(t_rec->prompts.parameters,~:~,8,"activity_type_cd")
    		set t_rec->cons.new_ippdf_oe_change_processing = piece(t_rec->prompts.parameters,~:~,9,"0")

    		if (t_rec->cons.new_ippdf_orders_per_req <= 0)
    			set t_rec->cons.new_ippdf_orders_per_req = 1
    		endif
    		
    		update into code_value
       		 set
             	 display = t_rec->cons.new_ippdf_title
                ,display_key = cnvtupper(cnvtalphanum(t_rec->cons.new_ippdf_title))
             	,definition = t_rec->cons.new_ippdf_req_script
             	,collation_seq = t_rec->cons.new_ippdf_orders_per_req
            	,updt_dt_tm = cnvtdatetime(curdate,curtime3)
            	,updt_id = reqinfo->updt_id
            	,updt_cnt = (updt_cnt + 1)
        		where code_value = t_rec->cons.ippdf_code_value and code_value > 0.0
       		commit

    		if (t_rec->cons.new_ippdf_priority_group > "")
                set stat = sAddUpdateCodeValueExtension(
                                                             value(t_rec->cons.ippdf_code_value)
                                                            ,"RM_PRIORITY_GROUP"
                                                            ,value(t_rec->cons.new_ippdf_priority_group)
                                                            ,2
                                                        )
            endif

            if (t_rec->cons.new_ippdf_priority_oem > "")
                set stat = sAddUpdateCodeValueExtension(
                                                             value(t_rec->cons.ippdf_code_value)
                                                            ,"RM_PRIORITY_OEM"
                                                            ,value(t_rec->cons.new_ippdf_priority_oem)
                                                            ,2
                                                        )
            endif

            if (t_rec->cons.new_ippdf_type_display > "")
                set stat = sAddUpdateCodeValueExtension(
                                                             value(t_rec->cons.ippdf_code_value)
                                                            ,"RM_TYPE_DISPLAY"
                                                            ,value(t_rec->cons.new_ippdf_type_display)
                                                            ,2
                                                        )
            endif

            if (t_rec->cons.new_ippdf_sched_loc_check > "")
                set stat = sAddUpdateCodeValueExtension(
                                                             value(t_rec->cons.ippdf_code_value)
                                                            ,"SCHED_LOC_CHECK"
                                                            ,value(t_rec->cons.new_ippdf_sched_loc_check)
                                                            ,2
                                                        )
            endif

            if (t_rec->cons.new_ippdf_subtype_processing > "")
                set stat = sAddUpdateCodeValueExtension(
                                                             value(t_rec->cons.ippdf_code_value)
                                                            ,"SUBTYPE_PROCESSING"
                                                            ,value(t_rec->cons.new_ippdf_subtype_processing)
                                                            ,2
                                                        )
            endif

            if (t_rec->cons.new_ippdf_oe_change_processing > "")
                set stat = sAddUpdateCodeValueExtension(
                                                             value(t_rec->cons.ippdf_code_value)
                                                            ,"OE_CHANGE_PROCESSING"
                                                            ,value(t_rec->cons.new_ippdf_oe_change_processing)
                                                            ,2
                                                        )
            endif
    	endif
    else
    	set stat = initrec(102901_request)
        free record 102901_reply
        
        set 102901_request->code_value_qual = 1
        set stat = alterlist(102901_request->code_value,102901_request->code_value_qual)
        set 102901_request->code_value[102901_request->code_value_qual].action_type = "ADD"
        set 102901_request->code_value[102901_request->code_value_qual].code_set = bc_all_pdf_std_variables->code_set.printtopdf
        set 102901_request->code_value[102901_request->code_value_qual].cdf_meaning = "REQUISITION"
        set 102901_request->code_value[102901_request->code_value_qual].display = "<DEFINE> Requisition"
        set 102901_request->code_value[102901_request->code_value_qual].description = t_rec->cons.requisition_cdf_meaning
        set 102901_request->code_value[102901_request->code_value_qual].definition =  t_rec->cons.requisition_cdf_meaning
        set 102901_request->code_value[102901_request->code_value_qual].collation_seq_ind = 1
        set 102901_request->code_value[102901_request->code_value_qual].collation_seq = 1
 
        call echorecord(102901_request)
        set stat = tdbexecute(100008,100083,102901,"REC",102901_request,"REC",102901_reply)
        call echorecord(102901_reply)
 
        if ((102901_reply->status_data->status = "S") and (102901_reply->code_value[1].code_value > 0.0))
            set t_rec->cons.rm_code_value = 102901_reply->code_value[1].code_value
            update into code_value set updt_id = reqinfo->updt_id
            where code_value = t_rec->cons.rm_code_value
            and   code_value > 0.0
            commit
		endif

        /* To-Do
        
        "EXCLUDE_DATE_START": 
        "EXCLUDE_DATE_END": 
         */

        set stat = sAddUpdateCodeValueExtension(
                                                             value(t_rec->cons.rm_code_value)
                                                            ,"RM_PRIORITY_GROUP"
                                                            ,"1"
                                                            ,2
                                                        )
        set stat = sAddUpdateCodeValueExtension(
                                                             value(t_rec->cons.rm_code_value)
                                                            ,"RM_PRIORITY_OEM"
                                                            ,"Priority"
                                                            ,2
                                                        )
        set stat = sAddUpdateCodeValueExtension(
                                                             value(t_rec->cons.rm_code_value)
                                                            ,"RM_TYPE_DISPLAY"
                                                            ,"Lab, MI, Cardiology"
                                                            ,2
                                                        )
        set stat = sAddUpdateCodeValueExtension(
                                                             value(t_rec->cons.rm_code_value)
                                                            ,"SCHED_LOC_CHECK"
                                                            ,"1"
                                                            ,2
                                                        )
        set stat = sAddUpdateCodeValueExtension(
                                                             value(t_rec->cons.rm_code_value)
                                                            ,"SUBTYPE_PROCESSING"
                                                            ,"activity_type_cd"
                                                            ,2
                                                        )
        set stat = sAddUpdateCodeValueExtension(
                                                             value(t_rec->cons.rm_code_value)
                                                            ,"OE_CHANGE_PROCESSING"
                                                            ,"0"
                                                            ,2
                                                        )              
    endif
 
    call echorecord(t_rec)
else
    set stat = cnvtjsontorec(sGetRequisitionDefinitions(null))
    for (i=1 to requisition_list->cnt)
        set record_data->req_cnt = (record_data->req_cnt + 1)
        set stat = alterlist(record_data->req_list,record_data->req_cnt)
        set record_data->req_list[record_data->req_cnt].code_value  = requisition_list->qual[i].code_value
        set record_data->req_list[record_data->req_cnt].display = requisition_list->qual[i].display
        set record_data->req_list[record_data->req_cnt].description = requisition_list->qual[i].description
        set record_data->req_list[record_data->req_cnt].definition = requisition_list->qual[i].definition
        set record_data->req_list[record_data->req_cnt].requisition_format_cd
            = requisition_list->qual[i].requisition_format_cd
        set record_data->req_list[record_data->req_cnt].requisition_format_title
            = requisition_list->qual[i].requisition_format_title
        set record_data->req_list[record_data->req_cnt].sched_loc_check = requisition_list->qual[i].sched_loc_check
        set record_data->req_list[record_data->req_cnt].orders_per_req_ind = requisition_list->qual[i].orders_per_req_ind
        set record_data->req_list[record_data->req_cnt].rm_priority_group = requisition_list->qual[i].rm_priority_group
        set record_data->req_list[record_data->req_cnt].rm_priority_oem = requisition_list->qual[i].rm_priority_oem
        set record_data->req_list[record_data->req_cnt].rm_type_display = requisition_list->qual[i].rm_type_display
        set record_data->req_list[record_data->req_cnt].subtype_processing = requisition_list->qual[i].subtype_processing
        set record_data->req_list[record_data->req_cnt].exclude_date_start = requisition_list->qual[i].exclude_date_start
        set record_data->req_list[record_data->req_cnt].exclude_date_end = requisition_list->qual[i].exclude_date_end
        set record_data->req_list[record_data->req_cnt].oe_change_processing = requisition_list->qual[i].oe_change_processing
 
        if (requisition_list->qual[i].rm_priority_group > record_data->params.priority_group_order_max)
        	set record_data->params.priority_group_order_max = requisition_list->qual[i].rm_priority_group
        endif
 
 
        select distinct
			off.label_text
		from
			 code_value cv2
			,order_catalog oc
			,oe_format_fields off
			,order_entry_fields oef
			,oe_field_meaning ofm
		plan cv2
			where cv2.code_set = 6002
			and   cv2.code_value = record_data->req_list[record_data->req_cnt].requisition_format_cd
			and   cv2.active_ind = 1
		join oc
			where oc.requisition_format_cd = cv2.code_value
			and   oc.active_ind = 1
		join off
			where off.oe_format_id = oc.oe_format_id
		join oef
			where oef.oe_field_id = off.oe_field_id
		join ofm
			where ofm.oe_field_meaning_id = oef.oe_field_meaning_id
			and	  ofm.oe_field_meaning in( "PRIORITY","COLLPRI")
		order by
			off.label_text
		head off.label_text
			if (locateval(j,1,record_data->params.priority_cnt,
					trim(off.label_text),record_data->params.priority_qual[j].value) = 0)
				record_data->params.priority_cnt = (record_data->params.priority_cnt + 1)
				stat = alterlist(record_data->params.priority_qual,record_data->params.priority_cnt)
				record_data->params.priority_qual[record_data->params.priority_cnt].value = trim(off.label_text)
			endif
		with nocounter
    endfor
endif
 
#exit_success
 
set record_data->status_data[1].status = "S"
 
#exit_script
 
 
set _memory_reply_string = cnvtrectojson (record_data)
;call echo(_memory_reply_string)
call echorecord(record_data)
;call echorecord(t_rec)
end
go
 