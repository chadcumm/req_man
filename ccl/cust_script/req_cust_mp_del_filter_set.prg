/*****************************************************************************
******************************************************************************

  Author:             Chad Cummings
  Date Written:       03/01/2019
  Solution:           
  Source file name:   req_cust_mp_del_filter_set.prg
  Object name:        req_cust_mp_del_filter_set
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
******************************************************************************/
DROP PROGRAM req_cust_mp_del_filter_set GO
CREATE PROGRAM req_cust_mp_del_filter_set
 prompt 
	"Output to File/Printer/MINE" = "MINE"
	, "User ID:" = 0.0
	, "FILTER_SET_NAME" = "0"


with OUTDEV, USER_ID, FILTER_SET_NAME
  
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
  1 prsnl_id = f8
  1 filter_set_preface = vc
  1 filter_set_name = vc
  1 filter_set_values = vc
  1 final_filter_set_name = vc
  1 application_number = i4
  1 error_message = vc
  1 status_data
    2 status = c1
    2 subeventstatus [1 ]
      3 operationname = c25
      3 operationstatus = c1
      3 targetobjectname = c25
      3 targetobjectvalue = vc
)

 
SET record_data->status_data.status 	= "F"
set record_data->error_message 			= "Start"

set record_data->prsnl_id 				= $USER_ID
set record_data->filter_set_name 		= $FILTER_SET_NAME
set record_data->application_number 	= 600005;reqinfo->updt_app

set record_data->filter_set_preface 	= "TEST_"
set record_data->final_filter_set_name	= concat(
													 trim(record_data->filter_set_preface)
													,trim(record_data->filter_set_name)
												)



record dcp_reply (
    1 status_data
      2 status = c1
      2 subeventstatus [1 ]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
record dcp_del_request (
    1 nv_cnt = i4
    1 nv [* ]
      2 name_value_prefs_id = f8
  )
  
SELECT INTO "nl:"
   FROM (app_prefs a ),
    (name_value_prefs n )
   PLAN (a
    WHERE (a.prsnl_id =  record_data->prsnl_id )
    AND (a.application_number = record_data->application_number ) )
    JOIN (n
    WHERE (n.parent_entity_id = a.app_prefs_id )
    AND (n.parent_entity_name = "APP_PREFS" )
    AND (n.pvc_name =  record_data->final_filter_set_name ) )
   HEAD REPORT
    cnt = 0
   DETAIL
    cnt = (cnt + 1 ) ,
    IF ((cnt > size (dcp_del_request->nv ,5 ) ) ) stat = alterlist (dcp_del_request->nv ,(cnt + 9 ))
    ENDIF
    ,dcp_del_request->nv[cnt ].name_value_prefs_id = n.name_value_prefs_id
   FOOT REPORT
    dcp_del_request->nv_cnt = cnt ,
    stat = alterlist (dcp_del_request->nv ,cnt )
   WITH nocounter
call echo("checking curqual")

  IF ((curqual > 0 ) )
   EXECUTE dcp_del_name_value WITH replace ("REQUEST" ,"DCP_DEL_REQUEST" ) ,
   replace ("REPLY" ,"DCP_REPLY" )
   IF ((dcp_reply->status_data.status = "F" ) )
    SET record_data->status_data.status = "F"
    GO TO exit_script
   ENDIF
  ENDIF
  IF ((validate (debug_ind ,0 ) = 1 ) )
   CALL echorecord (dcp_del_request )
   CALL echorecord (dcp_reply )
  ENDIF   
 
SET record_data->status_data.status 	= "S"
SET modify maxvarlen 20000000
SET _memory_reply_string = cnvtrectojson (record_data )
 
#exit_script
	call echo("exit_script")
#exit_program
 call echorecord(record_data)
 free record record_data
END GO
