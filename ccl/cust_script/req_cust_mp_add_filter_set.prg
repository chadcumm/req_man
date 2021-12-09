/*****************************************************************************
******************************************************************************

  Author:             Chad Cummings
  Date Written:       03/01/2019
  Solution:           
  Source file name:   req_cust_mp_add_filter_set.prg
  Object name:        req_cust_mp_add_filter_set
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
DROP PROGRAM req_cust_mp_add_filter_set GO
CREATE PROGRAM req_cust_mp_add_filter_set
 prompt 
	"Output to File/Printer/MINE" = "MINE"
	, "User ID:" = 0.0
	, "FILTER_SET_NAME" = "0"
	, "FILTER_SET_VALUES" = "" 

with OUTDEV, USER_ID, FILTER_SET_NAME, FILTER_SET_VALUES
  
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
  1 final_filter_set_name = vc
  1 final_default_filter_set_pref = vc
  1 filter_set_values = vc

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

DECLARE maintainuserpreferences (null ) = null WITH protect
DECLARE breakstring ((p1 = vc (val ) ) ,(p2 = vc (ref ) ) ,(p3 = vc (val ) ) ) = null WITH protect
 
SET record_data->status_data.status 	= "F"
set record_data->error_message 			= "Original Status"

set record_data->prsnl_id 				= $USER_ID
set record_data->filter_set_name 		= $FILTER_SET_NAME
set record_data->filter_set_values		= $FILTER_SET_VALUES
set record_data->application_number 	= 600005;reqinfo->updt_app

set record_data->filter_set_preface 	= "TEST_"
set record_data->final_filter_set_name	= concat(
													 trim(record_data->filter_set_preface)
													,trim(record_data->filter_set_name)
												)
set record_data->final_default_filter_set_pref = concat(
													 trim(record_data->filter_set_preface)
													,trim("DEFAULT_FILTER_SET")
												)
call adddefaultfilterset(null)
call addnewfilterset(null)



SET record_data->status_data.status 	= "S"
SET modify maxvarlen 20000000
SET _memory_reply_string = cnvtrectojson (record_data )

SUBROUTINE  adddefaultfilterset (null )
  DECLARE begin_date_time = q8 WITH constant (cnvtdatetime (curdate ,curtime3 ) ) ,private
  RECORD dcp_reply (
    1 status_data
      2 status = c1
      2 subeventstatus [1 ]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
  RECORD dcp_add_request (
    1 application_number = i4
    1 position_cd = f8
    1 prsnl_id = f8
    1 nv [* ]
      2 pvc_name = c32
      2 pvc_value = vc
      2 sequence = i2
      2 merge_id = f8
      2 merge_name = vc
  )
 
  CALL breakstring ( value(record_data->final_filter_set_name) ,dcp_add_request,value(record_data->final_default_filter_set_pref) )
 ; CALL breakstring ( value("Default") ,dcp_add_request,value(record_data->final_default_filter_set_pref) )
  
  SET dcp_add_request->application_number = record_data->application_number
  SET dcp_add_request->prsnl_id =  record_data->prsnl_id
  
  EXECUTE dcp_add_app_prefs WITH replace ("REQUEST" ,"DCP_ADD_REQUEST" ) , replace ("REPLY" ,"DCP_REPLY" )
  IF ((dcp_reply->status_data.status = "F" ) )
   SET record_data->status_data.status = "F"
   GO TO exit_script
  ENDIF
  IF ((validate (debug_ind ,0 ) = 1 ) )
   CALL echorecord (dcp_add_request )
   CALL echorecord (dcp_reply )
  ENDIF
  FREE RECORD dcp_reply
  FREE RECORD dcp_add_request

 END ;Subroutine
 
SUBROUTINE  addnewfilterset (null )
  DECLARE begin_date_time = q8 WITH constant (cnvtdatetime (curdate ,curtime3 ) ) ,private
  RECORD dcp_reply (
    1 status_data
      2 status = c1
      2 subeventstatus [1 ]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
  RECORD dcp_add_request (
    1 application_number = i4
    1 position_cd = f8
    1 prsnl_id = f8
    1 nv [* ]
      2 pvc_name = c32
      2 pvc_value = vc
      2 sequence = i2
      2 merge_id = f8
      2 merge_name = vc
  )
 
  CALL breakstring ( value(record_data->filter_set_values) ,dcp_add_request ,  value(record_data->final_filter_set_name) )
  
  SET dcp_add_request->application_number = record_data->application_number
  SET dcp_add_request->prsnl_id =  record_data->prsnl_id
  
  EXECUTE dcp_add_app_prefs WITH replace ("REQUEST" ,"DCP_ADD_REQUEST" ) , replace ("REPLY" ,"DCP_REPLY" )
  IF ((dcp_reply->status_data.status = "F" ) )
   SET record_data->status_data.status = "F"
   GO TO exit_script
  ENDIF
  IF ((validate (debug_ind ,0 ) = 1 ) )
   CALL echorecord (dcp_add_request )
   CALL echorecord (dcp_reply )
  ENDIF
  FREE RECORD dcp_reply
  FREE RECORD dcp_add_request

 END ;Subroutine
 
 SUBROUTINE  breakstring (string ,rec ,pvc_name )
 
  DECLARE begin_date_time = q8 WITH constant (cnvtdatetime (curdate ,curtime3 ) ) ,private
  DECLARE max_len = i4 WITH constant (256 ) ,protect
  DECLARE idx = i4 WITH noconstant (0 ) ,protect
  DECLARE curposition = i4 WITH noconstant (1 ) ,protect
  IF ((reqinfo->updt_app = 3202004 ) )
   IF ((validate (debug_ind ,0 ) = 1 ) )
    CALL echo ('~~~*** Replacing ^ with " ***~~~' )
   ENDIF
   SET string = replace (string ,"^" ,'"' ,0 )
  ENDIF
  SET totalstringsize = size (string )
  WHILE ((curposition <= totalstringsize ) )
   SET idx = (idx + 1 )
   SET stat = alterlist (rec->nv ,idx )
   SET rec->nv[idx ].sequence = idx
   SET rec->nv[idx ].pvc_name = pvc_name
   SET len = (totalstringsize - (curposition - 1 ) )
   IF ((len > max_len ) )
    SET len = max_len
    SET rec->nv[idx ].pvc_value = substring (curposition ,len ,string )
    SET curposition = (curposition + max_len )
   ELSE
    SET rec->nv[idx ].pvc_value = substring (curposition ,len ,string )
    SET curposition = (totalstringsize + 1 )
   ENDIF
  ENDWHILE
 END ;Subroutine
 
#exit_script
	call echo("exit_script")
#exit_program
 call echorecord(record_data)
 free record record_data
END GO
