drop program req_cust_mp_get_person go
create program req_cust_mp_get_person

PROMPT
  "Output" = "MINE" ,
  "person_id:" = " " 
 WITH outdev ,person_id

SET person_parser = build ("p.person_id IN (" , $PERSON_ID ,")" )

FREE RECORD record_data
RECORD record_data (
  1 patient_name = vc
  1 patient_person_id = f8
  1 date_used = i2
  1 status_data
    2 status = c1
    2 subeventstatus [1 ]
      3 operationname = c25
      3 operationstatus = c1
      3 targetobjectname = c25
      3 targetobjectvalue = vc
)

 
SET record_data->status_data.status = "F"

select into "nl:"
from
	person p
plan p
	where parser(person_parser)
detail
	record_data->patient_name = p.name_full_formatted
	record_data->patient_person_id = p.person_id
with nocounter
 

SET record_data->status_data.status = "S"

#exit_script

CALL echorecord (record_data )
DECLARE strjson = vc
DECLARE _memory_reply_string = vc
SET strjson = cnvtrectojson (record_data )
SET _memory_reply_string = strjson
 
end
go
