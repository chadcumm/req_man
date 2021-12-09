/*****************************************************************************
******************************************************************************

  Author:             Chad Cummings
  Date Written:       03/01/2019
  Solution:           
  Source file name:   rm_location_manager.prg
  Object name:        rm_location_manager
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

drop program rm_location_manager:dba go
create program rm_location_manager:dba

prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to. 

with OUTDEV


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
	1 loc_cnt			= i2
	1 loc_list[*]
	 2 facility_cd 		= f8
	 2 facility_name	= vc
	 2 unit_cnt 		= i2
	 2 unit_qual[*]
	  3 unit_cd			= f8
	  3 unit_name		= vc
	  3 code_value		= f8
)

free record record_data
record record_data
(
	1 loc_cnt			= i2
	1 loc_list[*]
	 2 facility_cd 		= f8
	 2 facility_name	= vc
	 2 unit_cnt 		= i2
	 2 unit_qual[*]
	  3 unit_cd			= f8
	  3 unit_name		= vc
	  3 code_value		= f8
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
declare temp_string = vc with noconstant("")

set record_data->status_data[1].status = "F"

set t_rec->prompts.outdev			= $OUTDEV

SELECT DISTINCT
   location_cd = l3.location_cd ,
   location = trim (uar_get_code_display (l3.location_cd ) ),
   facility = trim (uar_get_code_description (l.location_cd ) )
FROM 
	prsnl_org_reltn por,
    organization org,
    location l,
    location_group lg,
    location l2,
    location_group lg2,
    location l3,
    code_value cv1,
    code_value cv2,
    code_value cv3,
    dummyt d1
plan por
	where por.person_id = 2
    and por.beg_effective_dt_tm < cnvtdatetime (curdate ,curtime3)
    and por.end_effective_dt_tm >= cnvtdatetime (curdate ,curtime3)
    and por.active_ind = 1
join org
    where org.organization_id = por.organization_id 
    and org.beg_effective_dt_tm < cnvtdatetime (curdate ,curtime3 ) 
    and org.end_effective_dt_tm >= cnvtdatetime (curdate ,curtime3 ) 
    and org.active_ind = 1
join l
   	where l.organization_id = org.organization_id 
    and l.location_type_cd = value(uar_get_code_by_cki("CKI.CODEVALUE!2844"))
    and l.beg_effective_dt_tm < cnvtdatetime (curdate ,curtime3 ) 
    and l.end_effective_dt_tm >= cnvtdatetime (curdate ,curtime3 ) 
    and l.active_ind = 1 
join cv1
    where cv1.code_value = l.location_cd
join lg
    where lg.parent_loc_cd = l.location_cd
    and lg.root_loc_cd = 0 
    and lg.beg_effective_dt_tm < cnvtdatetime (curdate ,curtime3 )
    and lg.end_effective_dt_tm >= cnvtdatetime (curdate ,curtime3 )
    and lg.active_ind = 1 
join l2
    where l2.location_cd = lg.child_loc_cd 
    and l2.beg_effective_dt_tm < cnvtdatetime (curdate ,curtime3 ) 
    and l2.end_effective_dt_tm >= cnvtdatetime (curdate ,curtime3 ) 
    and l2.active_ind = 1 
join lg2
    where lg.child_loc_cd = lg2.parent_loc_cd 
    and lg2.root_loc_cd = 0 
    and lg2.beg_effective_dt_tm < cnvtdatetime (curdate ,curtime3 ) 
    and lg2.end_effective_dt_tm >= cnvtdatetime (curdate ,curtime3 ) 
    and lg2.active_ind = 1 
join l3
    where l3.location_cd = lg2.child_loc_cd 
    and l3.beg_effective_dt_tm < cnvtdatetime (curdate ,curtime3 ) 
    and l3.end_effective_dt_tm >= cnvtdatetime (curdate ,curtime3 ) 
    and l3.active_ind = 1 
    and l3.location_type_cd in(	
    							 select
							     cv.code_value
							     from code_value cv 
							     where cv.cdf_meaning in("AMBULATORY","NURSEUNIT")
							   )
join cv2
    where cv2.code_value = l3.location_cd
join d1
join cv3
    where cv3.code_set = 103507
    and   cv3.cdf_meaning = "LOCATION"
    and   cv3.active_ind = 1
    and   cv3.display = cv2.display
order by
   	facility ,
   	location,
   	l.location_cd,
    l3.location_cd
head report
    org_cnt = 0 ,
    unit_cnt = 0,
    temp_string = ""
   ;HEAD l3.location_cd
   ;head l.location_cd
head facility
	call echo(build2("l.location_cd=",l.location_cd))
	call echo(build2("facility=",facility))
 
    unit_cnt = 0,
    temp_string = ""
    org_cnt = (org_cnt + 1 ) ,
   
    IF ((mod (org_cnt ,10 ) = 1 ) )
    	stat = alterlist (t_rec->loc_list ,(org_cnt + 9 ) )
    ENDIF
    temp_string = replace (facility ,char (10 ) ," " )
    t_rec->loc_list[org_cnt].facility_name = replace (temp_string ,char (13 ) ," " )
    t_rec->loc_list[org_cnt].facility_cd = l.location_cd
   
head location
   	call echo(build2("l3.location_cd=",l3.location_cd))
   	call echo(build2("location=",location))
   	unit_cnt = (unit_cnt + 1)
   	stat = alterlist (t_rec->loc_list[org_cnt].unit_qual,unit_cnt )
   	temp_string = replace (location ,char (10 ) ," " )
   	t_rec->loc_list[org_cnt ].unit_qual[unit_cnt].unit_name = replace (temp_string ,char (13 ) ," " )
   	t_rec->loc_list[org_cnt ].unit_qual[unit_cnt].unit_cd = l3.location_cd
   	t_rec->loc_list[org_cnt ].unit_qual[unit_cnt].code_value = cv3.code_value
foot report
    stat = alterlist (t_rec->loc_list ,org_cnt )
with nocounter, outerjoin = d1

for (i=1 to size(t_rec->loc_list,5))
	set stat = alterlist(record_data->loc_list,i)
	set record_data->loc_list[i].facility_cd	= t_rec->loc_list[i].facility_cd
	set record_data->loc_list[i].facility_name	= t_rec->loc_list[i].facility_name
	for (j=1 to size(t_rec->loc_list[i].unit_qual,5))
		set stat = alterlist(record_data->loc_list[i].unit_qual,j)
		set record_data->loc_list[i].unit_qual[j].unit_name		= t_rec->loc_list[i].unit_qual[j].unit_name
		set record_data->loc_list[i].unit_qual[j].unit_cd		= t_rec->loc_list[i].unit_qual[j].unit_cd
		set record_data->loc_list[i].unit_qual[j].code_value	= t_rec->loc_list[i].unit_qual[j].code_value
	endfor
endfor
   
set record_data->status_data[1].status = "S"

#exit_script

set _memory_reply_string = cnvtrectojson (record_data)
;call echo(_memory_reply_string)
call echorecord(record_data)
;call echorecord(t_rec)
end
go
