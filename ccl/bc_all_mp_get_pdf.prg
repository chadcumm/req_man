/*****************************************************************************
******************************************************************************

  Author:             Chad Cummings
  Date Written:       03/01/2019
  Solution:           
  Source file name:   bc_all_mp_get_pdf.prg
  Object name:        bc_all_mp_get_pdf
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
002   10/14/2020  Chad Cummings			Removed ORDERED as a valid status
003   10/15/2020  Chad Cummings			changed sorting to correct document date
004   10/20/2020  Chad Cummings			changed sorting to include requested date
005   10/27/2020  Chad Cummings			changed to new reference_nbr
006   11/17/2020  Chad Cummings			updating to ordering provider on order and added document prsnl
007   11/25/2020  Chad Cummings			added unspecified label to ordering provider when missing
******************************************************************************/
 
drop program bc_all_mp_get_pdf:dba go
create program bc_all_mp_get_pdf:dba
prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "personId" = ""
	, "encntrId" = ""
 
with OUTDEV, personId, encntrId
 
 
record outrec (
	1 error_ind						= I2
	1 error_msg						= VC
	1 data[*]
		2 event_id					= f8
		2 clinical_event_id			= f8
		2 parent_event_id			= f8
		2 event_title_txt			= vc
		2 comment_txt				= vc
		2 ordering_provider			= vc
		2 document_prsnl			= vc	;006
		2 service_dt_tm_txt			= vc
		2 requested_start_dt_tm_txt = vc
		2 reference_nbr				= vc
		2 normal_ref_range_txt		= vc	;005
		2 status					= vc
		2 url						= vc	
		
)

free record t_rec
record t_rec
(
	1 cnt							= i2
	1 data[*]
		2 event_id					= f8
		2 clinical_event_id			= f8
		2 parent_event_id			= f8
		2 event_title_txt			= vc
		2 comment_txt				= vc
		2 ordering_provider			= vc
		2 document_prsnl			= vc	;006
		2 service_dt_tm_txt			= vc
		2 service_dt_tm				= dq8
		2 requested_start_dt_tm_txt = vc
		2 requested_start_dt_tm		= dq8
		2 reference_nbr				= vc
		2 normal_ref_range_txt		= vc	;005
		2 status					= vc
		2 url						= vc	
		2 valid_doc_ind				= i2
		2 multiple_order_dates_ind	= i2
		2 order_cnt					= i2
		2 order_qual[*]
		 3 order_id					= f8
		 3 order_status_cd			= f8
		 3 requisition_format_cd	= f8
		 3 requested_start_dt_tm	= dq8
		 3 order_mnemonic			= vc
		 3 template_order_id		= f8
		 3 protocol_order_id		= f8
)
select into "nl:"
from
	 clinical_event ce
	,clinical_event pe
	,encounter e
	,ce_blob_result ceb
	,prsnl p
plan e
	where e.encntr_id = $encntrId
join ce
	where ce.person_id = e.person_id
	and   ce.encntr_id = e.encntr_id
;	and   ce.event_cd = value(uar_get_code_by("DISPLAY",72,"Print to PDF Requisition"))
	and   ce.event_cd = value(uar_get_code_by("DISPLAY",72,"Print to PDF Req"))
	and	  ce.result_status_cd in(
									  value(uar_get_code_by("MEANING",8,"AUTH"))
									 ,value(uar_get_code_by("MEANING",8,"MODIFIED"))
									 ;003 ,value(uar_get_code_by("MEANING",8,"ALTERED"))
									 ;003 ,value(uar_get_code_by("MEANING",8,"INERROR"))
								)
	
	and   ce.valid_until_dt_tm >= cnvtdatetime(curdate, curtime3)
	and   ce.event_tag        != "Date\Time Correction"
join pe
	where pe.event_id = ce.parent_event_id
	and	  pe.result_status_cd in(
									  value(uar_get_code_by("MEANING",8,"AUTH"))
									 ,value(uar_get_code_by("MEANING",8,"MODIFIED"))
									 ;003 ,value(uar_get_code_by("MEANING",8,"ALTERED"))
									 ;003 ,value(uar_get_code_by("MEANING",8,"INERROR"))
								)
	
	and   pe.valid_until_dt_tm >= cnvtdatetime(curdate, curtime3)
	and   pe.event_tag        != "Date\Time Correction"
join ceb
	where ceb.event_id = ce.event_id
    and   ceb.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3)
join p
	where p.person_id = ce.verified_prsnl_id
order by
	;003 ce.event_end_dt_tm desc
	 pe.event_end_dt_tm desc ;003
	,ce.event_end_dt_tm ;003
	,ce.clinical_event_id
	
head report
	i =0
detail
	i = (i+1)
	t_rec->cnt = i
	stat = alterlist(t_rec->data,i)
	t_rec->data[i].event_id =   ce.event_id
	t_rec->data[i].clinical_event_id =   ce.clinical_event_id
	t_rec->data[i].parent_event_id =   ce.parent_event_id
	t_rec->data[i].event_title_txt = pe.event_title_text
	t_rec->data[i].comment_txt = ""
	t_rec->data[i].reference_nbr = pe.reference_nbr
	t_rec->data[i].normal_ref_range_txt = pe.normal_ref_range_txt	;005
	;006 t_rec->data[i].ordering_provider = p.name_full_formatted
	t_rec->data[i].document_prsnl = p.name_full_formatted	;006
	t_rec->data[i].service_dt_tm_txt = format(pe.event_end_dt_tm,"dd-mmm-yyyy hh:mm;;q")
	t_rec->data[i].service_dt_tm = pe.event_end_dt_tm
	t_rec->data[i].status = piece(t_rec->data[i].event_title_txt,":",1,"")
	if (t_rec->data[i].status = t_rec->data[i].event_title_txt)
		t_rec->data[i].status = "Pending"
	else
		t_rec->data[i].event_title_txt = replace(t_rec->data[i].event_title_txt,concat(t_rec->data[i].status,":"),"")
	endif
	t_rec->data[i].status = cnvtcap(t_rec->data[i].status)
with format(date,";;q"),uar_code(d)

;call showError(url_test)

declare notfnd = vc with constant("<not found>")
declare order_string = vc with noconstant(" ")
declare i = i2 with noconstant(0)
declare k = i2 with noconstant(0)
declare j = i2 with noconstant(0)
declare pos = i2 with noconstant(0)
declare prev_req_dt_tm = dq8 

for (i = 1 to size(t_rec->data,5))
	set k = 1
	;005 set order_string = piece(t_rec->data[i].reference_nbr,":",k,notfnd)
	set order_string = piece(t_rec->data[i].normal_ref_range_txt,":",k,notfnd)	;005
	call echo(build("order_string=",order_string))
	while (order_string != notfnd)
		;005 set order_string = piece(t_rec->data[i].reference_nbr,":",k,notfnd)
		set order_string = piece(t_rec->data[i].normal_ref_range_txt,":",k,notfnd)	;005
		call echo(build2("-->inside while order_string=",order_string))
		
		set pos = locateval(j,1,t_rec->data[i].order_cnt,cnvtreal(order_string),t_rec->data[i].order_qual[j].order_id)
		call echo(build2("-->inside while pos=",pos))
		if ((pos = 0) and (cnvtreal(order_string) > 0))
			set t_rec->data[i].order_cnt = (t_rec->data[i].order_cnt + 1)
			set stat = alterlist(t_rec->data[i].order_qual,t_rec->data[i].order_cnt)
			set t_rec->data[i].order_qual[t_rec->data[i].order_cnt].order_id = cnvtreal(order_string)
		endif
		set k = (k + 1)
	endwhile
endfor

select into "nl:"
	 event_id = t_rec->data[d1.seq].event_id
	,sel_order_id = t_rec->data[d1.seq].order_qual[d2.seq].order_id
from
	 (dummyt d1 with seq=t_rec->cnt)
	,(dummyt d2)
	,(dummyt d3)
	,orders o
	,order_catalog oc
	,order_detail od
plan d1
	where maxrec(d2,t_rec->data[d1.seq].order_cnt)
join d2
join o
	where (		(o.order_id = t_rec->data[d1.seq].order_qual[d2.seq].order_id)
			or 	(o.template_order_id = t_rec->data[d1.seq].order_qual[d2.seq].order_id)
			or 	(o.protocol_order_id = t_rec->data[d1.seq].order_qual[d2.seq].order_id)
		  )
			
	and   o.order_status_cd in(
									 value(uar_get_code_by("MEANING",6004,"FUTURE"))
									;002 ,value(uar_get_code_by("MEANING",6004,"ORDERED"))
								)
join oc
	where oc.catalog_cd = o.catalog_cd
join d3
join od
	where od.order_id = o.order_id
	and   od.oe_field_meaning = "REQSTARTDTTM"
order by
	 event_id
	,sel_order_id
	,o.order_id
	,o.protocol_order_id
	,o.template_order_id
	,od.action_sequence
head report
	stat = 0
	order_id = 0.0
	call echo("inside orders query")
;head event_id
head sel_order_id
	order_id = o.order_id
head o.order_id
	;if ((o.protocol_order_id = 0.0) and (o.template_order_id = 0.0))
	;		order_id = o.order_id
	;endif
	call echo("new order")
	call echo(build("parent order_id=",order_id))
	call echo(build("current order_id=",o.order_id))

	t_rec->data[d1.seq].order_qual[d2.seq].order_status_cd = o.order_status_cd
	t_rec->data[d1.seq].order_qual[d2.seq].requisition_format_cd = oc.requisition_format_cd
	t_rec->data[d1.seq].order_qual[d2.seq].order_mnemonic = o.order_mnemonic
	t_rec->data[d1.seq].order_qual[d2.seq].protocol_order_id = o.protocol_order_id
	t_rec->data[d1.seq].order_qual[d2.seq].template_order_id = o.template_order_id
head od.action_sequence
	if (od.order_id = order_id)
		call echo(build("-->setting requested date and time=",format(od.oe_field_dt_tm_value,";;q")))
		;t_rec->data[d1.seq].order_qual[d2.seq].requested_start_dt_tm = o.current_start_dt_tm
		t_rec->data[d1.seq].order_qual[d2.seq].requested_start_dt_tm = od.oe_field_dt_tm_value
	endif
foot o.order_id
	call echo(build("->final requested date and time=",format(t_rec->data[d1.seq].order_qual[d2.seq].requested_start_dt_tm,";;q")))
;foot event_id
foot sel_order_id
	order_id = 0.0
foot report
	stat = 0
with nocounter,outerjoin=d3,nullreport

;start 006
select into "nl:"
	 event_id = t_rec->data[d1.seq].event_id
	,sel_order_id = t_rec->data[d1.seq].order_qual[d2.seq].order_id
from
	 (dummyt d1 with seq=t_rec->cnt)
	,(dummyt d2)
	,orders o
	,order_action oa
	,prsnl p
plan d1
	where maxrec(d2,t_rec->data[d1.seq].order_cnt)
join d2
join o
	where o.order_id = t_rec->data[d1.seq].order_qual[d2.seq].order_id
join oa
	where oa.order_id = o.order_id
join p
	where p.person_id = oa.order_provider_id
order by
	 event_id
	,sel_order_id
	,o.order_id
	,oa.action_sequence desc
head report
	stat = 0
	order_id = 0.0
	call echo("inside orders query")
head o.order_id
	t_rec->data[d1.seq].ordering_provider = p.name_full_formatted
foot report
	stat = 0
with nocounter,nullreport
;end 006
select into "nl:"
	 event_id=t_rec->data[d1.seq].event_id
	,order_id=t_rec->data[d1.seq].order_qual[d2.seq].order_id
	,requested_start_dt_tm =t_rec->data[d1.seq].order_qual[d2.seq].requested_start_dt_tm
from
	 (dummyt d1 with seq=t_rec->cnt)
	,(dummyt d2)
plan d1
	where maxrec(d2,t_rec->data[d1.seq].order_cnt)
join d2
	;where t_rec->data[d1.seq].order_qual[d2.seq].order_status_cd = value(uar_get_code_by("MEANING",6004,"FUTURE"))
	where t_rec->data[d1.seq].order_qual[d2.seq].order_status_cd > 0.0
order by
	 event_id
	,requested_start_dt_tm
	,order_id
head report
	call echo("determining earliest requested start date and time")
	multiple_order_dates_ind = 0
head event_id
	multiple_order_dates_ind = 0
	call echo(build("event=",t_rec->data[d1.seq].event_id))
	prev_req_dt_tm = t_rec->data[d1.seq].order_qual[d2.seq].requested_start_dt_tm
	call echo(build("->first=",format(t_rec->data[d1.seq].order_qual[d2.seq].requested_start_dt_tm,";;q")))
	t_rec->data[d1.seq].requested_start_dt_tm = t_rec->data[d1.seq].order_qual[d2.seq].requested_start_dt_tm
head order_id
	call echo(build("->order_id=",order_id))
detail
	call echo(build("-->this=",format(t_rec->data[d1.seq].order_qual[d2.seq].requested_start_dt_tm,";;q")))
	call echo(build("-->prev_req_dt_tm=",format(t_rec->data[d1.seq].order_qual[d2.seq].requested_start_dt_tm,";;q")))
foot order_id
	if (t_rec->data[d1.seq].order_qual[d2.seq].order_status_cd = uar_get_code_by("MEANING",6004,"FUTURE"))
		if (prev_req_dt_tm != t_rec->data[d1.seq].order_qual[d2.seq].requested_start_dt_tm)
			multiple_order_dates_ind = 1
			call echo(build("--->multiple_order_dates_ind=",multiple_order_dates_ind))
		endif
		prev_req_dt_tm = t_rec->data[d1.seq].order_qual[d2.seq].requested_start_dt_tm
	endif
foot event_id
	t_rec->data[d1.seq].multiple_order_dates_ind = multiple_order_dates_ind
with nocounter

for (i=1 to t_rec->cnt)
	for (j=1 to t_rec->data[i].order_cnt)
		if (t_rec->data[i].order_qual[j].order_status_cd = uar_get_code_by("MEANING",6004,"FUTURE"))
			set t_rec->data[i].valid_doc_ind = 1
		endif
		if (t_rec->data[i].order_qual[j].order_status_cd = uar_get_code_by("MEANING",6004,"ORDERED"))
			if (t_rec->data[i].order_qual[j].requisition_format_cd = uar_get_code_by("MEANING",6002,"AMBREFERREQ"))
				set t_rec->data[i].valid_doc_ind = 1
			endif
		endif
	endfor
endfor

set i = 0
/*
004
for (j=1 to t_rec->cnt)
 if (t_rec->data[j].valid_doc_ind = 1)
	set i = (i + 1)
	set stat = alterlist(outrec->data,i)
	set outrec->data[i].event_id 			=   t_rec->data[j].event_id
	set outrec->data[i].clinical_event_id 	=	t_rec->data[j].clinical_event_id
	set outrec->data[i].parent_event_id 		=	t_rec->data[j].parent_event_id
	set outrec->data[i].event_title_txt 		=	t_rec->data[j].event_title_txt
	set outrec->data[i].comment_txt 			= 	t_rec->data[j].comment_txt
	set outrec->data[i].reference_nbr 		= 	t_rec->data[j].reference_nbr
	set outrec->data[i].ordering_provider 	= 	t_rec->data[j].ordering_provider
	set outrec->data[i].service_dt_tm_txt 	= 	t_rec->data[j].service_dt_tm_txt
	set outrec->data[i].requested_start_dt_tm_txt = 	format(t_rec->data[j].requested_start_dt_tm,"dd-mmm-yyyy hh:mm;;q")
	if (t_rec->data[j].multiple_order_dates_ind = 1)
		set outrec->data[i].requested_start_dt_tm_txt = CONCAT(outrec->data[i].requested_start_dt_tm_txt,"*")
	endif
	set outrec->data[i].status 				= 	t_rec->data[j].status
 endif
endfor
*/
;start 004
select into "nl:"
	 service_dt_tm=t_rec->data[d1.seq].service_dt_tm
	,requested_start_dt_tm=t_rec->data[d1.seq].requested_start_dt_tm
from
	(dummyt d1 with seq=t_rec->cnt)
plan d1
	where t_rec->data[d1.seq].valid_doc_ind = 1
order by
	service_dt_tm desc
	,requested_start_dt_tm
detail
	i = (i + 1)
	stat = alterlist(outrec->data,i)
	outrec->data[i].event_id 				=   t_rec->data[d1.seq].event_id
	outrec->data[i].clinical_event_id 		=	t_rec->data[d1.seq].clinical_event_id
	outrec->data[i].parent_event_id 		=	t_rec->data[d1.seq].parent_event_id
	outrec->data[i].event_title_txt 		=	t_rec->data[d1.seq].event_title_txt
	outrec->data[i].comment_txt 			= 	t_rec->data[d1.seq].comment_txt
	outrec->data[i].reference_nbr 			= 	t_rec->data[d1.seq].reference_nbr
	outrec->data[i].normal_ref_range_txt 	= 	t_rec->data[d1.seq].normal_ref_range_txt	;005
	outrec->data[i].ordering_provider 		= 	t_rec->data[d1.seq].ordering_provider
	;start 007
	if (outrec->data[i].ordering_provider = "")
		outrec->data[i].ordering_provider = "Unspecified"
	endif
	;end 007
	outrec->data[i].service_dt_tm_txt 		= 	t_rec->data[d1.seq].service_dt_tm_txt
	outrec->data[i].requested_start_dt_tm_txt = 	format(t_rec->data[d1.seq].requested_start_dt_tm,"dd-mmm-yyyy hh:mm;;q")
	if (t_rec->data[d1.seq].multiple_order_dates_ind = 1)
		outrec->data[i].requested_start_dt_tm_txt = CONCAT(outrec->data[i].requested_start_dt_tm_txt,"*")
	endif
	outrec->data[i].status 				= 	t_rec->data[d1.seq].status
with nocounter
;end 004

SET _Memory_Reply_String = cnvtrectojson(outrec) ;send outrec to mpage

call echo(_Memory_Reply_String)
call echorecord(outrec)
call echorecord(t_Rec)

 
SUBROUTINE showError(sMsg)	;used to show errors to the end user
 
 	set t_rec->error_ind = 1
 	set t_rec->error_msg = sMsg
 
	SELECT INTO $OUTDEV
		MSG = sMsg
	FROM DUMMYT
	WITH NOCOUNTER, SEPARATOR=" ", FORMAT
 
END ;showError
 
#END_REPORT
 
end go
