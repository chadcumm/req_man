/*****************************************************************************
******************************************************************************

  Author:             Chad Cummings
  Date Written:       03/01/2019
  Solution:           
  Source file name:   rm_oef_manager.prg
  Object name:        rm_oef_manager
  Request #:

  Program purpose:

  Executing from:     

  Special Notes:       

******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************

Mod   Mod Date    Developer              Comment
---   ----------  --------------------  --------------------------------------
000   01/20/2020  Chad Cummings			Initial Release ;ADD JIRA
******************************************************************************/

drop program rm_oef_manager:dba go
create program rm_oef_manager:dba

prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "REQUISITION_CD" = ""
	, "OE_FORMAT_ID" = ""
	, "OE_FIELD_ID" = ""
	, "ACTIVE_IND" = ""
	, "CODE_VALUE" = "" 

with OUTDEV, REQUISITION_CD, OE_FORMAT_ID, OE_FIELD_ID, ACTIVE_IND, CODE_VALUE


call echo(build("loading script:",curprog))
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
	 2 outdev			= vc
	 2 requisition_cd	= f8
	 2 oe_format_id		= f8
	 2 oe_field_id		= f8
	 2 active_ind		= vc
	 2 code_value		= f8
	1 pos				= i2
	1 type 				= i2
	1 action			= vc
	1 active_ind		= i2
	1 updt_active_ind   = i2
	1 found_code_value  = f8
	1 new
	 2 code_value		= f8
	 2 display			= vc
	 2 description		= vc
	 2 definition 		= vc
	1 existing[*]
	 2 code_value				= f8
	 2 requisition_format_cd 	= f8
	 2 oe_format_id				= f8
	 2 oe_field_id 				= f8
	 2 active_ind				= i2
	 2 modified_dt_tm			= dq8
	 2 modified_by				= vc
)

free record record_data
record record_data
(
  1 requsitions[*]
   2 format_name = vc
   2 pdf_name = vc
   2 format_cd = f8
   2 processing_type = i2
   2 formats[*]
    3 oe_format_id = f8
    3 oe_format_name = vc
    3 fields[*]
     4 code_value = f8
     4 active_ind = i2
     4 oe_field_id = f8
     4 oe_field_desc = vc
     4 modified_by = vc
     4 modified_dt_tm = vc
  1 format_list[*]
   2 oe_format_name = vc
   2 oe_format_id = f8
  1 error_message = vc
  1 status_data
    2 status = c1
    2 subeventstatus [1]
      3 operationname = c25
      3 operationstatus = c1
      3 targetobjectname = c25
      3 targetobjectvalue = vc
)

;call echorecord(bc_common)

set record_data->status_data[1].status = "F"

set t_rec->prompts.outdev			= $OUTDEV
set t_rec->prompts.oe_format_id		= cnvtreal($OE_FORMAT_ID)
set t_rec->prompts.oe_field_id		= cnvtreal($OE_FIELD_ID)
set t_rec->prompts.requisition_cd	= cnvtreal($REQUISITION_CD)
set t_rec->prompts.active_ind		= $ACTIVE_IND
set t_rec->prompts.code_value		= cnvtint($CODE_VALUE)

if (t_rec->prompts.requisition_cd = 0.0)
	set t_rec->action = "REQ_LIST"
	call echo(build2("t_rec->action =",t_rec->action))
	go to action_found
endif

if ((t_rec->prompts.requisition_cd > 0.0) and (t_rec->prompts.oe_format_id = 0.0) and (t_rec->prompts.oe_field_id = 0.0))
	set t_rec->action = "REQ_REVIEW"
	call echo(build2("t_rec->action =",t_rec->action))
	go to action_found
endif

if ((t_rec->prompts.requisition_cd > 0.0) and (t_rec->prompts.oe_format_id >= 0.0) and (t_rec->prompts.oe_field_id > 0.0))
	if (t_rec->prompts.code_value > 0.0)
		set t_rec->action = "FIELD_MOD_CV"
	else
		set t_rec->action = "FIELD_MOD"
	endif
	call echo(build2("t_rec->action =",t_rec->action))
	go to action_found
endif

#action_found

if (t_rec->action = "")
	set t_rec->action = "REQ_LIST"
endif

call echo(build2("t_rec->action =",t_rec->action))

select into "nl:"
from
	 code_value cv
	,code_value ec
	,code_value_extension cve1
	,(dummyt d1)
plan cv
	where cv.code_set 		= bc_common->code_set
	and   cv.active_ind 	= 1
	and   cv.cdf_meaning	= "REQUISITION"
join ec
	where ec.code_set 		= 6002
	and   ec.cdf_meaning	= cv.description
	and   ec.active_ind		= 1
join d1
join cve1
	where cve1.code_value = cv.code_value
	and   cve1.field_name = "OE_CHANGE_PROCESSING"
order by
	 cv.display
	,ec.display
	,ec.code_value
head report
	i = 0
head ec.code_value
	if (cve1.field_value in("1","2"))
		i = (i + 1)
		stat = alterlist(record_data->requsitions,i)
		record_data->requsitions[i].format_cd = ec.code_value
		record_data->requsitions[i].pdf_name = cv.display
		record_data->requsitions[i].format_name = ec.display
		record_data->requsitions[i].processing_type = cnvtint(cve1.field_value)
	endif
foot report
	null
with nocounter,outerjoin = d1

if (t_rec->action = "REQ_REVIEW")
	set t_rec->pos 
		= locateval(i,1,size(record_data->requsitions,5),t_rec->prompts.requisition_cd,record_data->requsitions[i].format_cd)
	set t_rec->type = record_data->requsitions[t_rec->pos].processing_type
	
	if (t_rec->type = 1)
		select distinct
			 o.oe_field_id
		from
			 order_catalog oc
			,order_entry_fields o
			,oe_format_fields off
			,order_entry_format oef	
			,order_catalog_synonym ocs
			,code_value cv2
		plan cv2
			where cv2.code_set = 6002
			and   cv2.code_value = t_rec->prompts.requisition_cd
		join oc
			where oc.requisition_format_cd = cv2.code_value
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
			 o.description
			,o.oe_field_id
		head report
			i = 0
			req_cnt = t_rec->pos
			cnt = 0
			cnt = (cnt + 1)
			stat = alterlist(record_data->requsitions[req_cnt].formats,cnt)
			record_data->requsitions[req_cnt].formats[cnt].oe_format_id = 0.0
		head o.oe_field_id
			i = (i + 1)
			stat = alterlist(record_data->requsitions[req_cnt].formats[cnt].fields,i)
			record_data->requsitions[req_cnt].formats[cnt].fields[i].oe_field_id = off.oe_field_id
			record_data->requsitions[req_cnt].formats[cnt].fields[i].oe_field_desc = o.description
		foot report
			null
		with nocounter,uar_code(m,d),format(date,";;q")
		
		/* Get the total list of formats for the requisition */
		select distinct
			 o.oe_field_id
		from
			 order_catalog oc
			,order_entry_fields o
			,oe_format_fields off
			,order_entry_format oef	
			,order_catalog_synonym ocs
			,code_value cv2
		plan cv2
			where cv2.code_set = 6002
			and   cv2.code_value = t_rec->prompts.requisition_cd
		join oc
			where oc.requisition_format_cd = cv2.code_value
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
		head report
			i = 0
		head oef.oe_format_id
			i = (i + 1)
			stat = alterlist(record_data->format_list,i)
			record_data->format_list[i].oe_format_id = oef.oe_format_id
			record_data->format_list[i].oe_format_name = oef.oe_format_name
		foot report
			null
		with nocounter,uar_code(m,d),format(date,";;q")
		
	else
		select distinct
			 o.oe_field_id
			 ,oef.oe_format_id
		from
			 order_catalog oc
			,order_entry_fields o
			,oe_format_fields off
			,order_entry_format oef	
			,order_catalog_synonym ocs
			,code_value cv2
		plan cv2
			where cv2.code_set = 6002
			and   cv2.code_value = t_rec->prompts.requisition_cd
		join oc
			where oc.requisition_format_cd = cv2.code_value
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
			,o.description
			,o.oe_field_id
		head report
			i = 0
			req_cnt = t_rec->pos
			cnt = 0
		head oef.oe_format_id
			i=0
			cnt = (cnt + 1)
			stat = alterlist(record_data->requsitions[req_cnt].formats,cnt)
			record_data->requsitions[req_cnt].formats[cnt].oe_format_id = oef.oe_format_id
			record_data->requsitions[req_cnt].formats[cnt].oe_format_name = oef.oe_format_name
		head o.oe_field_id
			i = (i + 1)
			stat = alterlist(record_data->requsitions[req_cnt].formats[cnt].fields,i)
			record_data->requsitions[req_cnt].formats[cnt].fields[i].oe_field_id = off.oe_field_id
			record_data->requsitions[req_cnt].formats[cnt].fields[i].oe_field_desc = o.description
		foot report
			null
		with nocounter,uar_code(m,d),format(date,";;q")
	endif
	
	/* Find existing code values */
	select  
		 requisition_format_cd=cnvtreal(cve1.field_value)
		,oe_format_id=cnvtreal(cve2.field_value)
		,oe_field_id=cnvtreal(cve3.field_value)
	from
		 code_value cv1
		,code_value cv2
		,code_value cv3
		,code_value_extension cve1
		,code_value_extension cve2
		,code_value_extension cve3
		,code_value_extension cve4
		,prsnl p
	plan cv1
		where cv1.code_set = 103509
		and   cv1.cdf_meaning = "FIELD"
		and	  cv1.active_ind in(0,1)
	join p
		where p.person_id = cv1.updt_id
	join cve1
		where cve1.code_value = cv1.code_value
		and   cve1.field_name = "REQUISITION_FORMAT_CD"
	join cve2
		where cve2.code_value = cv1.code_value
		and   cve2.field_name = "OE_FORMAT_ID"
	join cve3
		where cve3.code_value = cv1.code_value
		and   cve3.field_name = "OE_FIELD_ID"
	join cv2
		where cv2.code_set = 6002
		and   cv2.code_value = cnvtreal(cve1.field_value)
	join cv3
		where cv3.code_set = 103507
		and   cv3.description = cv2.cdf_meaning
	join cve4
		where cve4.code_value = cv3.code_value
		and   cve4.field_name = "OE_CHANGE_PROCESSING"
	order by
		 requisition_format_cd
		,oe_format_id
		,oe_field_id
	head report
		i = 0
	detail
		call echo(build2("cv1.code_value=",cv1.code_value))
		i = (i + 1)
		stat = alterlist(t_rec->existing,i)
		t_rec->existing[i].code_value 				= cv1.code_value
		t_rec->existing[i].requisition_format_cd	= requisition_format_cd
		t_rec->existing[i].oe_format_id				= oe_format_id
		t_rec->existing[i].oe_field_id				= oe_field_id
		t_rec->existing[i].active_ind				= cv1.active_ind
		t_rec->existing[i].modified_by				= p.name_full_formatted
		t_rec->existing[i].modified_dt_tm			= cv1.updt_dt_tm
	with nocounter
	
	/* addding code values requisition lists */
	call echo("addding code values requisition lists")
	
	for (i = 1 to size(record_data->requsitions,5))
		
		;call echo(build2("->",))
		call echo(build2("->record_data->requsitions[i].format_cd",record_data->requsitions[i].format_cd))
	
		for (j = 1 to size(record_data->requsitions[i].formats,5))
		
			call echo(build2("-->record_data->requsitions[i].formats[j].oe_format_id",record_data->requsitions[i].formats[j].oe_format_id))
			
			for (k = 1 to size(record_data->requsitions[i].formats[j].fields,5))
			
				call echo(build2("->record_data->requsitions[i].formats[j].fields[k].oe_field_id"
					,record_data->requsitions[i].formats[j].fields[k].oe_field_id))
				
				for (h = 1 to size(t_rec->existing,5))
					if (
								(t_rec->existing[h].requisition_format_cd	= record_data->requsitions[i].format_cd)
							and (t_rec->existing[h].oe_format_id			= record_data->requsitions[i].formats[j].oe_format_id)
							and (t_rec->existing[h].oe_field_id				= record_data->requsitions[i].formats[j].fields[k].oe_field_id)
						)
						set record_data->requsitions[i].formats[j].fields[k].code_value = t_rec->existing[h].code_value
						set record_data->requsitions[i].formats[j].fields[k].active_ind = t_rec->existing[h].active_ind
						set record_data->requsitions[i].formats[j].fields[k].modified_by = t_rec->existing[h].modified_by
						set record_data->requsitions[i].formats[j].fields[k].modified_dt_tm = 
							format(t_rec->existing[h].modified_dt_tm,"dd-mmm-yyyy hh:mm:ss;;q")
						call echo(build2("matched code_value=",t_rec->existing[h].code_value))
					endif
				endfor
			endfor
		endfor
	endfor
endif

if (t_rec->action in("FIELD_MOD","FIELD_MOD_CV"))
	call echo("inside FIELD_MOD actions")
	if (t_rec->action = "FIELD_MOD_CV")
		call echo("inside FIELD_MOD_CV actions")
		call echo(cnvtupper(t_rec->prompts.active_ind))
		
		if (cnvtupper(t_rec->prompts.active_ind) = "TRUE")
			set t_rec->updt_active_ind = 1
		elseif (cnvtupper(t_rec->prompts.active_ind) = "FALSE")
			set t_rec->updt_active_ind = 0
		else
			go to exit_script
		endif
		
		call echo("updating code value")
		update into code_value
		set 
			 active_ind = t_rec->updt_active_ind
			,updt_dt_tm = cnvtdatetime(curdate,curtime3)
			,updt_id = reqinfo->updt_id
			,updt_cnt = (updt_cnt + 1)
		where code_value = t_rec->prompts.code_value
		commit
	elseif (t_rec->action = "FIELD_MOD")
		call echo("check for existing code value")
		select into "nl:"
		from
			 code_value cv1
			,code_value_extension cve1
			,code_value_extension cve2
			,code_value_extension cve3
		plan cv1
			where cv1.code_set = 103509
			and   cv1.cdf_meaning = "FIELD"
			and	  cv1.active_ind in(0,1)
		join cve1
			where cve1.code_value = cv1.code_value
			and   cve1.field_name = "REQUISITION_FORMAT_CD"
		join cve2
			where cve2.code_value = cv1.code_value
			and   cve2.field_name = "OE_FORMAT_ID"
		join cve3
			where cve3.code_value = cv1.code_value
			and   cve3.field_name = "OE_FIELD_ID"
		detail
			if (
					(t_rec->prompts.requisition_cd = cnvtreal(cve1.field_value))
				and (t_rec->prompts.oe_format_id = cnvtreal(cve2.field_value))
				and (t_rec->prompts.oe_field_id = cnvtreal(cve3.field_value)))
				t_rec->found_code_value = cv1.code_value
				call echo("found existing cv")	
			endif
		with nocounter
		if (t_rec->found_code_value > 0.0)
			call echo("inside found_code_value actions")
			call echo(cnvtupper(t_rec->prompts.active_ind))
			
			if (cnvtupper(t_rec->prompts.active_ind) = "TRUE")
				set t_rec->updt_active_ind = 1
			elseif (cnvtupper(t_rec->prompts.active_ind) = "FALSE")
				set t_rec->updt_active_ind = 0
			else
				go to exit_script
			endif
			
			call echo("updating code value")
			update into code_value
			set 
				 active_ind = t_rec->updt_active_ind
				,updt_dt_tm = cnvtdatetime(curdate,curtime3)
				,updt_id = reqinfo->updt_id
				,updt_cnt = (updt_cnt + 1)
			where code_value = t_rec->prompts.code_value
			commit
		else
			call echo("no existing code_value found")
			
			select into "nl:"
			from 
				order_entry_fields oef
			plan oef
				where oef.oe_field_id = t_rec->prompts.oe_field_id
			detail
				t_rec->new.display = oef.description
			with nocounter
			
			if (t_rec->prompts.oe_format_id > 0.0)
				select into "nl:"
				from 
					order_entry_format oef
				plan oef
					where oef.oe_format_id = t_rec->prompts.oe_format_id
				detail
					t_rec->new.description = oef.oe_format_name
				with nocounter
			else
				set t_rec->new.description = "<not set>"
			endif
			
			set t_rec->new.definition = uar_get_code_display(t_rec->prompts.requisition_cd)
			
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
			set 102901_request->code_value_qual = 1
			set stat = alterlist(102901_request->code_value,102901_request->code_value_qual)
			set 102901_request->code_value[102901_request->code_value_qual].action_type = "ADD"
			set 102901_request->code_value[102901_request->code_value_qual].code_set = 103509
			set 102901_request->code_value[102901_request->code_value_qual].cdf_meaning = "FIELD"
			set 102901_request->code_value[102901_request->code_value_qual].display = t_rec->new.display
			set 102901_request->code_value[102901_request->code_value_qual].description = t_rec->new.description
			set 102901_request->code_value[102901_request->code_value_qual].definition =  t_rec->new.definition

			call echorecord(102901_request)
			set stat = tdbexecute(100008,100083,102901,"REC",102901_request,"REC",102901_reply)
			call echorecord(102901_reply)
			
			if ((102901_reply->status_data->status = "S") and (102901_reply->code_value[1].code_value > 0.0))
				set t_rec->new.code_value = 102901_reply->code_value[1].code_value
				update into code_value set updt_id = reqinfo->updt_id where code_value = 102901_reply->code_value[1].code_value
				commit 
			endif
			
			if (t_rec->new.code_value > 0.0)
			
				record 4171666_request (
				  1 extension_list [*]   
				    2 action_type_flag = i2   
				    2 code_set = i4   
				    2 code_value = f8   
				    2 field_name = vc  
				    2 field_type = i4   
				    2 field_value = vc  
				) 

				set stat = alterlist(4171666_request->extension_list,3)
				set 4171666_request->extension_list[1].action_type_flag = 1
				set 4171666_request->extension_list[1].code_value = t_rec->new.code_value
				set 4171666_request->extension_list[1].code_set = 103509
				set 4171666_request->extension_list[1].field_name = "OE_FIELD_ID"
				set 4171666_request->extension_list[1].field_value = cnvtstring(t_rec->prompts.oe_field_id)
				set 4171666_request->extension_list[1].field_type = 1
				
				set 4171666_request->extension_list[2].action_type_flag = 1
				set 4171666_request->extension_list[2].code_value = t_rec->new.code_value
				set 4171666_request->extension_list[2].code_set = 103509
				set 4171666_request->extension_list[2].field_name = "OE_FORMAT_ID"
				set 4171666_request->extension_list[2].field_value = cnvtstring(t_rec->prompts.oe_format_id)
				set 4171666_request->extension_list[2].field_type = 1
				
				set 4171666_request->extension_list[3].action_type_flag = 1
				set 4171666_request->extension_list[3].code_value = t_rec->new.code_value
				set 4171666_request->extension_list[3].code_set = 103509
				set 4171666_request->extension_list[3].field_name = "REQUISITION_FORMAT_CD"
				set 4171666_request->extension_list[3].field_value = cnvtstring(t_rec->prompts.requisition_cd)
				set 4171666_request->extension_list[3].field_type = 1
				
				call echorecord(4171666_request)
				set stat = tdbexecute(4170105,4170151,4171666,"REC",4171666_request,"REC",4171666_reply)
				call echorecord(4171666_reply)

			endif
				
		endif

	endif
endif

set record_data->status_data[1].status = "S"

#exit_script

set _memory_reply_string = cnvtrectojson (record_data)
;call echo(_memory_reply_string)
call echorecord(record_data)
call echorecord(t_rec)
end
go
