/*****************************************************************************
******************************************************************************

  Author:             Chad Cummings
  Date Written:       03/01/2019
  Solution:           
  Source file name:   bc_all_mp_add_req_status.prg
  Object name:        bc_all_mp_add_req_status
  Request #:

  Program purpose:

  Executing from:     

  Special Notes:       

******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************

Mod   Mod Date    Developer              Comment
---   ----------  --------------------  --------------------------------------
001   10/01/2019  Chad Cummings			Initial Release
******************************************************************************/
drop program bc_all_mp_add_req_status:dba go
create program bc_all_mp_add_req_status:dba

prompt 
	"Output to File/Printer/MINE" = "MINE"
	, "EVENT_ID" = 0
	, "req_status" = "" 

with OUTDEV, EVENT_ID, REQ_STATUS

FREE RECORD record_data
RECORD record_data (
  1 req_status = vc
  1 parent_event_id = f8
  1 date_used = i2
  1 latest_status = vc
  1 error_message = vc
  1 status_data
    2 status = c1
    2 subeventstatus [1 ]
      3 operationname = c25
      3 operationstatus = c1
      3 targetobjectname = c25
      3 targetobjectvalue = vc
)

SET record_data->status_data.status = "F"

;free record t_rec
record t_rec
(
	1 event_id = f8
	1 cancel_ind = i2
	1 updt_ind = i2
	1 request_prsnl_id = f8
	1 new_title = vc
	1 normal_ref_range_txt = vc
	1 req_status = vc
	1 latest_status = vc
) with protect

record 1120120request (
 1 event_qual [*]   
  2 event_id = f8   
)

set t_rec->event_id = $EVENT_ID
set t_rec->request_prsnl_id	= reqinfo->updt_id
set t_rec->req_status = $req_status

set record_data->parent_event_id = t_rec->event_id
set record_data->req_status = t_rec->req_status

if (t_rec->event_id <= 0.0)
	go to exit_script
endif

if ((t_rec->req_status = "") or (t_rec->req_status = "null"))
	set record_data->status_data.status = "F"
	set record_data->error_message = "Select at least one Requisition Status"
	go to exit_script
endif

declare notfnd = vc with constant("<not found>"), protect
declare order_string = vc with noconstant(" "), protect
declare i = i2 with noconstant(0), protect
declare k = i2 with noconstant(0), protect
declare j = i2 with noconstant(0), protect
declare pos = i2 with noconstant(0), protect
	

call echo(build2(^tdbexecute(600005, 1120006, 1120120, "REC", 1120120request, "REC", 1120120reply)^))
set stat = initrec(1120120request)
free record 1120120reply
set stat = alterlist(1120120request->event_qual,1)
set 1120120request->event_qual[1].event_id = record_data->parent_event_id

set stat = tdbexecute(600005, 1120006, 1120120, "REC", 1120120request, "REC", 1120120reply)

if (validate(1120120reply))
	call echorecord(1120120reply)
	;set record_data->tlist[i].action_history = concat(cnvtrectojson(1120120request),cnvtrectojson(1120120reply))
	call echo(build2(^->validate(1120120reply)^))
	if (1120120reply->status_data->status = "S")
		call echo(build2(^-->1120120reply->status_data->status = "S"^))
		for (k=1 to size(1120120reply->rb_list,5))
			call echo(build2(^--->k=^,k))
			call echo(build2(^size(1120120reply->rb_list[k].event_list,5)=^,size(1120120reply->rb_list[k].event_list,5)))
			for (j=1 to size(1120120reply->rb_list[k].event_list,5))
				call echo(build2(^--->j=^,j))
				call echo(build2(^--->cnvtupper(1120120reply->rb_list[k].event_list[j].event_class_cd_disp)=^
					,cnvtupper(1120120reply->rb_list[k].event_list[j].event_class_cd_disp)))
				if (cnvtupper(1120120reply->rb_list[k].event_list[j].event_class_cd_disp) = "MDOC")
					call echo("mdoc found")
					

					select into "nl:"
						action_dt_tm = 1120120reply->rb_list[k].event_list[j].event_prsnl_list[d1.seq].action_dt_tm
					from
						(dummyt d1 with seq = size(1120120reply->rb_list[k].event_list[j].event_prsnl_list,5))
						,prsnl p
					plan d1
						where 1120120reply->rb_list[k].event_list[j].event_prsnl_list[d1.seq].action_type_cd_disp
								in("Author")
					join p
						where p.person_id = 1120120reply->rb_list[k].event_list[j].event_prsnl_list[d1.seq].action_prsnl_id	
					order by
						action_dt_tm desc
					head report
						 cnt = 0
					detail
						cnt = (cnt + 1)
						if (cnt = 1)
							record_data->latest_status = 1120120reply->rb_list[k].event_list[j].event_prsnl_list[d1.seq].action_comment
						endif
					foot report
						cnt = 0
					with nocounter	
				endif
			endfor
		endfor
	endif
endif
				
if (t_rec->req_status = record_data->latest_status)
	SET record_data->status_data.status = "S"
	go to exit_script
endif

select into "nl:"
from
	clinical_event ce
plan ce
	where ce.event_id = t_rec->event_id
detail
	call echo(build2("-->Inside Detail Section"))
	call echo(build2("--->",trim(ce.event_title_text)))
	t_rec->normal_ref_range_txt = ce.normal_ref_range_txt
	call echo(build2("-->",uar_get_code_display(ce.event_cd)))
	call echo(build2("<--Exit Detail Section"))
with nocounter

free record ensure_request 
free record ensure_reply 
 
record ensure_request (
   1 req                   [*]
      2 ensure_type           = i2
      2 version_dt_tm         = dq8
      2 version_dt_tm_ind     = i2
      2 event_prsnl
         3 event_prsnl_id        = f8
         3 person_id             = f8
         3 event_id              = f8
         3 action_type_cd        = f8
         3 request_dt_tm         = dq8
         3 request_dt_tm_ind     = i2
         3 request_prsnl_id      = f8
         3 request_prsnl_ft      = vc
         3 request_comment       = vc
         3 action_dt_tm          = dq8
         3 action_dt_tm_ind      = i2
         3 action_prsnl_id       = f8
         3 action_prsnl_ft       = vc
         3 proxy_prsnl_id        = f8
         3 proxy_prsnl_ft        = vc
         3 action_status_cd      = f8
         3 action_comment        = vc
         3 change_since_action_flag  = i2
         3 change_since_action_flag_ind  = i2
         3 action_prsnl_pin      = vc
         3 defeat_succn_ind      = i2
         3 ce_event_prsnl_id     = f8
         3 valid_from_dt_tm      = dq8
         3 valid_from_dt_tm_ind  = i2
         3 valid_until_dt_tm     = dq8
         3 valid_until_dt_tm_ind  = i2
         3 updt_dt_tm            = dq8
         3 updt_dt_tm_ind        = i2
         3 updt_task             = i4
         3 updt_task_ind         = i2
         3 updt_id               = f8
         3 updt_cnt              = i4
         3 updt_cnt_ind          = i2
         3 updt_applctx          = i4
         3 updt_applctx_ind      = i2
         3 long_text_id          = f8
         3 linked_event_id       = f8
         3 request_tz            = i4
         3 action_tz             = i4
         3 system_comment        = vc
         3 event_action_modifier_list  [*]
            4 ce_event_action_modifier_id  = f8
            4 event_action_modifier_id  = f8
            4 event_id              = f8
            4 event_prsnl_id        = f8
            4 action_type_modifier_cd  = f8
            4 valid_from_dt_tm      = dq8
            4 valid_from_dt_tm_ind  = i2
            4 valid_until_dt_tm     = dq8
            4 valid_until_dt_tm_ind  = i2
            4 updt_dt_tm            = dq8
            4 updt_dt_tm_ind        = i2
            4 updt_task             = i4
            4 updt_task_ind         = i2
            4 updt_id               = f8
            4 updt_cnt              = i4
            4 updt_cnt_ind          = i2
            4 updt_applctx          = i4
            4 updt_applctx_ind      = i2
         3 ensure_type           = i2
         3 digital_signature_ident  = vc
         3 action_prsnl_group_id  = f8
         3 request_prsnl_group_id  = f8
         3 receiving_person_id   = f8
         3 receiving_person_ft   = vc
      2 ensure_type2          = i2
      2 clinsig_updt_dt_tm_flag  = i2
      2 clinsig_updt_dt_tm    = dq8
      2 clinsig_updt_dt_tm_ind  = i2
   1 message_item
      2 message_text          = vc
      2 subject               = vc
      2 confidentiality       = i2
      2 priority              = i2
      2 due_date              = dq8
      2 sender_id             = f8
   1 user_id               = f8
) 
 
record ensure_reply (
   1 rep                   [*]
      2 event_prsnl_id        = f8
      2 event_id              = f8
      2 action_prsnl_id       = f8
      2 action_type_cd        = f8
      2 sb
         3 severityCd            = i4
         3 statusCd              = i4
         3 statusText            = vc
         3 subStatusList         [*]
            4 subStatusCd           = i4
   1 sb
      2 severityCd            = i4
      2 statusCd              = i4
      2 statusText            = vc
      2 subStatusList         [*]
         3 subStatusCd           = i4
 
%i cclsource:status_block.inc
) 

set stat = alterlist(ensure_request->req, 1) 
set ensure_request->req[1].ensure_type 			 		= 2 
set ensure_request->req[1].version_dt_tm_ind 			= 1 
set ensure_request->req[1].event_prsnl.event_id 		= t_rec->event_id
set ensure_request->req[1].event_prsnl.action_type_cd 	= value(uar_get_code_by("MEANING",21,"AUTHOR"))  
set ensure_request->req[1].event_prsnl.action_dt_tm 	= cnvtdatetime(curdate,curtime3) 
set ensure_request->req[1].event_prsnl.updt_dt_tm 		= cnvtdatetime(curdate,curtime3)
set ensure_request->req[1].event_prsnl.action_prsnl_id 	= t_rec->request_prsnl_id
set ensure_request->req[1].event_prsnl.proxy_prsnl_id 	= 0.00 
set ensure_request->req[1].event_prsnl.action_status_cd = value(uar_get_code_by("MEANING",103,"COMPLETED"))
set ensure_request->req[1].event_prsnl.defeat_succn_ind = 1 
set ensure_request->req[1].event_prsnl.action_comment 	= t_rec->req_status

if (t_rec->cancel_ind = 0)
	execute inn_event_prsnl_batch_ensure ^NOFORMS^ with replace("ensure_request",ensure_request),replace("ensure_reply",ensure_reply)
	update into clinical_event ce 
	set ce.normal_ref_range_txt = t_rec->normal_ref_range_txt
	where ce.event_id = t_rec->event_id
	commit 
endif 

if ((t_rec->event_id > 0.0) and (t_rec->updt_ind = 1))
	update into clinical_event ce 
	set ce.event_title_text = t_rec->new_title, 
		ce.result_status_cd = value(uar_get_code_by("MEANING",8,"AUTH"))
	where ce.event_id = t_rec->event_id
	commit 
endif


SET record_data->status_data.status = "S"

#exit_script

CALL echorecord (record_data )
DECLARE strjson = vc
DECLARE _memory_reply_string = vc
SET strjson = cnvtrectojson (record_data )
SET _memory_reply_string = strjson

end go
