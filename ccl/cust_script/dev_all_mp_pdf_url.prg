/*****************************************************************************
******************************************************************************

  Author:             Chad Cummings
  Date Written:       03/01/2019
  Solution:           
  Source file name:   dev_all_mp_pdf_url.prg
  Object name:        dev_all_mp_pdf_url
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
002   11/27/2020  Chad Cummings			Action List Sort by Date and Time
003   12/16/2020  Chad Cummings			Updated status per Sprint 5
004   01/18/2021  Chad Cummings			Added valid indicator to ensure reqs are still active
005   02/14/2021  Chad Cummings			Added status for undo print
******************************************************************************/
drop program dev_all_mp_pdf_url go
create program dev_all_mp_pdf_url 

prompt 
	"Output to File/Printer/MINE" = "MINE"
	, "EVENT_ID" = 0 

with OUTDEV, CE_EVENT_ID


free record patientdata
record patientdata
(
	1 person_id = f8
	1 encntr_id = f8
)



free record record_data
record record_data
(
	1 clinical_event_id = f8
	1 event_id = f8
	1 parent_event_id = f8
	1 cmv_url = vc
	1 cmv_base = vc
	1 identifier = vc
	1 action_list_cnt = i2
	1 status = vc ;005
	1 printed_status = vc ;05
	1 valid_ind = i2 ;004
	1 order_list = vc ;004
	1 order_parser = vc ;004
	1 protocol_order_parser = vc ;004
	1 template_order_parser = vc ;004
	1 result_status_cd = f8 ;004
	1 action_list[*]
	 2 ce_event_prsnl_id = f8
	 2 action_prsnl_id = f8 ;003
	 2 action_prsnl_position_cd = f8 ;003
	 2 action_prsnl_position_disp = vc ;003
	 2 action_status_cd_disp =vc
	 2 action_type_cd_disp = vc
	 2 action_prsnl_name_full = vc
	 2 action_dt_tm = dq8
	 2 action_dt_tm_disp = vc
	 2 action_comment = vc
	  1 error_message = vc
  1 status_data
    2 status = c1
    2 subeventstatus [1 ]
      3 operationname = c25
      3 operationstatus = c1
      3 targetobjectname = c25
      3 targetobjectvalue = vc
)

set record_data->clinical_event_id = $CE_EVENT_ID

if (record_data->clinical_event_id = 0.0)
	set record_data->clinical_event_id = 230668007.00 ;TESTING
endif

select into "nl:"
from
	 clinical_event ce
	,clinical_event pe
	,encounter e
	,person p
plan ce
	where ce.clinical_event_id = record_data->clinical_event_id
join pe
	where pe.event_id = ce.parent_event_id
	/*and     ce.valid_from_dt_tm <= cnvtdatetime(curdate,curtime3)
	and     ce.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3)
	and     ce.result_status_cd in(
											 value(uar_get_code_by("MEANING",8,"AUTH"))
											,value(uar_get_code_by("MEANING",8,"MODIFIED"))
											,value(uar_get_code_by("MEANING",8,"ALTERED"))
										)
	*/
join e
	where e.encntr_id = ce.encntr_id
join p
	where p.person_id = e.person_id
detail
	patientdata->encntr_id = e.encntr_id
	patientdata->person_id = p.person_id
	record_data->order_list = pe.normal_ref_range_txt
	record_data->order_list = replace(record_data->order_list,":",",",0)
	record_data->result_status_cd = ce.result_status_cd
	
	record_data->status = piece(pe.event_title_text,":",1,"")
	
	if (record_data->status not in("ACTIONED","MODIFIED","CANCELED"))		
		record_data->status = "PENDING"
	endif
	
	if (record_data->status in("ACTIONED"))
			record_data->printed_status = "Printed"
		else
			record_data->printed_status = "Pending"
		endif
	
with nocounter


select into "nl:"
from
	 clinical_event ce
	,ce_blob_result cbr
plan ce
	where ce.clinical_event_id = record_data->clinical_event_id
join cbr
	where cbr.event_id = ce.event_id
	and   cbr.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3)
order by
     ce.encntr_id
	,ce.event_id
	,ce.valid_from_dt_tm desc
head ce.encntr_id
	record_data->identifier = cbr.blob_handle
	record_data->event_id = ce.event_id
	record_data->parent_event_id = ce.parent_event_id
with nocounter

set record_data->cmv_base = concat(
										"http://phsacdea.cerncd.com/"
										,"camm/"
										,trim(cnvtlower(curdomain))				
										;,trim(cnvtlower(b0783))
										,".phsa_cd.cerncd.com/service/mediaContent/"
								)
;set record_data->cmv_base = "http://phsacdeanp/camm-mpage/b0783.phsa_cd.cerncd.com/service/mediaContent/"
set record_data->cmv_url = concat(trim(record_data->cmv_base),trim(record_data->identifier))

set record_data->order_parser = concat("o.order_id in(",trim(record_data->order_list),")")
set record_data->template_order_parser = concat("o.template_order_id in(",trim(record_data->order_list),")")
set record_data->protocol_order_parser = concat("o.protocol_order_id in(",trim(record_data->order_list),")")

select into "nl:"
from
	orders o
plan o
	where (		parser(record_data->order_parser)
	      or	parser(record_data->template_order_parser)
	      or	parser(record_data->protocol_order_parser)
	      )
	and   o.order_status_cd in(
										 value(uar_get_code_by("MEANING",6004,"FUTURE"))
										,value(uar_get_code_by("MEANING",6004,"VOIDEDWRSLT"))
									)
detail
	record_data->valid_ind = 1
with nocounter 

if (record_data->valid_ind = 1)
	if (record_data->result_status_cd not in(
											 value(uar_get_code_by("MEANING",8,"AUTH"))
											,value(uar_get_code_by("MEANING",8,"MODIFIED"))
											,value(uar_get_code_by("MEANING",8,"ALTERED"))
										))
		set record_data->valid_ind = 0
	endif
endif

/*
select into "nl:"
	from
		 (dummyt d1 with seq=size(record_data->tlist,5))
		,(dummyt d2 with seq=1)
		,orders o
		,order_action oa
		,prsnl p
	plan d1
		where maxrec(d2,record_data->tlist[d1.seq].olist_cnt)
	join d2
	join o
		where o.order_id = record_data->tlist[d1.seq].olist[d2.seq].order_id
		and   o.order_status_cd in(
										 value(uar_get_code_by("MEANING",6004,"FUTURE"))
										;002 ,value(uar_get_code_by("MEANING",6004,"ORDERED"))
									)
	join oa
		where oa.order_id = o.order_id
	join p
		where p.person_id = oa.order_provider_id
		and parser(provider_parser)
	order by
		 o.order_id
		,oa.action_sequence desc
*/

if (record_data->cmv_url > " ")
	SET record_data->status_data.status = "S"
endif

SET modify maxvarlen 20000000
SET _memory_reply_string = cnvtrectojson (record_data )

call echorecord(record_data)
end go