/*****************************************************************************
******************************************************************************

  Author:             Chad Cummings
  Date Written:       03/01/2019
  Solution:           
  Source file name:   rm_filter_manager.prg
  Object name:        rm_filter_manager
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

drop program rm_filter_manager:dba go
create program rm_filter_manager:dba

prompt 
	"Output to File/Printer/MINE" = "MINE"
	, "PRSNL_ID" = "" 

with OUTDEV, PRSNL_ID


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
	 2 prsnl_id			= vc
	 2 filter_set		= vc
	1 values
	 2 prsnl_id			= f8
	1 prsnl_cnt 		= i2
	1 prsnl_qual[*]
	 2 prsnl_id			= f8
	 2 prsnl_name		= vc
	 2 prsnl_position	= vc
	 2 default_filter	= vc
	 2 hide_ind			= i2
	 2 filter_cnt 		= i2
	 2 filter_qual[*]
	  3	filter_name		= vc
	  3 filter_display	= vc
	  3 filter_params	= vc
	  3 hide_ind		= i2
)

free record record_data
record record_data
(
	1 prsnl_cnt 		= i2
	1 prsnl_qual[*]
	 2 prsnl_id			= f8
	 2 prsnl_name		= vc
	 2 prsnl_position	= vc
	 2 default_filter	= vc
	 2 filter_cnt 		= i2
	 2 filter_qual[*]
	  3	filter_name		= vc
	  3 filter_params	= vc
	  3 filter_display	= vc
  1 error_message = vc
  1 status_data
    2 status = c1
    2 subeventstatus [1]
      3 operationname = c25
      3 operationstatus = c1
      3 targetobjectname = c25
      3 targetobjectvalue = vc
)

record 500525request (
  1 application_number = i4   
  1 position_cd = f8   
  1 prsnl_id = f8   
  1 www_flag = i2   
  1 preftool_ind = i2   
  1 top_view_list_cnt = i4   
  1 top_view_list [*]   
    2 frame_type = c20  
) 

RECORD 500525reply (
   1 app
     2 application_number = i4
     2 position_cd = f8
     2 prsnl_id = f8
     2 nv_cnt = i4
     2 nv [* ]
       3 name_value_prefs_id = f8
       3 nv_type_flag = i2
       3 pvc_name = c32
       3 pvc_value = vc
       3 sequence = i2
       3 merge_id = f8
       3 merge_name = vc
       3 updt_cnt = i4
   1 view_level_flag = i2
   1 view_cnt = i4
   1 pview [* ]
     2 view_prefs_id = f8
     2 application_number = i4
     2 position_cd = f8
     2 prsnl_id = f8
     2 frame_type = c12
     2 view_name = c12
     2 view_seq = i4
     2 updt_cnt = i4
     2 nv_cnt = i4
     2 nv [* ]
       3 name_value_prefs_id = f8
       3 nv_type_flag = i2
       3 pvc_name = c32
       3 pvc_value = vc
       3 sequence = i2
       3 merge_id = f8
       3 merge_name = vc
       3 updt_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus [1 ]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 
;call echorecord(bc_common)
declare temp_string = vc with noconstant("")

set record_data->status_data[1].status = "F"

set t_rec->prompts.outdev			= $OUTDEV
set t_rec->prompts.prsnl_id			= $PRSNL_ID
   
set t_rec->values.prsnl_id			= cnvtreal(t_rec->prompts.prsnl_id)

if (t_rec->values.prsnl_id > 0.0)
	go to exit_script
endif

select 
	 p.name_full_formatted
	,n.updt_dt_tm
	,position=uar_get_code_display(p.position_cd)
	,fitler_name=replace(n.pvc_name,"TEST_","")
	,n.pvc_name
from
	 app_prefs a
	,name_value_prefs n
	,prsnl p
plan a
	where a.prsnl_id > 0.0
	and a.application_number = 600005
join p
	where p.person_id = a.prsnl_id
join n
	where n.parent_entity_id = a.app_prefs_id
	and n.parent_entity_name = "APP_PREFS"
	and n.pvc_name = "TEST_*"
order by
	 p.name_full_formatted
	,fitler_name
	,p.person_id
	,n.name_value_prefs_id
	,n.pvc_name
head report
	i = 0
	j = 0
head p.person_id
	i = (i + 1)
	stat = alterlist(t_rec->prsnl_qual,i)
	t_rec->prsnl_qual[i].prsnl_id			= p.person_id
	t_rec->prsnl_qual[i].prsnl_name			= p.name_full_formatted
	t_rec->prsnl_qual[i].prsnl_position		= uar_get_code_display(p.position_cd)
	j = 0
head n.pvc_name
	if (n.pvc_name = "TEST_DEFAULT_FILTER_SET")
		t_rec->prsnl_qual[i].default_filter = replace(n.pvc_value,"TEST_","")
	else
		j = (j + 1)
		stat = alterlist(t_rec->prsnl_qual[i].filter_qual,j)
		t_rec->prsnl_qual[i].filter_qual[j].filter_name = n.pvc_name
		t_rec->prsnl_qual[i].filter_qual[j].filter_display = replace(n.pvc_name,"TEST_","")
	endif
foot p.person_id
	t_rec->prsnl_qual[i].filter_cnt = j
foot report
	t_rec->prsnl_cnt = i
with nocounter

select into "nl:"
	 position = t_rec->prsnl_qual[d1.seq].prsnl_position
	,name = t_rec->prsnl_qual[d1.seq].prsnl_name
	,id = t_rec->prsnl_qual[d1.seq].prsnl_id
from 
	 (dummyt d1 with seq=t_rec->prsnl_cnt)
	,(dummyt d2 with seq=1)
plan d1
	where maxrec(d2,t_rec->prsnl_qual[d1.seq].filter_cnt) >= 0
join d2 
order by
	 position
	,name
	,id
head report
	i = 0
	k = 0
head id
	k = 0
	if (t_rec->prsnl_qual[d1.seq].hide_ind = 0)
		record_data->prsnl_cnt = (record_data->prsnl_cnt + 1)
		stat = alterlist(record_data->prsnl_qual,record_data->prsnl_cnt)
		record_data->prsnl_qual[record_data->prsnl_cnt].prsnl_id		= t_rec->prsnl_qual[d1.seq].prsnl_id
		record_data->prsnl_qual[record_data->prsnl_cnt].prsnl_name		= t_rec->prsnl_qual[d1.seq].prsnl_name
		record_data->prsnl_qual[record_data->prsnl_cnt].prsnl_position	= t_rec->prsnl_qual[d1.seq].prsnl_position
		record_data->prsnl_qual[record_data->prsnl_cnt].default_filter	= t_rec->prsnl_qual[d1.seq].default_filter
	endif
detail
	if ((t_rec->prsnl_qual[d1.seq].filter_qual[d2.seq].hide_ind = 0) and (t_rec->prsnl_qual[d1.seq].hide_ind = 0))
		k = (k + 1)
		stat = alterlist(record_data->prsnl_qual[record_data->prsnl_cnt].filter_qual,k)
		record_data->prsnl_qual[record_data->prsnl_cnt].filter_qual[k].filter_name = 
			t_rec->prsnl_qual[d1.seq].filter_qual[d2.seq].filter_name
		record_data->prsnl_qual[record_data->prsnl_cnt].filter_qual[k].filter_params = 
			t_rec->prsnl_qual[d1.seq].filter_qual[d2.seq].filter_params
		record_data->prsnl_qual[record_data->prsnl_cnt].filter_qual[k].filter_display = 
			t_rec->prsnl_qual[d1.seq].filter_qual[d2.seq].filter_display
	endif		
foot report
	null
with nocounter,outerjoin=d1
  
set record_data->status_data[1].status = "S"

#exit_script

set _memory_reply_string = cnvtrectojson (record_data)
;call echo(_memory_reply_string)
;call echorecord(t_rec)
call echorecord(record_data)

end
go

