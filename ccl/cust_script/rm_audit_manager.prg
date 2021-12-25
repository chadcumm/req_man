/*****************************************************************************
******************************************************************************
 
  Author:             Chad Cummings
  Date Written:       12/17/2021
  Solution:
  Source file name:   rm_audit_manager.prg
  Object name:        rm_audit_manager
  Request #:
 
  Program purpose:
 
  Executing from:
 
  Special Notes:
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod   Mod Date    Developer              Comment
---   ----------  --------------------  --------------------------------------
000   12/17/2021  Chad Cummings			    Initial Release
001   12/17/2021  Chad Cummings         CST-130820
******************************************************************************/
 
drop program rm_audit_manager:dba go
create program rm_audit_manager:dba
 
prompt 
	"Output to File/Printer/MINE" = "MINE"
	, "REQUISITION_FORMAT_CD" = 0
	, "TYPE" = "" 

with OUTDEV, REQUISITION_FORMAT_CD, TYPE
 
 
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
 
 
 
record t_rec
(
	1 prompts
	    2 outdev			          = vc
      2 requisition_format_cd = f8
      2 type                  = vc
  1 cons 
      2 requisition_format_cd = f8
      2 type = vc
  1 oef_cnt = i2
  1 oef_qual[*]
      2 oe_format_id = f8
      2 description = vc
      2 pass_ind = i2
      2 order_cnt = i2
      2 oe_field_cnt = i2
      2 oe_field_qual[*]
          3 oe_field_id = f8
          3 label_text = vc
) with protect
 
free record record_data
record record_data
(
    1 prompts
        2 outdev			= vc
    1 oef_cnt = i2
    1 oef_qual[*]
      2 oe_format_id = f8
      2 description = vc
      2 pass_ind = i2
      2 order_cnt = i2
      2 oe_field_cnt = i2
      2 oe_field_qual[*]
          3 oe_field_id = f8
          3 label_text = vc
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
 
declare temp_string = vc with noconstant("")
 
set record_data->status_data[1].status = "F"
 
set t_rec->prompts.outdev			                = $OUTDEV
set t_rec->prompts.requisition_format_cd			= $REQUISITION_FORMAT_CD
set t_rec->prompts.type			                  = $TYPE

set t_rec->cons.requisition_format_cd = t_rec->prompts.requisition_format_cd
set t_rec->cons.type                  = t_rec->prompts.type

if (t_rec->cons.requisition_format_cd > 0.0)
  if (cnvtupper(t_rec->cons.type) = 'OEF')
    select distinct into "nl:"
    from  
       code_value cv1
      ,order_catalog oc
      ,order_catalog_synonym ocs
      ,order_entry_format oef
      ,order_entry_fields o
			,oe_format_fields off
    plan cv1  
      where cv1.code_value = t_rec->cons.requisition_format_cd
    join oc 
      where oc.requisition_format_cd = cv1.code_value
      	and oc.active_ind = 1
		join ocs
			where ocs.catalog_cd = oc.catalog_cd
		join oef
			where oef.oe_format_id = ocs.oe_format_id
    join off
			where off.oe_format_id = oef.oe_format_id
		join o
			where o.oe_field_id = off.oe_field_id
    order by
       oef.oe_format_name
      ,oef.oe_format_id
      ,off.label_text
      ,off.oe_field_id
    head report 
      i = 0
      j = 0
    head oef.oe_format_id
      i = (i + 1)
      j = 0
      stat = alterlist(t_rec->oef_qual,i)
      t_rec->oef_qual[i].oe_format_id = oef.oe_format_id
      t_rec->oef_qual[i].description = oef.oe_format_name
      t_rec->oef_qual[i].pass_ind = 1
    head off.oe_field_id
      j = (j + 1)
      stat = alterlist(t_rec->oef_qual[i].oe_field_qual,j)
      t_rec->oef_qual[i].oe_field_qual[j].oe_field_id = off.oe_field_id
      t_rec->oef_qual[i].oe_field_qual[j].label_text = off.label_text
    foot oef.oe_format_id
      t_rec->oef_qual[i].oe_field_cnt = j
    foot report 
      t_rec->oef_cnt = i
    with nocounter

    select into "nl:"
    from
       order_catalog oc
      ,order_catalog_synonym ocs
      ,order_entry_format oef
    plan oc
      where oc.requisition_format_cd = t_rec->cons.requisition_format_cd
    join ocs
			where ocs.catalog_cd = oc.catalog_cd
		join oef
			where oef.oe_format_id = ocs.oe_format_id
      and   expand(i,1,t_rec->oef_cnt,oef.oe_format_id,t_rec->oef_qual[i].oe_format_id)
    order by
       oef.oe_format_id
      ,ocs.synonym_id
    head report 
      k = 0
      j = 0
    head oef.oe_format_id
      j = locateval(h,1,t_rec->oef_cnt,oef.oe_format_id,t_rec->oef_qual[h].oe_format_id)
      k = 0
    head ocs.synonym_id
      k = (k + 1)
    foot oef.oe_format_id
      t_rec->oef_qual[j].order_cnt = k
    with nocounter


  
    set stat = moverec(t_rec->oef_qual,record_data->oef_qual)
    set record_data->oef_cnt = t_rec->oef_cnt
    


  endif
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
  endfor
endif

#exit_success
 
set record_data->status_data[1].status = "S"
 
#exit_script
 
 
set _memory_reply_string = cnvtrectojson (record_data)
;call echo(_memory_reply_string)
call echorecord(record_data)
call echorecord(t_rec)
end
go
 