drop program rm_full_order_req_audit go
create program rm_full_order_req_audit

prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Report Type" = 0
	, "START_DT_TM" = "SYSDATE"
	, "END_DT_TM" = "SYSDATE"
	, "MRN" = "110872642" 

with OUTDEV, REPORT_TYPE, START_DT_TM, END_DT_TM, MRN


call echo(build("loading script:",curprog))
declare nologvar = i2 with noconstant(1), protect	;do not create log = 1		, create log = 0
declare debug_ind = i2 with noconstant(0), protect	;0 = no debug, 1=basic debug with echo, 2=msgview debug ;000
declare rec_to_file = i2 with noconstant(0), protect


record t_rec	
(
	1 prompts
     2 outdev = vc
     2 start_dt_tm = vc
     2 end_dt_tm = vc
     2 report_type = i4
     2 mrn = vc
	1 cons
	 2 start_dt_tm = dq8
	 2 end_dt_tm = dq8
	 2 mrn = vc
	 2 person_id = f8
	1 cnt =i4
	1 qual[*]
	 2 person_id = f8
	 2 encntr_id = f8
	 2 name = vc
	 2 mrn = vc
	 2 order_cnt = i2
	 2 order_qual[*]
	  3 order_id = f8
	  3 template_order_flag = i2
	  3 protocol_order_id = f8
	  3 order_mnemonic = vc
	  3 req_type = vc
	  3 event_id = f8
	  3 parent_event_id = f8
	  3 event_title_text = vc
	  3 pathway_id = f8
	  3 pathway_desc = vc
	  3 pw_group_desc = vc
	  3 order_dt_tm = dq8
	  3 order_dt_tm_vc = vc
	  3 requested_start_dt_tm = dq8
	  3 requested_start_dt_tm_vc = vc
	  3 scheduling = vc
	  3 child_order_on_req_ind = i2
	  3 parent_order_on_req_ind = i2
	  3 neither_order_on_req_ind = i2
	  3 present_in_rm_ind = i2
	  3 present_in_ippdf_ind = i2
	 2 req_cnt = i2
	 2 req_qual[*]
	  3 parent_event_id = f8
	  3 event_id = f8
	  3 event_title_text = vc
	  3 event_end_dt_tm = vc
	  3 reference_range = vc
	  3 valid_order_remain_ind = i2
	  3 order_cnt = i2
	  3 present_in_rm_ind = i2
	  3 present_in_ippdf_ind = i2
	  3 order_qual[*]
	   4 order_id = f8
	   4 template_order_flag = i2
	   4 protocol_order_id = f8
	   4 order_mnemonic = vc
	   4 order_status = vc
	   4 child_order_remain_ind = i2
	   
) with protect

declare notfnd = vc with constant("<not found>"), protect
declare order_string = vc with noconstant(" "), protect
declare i = i4 with noconstant(0), protect
declare ii = i4 with noconstant(0), protect
declare k = i4 with noconstant(0), protect
declare kk = i4 with noconstant(0), protect
declare j = i4 with noconstant(0), protect
declare jj = i4 with noconstant(0), protect
declare pos = i2 with noconstant(0), protect
declare t = i4 with noconstant(0), protect

set t_rec->prompts.outdev		= $OUTDEV
set t_rec->prompts.start_dt_tm	= $START_DT_TM
set t_rec->prompts.end_dt_tm	= $END_DT_TM
set t_rec->prompts.report_type	= $REPORT_TYPE
set t_rec->prompts.mrn			= $MRN


set t_rec->cons.start_dt_tm 	= cnvtdatetime(curdate,0)
set t_rec->cons.end_dt_tm 		= cnvtdatetime(curdate, 235959)
if (t_rec->prompts.start_dt_tm > " ")
	set t_rec->cons.start_dt_tm = cnvtdatetime(t_rec->prompts.start_dt_tm)
endif
if (t_rec->prompts.end_dt_tm > " ")
	set t_rec->cons.end_dt_tm 	= cnvtdatetime(t_rec->prompts.end_dt_tm)
endif
set t_rec->cons.mrn = t_rec->prompts.mrn

%i cust_script:bc_play_routines.inc
%i cust_script:bc_play_req.inc

call bc_custom_code_set(0)
call bc_log_level(0)
call bc_check_validation(0)
call bc_pdf_event_code(0)
call bc_pdf_content_type(0)
call bc_get_included_locations(0)
call bc_get_multiple_ord_requisitions(0)
call bc_get_single_ord_requisitions(0)
call bc_get_scheduling_fields(0)

if (t_rec->cons.mrn > " ")
	select into "nl:"
	from person_alias pa
	plan pa
		where pa.alias = t_rec->cons.mrn
		and   pa.person_alias_type_cd = 10
		and   pa.active_ind = 1
		and   cnvtdatetime(curdate,curtime3) between pa.beg_effective_dt_tm and pa.end_effective_dt_tm
	order by
		 pa.person_id
		,pa.beg_effective_dt_tm desc
	head pa.person_id
		t_rec->cons.person_id = pa.person_id
	with nocounter
endif

select
	if (t_rec->cons.person_id > 0.0)
		plan o
			where o.order_status_cd in(value(uar_get_code_by("MEANING",6004,"FUTURE")))
			and   o.person_id = t_rec->cons.person_id
			and   o.orig_order_dt_tm >= cnvtdatetime("02-DEC-2020 00:00:00")
		join oc
			where oc.catalog_cd = o.catalog_cd
		join cv1
			where cv1.code_value = oc.requisition_format_cd
		join e
			where e.encntr_id = o.originating_encntr_id
			and   expand(k,1,bc_common->location_cnt,e.loc_nurse_unit_cd,bc_common->location_qual[k].code_value)
		join p
			where p.person_id = o.person_id
	else
		plan o
			where o.order_status_cd in(value(uar_get_code_by("MEANING",6004,"FUTURE")))
			and   o.orig_order_dt_tm between cnvtdatetime(t_rec->cons.start_dt_tm) and cnvtdatetime(t_rec->cons.end_dt_tm)
		join oc
			where oc.catalog_cd = o.catalog_cd
		join cv1
			where cv1.code_value = oc.requisition_format_cd
		join e
			where e.encntr_id = o.originating_encntr_id
			and   expand(k,1,bc_common->location_cnt,e.loc_nurse_unit_cd,bc_common->location_qual[k].code_value)
		join p
			where p.person_id = o.person_id
	endif
into "nl:"
from
	 orders o
	,encounter e
	,person p
	,order_catalog oc
	,code_value cv1
plan o
	where o.order_status_cd in(value(uar_get_code_by("MEANING",6004,"FUTURE")))
	and   o.orig_order_dt_tm between cnvtdatetime(t_rec->cons.start_dt_tm) and cnvtdatetime(t_rec->cons.end_dt_tm)
join oc
	where oc.catalog_cd = o.catalog_cd
join cv1
	where cv1.code_value = oc.requisition_format_cd
join e
	where e.encntr_id = o.originating_encntr_id
	and   expand(k,1,bc_common->location_cnt,e.loc_nurse_unit_cd,bc_common->location_qual[k].code_value)
join p
	where p.person_id = o.person_id
order by
	 o.person_id
	,o.order_id
head report
	i = 0
	j = 0
	o_pass = 0
head o.person_id
	i = (i + 1)
	;call echo(build2("i=",i))
	stat = alterlist(t_rec->qual,i)
	t_rec->qual[i].encntr_id = e.encntr_id
	t_rec->qual[i].name = p.name_full_formatted
	t_rec->qual[i].person_id = p.person_id
	j = 0
head o.order_id
	o_pass = 0
	o_pass = locateval(k,1,bc_common->requisition_cnt,oc.requisition_format_cd,bc_common->requisition_qual[k].requisition_format_cd)
	if (o_pass = 0)
		o_pass = locateval(k,1,bc_common->req_multiple_cnt,oc.requisition_format_cd,bc_common->req_multiple_qual[k].requisition_format_cd)
	endif
foot o.order_id
	if (o_pass > 0)
		j = (j + 1)
		;call echo(build2("->j=",j))
		stat = alterlist(t_rec->qual[i].order_qual,j)
		t_rec->qual[i].order_qual[j].order_id = o.order_id
		t_rec->qual[i].order_qual[j].template_order_flag = o.template_order_flag
		t_rec->qual[i].order_qual[j].protocol_order_id = o.protocol_order_id
		t_rec->qual[i].order_qual[j].req_type = uar_get_code_meaning(oc.requisition_format_cd)
		t_rec->qual[i].order_qual[j].order_mnemonic = o.order_mnemonic	
		t_rec->qual[i].order_qual[j].order_dt_tm = o.orig_order_dt_tm
		t_rec->qual[i].order_qual[j].order_dt_tm_vc = format(o.orig_order_dt_tm,"dd-mmm-yyyy hh:mm:ss;;d")
		t_rec->qual[i].order_qual[j].requested_start_dt_tm = o.current_start_dt_tm
		t_rec->qual[i].order_qual[j].requested_start_dt_tm_vc = format(o.current_start_dt_tm,"dd-mmm-yyyy;;d")
	endif
foot o.person_id
	t_rec->qual[i].order_cnt = j
	;call echo(build2("t_rec->qual[i].order_cnt=",t_rec->qual[i].order_cnt))
foot report
	t_rec->cnt = i
with nocounter;, time=120

select into "nl:"
from
	(dummyt d with seq=t_rec->cnt)
	,clinical_event ce
plan d
	where t_rec->qual[d.seq].order_cnt > 0
join ce
	where ce.person_id = t_rec->qual[d.seq].person_id
	and   ce.event_cd = bc_common->pdf_event_cd
	and   ce.normal_ref_range_txt > " "
	and   cnvtdatetime(curdate,curtime3) between ce.valid_from_dt_tm and ce.valid_until_dt_tm
	and	  ce.result_status_cd in(
									  value(uar_get_code_by("MEANING",8,"AUTH"))
									 ,value(uar_get_code_by("MEANING",8,"MODIFIED"))
									 ;003 ,value(uar_get_code_by("MEANING",8,"ALTERED"))
									 ;003 ,value(uar_get_code_by("MEANING",8,"INERROR"))
								)
head report
	i = 0
head ce.person_id
	i = 0
	k = 0
detail
	i = (i + 1)
	stat = alterlist(t_rec->qual[d.seq].req_qual,i)
	t_rec->qual[d.seq].req_qual[i].event_id				= ce.event_id
	t_rec->qual[d.seq].req_qual[i].event_title_text		= ce.event_title_text
	t_rec->qual[d.seq].req_qual[i].parent_event_id		= ce.parent_event_id
	t_rec->qual[d.seq].req_qual[i].reference_range		= ce.normal_ref_range_txt
	t_rec->qual[d.seq].req_qual[i].event_end_dt_tm		= format(ce.event_end_dt_tm,"dd-mmm-yyyy hh:mm:ss;;d")
	
	t_rec->qual[d.seq].person_id = ce.person_id
	t_rec->qual[d.seq].encntr_id = ce.encntr_id
	
	order_string = t_rec->qual[d.seq].req_qual[i].reference_range
	
	k = 1
	while (order_string != notfnd)
		;call echo(build2("order_string=",order_string))
		order_string = piece(t_rec->qual[d.seq].req_qual[i].reference_range,":",k,notfnd)
		if (cnvtreal(order_string) > 0)
			pos = 0
			pos = locateval(
									 j
									,1
									,t_rec->qual[d.seq].req_qual[i].order_cnt
									,cnvtreal(order_string)
									,t_rec->qual[d.seq].req_qual[i].order_qual[j].order_id
								)
			if ((pos = 0) and (cnvtreal(order_string) > 0))
				t_rec->qual[d.seq].req_qual[i].order_cnt = (t_rec->qual[d.seq].req_qual[i].order_cnt + 1)
				stat = alterlist(t_rec->qual[d.seq].req_qual[i].order_qual,t_rec->qual[d.seq].req_qual[i].order_cnt)
				t_rec->qual[d.seq].req_qual[i].order_qual[t_rec->qual[d.seq].req_qual[i].order_cnt].order_id = cnvtreal(order_string)
			endif
		endif
		k = (k + 1)
	endwhile
	order_string = ""
	
foot ce.person_id
	t_rec->qual[d.seq].req_cnt = i
with nocounter;, time=120


select into "nl:"
from
	 (dummyt d1 with seq=t_rec->cnt)
	,(dummyt d2 with seq=1)
	,(dummyt d3 with seq=1)
	,orders o
plan d1
	where maxrec(d2,t_rec->qual[d1.seq].req_cnt)
join d2
	where maxrec(d3,t_rec->qual[d1.seq].req_qual[d2.seq].order_cnt	)
join d3
join o
	where o.order_id = t_rec->qual[d1.seq].req_qual[d2.seq].order_qual[d3.seq].order_id
detail
	t_rec->qual[d1.seq].req_qual[d2.seq].order_qual[d3.seq].order_mnemonic 		= o.order_mnemonic
	t_rec->qual[d1.seq].req_qual[d2.seq].order_qual[d3.seq].order_status 		= uar_get_code_display(o.order_status_cd)
	t_rec->qual[d1.seq].req_qual[d2.seq].order_qual[d3.seq].template_order_flag = o.template_order_flag
	t_rec->qual[d1.seq].req_qual[d2.seq].order_qual[d3.seq].protocol_order_id 	= o.protocol_order_id
	if (uar_get_code_display(o.order_status_cd) = "Future")
		t_rec->qual[d1.seq].req_qual[d2.seq].valid_order_remain_ind = 1
	endif
with nocounter

select into "nl:"
from
	 (dummyt d1 with seq=t_rec->cnt)
	,(dummyt d2 with seq=1)
	,(dummyt d3 with seq=1)
	,orders o
plan d1
	where maxrec(d2,t_rec->qual[d1.seq].req_cnt)
join d2
	where maxrec(d3,t_rec->qual[d1.seq].req_qual[d2.seq].order_cnt	)
join d3
	where t_rec->qual[d1.seq].req_qual[d2.seq].order_qual[d3.seq].template_order_flag = 7
join o
	where o.protocol_order_id = t_rec->qual[d1.seq].req_qual[d2.seq].order_qual[d3.seq].order_id
detail
	t_rec->qual[d1.seq].req_qual[d2.seq].order_qual[d3.seq].order_mnemonic 		= o.order_mnemonic
	t_rec->qual[d1.seq].req_qual[d2.seq].order_qual[d3.seq].order_status 		= uar_get_code_display(o.order_status_cd)
	t_rec->qual[d1.seq].req_qual[d2.seq].order_qual[d3.seq].template_order_flag = o.template_order_flag
	t_rec->qual[d1.seq].req_qual[d2.seq].order_qual[d3.seq].protocol_order_id 	= o.protocol_order_id
	if (uar_get_code_display(o.order_status_cd) = "Future")
		t_rec->qual[d1.seq].req_qual[d2.seq].valid_order_remain_ind = 1
	endif
with nocounter


select into "nl:"
from
	 (dummyt d1 with seq=t_rec->cnt)
	,(dummyt d2 with seq=1)
	,(dummyt d3 with seq=1)
	,orders o
plan d1
	where maxrec(d2,t_rec->qual[d1.seq].req_cnt)
join d2
	where maxrec(d3,t_rec->qual[d1.seq].req_qual[d2.seq].order_cnt	)
join d3
join o
	where o.order_id = t_rec->qual[d1.seq].req_qual[d2.seq].order_qual[d3.seq].protocol_order_id
detail
	if (uar_get_code_display(o.order_status_cd) = "Future")
		t_rec->qual[d1.seq].req_qual[d2.seq].valid_order_remain_ind = 1
	endif
with nocounter
	
select into "nl:"
from
	 (dummyt d1 with seq=t_rec->cnt)
	,(dummyt d2 with seq=1)
	,order_detail od
plan d1
	where maxrec(d2,t_rec->qual[d1.seq].order_cnt)
join d2
join od
	where od.order_id = t_rec->qual[d1.seq].order_qual[d2.seq].order_id
	and   od.oe_field_id in(
							bc_common->scheduling_location_field_non_radiology_id
							,bc_common->scheduling_location_field_id
							)
order by
	 od.order_id
	,od.oe_field_id 
	,od.detail_sequence desc
head od.order_id
	t_rec->qual[d1.seq].order_qual[d2.seq].scheduling = od.oe_field_display_value
with nocounter


select into "nl:"
from
	 (dummyt d1 with seq=t_rec->cnt)
	,(dummyt d2 with seq=1)
plan d1
	where maxrec(d2,t_rec->qual[d1.seq].order_cnt)
join d2
head report
	i = 0
	j = 0
	order_string = " "
detail
	;call echo(build2("checking for order_id=",t_rec->qual[d1.seq].order_qual[d2.seq].order_id))
	;call echo(build2("checking for order_mnemonic=",t_rec->qual[d1.seq].order_qual[d2.seq].order_mnemonic))
	;call echo(build2("looking at req cnt=",t_rec->qual[d1.seq].req_cnt))
	for (j = 1 to t_rec->qual[d1.seq].req_cnt)
	 if (t_rec->qual[d1.seq].order_qual[d2.seq].event_id = 0)
		i = 0 
		order_string = cnvtstring(t_rec->qual[d1.seq].order_qual[d2.seq].order_id,20,0)
		;call echo(build2("order_string = ",order_string))
		;call echo(build2("in ",t_rec->qual[d1.seq].req_qual[j].reference_range))
		i = findstring(trim(order_string),t_rec->qual[d1.seq].req_qual[j].reference_range,1)
		;call echo(build2("->i=",i))
		if (i > 0)
			t_rec->qual[d1.seq].order_qual[d2.seq].event_id = t_rec->qual[d1.seq].req_qual[j].event_id
			t_rec->qual[d1.seq].order_qual[d2.seq].parent_event_id = t_rec->qual[d1.seq].req_qual[j].parent_event_id
			t_rec->qual[d1.seq].order_qual[d2.seq].event_title_text 
				= t_rec->qual[d1.seq].req_qual[j].event_title_text
			if (t_rec->qual[d1.seq].order_qual[d2.seq].protocol_order_id = 0.0)
				t_rec->qual[d1.seq].order_qual[d2.seq].parent_order_on_req_ind = 99
			else
				t_rec->qual[d1.seq].order_qual[d2.seq].child_order_on_req_ind = 98
			endif
		else
			if (t_rec->qual[d1.seq].order_qual[d2.seq].protocol_order_id > 0.0)
				order_string = cnvtstring(t_rec->qual[d1.seq].order_qual[d2.seq].protocol_order_id,20,0)
				;call echo(build2("order_string = ",order_string))
				i = findstring(trim(order_string),t_rec->qual[d1.seq].req_qual[j].reference_range,1)
				;call echo(build2("->i=",i))
				if (i > 0)
					t_rec->qual[d1.seq].order_qual[d2.seq].event_id = t_rec->qual[d1.seq].req_qual[j].event_id
					t_rec->qual[d1.seq].order_qual[d2.seq].parent_event_id = t_rec->qual[d1.seq].req_qual[j].parent_event_id
					t_rec->qual[d1.seq].order_qual[d2.seq].event_title_text 
						= t_rec->qual[d1.seq].req_qual[j].event_title_text
						
					if (t_rec->qual[d1.seq].order_qual[d2.seq].protocol_order_id = 0.0)
						t_rec->qual[d1.seq].order_qual[d2.seq].parent_order_on_req_ind = 89
					else
						t_rec->qual[d1.seq].order_qual[d2.seq].parent_order_on_req_ind = 88
					endif
				endif
			endif
		endif
	 endif
	endfor
with nocounter

select into "nl:"
from
	 (dummyt d1 with seq=t_rec->cnt)
	,(dummyt d2 with seq=1)
	,act_pw_comp apc
	,pathway p
plan d1
	where maxrec(d2,t_rec->qual[d1.seq].order_cnt)
join d2
join apc
	where 	apc.parent_entity_id = t_rec->qual[d1.seq].order_qual[d2.seq].order_id
	
join p
	where p.pathway_id = apc.pathway_id
detail
	t_rec->qual[d1.seq].order_qual[d2.seq].pathway_id = p.pathway_id
	t_rec->qual[d1.seq].order_qual[d2.seq].pathway_desc = p.description
	t_rec->qual[d1.seq].order_qual[d2.seq].pw_group_desc = p.pw_group_desc
with nocounter

select into "nl:"
from
	 (dummyt d1 with seq=t_rec->cnt)
	,(dummyt d2 with seq=1)
	,act_pw_comp apc
	,pathway p
plan d1
	where maxrec(d2,t_rec->qual[d1.seq].order_cnt)
join d2
	where t_rec->qual[d1.seq].order_qual[d2.seq].pathway_id = 0.0
	and   t_rec->qual[d1.seq].order_qual[d2.seq].protocol_order_id > 0.0
join apc
	where 	apc.parent_entity_id = t_rec->qual[d1.seq].order_qual[d2.seq].protocol_order_id	
join p
	where p.pathway_id = apc.pathway_id
detail
	t_rec->qual[d1.seq].order_qual[d2.seq].pathway_id = p.pathway_id
	t_rec->qual[d1.seq].order_qual[d2.seq].pathway_desc = p.description
	t_rec->qual[d1.seq].order_qual[d2.seq].pw_group_desc = p.pw_group_desc
with nocounter

select into "nl:"
from
	 (dummyt d1 with seq=t_rec->cnt)
	,(dummyt d2 with seq=1)
plan d1
	where maxrec(d2,t_rec->qual[d1.seq].order_cnt)
join d2	
	where t_rec->qual[d1.seq].order_qual[d2.seq].template_order_flag = 7
head report
	pos = 0
detail
	if (t_rec->qual[d1.seq].order_qual[d2.seq].parent_order_on_req_ind = 0)
		if (t_rec->qual[d1.seq].order_qual[d2.seq].child_order_on_req_ind = 0)
		 for (k=1 to t_rec->qual[d1.seq].order_cnt)
		  if (t_rec->qual[d1.seq].order_qual[k].protocol_order_id = t_rec->qual[d1.seq].order_qual[d2.seq].order_id)
			;call echo(build2("matched protocol_order_id = ",t_rec->qual[d1.seq].order_qual[k].protocol_order_id))
			for (j = 1 to t_rec->qual[d1.seq].req_cnt)
		 		i = 0 
				order_string = cnvtstring(t_rec->qual[d1.seq].order_qual[k].order_id,20,0)
				;call echo(build2("order_string = ",order_string))
				;call echo(build2("in ",t_rec->qual[d1.seq].req_qual[j].reference_range))
				i = findstring(trim(order_string),t_rec->qual[d1.seq].req_qual[j].reference_range,1)
				if (i > 0)
				 t_rec->qual[d1.seq].order_qual[d2.seq].child_order_on_req_ind = 77
				endif
			endfor
		   endif
		 endfor
		endif
	endif
with nocounter

select into "nl:"
from
	 (dummyt d1 with seq=t_rec->cnt)
	,(dummyt d2 with seq=1)
plan d1
	where maxrec(d2,t_rec->qual[d1.seq].order_cnt)
join d2	
head report
	pos = 0
detail
	if ((t_rec->qual[d1.seq].order_qual[d2.seq].child_order_on_req_ind = 0) and 
		(t_rec->qual[d1.seq].order_qual[d2.seq].parent_order_on_req_ind =  0 ))
		if (t_rec->qual[d1.seq].order_qual[d2.seq].scheduling > " ")
			if (t_rec->qual[d1.seq].order_qual[d2.seq].scheduling in("Paper Referral","Print to Paper"))
				t_rec->qual[d1.seq].order_qual[d2.seq].neither_order_on_req_ind = 1
			endif
		else
			t_rec->qual[d1.seq].order_qual[d2.seq].neither_order_on_req_ind = 1
		endif
	endif
with nocounter



/*
select into "nl:"
from
	 (dummyt d1 with seq=t_rec->cnt)
	,(dummyt d2 with seq=1)
plan d1
	where maxrec(d2,t_rec->qual[d1.seq].order_cnt)
join d2	
head report
	pos = 0
detail
	pos = 0
	if (t_rec->qual[d1.seq].order_qual[d2.seq].event_id = 0.0)
		if (t_rec->qual[d1.seq].order_qual[d2.seq].template_order_flag = 7)
			pos = locateval(i,1,t_rec->qual[d1.seq].order_cnt,
							t_rec->qual[d1.seq].order_qual[d2.seq].order_id,
							t_rec->qual[d1.seq].order_qual[i].protocol_order_id)
							
			if (pos > 0)
				if (t_rec->qual[d1.seq].order_qual[pos].event_id > 0)
					t_rec->qual[d1.seq].order_qual[d2.seq].event_id = 
						t_rec->qual[d1.seq].order_qual[pos].event_id
					t_rec->qual[d1.seq].order_qual[d2.seq].event_title_text = 
						t_rec->qual[d1.seq].order_qual[pos].event_title_text
					if (t_rec->qual[d1.seq].order_qual[d2.seq].protocol_order_id = 0.0)
						t_rec->qual[d1.seq].order_qual[d2.seq].parent_order_on_req_ind = 1
					else
						t_rec->qual[d1.seq].order_qual[d2.seq].child_order_on_req_ind = 1
					endif
				endif
			endif	
		endif
	endif
with nocounter
*/

select into "nl:"
from
	(dummyt d with seq=t_rec->cnt)
	,person_alias pa
plan d
join pa
	where pa.person_id = t_rec->qual[d.seq].person_id
	and   pa.person_alias_type_cd = 10
	and   pa.active_ind = 1
	and   cnvtdatetime(curdate,curtime3) between pa.beg_effective_dt_tm and pa.end_effective_dt_tm
detail
	t_rec->qual[d.seq].mrn = pa.alias
with nocounter


select into "nl:"
from
	 (dummyt d1 with seq=t_rec->cnt)
	,(dummyt d2 with seq=1)
plan d1
	where maxrec(d2,t_rec->qual[d1.seq].order_cnt)
join d2
	where t_rec->qual[d1.seq].order_qual[d2.seq].event_id > 0.0
detail
	t_rec->qual[d1.seq].order_qual[d2.seq].present_in_ippdf_ind = 1
	t_rec->qual[d1.seq].order_qual[d2.seq].present_in_rm_ind = 1
with nocounter

for (ii=1 to t_rec->cnt)
	;call echo(build("execute bc_all_mp_get_pdf_audit"))
	execute bc_all_mp_get_pdf_audit ^nl:^,value(t_rec->qual[ii].person_id),value(t_rec->qual[ii].encntr_id)
	call echo(build2("size(outrec->data=",size(outrec->data,5)))
	
	;call echo(build2("processing reqs=",t_rec->qual[ii].req_cnt))
	for (jj=1 to t_rec->qual[ii].req_cnt)
		if (t_rec->qual[ii].req_qual[jj].event_id > 0.0)
			;call echo(build2("t_rec->qual[ii].req_qual[jj].event_id=",t_rec->qual[ii].req_qual[jj].event_id))
			;call echo(build2("t_rec->qual[ii].req_qual[jj].parent_event_id=",t_rec->qual[ii].req_qual[jj].parent_event_id))
			for (kk=1 to size(outrec->data,5))
				;call echo(build2("outrec->data[kk].parent_event_id=",outrec->data[kk].parent_event_id))
				if (outrec->data[kk].parent_event_id = t_rec->qual[ii].req_qual[jj].parent_event_id)
					set t_rec->qual[ii].req_qual[jj].present_in_ippdf_ind = 22
					set t_rec->qual[ii].req_qual[jj].present_in_rm_ind = 23
				endif
			endfor
		endif
	endfor
	call echo(build2("processing orders=",t_rec->qual[ii].order_cnt))
	for (jj=1 to t_rec->qual[ii].order_cnt)
		if (t_rec->qual[ii].order_qual[jj].event_id > 0.0)
			call echo(build2("t_rec->qual[ii].order_qual[jj].parent_event_id=",t_rec->qual[ii].order_qual[jj].parent_event_id))
			for (kk=1 to size(outrec->data,5))
				if (outrec->data[kk].parent_event_id = t_rec->qual[ii].order_qual[jj].parent_event_id)
					set t_rec->qual[ii].order_qual[jj].present_in_ippdf_ind = 33
					set t_rec->qual[ii].order_qual[jj].present_in_rm_ind = 34
				endif
			endfor
		endif
	endfor
endfor

if (t_rec->prompts.report_type = 1)
call echo(build2("report_type = 1"))
select distinct into $OUTDEV
	 mrn 			= substring(1,15,t_rec->qual[d1.seq].mrn)
	,name 			= substring(1,50,t_rec->qual[d1.seq].name)
	,order_id 		= t_rec->qual[d1.seq].order_qual[d2.seq].order_id
	,template_order_flag 		= t_rec->qual[d1.seq].order_qual[d2.seq].template_order_flag
	,p_order_id 		= t_rec->qual[d1.seq].order_qual[d2.seq].protocol_order_id
	,order_dt_tm = substring(1,20,t_rec->qual[d1.seq].order_qual[d2.seq].order_dt_tm_vc)
	,requested_start_dt_tm = substring(1,20,t_rec->qual[d1.seq].order_qual[d2.seq].requested_start_dt_tm_vc)
	,order_mnemonic = substring(1,100,t_rec->qual[d1.seq].order_qual[d2.seq].order_mnemonic)
	,sch_location = substring(1,100,t_rec->qual[d1.seq].order_qual[d2.seq].scheduling)
	,pw_group_desc = substring(1,100,t_rec->qual[d1.seq].order_qual[d2.seq].pw_group_desc)
	,pathway_desc = substring(1,100,t_rec->qual[d1.seq].order_qual[d2.seq].pathway_desc)
	,pathway_id 		= t_rec->qual[d1.seq].order_qual[d2.seq].pathway_id
	,event_id 		= t_rec->qual[d1.seq].order_qual[d2.seq].event_id
	,parent_event_id 		= t_rec->qual[d1.seq].req_qual[d3.seq].parent_event_id
	,reference_range 		= substring(1,1000,t_rec->qual[d1.seq].req_qual[d3.seq].reference_range)
	,title 		= substring(1,400,t_rec->qual[d1.seq].order_qual[d2.seq].event_title_text)
	,parent_order_on_req_ind 		= t_rec->qual[d1.seq].order_qual[d2.seq].parent_order_on_req_ind
	,child_order_on_req_ind 		= t_rec->qual[d1.seq].order_qual[d2.seq].child_order_on_req_ind
	,neither_order_on_req_ind 		= t_rec->qual[d1.seq].order_qual[d2.seq].neither_order_on_req_ind
	,present_in_ippdf_ind 		= t_rec->qual[d1.seq].order_qual[d2.seq].present_in_ippdf_ind
	,present_in_rm_ind 		= t_rec->qual[d1.seq].order_qual[d2.seq].present_in_rm_ind
from (dummyt d1 with seq=t_rec->cnt)
	,(dummyt d2 with seq=1)
	,(dummyt d3 with seq=1)
plan d1
	where maxrec(d2,t_rec->qual[d1.seq].order_cnt)
	and   maxrec(d3,t_rec->qual[d1.seq].req_cnt)
join d2
	;where t_rec->qual[d1.seq].order_qual[d2.seq].event_id = 0.0
	;and t_rec->qual[d1.seq].order_qual[d2.seq].scheduling = ""
	;where t_rec->qual[d1.seq].order_qual[d2.seq].neither_order_on_req_ind = 1
join d3
	where t_rec->qual[d1.seq].order_qual[d2.seq].event_id = outerjoin(t_rec->qual[d1.seq].req_qual[d3.seq].event_id)
order by
	name
	,pw_group_desc
	,pathway_desc
	,order_mnemonic
	,order_id
	,p_order_id
	,event_id
with nocounter,separator=" ",format,outerjoin=d3
endif


if (t_rec->prompts.report_type = 2)
call echo(build2("report_type = 2"))

select distinct into $OUTDEV
	 mrn 						= substring(1,15,t_rec->qual[d1.seq].mrn)
	,name 						= substring(1,50,t_rec->qual[d1.seq].name)
	,event_id					= t_rec->qual[d1.seq].req_qual[d2.seq].event_id
	,title						= substring(1,150,t_rec->qual[d1.seq].req_qual[d2.seq].event_title_text)
	,event_end_dt_tm			= substring(1,25,t_rec->qual[d1.seq].req_qual[d2.seq].event_end_dt_tm)
	,reference_range			= substring(1,1000,t_rec->qual[d1.seq].req_qual[d2.seq].reference_range)
	,valid_order_remain_ind		= t_rec->qual[d1.seq].req_qual[d2.seq].valid_order_remain_ind
	,present_in_ippdf_ind		= t_rec->qual[d1.seq].req_qual[d2.seq].present_in_ippdf_ind
	,present_in_rm_ind			= t_rec->qual[d1.seq].req_qual[d2.seq].present_in_rm_ind
	
from (dummyt d1 with seq=t_rec->cnt)
	,(dummyt d2 with seq=1)
plan d1
	where   maxrec(d2,t_rec->qual[d1.seq].req_cnt)
join d2
	;where t_rec->qual[d1.seq].req_qual[d2.seq].valid_order_remain_ind = 0
	;and t_rec->qual[d1.seq].req_qual[d2.seq].present_in_ippdf_ind > 0
order by
	name
with nocounter,separator=" ",format
endif

call echorecord(t_rec)
end go
