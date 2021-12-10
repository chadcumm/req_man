drop program bc_print_req_manage go
create program bc_print_req_manage

prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "START_DT_TM" = "SYSDATE"
	, "END_DT_TM" = "SYSDATE"
	, "Batch Type" = ""
	, "MODIFIED_REQS" = 0
	, "Audit Mode" = 1
	, "REPORT_TYPE" = "BATCH" 

with OUTDEV, START_DT_TM, END_DT_TM, BATCH_TYPE, MODIFIED_REQS, AUDIT_MODE, 
	REPORT_TYPE


call echo(build("loading script:",curprog))
declare nologvar = i2 with noconstant(1), protect	;do not create log = 1		, create log = 0
declare debug_ind = i2 with noconstant(0), protect	;0 = no debug, 1=basic debug with echo, 2=msgview debug ;000
declare rec_to_file = i2 with noconstant(0), protect

declare notfnd = vc with constant("<not found>"), protect
declare order_string = vc with noconstant(" "), protect
declare i = i2 with noconstant(0), protect
declare k = i2 with noconstant(0), protect
declare j = i2 with noconstant(0), protect
declare pos = i2 with noconstant(0), protect
declare t = i2 with noconstant(0), protect

set reqinfo->updt_id = 1

record t_rec
(
    1 prompts
     2 outdev = vc
     2 start_dt_tm = vc
     2 end_dt_tm = vc
     2 batch_type = vc
     2 audit_mode = i2
     2 modified_reqs = i2
     2 report_type = vc
	1 cons
	 2 base_url = vc
	 2 username = vc
	 2 password = vc
	 2 directory = vc
	 2 batch_time = dq8
	 2 start_dt_tm = dq8
	 2 end_dt_tm = dq8
	 2 printer = vc
	 2 download_ind = i2
	 2 print_ind = i2
	 2 print_action_ind = i2
	 2 comment_ind = i2
	 2 req_status_ind = i2
	 2 batch_parser = vc
	 2 modified_start_dt_tm = dq8
	 2 last_name_filter = vc
	1 cnt = i4
	1 valid_cnt = i4
	1 qual[*]
	 2 clinical_event_id = f8
	 2 event_id = f8
	 2 parent_event_id = f8
	 2 encntr_id = f8
	 2 person_id = f8
	 2 patient_name = vc
	 2 patient_name_key = vc
	 2 facility = vc
	 2 unit = vc
	 2 unit_cd = f8
	 2 fin = vc
	 2 mrn = vc
	 2 title = vc
	 2 uuid = vc
	 2 event_end_dt_tm = dq8
	 2 order_list = vc
	 2 filename = vc
	 2 dclcom = vc
	 2 order_cnt = i4
	 2 requisition_format_cd = f8
	 2 requisition_format = vc
	 2 valid_req = i2
	 2 order_qual[*]
	  3 order_id = f8
	  3 order_status = vc
	  3 mnemonic = vc
	  3 unit = vc
	 2 req_status_cnt = i2
	 2 req_status_qual[*]
	  3 status_prsnl_id = f8
	  3 status_prsnl = vc
	  3 status = vc
	  3 status_dt_tm = dq8
	  3 ce_event_prsnl_id = f8
	 2 latest_status = vc
) with protect

record final_out
(
	1 batch_cnt = i2
	1 total_cnt = i4
	1 start_dt_tm = dq8
	1 end_dt_tm = dq8
	1 duration = f8
	1 batch_qual[*]
	 2 batch_id = i2
	 2 req_format = vc
	 2 req_cnt = i4
	 2 start_dt_tm = dq8
	 2 end_dt_tm = dq8
	 2 duration = f8
	 2 req_qual[*]
	  3 clinical_event_id = f8
	  3 event_id = f8
	  3 parent_event_id = f8
	  3 encntr_id = f8
	  3 person_id = f8
	  3 patient_name = vc
	  3 patient_name_key = vc
	  3 facility = vc
	  3 unit = vc
	  3 unit_cd = f8
	  3 fin = vc
	  3 mrn = vc
	  3 title = vc
	  3 event_end_dt_tm = dq8
	  3 filename = vc
	  3 uuid = vc
	  3 dclcom = vc
	  3 dclcom_stat = i2
	  3 print_com = vc
	  3 print_com_stat = i2
	  3 requisition_format = vc
	  3 latest_status = vc
) with protect

set t_rec->prompts.outdev		= $OUTDEV
set t_rec->prompts.start_dt_tm	= $START_DT_TM
set t_rec->prompts.end_dt_tm	= $END_DT_TM
set t_rec->prompts.batch_type	= $BATCH_TYPE
set t_rec->prompts.audit_mode	= $AUDIT_MODE
set t_rec->prompts.modified_reqs= $MODIFIED_REQS
set t_rec->prompts.report_type	= $REPORT_TYPE

set t_rec->cons.start_dt_tm 	= cnvtdatetime("29-MAR-2021 00:00:00")
set t_rec->cons.end_dt_tm 		= cnvtdatetime("30-MAR-2021 00:00:00")
set t_rec->cons.base_url 		= "http://phsacdea.cerncd.com/camm/p0783.phsa_cd.cerncd.com/service/mediaContent/"
set t_rec->cons.username 		= "chad.cummings@p0783"
set t_rec->cons.password 		= "QN0mHgiIjJJq57pt!"
set t_rec->cons.directory 		= "/cerner/d_p0783/cclscratch/"
set t_rec->cons.batch_time 		= cnvtdatetime(curdate,curtime3)
set t_rec->cons.modified_start_dt_tm 	= cnvtdatetime("26-MAY-2021 00:00:00")
set t_rec->cons.printer			= "590_2ndfl_bw"; "pdfprinttest" ;590_2ndfl_bw

set t_rec->cons.last_name_filter = "CSTBCCVAMOCK"

if (t_rec->prompts.audit_mode = 0)
	set t_rec->cons.print_ind			= 1
	set t_rec->cons.download_ind		= 1
	set t_rec->cons.print_action_ind	= 1
	set t_rec->cons.comment_ind			= 1
	set t_rec->cons.req_status_ind		= 1
endif

if (t_rec->prompts.batch_type not in("BONE","LAB","ECG","ALL"))
	go to exit_script
endif

if (t_rec->prompts.report_type not in("DETAIL","BATCH"))
	go to exit_script
endif

%i cust_script:bc_play_routines.inc
%i cust_script:bc_play_req.inc

if (t_rec->prompts.start_dt_tm > " ")
	set t_rec->cons.start_dt_tm = cnvtdatetime(t_rec->prompts.start_dt_tm)
endif
if (t_rec->prompts.end_dt_tm > " ")
	set t_rec->cons.end_dt_tm 	= cnvtdatetime(t_rec->prompts.end_dt_tm)
endif

call bc_custom_code_set(0)
call bc_log_level(0)
call bc_check_validation(0)
call bc_pdf_event_code(0)
call bc_pdf_content_type(0)
call bc_get_included_locations(0)

set t_rec->cons.batch_parser = concat(^t_rec->qual[d1.seq].requisition_format in(^)
if (t_rec->prompts.batch_type = "BONE")
	set t_rec->cons.batch_parser = concat(t_rec->cons.batch_parser,^"LAB_BONE_MARROW"^)
elseif (t_rec->prompts.batch_type = "LAB")
	set t_rec->cons.batch_parser = concat(t_rec->cons.batch_parser,^"GROUP_SCREEN_REQUISITION","LAB_OUTPATIENT_REQ"^)
elseif (t_rec->prompts.batch_type = "ECG")
	set t_rec->cons.batch_parser = concat(t_rec->cons.batch_parser,^"ORDRES_ECG_ORDER_REQ"^)
elseif (t_rec->prompts.batch_type = "ALL")
	set t_rec->cons.batch_parser = concat(t_rec->cons.batch_parser
		,^"GROUP_SCREEN_REQUISITION","LAB_OUTPATIENT_REQ","ORDRES_ECG_ORDER_REQ","LAB_BONE_MARROW"^)
endif
set t_rec->cons.batch_parser = concat(t_rec->cons.batch_parser,^)^)

select into "nl:"
from
	 clinical_event ce
	,encounter e
	,person p
plan ce
	where ce.event_cd = bc_common->pdf_event_cd 
	and   ce.event_end_dt_tm between cnvtdatetime(t_rec->cons.start_dt_tm) and cnvtdatetime(t_rec->cons.end_dt_tm)
	and   cnvtdatetime(curdate,curtime3) between ce.valid_from_dt_tm and ce.valid_until_dt_tm
	and	  ce.result_status_cd in(
									  value(uar_get_code_by("MEANING",8,"AUTH"))
									 ,value(uar_get_code_by("MEANING",8,"MODIFIED"))
									 ,value(uar_get_code_by("MEANING",8,"ALTERED")))
	and   ce.view_level = 1

join p
	where p.person_id = ce.person_id
	;and   p.name_last = t_rec->cons.last_name_filter
join e
	where e.encntr_id = ce.encntr_id
	and   e.encntr_id > 0.0
order by
	 p.name_full_formatted
	,ce.parent_event_id
head report
	cnt = 0
head ce.parent_event_id
	cnt = (cnt + 1)
	stat = alterlist(t_rec->qual,cnt)
	t_rec->qual[cnt].encntr_id 			= ce.encntr_id
	t_rec->qual[cnt].person_id 			= ce.person_id
	t_rec->qual[cnt].event_id 			= ce.event_id
	t_rec->qual[cnt].clinical_event_id	= ce.clinical_event_id
	t_rec->qual[cnt].parent_event_id	= ce.parent_event_id
	t_rec->qual[cnt].title 				= ce.event_title_text
	t_rec->qual[cnt].event_end_dt_tm	= ce.event_end_dt_tm
	t_rec->qual[cnt].patient_name		= p.name_full_formatted
	t_rec->qual[cnt].patient_name_key	= cnvtalphanum(p.name_full_formatted)
	t_rec->qual[cnt].facility			= uar_get_code_display(e.loc_facility_cd)
	t_rec->qual[cnt].order_list			= ce.normal_ref_range_txt
	t_rec->qual[cnt].unit				= uar_get_code_display(e.loc_nurse_unit_cd)
	t_rec->qual[cnt].unit_cd			= e.loc_nurse_unit_cd
foot ce.parent_event_id
	k = 1
	order_string = ""
	while (order_string != notfnd)
		order_string = piece(t_rec->qual[cnt].order_list,":",k,notfnd)
		pos = locateval(
								 j
								,1
								,t_rec->qual[cnt].order_cnt
								,cnvtreal(order_string)
								,t_rec->qual[cnt].order_qual[j].order_id
							)
		if ((pos = 0) and (cnvtreal(order_string) > 0))
			t_rec->qual[cnt].order_cnt = (t_rec->qual[cnt].order_cnt + 1)
			stat = alterlist(t_rec->qual[cnt].order_qual,t_rec->qual[cnt].order_cnt)
			t_rec->qual[cnt].order_qual[t_rec->qual[cnt].order_cnt].order_id = cnvtreal(order_string)
		endif
		k = (k + 1)
	endwhile
foot report
	t_rec->cnt = cnt
with nocounter

select into "nl:"
	event_id = t_rec->qual[d1.seq].event_id
from
	  (dummyt d1 with seq=t_rec->cnt)
	 ,(dummyt d2)
	 ,orders o
	 ,orders o2
	 ,order_catalog oc
plan d1
	where maxrec(d2,t_rec->qual[d1.seq].order_cnt)
join d2
join o
	where o.order_id = t_rec->qual[d1.seq].order_qual[d2.seq].order_id
join o2
	where o2.protocol_order_id = outerjoin(o.order_id)
join oc
	where oc.catalog_cd = o.catalog_cd
order by
	 event_id
	,o.order_id
	,o2.order_id
head report
	valid_ind = 0
	running_total = 0
	pos = 0
head event_id
	valid_ind = 0
head o.order_id
	t_rec->qual[d1.seq].order_qual[d2.seq].mnemonic = o.order_mnemonic
	t_rec->qual[d1.seq].order_qual[d2.seq].order_status = uar_get_code_display(o.order_status_cd)
	t_rec->qual[d1.seq].requisition_format_cd = oc.requisition_format_cd
	t_rec->qual[d1.seq].requisition_format = uar_get_code_display(oc.requisition_format_cd)
head o2.order_id
	if (o2.order_id > 0.0)
		if (t_rec->qual[d1.seq].order_qual[d2.seq].order_status != "Future")
			if (uar_get_code_display(o2.order_status_cd) = "Future")
				valid_ind = 1
			endif
		endif
	endif
foot o.order_id
	if (t_rec->qual[d1.seq].order_qual[d2.seq].order_status = "Future")
		valid_ind = 1
	endif
	t_rec->qual[d1.seq].order_qual[d2.seq].unit = uar_get_code_display(o.future_location_nurse_unit_cd)
	pos = locateval(i,1,bc_common->location_cnt,o.future_location_nurse_unit_cd,bc_common->location_qual[i].code_value)
	if (pos = 0)
	 	pos = locateval(i,1,bc_common->location_cnt,t_rec->qual[d1.seq].unit_cd,bc_common->location_qual[i].code_value)
		if (pos = 0)
			valid_ind = 0
		endif
	endif
	if ((t_rec->qual[d1.seq].unit = "SPH MSSU OPAT") or (t_rec->qual[d1.seq].order_qual[d2.seq].unit = "SPH MSSU OPAT"))
		valid_ind = 0
	endif
	
	/*if ((t_rec->qual[d1.seq].title = "ACTIONED*"))
		valid_ind = 0
	endif
	*/
foot event_id
	t_rec->qual[d1.seq].valid_req = valid_ind 
	if (t_rec->qual[d1.seq].valid_req = 1)
		running_total = (running_total + 1)
	endif
foot report
	t_rec->valid_cnt = running_total
with nocounter

select into "nl:"
from
 	 (dummyt d1 with seq=size(t_rec->qual,5))
	,ce_event_prsnl cep	
	,prsnl pr 
plan d1
	where t_rec->qual[d1.seq].valid_req = 1
join cep
	where cep.event_id =    t_rec->qual[d1.seq].event_id
	and   cep.action_type_cd in(value(uar_get_code_by("MEANING",21,"AUTHOR")))
	and   cnvtdatetime(curdate,curtime3) between cep.valid_from_dt_tm and cep.valid_until_dt_tm
join pr
	where pr.person_id = cep.action_prsnl_id
order by
	 cep.event_id
	,cep.action_dt_tm
head report
	cnt = 0
head cep.event_id
	cnt = 0
head cep.ce_event_prsnl_id
	cnt = (cnt + 1)
	stat = alterlist(t_rec->qual[d1.seq].req_status_qual, cnt)
	t_rec->qual[d1.seq].req_status_qual[cnt].status_prsnl_id 	= cep.action_prsnl_id
	t_rec->qual[d1.seq].req_status_qual[cnt].status_dt_tm		= cep.action_dt_tm
	t_rec->qual[d1.seq].req_status_qual[cnt].status_prsnl		= pr.name_full_formatted
	t_rec->qual[d1.seq].req_status_qual[cnt].status				= cep.action_comment
	t_rec->qual[d1.seq].req_status_qual[cnt].ce_event_prsnl_id	= cep.ce_event_prsnl_id
foot cep.event_id
	t_rec->qual[d1.seq].req_status_cnt = cnt
	t_rec->qual[d1.seq].latest_status = cep.action_comment
	if (t_rec->prompts.modified_reqs = 1)
		if (t_rec->qual[d1.seq].latest_status != "*Modified*")
			t_rec->qual[d1.seq].valid_req = 0
		endif
	else
		if (t_rec->qual[d1.seq].latest_status = "*Modified*")
			t_rec->qual[d1.seq].valid_req = 0
		endif
	endif
with nocounter

select into "nl:"
from
	 (dummyt d1 with seq=t_rec->cnt)
	,clinical_event ce
	,ce_blob_result ceb
plan d1
join ce
	where ce.parent_event_id = t_rec->qual[d1.seq].parent_event_id
join ceb
	where ceb.event_id = ce.event_id
	and   ceb.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3)
detail
	t_rec->qual[d1.seq].uuid = ceb.blob_handle
with nocounter

select into "nl:"
from
	 (dummyt d1 with seq=t_rec->cnt)
	,encntr_alias ea
plan d1
	where t_rec->qual[d1.seq].encntr_id > 0.0
join ea
	where ea.encntr_id = t_rec->qual[d1.seq].encntr_id
	and   ea.encntr_alias_type_cd in(	
											 value(uar_get_code_by("MEANING",319,"MRN"))
											,value(uar_get_code_by("MEANING",319,"FIN NBR"))
										)
	and   cnvtdatetime(curdate,curtime3) between ea.beg_effective_dt_tm and ea.end_effective_dt_tm
	and   ea.active_ind = 1
detail
	case (uar_get_code_meaning(ea.encntr_alias_type_cd))
		of "MRN": t_rec->qual[d1.seq].mrn = cnvtalias(ea.alias,ea.alias_pool_cd)
		of "FIN NBR": t_rec->qual[d1.seq].fin = cnvtalias(ea.alias,ea.alias_pool_cd)
	endcase
with nocounter

select into "nl:"
	 requisition_format = substring(1,30,t_rec->qual[d1.seq].requisition_format)
	,patient_name = substring(1,60,t_rec->qual[d1.seq].patient_name)
	,ordered_dt_tm = t_rec->qual[d1.seq].event_end_dt_tm
from
	(dummyt d1 with seq=t_rec->cnt)
plan d1
	where t_rec->qual[d1.seq].valid_req = 1
	and   parser(t_rec->cons.batch_parser)
order by
	 ;requisition_format
	 patient_name
	,ordered_dt_tm
head report
	cnt = 0
	req_cnt = 0
;head requisition_format
	req_cnt = 0 
	cnt = (cnt + 1)
	stat = alterlist(final_out->batch_qual,cnt)
	final_out->batch_qual[cnt].batch_id = cnt
	final_out->batch_qual[cnt].req_format = requisition_format
detail
	req_cnt = (req_cnt + 1)
	stat = alterlist(final_out->batch_qual[cnt].req_qual,req_cnt)
	final_out->batch_qual[cnt].req_qual[req_cnt].uuid = t_rec->qual[d1.seq].uuid
	final_out->batch_qual[cnt].req_qual[req_cnt].filename = concat(
															trim(t_rec->qual[d1.seq].patient_name_key),^_^,
															trim(t_rec->qual[d1.seq].mrn),^_^,
															trim(t_rec->qual[d1.seq].requisition_format),^_^,
															trim(cnvtstring(t_rec->qual[d1.seq].parent_event_id)),^_^,
															trim(format(t_rec->qual[d1.seq].event_end_dt_tm,"yyyymmdd_hhmmss;;d")),
															^.pdf^)
	final_out->batch_qual[cnt].req_qual[req_cnt].dclcom = build2(
		^wget --user=^,trim(t_rec->cons.username),
		^ --password=^,trim(t_rec->cons.password),
		^ ^,trim(t_rec->cons.base_url),trim(t_rec->qual[d1.seq].uuid),
		^ -O ^,trim(t_rec->cons.directory),
		final_out->batch_qual[cnt].req_qual[req_cnt].filename
		)
	
	final_out->batch_qual[cnt].req_qual[req_cnt].print_com = build2(
			^lp -d ^,trim(t_rec->cons.printer),
			^ ^,trim(t_rec->cons.directory),
			final_out->batch_qual[cnt].req_qual[req_cnt].filename
		)
	final_out->batch_qual[cnt].req_qual[req_cnt].encntr_id = t_rec->qual[d1.seq].encntr_id
	final_out->batch_qual[cnt].req_qual[req_cnt].event_end_dt_tm = t_rec->qual[d1.seq].event_end_dt_tm
	final_out->batch_qual[cnt].req_qual[req_cnt].event_id = t_rec->qual[d1.seq].event_id
	final_out->batch_qual[cnt].req_qual[req_cnt].facility  = t_rec->qual[d1.seq].facility
	final_out->batch_qual[cnt].req_qual[req_cnt].fin = t_rec->qual[d1.seq].fin
	final_out->batch_qual[cnt].req_qual[req_cnt].mrn = t_rec->qual[d1.seq].mrn
	final_out->batch_qual[cnt].req_qual[req_cnt].parent_event_id = t_rec->qual[d1.seq].parent_event_id
	final_out->batch_qual[cnt].req_qual[req_cnt].patient_name = t_rec->qual[d1.seq].patient_name
	final_out->batch_qual[cnt].req_qual[req_cnt].patient_name_key = t_rec->qual[d1.seq].patient_name_key
	final_out->batch_qual[cnt].req_qual[req_cnt].person_id = t_rec->qual[d1.seq].person_id
	final_out->batch_qual[cnt].req_qual[req_cnt].title = t_rec->qual[d1.seq].title
	final_out->batch_qual[cnt].req_qual[req_cnt].unit = t_rec->qual[d1.seq].unit
	final_out->batch_qual[cnt].req_qual[req_cnt].unit_cd = t_rec->qual[d1.seq].unit_cd
	final_out->batch_qual[cnt].req_qual[req_cnt].clinical_event_id = t_rec->qual[d1.seq].clinical_event_id
	final_out->batch_qual[cnt].req_qual[req_cnt].requisition_format = t_rec->qual[d1.seq].requisition_format
	final_out->batch_qual[cnt].req_qual[req_cnt].latest_status = t_rec->qual[d1.seq].latest_status
foot requisition_format
	final_out->batch_qual[cnt].req_cnt = req_cnt
foot report
	final_out->batch_cnt = cnt
with nocounter

set final_out->start_dt_tm = cnvtdatetime(curdate,curtime3)
for (t=1 to final_out->batch_cnt)
	call echo(build("t=",t))
	call echo(build("req_format=",final_out->batch_qual[t].req_format))
	set final_out->batch_qual[t].start_dt_tm = cnvtdatetime(curdate,curtime3)
	for (j=1 to final_out->batch_qual[t].req_cnt)
		call echo(build("j=",j," of t=",t))
		call echo(build("patient=",final_out->batch_qual[t].req_qual[j].patient_name))
		set dclstat = 0					
		if (t_rec->cons.download_ind = 1)
			call echo(build("downloading ",j))
			call dcl(	 final_out->batch_qual[t].req_qual[j].dclcom
						,size(trim(final_out->batch_qual[t].req_qual[j].dclcom))
						,dclstat)
			set final_out->batch_qual[t].req_qual[j].dclcom_stat = dclstat
		endif
		if (t_rec->cons.print_ind = 1)
			if (final_out->batch_qual[t].req_qual[j].dclcom_stat = 1)
				call echo(build("printing ",j))
				set dclstat = 0					
				call dcl(	 final_out->batch_qual[t].req_qual[j].print_com
							,size(trim(final_out->batch_qual[t].req_qual[j].print_com))
							,dclstat)
				set final_out->batch_qual[t].req_qual[j].print_com_stat = dclstat
				set final_out->total_cnt = (final_out->total_cnt + 1)
				if (final_out->batch_qual[t].req_qual[j].print_com_stat = 1)
					if (t_rec->cons.print_action_ind = 1)
						call echo(build("bc_all_mp_add_print_status ",j))
						execute bc_all_mp_add_print_status 
											^NOFORMS^
											,value(final_out->batch_qual[t].req_qual[j].clinical_event_id)
											,^ADD^
						if (t_rec->cons.comment_ind = 1)
							call echo(build("bc_all_mp_add_req_comment ",j))
							execute bc_all_mp_add_req_comment
											^NOFORMS^
											,value(final_out->batch_qual[t].req_qual[j].parent_event_id)
											,^Printed for BCC VA Cutover^
						endif
						if (t_rec->cons.req_status_ind = 1)
							call echo(build("bc_all_mp_add_req_status ",j))
							execute bc_all_mp_add_req_status
											^NOFORMS^
											,value(final_out->batch_qual[t].req_qual[j].parent_event_id)
											,^Complete^
						endif
					endif
				endif
			endif
		endif
	endfor
	set final_out->batch_qual[t].end_dt_tm = cnvtdatetime(curdate,curtime3)
	set final_out->batch_qual[t].duration = datetimediff(	final_out->batch_qual[t].end_dt_tm,
															final_out->batch_qual[t].start_dt_tm,
															5)
endfor
set final_out->end_dt_tm = cnvtdatetime(curdate,curtime3)
set final_out->duration = datetimediff(	final_out->end_dt_tm
										,final_out->start_dt_tm
										,5)
free set _memory_reply_string
declare _memory_reply_string = vc

if (t_rec->prompts.report_type = "DETAIL")
select into t_rec->prompts.outdev
	 event_id = 				t_rec->qual[d1.seq].event_id 			
	,parent_event_id =       t_rec->qual[d1.seq].parent_event_id       
	,encntr_id =             t_rec->qual[d1.seq].encntr_id           
	,person_id =             t_rec->qual[d1.seq].person_id            
	,patient_name =          substring(1,50,t_rec->qual[d1.seq].patient_name)
	,patient_name_key =      t_rec->qual[d1.seq].patient_name_key     
	,facility =              substring(1,20,t_rec->qual[d1.seq].facility )            
	,unit = 				 substring(1,20,t_rec->qual[d1.seq].unit)
	,fin =                   t_rec->qual[d1.seq].fin                 
	,mrn =                   t_rec->qual[d1.seq].mrn                  
	,title =                 substring(1,255,t_rec->qual[d1.seq].title               )
	,uuid =                  t_rec->qual[d1.seq].uuid                 
	,event_end_dt_tm =       format(t_rec->qual[d1.seq].event_end_dt_tm,";;q")       
	,filename =              t_rec->qual[d1.seq].filename             
	,dclcom =                t_rec->qual[d1.seq].dclcom               
	,order_cnt =             t_rec->qual[d1.seq].order_cnt            
	,requisition_format_cd = t_rec->qual[d1.seq].requisition_format_cd
	,requisition_format =    t_rec->qual[d1.seq].requisition_format 
	,valid_req =             t_rec->qual[d1.seq].valid_req 
	,order_id =				 t_rec->qual[d1.seq].order_qual[d2.seq].order_id            
	,mnemonic =				 substring(1,50,t_rec->qual[d1.seq].order_qual[d2.seq].mnemonic)
	,order_status =			 substring(1,20,t_rec->qual[d1.seq].order_qual[d2.seq].order_status)
	,o_unit =				 substring(1,20,t_rec->qual[d1.seq].order_qual[d2.seq].unit)
from
	(dummyt d1 with seq=t_rec->cnt)
	,(dummyt d2)
plan d1
	where maxrec(d2,t_rec->qual[d1.seq].order_cnt)
join d2
order by
	 t_rec->qual[d1.seq].patient_name
	,t_rec->qual[d1.seq].title
with format,separator=" "

elseif (t_rec->prompts.report_type = "BATCH")

select into t_rec->prompts.outdev
	 total_duration=final_out->duration
	,batch = substring(1,30,final_out->batch_qual[d1.seq].req_format)
	,batch_duration = final_out->batch_qual[d1.seq].duration
	,format = substring(1,60,final_out->batch_qual[d1.seq].req_qual[d2.seq].requisition_format)
	,patient_name = substring(1,60,final_out->batch_qual[d1.seq].req_qual[d2.seq].patient_name)
	,mrn = substring(1,60,final_out->batch_qual[d1.seq].req_qual[d2.seq].mrn)
	,fin = substring(1,60,final_out->batch_qual[d1.seq].req_qual[d2.seq].fin)
	,title = substring(1,120,final_out->batch_qual[d1.seq].req_qual[d2.seq].title)
	,unit = substring(1,60,final_out->batch_qual[d1.seq].req_qual[d2.seq].unit)
	,ordered_dt_tm = final_out->batch_qual[d1.seq].req_qual[d2.seq].event_end_dt_tm
	,filename = substring(1,200,final_out->batch_qual[d1.seq].req_qual[d2.seq].filename)
	,download_ind = final_out->batch_qual[d1.seq].req_qual[d2.seq].dclcom_stat
	,print_ind = final_out->batch_qual[d1.seq].req_qual[d2.seq].print_com_stat
from
	 (dummyt d1 with seq=final_out->batch_cnt)
	,(dummyt d2)
plan d1
	where maxrec(d2,final_out->batch_qual[d1.seq].req_cnt)
join d2
order by
	 batch
	,patient_name
	,ordered_dt_tm
with format,separator=" "
endif

#exit_script
call echorecord(t_rec)
call echorecord(bc_common)
call echorecord(final_out)
call echo(build("t_rec->valid_cnt=",t_rec->valid_cnt))
call echo(build("final_out->total_cnt=",final_out->total_cnt))
end
go
