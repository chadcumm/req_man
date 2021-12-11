/*****************************************************************************
******************************************************************************

  Author:             Chad Cummings
  Date Written:       03/01/2019
  Solution:           
  Source file name:   rm_reg_req_by_conversation.prg
  Object name:        rm_reg_req_by_conversation
  Request #:

  Program purpose:

  Executing from:     CCL

  Special Notes:      Called by ccl program(s).
  						
						
						

******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************

Mod   Mod Date    Developer              Comment
---   ----------  --------------------  --------------------------------------
001   03/01/2019  Chad Cummings			initial build
******************************************************************************/
drop program rm_reg_req_by_conversation:dba go
create program rm_reg_req_by_conversation:dba

prompt 
	"Output to File/Printer/MINE" = "MINE"
	, "CONVERSATION_ID" = 0 

with OUTDEV, CONVERSATION_ID


set retval = -1


record t_rec
(
	1 patient
	 2 encntr_id 					= f8
	 2 person_id 					= f8
	1 retval 						= i2
	1 log_message 					=  vc
	1 log_misc1 					= vc
	1 return_value 					= vc
	1 regenerate_cnt				= i2
	1 req_cnt						= i2
	1 req_qual[*]	
	 2 event_id						= f8
	 2 order_list					= vc
	 2 regenerate_ind				= i2
	 2 ord_cnt						= i2
	 2 ord_qual[*]
	  3 order_id					= f8
	  3 requisition_format_cd		= f8
	  3 originatingencounterid 		= f8
	  3 encntrid 					= f8
	  3 pathwaycatalogid 			= f8
	  3 primarymnemonic 			= vc
	  3 catalog_cd					= f8

) with protect

set t_rec->retval							= -1
set t_rec->return_value						= "FAILED"

select into "nl:"
from
	orders o
	,order_action oa
plan oa
	where oa.order_conversation_id = $CONVERSATION_ID
join o
	where o.order_id = oa.order_id
detail
	t_rec->patient.encntr_id 				= o.originating_encntr_id
	t_rec->patient.person_id				= o.person_id
WITH NOCOUNTER


declare notfnd = vc with constant("<not found>"), protect
declare order_string = vc with noconstant(" "), protect
declare _i = i2 with noconstant(0), protect
declare _k = i2 with noconstant(0), protect
declare _j = i2 with noconstant(0), protect
declare i = i2 with noconstant(0), protect
declare k = i2 with noconstant(0), protect
declare j = i2 with noconstant(0), protect


if (t_rec->patient.person_id <= 0.0)
	set t_rec->log_message = concat("link_personid not found")
	go to exit_script
endif

free record req_requestin 
record req_requestin
(
	1 request
	 2 personid = f8
	 2 actionpersonnelid = f8
	 2 orderlist[*]
	  3 orderid = f8
	  3 orderproviderid = f8
	  3 actionpersonnelid = f8
	  3 requisitionformatcd = f8
	  3 actiontypecd = f8
	  3 originatingencounterid = f8
	  3 encntrid = f8
	  3 pathwaycatalogid = f8
	  3 catalogcd = f8
	  3 primarymnemonic = vc
	  3 detailList[*]
	   4 oeFieldId = f8
	  3 protocolinfo[*]
	   4 protocolType  = i2
	 2 trigger_app = i4
) 

set t_rec->return_value = "FALSE"

select into "nl:"
from
	person p
plan p
	where p.person_id = t_rec->patient.person_id
detail
	t_rec->log_message = concat(trim(t_rec->log_message),";","Query Executed")
with nocounter

/*
select into "nl:"
from
	 clinical_event ce
	,clinical_event pe
	,encounter e
	,ce_blob_result ceb
	,prsnl p1
	,person p
plan ce
	where ce.event_cd = value(uar_get_code_by("DISPLAY",72,"Print to PDF Req"))
	and	  ce.result_status_cd in(
									  value(uar_get_code_by("MEANING",8,"AUTH"))
									 ,value(uar_get_code_by("MEANING",8,"MODIFIED"))
								)
	
	and   ce.valid_until_dt_tm >= cnvtdatetime(curdate, curtime3)
	and   ce.event_tag        != "Date\Time Correction"
	and   ce.person_id 			= t_rec->patient.person_id
join pe
	where pe.event_id = ce.parent_event_id
	and	  pe.result_status_cd in(
									  value(uar_get_code_by("MEANING",8,"AUTH"))
									 ,value(uar_get_code_by("MEANING",8,"MODIFIED"))										
								)
	and   pe.valid_until_dt_tm >= cnvtdatetime(curdate, curtime3)
	and   pe.event_tag        != "Date\Time Correction"
join ceb
	where ceb.event_id = ce.event_id
    and   ceb.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3)
join p1
	where p1.person_id = ce.verified_prsnl_id
join e
	where e.encntr_id = ce.encntr_id
join p
	where p.person_id = e.person_id
order by
	 pe.event_end_dt_tm desc
	,pe.event_id
head report
	cnt = 0
head pe.event_id
	cnt = cnt + 1
	stat = alterlist(t_rec->req_qual,cnt)
	t_rec->req_qual[cnt].event_id = pe.event_id
	t_rec->req_qual[cnt].order_list = pe.normal_ref_range_txt
foot pe.event_id
	k = 1
	order_string = t_rec->req_qual[cnt].order_list
	while (order_string != notfnd)
		order_string = piece(t_rec->req_qual[cnt].order_list,":",k,notfnd)
		pos = locateval(
								 j
								,1
								,t_rec->req_qual[cnt].ord_cnt
								,cnvtreal(order_string)
								,t_rec->req_qual[cnt].ord_qual[j].order_id
							)
		if ((pos = 0) and (cnvtreal(order_string) > 0))
			t_rec->req_qual[cnt].ord_cnt = (t_rec->req_qual[cnt].ord_cnt + 1)
			stat = alterlist(t_rec->req_qual[cnt].ord_qual,t_rec->req_qual[cnt].ord_cnt)
			t_rec->req_qual[cnt].ord_qual[t_rec->req_qual[cnt].ord_cnt].order_id = cnvtreal(order_string)
		endif
		k = (k + 1)
	endwhile
	order_string = ""
foot report
	t_rec->req_cnt = cnt
with nocounter

*/

select into "nl:"
from
	orders o
	,order_action oa
plan oa
	where oa.order_conversation_id = $CONVERSATION_ID
join o
	where o.order_id = oa.order_id
	and   o.order_id > 0.0
	and   o.order_status_cd in(value(uar_get_code_by("MEANING",6004,"FUTURE")))
order by
	 o.person_id,
	 o.order_id
head report
	cnt = 0
head o.person_id
	cnt = cnt + 1
	stat = alterlist(t_rec->req_qual,cnt)
head o.order_id
	t_rec->req_qual[cnt].ord_cnt = (t_rec->req_qual[cnt].ord_cnt + 1)
	stat = alterlist(t_rec->req_qual[cnt].ord_qual,t_rec->req_qual[cnt].ord_cnt)
	t_rec->req_qual[cnt].ord_qual[t_rec->req_qual[cnt].ord_cnt].order_id = o.order_id
foot report
	t_rec->req_cnt = cnt
with nocounter

select into "nl:"
from
	 (dummyt d1 with seq=t_rec->req_cnt)
	,(dummyt d2 with seq=1)
	,orders o
	,order_action oa
	,prsnl p
	,order_catalog oc
plan d1
	where maxrec(d2,t_rec->req_qual[d1.seq].ord_cnt)
join d2
join o
	where o.order_id = t_rec->req_qual[d1.seq].ord_qual[d2.seq].order_id
	and   o.order_status_cd in(
									 value(uar_get_code_by("MEANING",6004,"FUTURE"))
									;002 ,value(uar_get_code_by("MEANING",6004,"ORDERED"))
								)
join oc
	where oc.catalog_cd = o.catalog_cd
join oa
	where oa.order_id = o.order_id
join p
	where p.person_id = oa.order_provider_id
detail
	;call echo(build2("o.order_mnemonic=",trim(o.order_mnemonic)))
	t_rec->req_qual[d1.seq].regenerate_ind = 1
	t_rec->req_qual[d1.seq].ord_qual[d2.seq].requisition_format_cd 	= oc.requisition_format_cd
	t_rec->req_qual[d1.seq].ord_qual[d2.seq].encntrid				= o.encntr_id
	t_rec->req_qual[d1.seq].ord_qual[d2.seq].originatingencounterid	= o.originating_encntr_id
	t_rec->req_qual[d1.seq].ord_qual[d2.seq].pathwaycatalogid		= o.pathway_catalog_id
	t_rec->req_qual[d1.seq].ord_qual[d2.seq].primarymnemonic		= o.order_mnemonic
	t_rec->req_qual[d1.seq].ord_qual[d2.seq].catalog_cd				= o.catalog_cd
with nocounter

call echorecord(t_rec)

for (_i=1 to t_rec->req_cnt)
	call echo(build("_i=",_i))
	call echo(build("t_rec->req_qual[_i].regenerate_ind=",t_rec->req_qual[_i].regenerate_ind))
	call echo(build("t_rec->regenerate_cnt=",t_rec->regenerate_cnt))
	if ((t_rec->req_qual[_i].regenerate_ind = 1) and (t_rec->regenerate_cnt >= 0))
		
		set stat =initrec(req_requestin)
		;set req_requestin->request->trigger_app 	= 999999
		set req_requestin->request->personid 		= t_rec->patient.person_id
		set req_requestin->actionpersonnelid		= reqinfo->updt_id
		set _j = 0
		call echo(build("t_rec->req_qual[_i].ord_cnt=",t_rec->req_qual[_i].ord_cnt))
		if (t_rec->req_qual[_i].ord_cnt > 0)			
		 for (_k=1 to t_rec->req_qual[_i].ord_cnt)
		 	call echo(build("_k=",_k))
		 	call echo(build("t_rec->req_qual[_i].ord_qual[_k].requisition_format_cd="
		 		,t_rec->req_qual[_i].ord_qual[_k].requisition_format_cd))
			if (t_rec->req_qual[_i].ord_qual[_k].requisition_format_cd > 0.0)
				set _j = (_j+1)
				set stat = alterlist(req_requestin->request->orderlist,_j) 
				set req_requestin->request->orderlist[_j].orderid					= t_rec->req_qual[_i].ord_qual[_k].order_id 
				set req_requestin->request->orderlist[_j].orderproviderid			= 1.0 
				set req_requestin->request->orderlist[_j].actionpersonnelid			= 1.0
				set req_requestin->request->orderlist[_j].requisitionformatcd		= t_rec->req_qual[_i].ord_qual[_k].requisition_format_cd
				set req_requestin->request->orderlist[_j].actiontypecd				= value(uar_get_code_by("MEANING",6003,"ORDER")) 
				set req_requestin->request->orderlist[_j].encntrid					= t_rec->req_qual[_i].ord_qual[_k].encntrid
				set req_requestin->request->orderlist[_j].originatingencounterid	= t_rec->req_qual[_i].ord_qual[_k].originatingencounterid
				set req_requestin->request->orderlist[_j].pathwaycatalogid			= t_rec->req_qual[_i].ord_qual[_k].pathwaycatalogid
				set req_requestin->request->orderlist[_j].primarymnemonic			= t_rec->req_qual[_i].ord_qual[_k].primarymnemonic
				set req_requestin->request->orderlist[_j].catalogcd					= t_rec->req_qual[_i].ord_qual[_k].catalog_cd
				
			endif
		 endfor
		endif	
		set t_rec->regenerate_cnt = (t_rec->regenerate_cnt + 1)
		;execute temp_bc_s_print_to_pdf_req with replace("REQUESTIN",REQ_REQUESTIN)
		execute temp_bc_print_to_pdf_req with replace("REQUESTIN",REQ_REQUESTIN)
		;execute ronc_bc_print_to_pdf_req with replace("REQUESTIN",REQ_REQUESTIN)
		call echorecord(req_requestin)
	endif
endfor


set t_rec->log_message = concat(trim(t_rec->log_message),";",cnvtrectojson(req_requestin))
set t_rec->log_message = build(trim(t_rec->log_message),";Generation count:",t_rec->regenerate_cnt)

/* Use if parameters are needed
if(size(trim(reflect(parameter(1,0))),1) > 0)
  set t_rec->log_message = value(parameter(1,0))
endif */



set t_rec->return_value = "TRUE"

#exit_script

if (trim(cnvtupper(t_rec->return_value)) = "TRUE")
	set t_rec->retval = 100
elseif (trim(cnvtupper(t_rec->return_value)) = "FALSE")
	set t_rec->retval = 0
else
	set t_rec->retval = 0
endif

set t_rec->log_message = concat(
										trim(t_rec->log_message),";",
										trim(cnvtupper(t_rec->return_value)),":",
										trim(cnvtstring(t_rec->patient.person_id)),"|",
										trim(cnvtstring(t_rec->patient.encntr_id)),"|"
									)
;call echorecord(t_rec)

set retval									= t_rec->retval
set log_message 							= t_rec->log_message
set log_misc1 								= t_rec->log_misc1


end 
go

