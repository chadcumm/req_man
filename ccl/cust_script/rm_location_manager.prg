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
000   01/20/2020  Chad Cummings			Initial Release 
001   12/14/2021  Chad Cummings         SUP-20211214
******************************************************************************/

drop program rm_location_manager:dba go
create program rm_location_manager:dba

prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "LOC_UNIT_CD" = 0
	, "SELECTED" = "" 

with OUTDEV, LOC_UNIT_CD, SELECTED


call echo(build("loading script:",curprog))

execute bc_all_pdf_std_routines

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
     2 loc_unit_cd      = f8
     2 selected         = vc
    1 constants
     2 rm_detail_ind    = i2
     2 rm_code_value    = f8
     2 rm_active_ind    = i2
     2 rm_new_active_ind = i2
     2 loc_display      = vc
     2 loc_description   = vc
     2 loc_code_value   = f8
	1 loc_cnt			= i2
	1 loc_list[*]
	 2 facility_cd 		= f8
	 2 facility_name	= vc
	 2 unit_cnt 		= i2
	 2 unit_qual[*]
	  3 unit_cd			= f8
	  3 unit_name		= vc
	  3 code_value		= f8
	  3 ippdf_only		= i2
) with protect

free record record_data
record record_data
(
    1 prompts
	 2 outdev			= vc
     2 loc_unit_cd      = f8
     2 selected         = vc
    1 constants
     2 rm_detail_ind    = i2
     2 rm_code_value    = f8
     2 rm_active_ind    = i2
     2 rm_new_active_ind = i2
     2 loc_display      = vc
     2 loc_description   = vc
     2 loc_code_value   = f8
	1 loc_cnt			= i2
	1 loc_list[*]
	 2 facility_cd 		= f8
	 2 facility_name	= vc
	 2 unit_cnt 		= i2
	 2 unit_qual[*]
	  3 unit_cd			= f8
	  3 unit_name		= vc
	  3 code_value		= f8
	  3 ippdf_only		= i2
  1 error_message = vc
  1 status_data
    2 status = c1
    2 subeventstatus [1]
      3 operationname = c25
      3 operationstatus = c1
      3 targetobjectname = c25
      3 targetobjectvalue = vc
) with protect

;call echorecord(bc_common)
declare temp_string = vc with noconstant("")

set record_data->status_data[1].status = "F"

set t_rec->prompts.outdev			= $OUTDEV
set t_rec->prompts.loc_unit_cd      = cnvtreal($LOC_UNIT_CD)
set t_rec->prompts.selected         = $SELECTED

if (cnvtlower(t_rec->prompts.selected) = ^false^)
    set t_rec->constants.rm_new_active_ind = 0
elseif (cnvtlower(t_rec->prompts.selected) = ^true^)
    set t_rec->constants.rm_new_active_ind = 1
elseif (cnvtlower(t_rec->prompts.selected) = ^ippdf only^)
    set t_rec->constants.rm_detail_ind = 1
    set t_rec->constants.rm_new_active_ind = 0
    set temp_string = "LOCATION_LTD"
elseif (cnvtlower(t_rec->prompts.selected) = ^requisition manager^)
    set t_rec->constants.rm_detail_ind = 1
    set t_rec->constants.rm_new_active_ind = 1
    set temp_string = "LOCATION"
endif

if (t_rec->prompts.loc_unit_cd > 0.0)
    select into "nl:"
    from    
        code_value cv
    plan cv 
        where cv.code_set = 220
        and   cv.active_ind = 1
        and   cv.code_value = t_rec->prompts.loc_unit_cd
    detail
        t_rec->constants.loc_code_value = cv.code_value
        t_rec->constants.loc_display    = cv.display
        t_rec->constants.loc_description = cv.description
    with nocounter

    select into "nl:"
    from    
        code_value cv1
    plan cv1
        where cv1.code_set = bc_common->code_set
        and   cv1.display = t_rec->constants.loc_display
    detail
        t_rec->constants.rm_code_value = cv1.code_value
        t_rec->constants.rm_active_ind = cv1.active_ind
    with nocounter

    if ((t_rec->prompts.loc_unit_cd > 0.0) and (t_rec->constants.rm_code_value = 0.0) and (t_rec->constants.rm_detail_ind = 0))
        ;Add new location code value definition
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
        set 102901_request->code_value[102901_request->code_value_qual].code_set = bc_common->code_set
        set 102901_request->code_value[102901_request->code_value_qual].cdf_meaning = "LOCATION_LTD"
        set 102901_request->code_value[102901_request->code_value_qual].display = t_rec->constants.loc_display
        set 102901_request->code_value[102901_request->code_value_qual].description = t_rec->constants.loc_display
        set 102901_request->code_value[102901_request->code_value_qual].definition =  t_rec->constants.loc_description

        call echorecord(102901_request)
        set stat = tdbexecute(100008,100083,102901,"REC",102901_request,"REC",102901_reply)
        call echorecord(102901_reply)
        
        if ((102901_reply->status_data->status = "S") and (102901_reply->code_value[1].code_value > 0.0))
            set t_rec->constants.rm_code_value = 102901_reply->code_value[1].code_value
            update into code_value set updt_id = reqinfo->updt_id where code_value = t_rec->constants.rm_code_value
                                                                  and   code_value > 0.0
            commit 
		endif
    endif

    if ((t_rec->prompts.loc_unit_cd > 0.0) and (t_rec->constants.rm_code_value > 0.0) and (t_rec->constants.rm_detail_ind = 0))
        update into code_value
        set 
             active_ind = t_rec->constants.rm_new_active_ind
            ,updt_dt_tm = cnvtdatetime(curdate,curtime3)
            ,updt_id = reqinfo->updt_id
            ,updt_cnt = (updt_cnt + 1)
        where code_value = t_rec->constants.rm_code_value and code_value > 0.0
        commit
    endif

    if ((t_rec->prompts.loc_unit_cd > 0.0) and (t_rec->constants.rm_code_value > 0.0) and (t_rec->constants.rm_detail_ind = 1))
        update into code_value
        set 
             cdf_meaning = temp_string
            ,updt_dt_tm = cnvtdatetime(curdate,curtime3)
            ,updt_id = reqinfo->updt_id
            ,updt_cnt = (updt_cnt + 1)
        where code_value = t_rec->constants.rm_code_value and code_value > 0.0
        commit
    endif

    go to exit_success
endif

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
    and   cv3.cdf_meaning in( "LOCATION","LOCATION_LTD")
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
   	
   	if (cv3.cdf_meaning = "LOCATION_LTD")
   		t_rec->loc_list[org_cnt ].unit_qual[unit_cnt].ippdf_only = 1
   	endif
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
		set record_data->loc_list[i].unit_qual[j].ippdf_only	= t_rec->loc_list[i].unit_qual[j].ippdf_only
	endfor
endfor

#exit_success

set record_data->status_data[1].status = "S"

#exit_script


set record_data->prompts.outdev	            = t_rec->prompts.outdev			
set record_data->prompts.loc_unit_cd        = t_rec->prompts.loc_unit_cd       
set record_data->prompts.selected           = t_rec->prompts.selected       
set record_data->constants.rm_detail_ind    = t_rec->constants.rm_detail_ind
set record_data->constants.rm_code_value    = t_rec->constants.rm_code_value 
set record_data->constants.rm_active_ind    = t_rec->constants.rm_active_ind 
set record_data->constants.rm_new_active_ind    = t_rec->constants.rm_new_active_ind 
set record_data->constants.loc_display      = t_rec->constants.loc_display   
set record_data->constants.loc_description  = t_rec->constants.loc_description
set record_data->constants.loc_code_value   = t_rec->constants.loc_code_value

set _memory_reply_string = cnvtrectojson (record_data)
;call echo(_memory_reply_string)
call echorecord(record_data)
;call echorecord(t_rec)
end
go
