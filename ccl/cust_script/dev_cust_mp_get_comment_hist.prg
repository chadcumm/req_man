/*****************************************************************************
******************************************************************************

  Author:             Chad Cummings
  Date Written:       03/01/2019
  Solution:           
  Source file name:   req_cust_mp_get_comment_hist.prg
  Object name:        req_cust_mp_get_comment_hist
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
001   12/01/2020  Chad Cummings			Updated to return CEID
002   12/07/2020  Chad Cummings			Included Priority
003   12/07/2020  Chad Cummings			Included Sub Activity Type
004   12/07/2020  Chad Cummings			Removed Requisition from type name
005   12/10/2020  Chad Cummings			Added priority and sub-type lists
006   12/16/2020  Chad Cummings			Updated statuses to match Sprint 5
007   07/07/2021  Chad Cummings			Switched Summary and Aciton positions
******************************************************************************/
DROP PROGRAM dev_cust_mp_get_comment_hist GO
CREATE PROGRAM dev_cust_mp_get_comment_hist
 prompt 
	"Output to File/Printer/MINE" = "MINE"
	, "EVENT_ID:" = 0.0
	 

with OUTDEV,EVENT_ID
  
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
  1 date_used = i2
  1 event_id = f8
  1 document_start_date = dq8
  1 document_end_date = dq8
  1 requested_start_date = dq8
  1 requested_end_date = dq8
  1 start_check = vc
  1 end_check = vc
  1 requested_start_check = vc
  1 requested_end_check = vc
  1 order_data_label = vc
  1 requested_data_label = vc
  1 task_info_text = vc
  1 allow_req_print = i2
  1 labreq_prg = vc
  1 autolog_spec_ind = i2
  1 lock_chart_access = i2
  1 label_print_type = vc
  1 label_print_auto_off = vc
  1 allow_depart = i2
  1 depart_label = vc
  1 adv_print_ind = i2
  1 adv_print_codeset = f8
  1 form_ind = i2
  1 formslist [* ]
    2 form_id = f8
    2 form_name = vc
  1 tlist [* ]
    2 person_id = f8
    2 encounter_id = f8
    2 person_name = vc
    2 gender = vc
    2 gender_char = vc
    2 dob = vc
    2 age = vc
    2 task_type = vc
    2 task_id = f8
    2 task_type_ind = i2
    2 task_describ = vc
    2 task_display = vc
    2 task_prn_ind = i2
    2 task_date = vc
    2 task_overdue = i2
    2 task_time = vc
    2 task_dt_tm_num = dq8
    2 task_dt_tm_utc = vc
    2 task_form_id = f8
    2 charge_ind = i2
    2 task_status = vc
    2 clerk_status = vc
    2 display_status = vc
    2 inprocess_ind = i2
    2 order_id = vc
    2 order_id_real = f8
    2 ordered_as_name = vc
    2 order_cdl = vc
    2 orig_order_dt = vc
    2 order_dt_tm_utc = vc
    2 ordering_provider = vc
    2 ord_comment = vc
    2 task_note = vc
    2 task_resched_time = i2
    2 can_chart_ind = i2
    2 visit_loc = vc
    2 visit_date = vc
    2 visit_date_display = vc
    2 visit_dt_tm_num = dq8
    2 visit_dt_utc = vc
    2 charted_by = vc
    2 charted_dt = vc
    2 charted_dt_utc = vc
    2 not_done = i2
    2 result_set_id = f8
    2 not_done_reason = vc
    2 not_done_reason_comm = vc
    2 status_reason_cd = f8
    2 powerplan_ind = i2
    2 powerplan_name = vc
    2 event_id = f8
    2 parent_event_id = f8
    2 normal_ref_range_txt = vc
    2 requisition_format_cd = f8
    2 dfac_activity_id = f8
    2 priority = vc ;002
    2 sub_activity_type = vc ;003
    2 action_history = vc ;006
    2 comment_history = vc
    2 status_history = vc
    2 latest_comment = vc
    2 latest_status = vc
    2 keep_ind = i2
    2 olist [* ]
      3 order_name = vc
      3 ordering_prov = vc
      3 order_id = f8
      3 dlist [* ]
        4 rank_seq = vc
        4 diag = vc
        4 code = vc
    2 dlist [* ]
      3 rank_seq = vc
      3 diag = vc
      3 code = vc
    2 asc_num = vc
    2 contain_list [* ]
      3 contain_sent = vc
      3 task_id = f8
    2 order_cnt = i2
    2 abn_track_ids = vc
    2 abn_list [* ]
      3 order_disp = vc
      3 alert_date = vc
      3 alert_state = vc
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
    2 type = vc
    2 selected = i2
  1 priority_pref_found = i2
  1 priority_list [* ]
   2 group_name = vc
   2 group[*]
    3 priority = vc
    3 selected = i2
  1 timer_cnt = i2
  1 timer_final = vc
  1 timer_qual[*]
   2 section = vc
   2 start_time = dq8
   2 end_time = dq8
   2 elapsed = i2
  1 error_message = vc
  1 action_history = vc ;006
  1 comment_history = vc
  1 status_history = vc
  1 latest_comment = vc
  1 latest_status = vc
  1 status_data
    2 status = c1
    2 subeventstatus [1 ]
      3 operationname = c25
      3 operationstatus = c1
      3 targetobjectname = c25
      3 targetobjectvalue = vc
)

record 1120120request (
 1 event_qual [*]   
  2 event_id = f8   
)

declare notfnd = vc with constant("<not found>")
declare order_string = vc with noconstant(" ")
declare temp_string = vc with noconstant("")
declare i = i2 with noconstant(0)
declare k = i2 with noconstant(0)
declare j = i2 with noconstant(0)
declare n = i2 with noconstant(0)
declare g = i2 with noconstant(0)
declare pos = i2 with noconstant(0)
declare found = i2 with noconstant(0)
declare status = vc with noconstant(" ")
	
free record current_status 
free record previous_status
free record status_history

record status_history
(
	1 cnt = i2
	1 qual[*]
  	 2 idx = i2
	 2 status_history = vc
	 2 action = vc
	 2 action_status = vc
	 2 cnt = i2
	 2 action_dt_tm = dq8
	 2 action_prsnl_name_full = vc
	 2 position = vc
	 2 qual[*]
	  3 status = vc
)
record current_status
(
	1 cnt = i2
	1 status_history = vc
	1 qual[*]
	 2 status = vc
)

record previous_status
(
	1 cnt = i2
	1 status_history = vc
	1 qual[*]
	 2 status = vc
)
	
set record_data->event_id = $EVENT_ID

		call echo(build2(^tdbexecute(600005, 1120006, 1120120, "REC", 1120120request, "REC", 1120120reply)^))
		set stat = initrec(1120120request)
		free record 1120120reply
		set stat = alterlist(1120120request->event_qual,1)
		set 1120120request->event_qual[1].event_id = record_data->event_id

		set stat = tdbexecute(600005, 1120006, 1120120, "REC", 1120120request, "REC", 1120120reply)
		
		if (validate(1120120reply))
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
								;start 033 
								where 1120120reply->rb_list[k].event_list[j].event_prsnl_list[d1.seq].action_type_cd_disp
										in("Confirm","Order","Modify","Cancel","Unconfirm")
								and   1120120reply->rb_list[k].event_list[j].event_prsnl_list[d1.seq].valid_until_dt_tm >=
										cnvtdatetime(curdate,curtime3)
								; end 003 
							join p
								where p.person_id = 1120120reply->rb_list[k].event_list[j].event_prsnl_list[d1.seq].action_prsnl_id	
							order by
								action_dt_tm desc
							head report
								 cnt = 0
							detail
								cnt = (cnt + 1)
								
								if (even(i) = 1)
									record_data->action_history = concat(record_data->action_history,~<tr id="even">~	)
								else
									record_data->action_history = concat(record_data->action_history,~<tr id="odd">~	)
								endif
								if (1120120reply->rb_list[k].event_list[j].event_prsnl_list[d1.seq].action_type_cd_disp in("Confirm"))
									1120120reply->rb_list[k].event_list[j].event_prsnl_list[d1.seq].action_type_cd_disp = "Printed"
								endif
								if (1120120reply->rb_list[k].event_list[j].event_prsnl_list[d1.seq].action_type_cd_disp in("Unconfirm"))
		1120120reply->rb_list[k].event_list[j].event_prsnl_list[d1.seq].action_type_cd_disp = "Status Reverted to Pending"
								endif
								record_data->action_history = concat(record_data->action_history
								,	~<td>~
								,	format(1120120reply->rb_list[k].event_list[j].event_prsnl_list[d1.seq].action_dt_tm,"dd-mmm-yyyy hh:mm:ss;;d")
								,	~</td>~
								,	~<td>~,(1120120reply->rb_list[k].event_list[j].event_prsnl_list[d1.seq].action_type_cd_disp),~</td>~
								;,	~<td>~,cnvtcap(1120120reply->rb_list[k].event_list[j].event_prsnl_list[d1.seq].action_status_cd_disp),~</td>~
								,	~<td>~,1120120reply->rb_list[k].event_list[j].event_prsnl_list[d1.seq].action_prsnl_name_full,~</td>~
								,	~<td>~,trim(uar_get_code_display(p.position_cd)),~</td>~
								;,	~<td>~,1120120reply->rb_list[k].event_list[j].event_prsnl_list[d1.seq].action_comment,~</td>~
									)
								record_data->action_history = concat(	record_data->action_history,~</tr>~	)
								
							foot report
								cnt = 0
							with nocounter
							call echo(record_data->action_history)
							
							
							select into "nl:"
								action_dt_tm = 1120120reply->rb_list[k].event_list[j].event_prsnl_list[d1.seq].action_dt_tm
							from
								(dummyt d1 with seq = size(1120120reply->rb_list[k].event_list[j].event_prsnl_list,5))
								,prsnl p
							plan d1
								where 1120120reply->rb_list[k].event_list[j].event_prsnl_list[d1.seq].action_type_cd_disp
										in("Assist")
							join p
								where p.person_id = 1120120reply->rb_list[k].event_list[j].event_prsnl_list[d1.seq].action_prsnl_id	
							order by
								action_dt_tm desc
							head report
								 cnt = 0
							detail
								cnt = (cnt + 1)
								if (cnt = 1)
									record_data->latest_comment = 1120120reply->rb_list[k].event_list[j].event_prsnl_list[d1.seq].action_comment
								endif
								if (even(i) = 1)
									record_data->comment_history = concat(record_data->comment_history,~<tr id="even">~	)
								else
									record_data->comment_history = concat(record_data->comment_history,~<tr id="odd">~	)
								endif
						
								record_data->comment_history = concat(record_data->comment_history
								,	~<td>~,format(1120120reply->rb_list[k].event_list[j].event_prsnl_list[d1.seq].action_dt_tm,"dd-mmm-yyyy hh:mm;;d"),~</td>~
								,	~<td><p align=left>~
								,	trim(1120120reply->rb_list[k].event_list[j].event_prsnl_list[d1.seq].action_comment)
								,	~</p></td>~
								,	~<td>~,1120120reply->rb_list[k].event_list[j].event_prsnl_list[d1.seq].action_prsnl_name_full,~</td>~
								,	~<td>~,trim(uar_get_code_display(p.position_cd)),~</td>~
									)
								record_data->comment_history = concat(	record_data->comment_history,~</tr>~	)
								
							foot report
								cnt = 0
							with nocounter
							
							call echo("starting status history")
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
								action_dt_tm 
							head report
								 cnt = 0
							detail
								cnt = (cnt + 1)
								status_history->cnt = cnt
								stat = alterlist(status_history->qual,cnt)
								status_history->qual[cnt].status_history = 1120120reply->rb_list[k].event_list[j].event_prsnl_list[d1.seq].action_comment
								status_history->qual[cnt].idx = cnt
								status_history->qual[cnt].action_dt_tm = 1120120reply->rb_list[k].event_list[j].event_prsnl_list[
								d1.seq].action_dt_tm
								status_history->qual[cnt].action_prsnl_name_full 
									= 1120120reply->rb_list[k].event_list[j].event_prsnl_list[d1.seq].action_prsnl_name_full
								status_history->qual[cnt].position = uar_get_code_display(p.position_cd)
								
								n = 1
								temp_string = piece(status_history->qual[cnt].status_history,",",n,notfnd) 
								while (temp_string != notfnd)
									temp_string = piece(status_history->qual[cnt].status_history,",",n,notfnd) 
									if (temp_string != notfnd)
										stat = alterlist(status_history->qual[cnt].qual,n)
										status_history->qual[cnt].qual[n].status = trim(temp_string)
										status_history->qual[cnt].cnt = n
									endif
									n = (n + 1)
								endwhile
								
								
							foot report
								cnt = 0
							with nocounter
							
							call echo("looking at actions")
							for (i = 1 to status_history->cnt)
								if ((status_history->qual[i].cnt = 1) and (i=1))
									set status_history->qual[i].action_status = status_history->qual[i].status_history
									set status_history->qual[i].action	= "Added"
								else
									set status_history->qual[i].status_history = ""
									select into "nl:"
										status = status_history->qual[i].qual[d1.seq].status
									from
										(dummyt d1 with seq=status_history->qual[i].cnt)
									order by
										status
									head report
										j = 0
										
									detail
										j = (j + 1)
										if (j > 1)
											status_history->qual[i].status_history = concat(status_history->qual[i].status_history,",")
										endif
										status_history->qual[i].status_history = concat(
																							 trim(status_history->qual[i].status_history)
																							,status_history->qual[i].qual[d1.seq].status
																						)
									with nocounter
									call echo(build("status_history->qual[i].idx=",status_history->qual[i].idx))
									call echo(build("status_history->qual[i].cnt=",status_history->qual[i].cnt))
									call echo(build("status_history->qual[i].status_history=",status_history->qual[i].status_history))
									
									if ((status_history->qual[i].cnt = 1) and (i=1))
										set status_history->qual[i].action = "Added"
										set status_history->qual[i].action_status = status_history->qual[i].status_history
									else
									 if (i>1)
										set stat = initrec(previous_status)
										for (n=1 to status_history->qual[i-1].cnt)
											set previous_status->cnt = n
											set stat = alterlist(previous_status->qual,previous_status->cnt)
											set previous_status->qual[previous_status->cnt].status = status_history->qual[i-1].qual[n].status
										endfor
									 else
									 	set stat = initrec(previous_status)
									 endif
										
										set stat = initrec(current_status)
										for (n=1 to status_history->qual[i].cnt)
											set current_status->cnt = n
											set stat = alterlist(current_status->qual,current_status->cnt)
											set current_status->qual[current_status->cnt].status = status_history->qual[i].qual[n].status
										endfor
										
										call echorecord(previous_status)
										call echorecord(current_status)
										if (status_history->qual[i].cnt > status_history->qual[i-1].cnt)
											set status_history->qual[i].action = "Added"
											for (pos = 1 to current_status->cnt)
												set found = locateval(g,1,previous_status->cnt,current_status->qual[pos].status,
												previous_status->qual[g].status)
												if (found = 0)
													set status_history->qual[i].action_status = current_status->qual[pos].status
												endif
											endfor
										else
											set status_history->qual[i].action = "Removed"
											for (pos = 1 to previous_status->cnt)
												set found = locateval(g,1,current_status->cnt,previous_status->qual[pos].status,
												current_status->qual[g].status)
												if (found = 0)
													set status_history->qual[i].action_status = previous_status->qual[pos].status
												endif
											endfor
										endif
									endif
									
										/*
										call echo("building previous status")
										set stat = initrec(previous_status)
										for (n=1 to status_history->qual[cnt-1].cnt)
											previous_status->cnt = n
											stat = alterlist(previous_status->qual,previous_status->cnt)
											previous_status->qual[previous_status->cnt].status = status_history->qual[cnt-1].qual[n].status
										endfor
										call echo("building current status")
										stat = initrec(current_status)
										for (n=1 to status_history->qual[cnt].cnt)
											current_status->cnt = n
											stat = alterlist(current_status->qual,current_status->cnt)
											current_status->qual[current_status->cnt].status = status_history->qual[cnt].qual[n].status
										endfor
										*/
									endif	
							endfor
							
							select into "nl:"
								pos = status_history->qual[d1.seq].idx
							from
								(dummyt d1 with seq=status_history->cnt)
							plan d1
							order by
								pos desc
							head report
								i = 0
							detail
								i = (i + 1)
								if (even(i) = 1)
									record_data->status_history = concat(record_data->status_history,~<tr id="even">~	)
								else
									record_data->status_history = concat(record_data->status_history,~<tr id="odd">~	)
								endif
								
								record_data->status_history = concat(record_data->status_history
								,	~<td>~,format(status_history->qual[d1.seq].action_dt_tm,"dd-mmm-yyyy hh:mm;;d"),~</td>~
								,	~<td>~,status_history->qual[d1.seq].action,~</td>~ ;007
								,	~<td>~,status_history->qual[d1.seq].action_status,~</td>~ ;007
								,	~<td style="text-align:left"><div style="text-align:left">~
								,	trim(status_history->qual[d1.seq].status_history)
								,	~</div></td>~
								
								,	~<td>~,status_history->qual[d1.seq].action_prsnl_name_full,~</td>~
								,	~<td>~,trim(status_history->qual[d1.seq].position),~</td>~
									)
									
									
								record_data->status_history = concat(	record_data->status_history,~</tr>~	)
						endif
					endfor
				endfor
			endif
		endif
		
	/*
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
	*/



							
call echorecord(status_history)								

SET record_data->status_data.status = "S"

SET modify maxvarlen 20000000
SET _memory_reply_string = cnvtrectojson (record_data )

#exit_script
	call echo("exit_script")
#exit_program

 call echorecord(record_data)
 FREE RECORD record_data
END GO
