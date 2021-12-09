/*****************************************************************************
******************************************************************************

  Author:             Chad Cummings
  Date Written:       03/01/2019
  Solution:           
  Source file name:   bc_all_mp_multi_pdf_viewer.prg
  Object name:        bc_all_mp_multi_pdf_viewer
  Request #:

  Program purpose:

  Executing from:     

  Special Notes:       

******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************

Mod   Mod Date    Developer              Comment
---   ----------  --------------------  --------------------------------------
001   10/01/2019  Chad Cummings			Initial Release
002   11/27/2020  Chad Cummings			Action List Sort by Date and Time
003   12/16/2020  Chad Cummings			Updated status per Sprint 5
******************************************************************************/
drop program bc_all_mp_multi_pdf_viewer go
create program bc_all_mp_multi_pdf_viewer 

prompt 
	"Output to File/Printer/MINE" = "MINE"
	, "CE_EVENT_ID" = 0 

with OUTDEV, CE_EVENT_ID


free record patientdata
record patientdata
(
	1 person_id = f8
	1 encntr_id = f8
)

free record resultdata
record resultdata
(
	1 clinical_event_id = f8
	1 event_id = f8
	1 parent_event_id = f8
	1 cmv_url = vc
	1 cmv_base = vc
	1 identifier = vc
	1 event_cnt = i2
	1 event_list[*]
	 2 clinical_event_id = f8
	 2 parent_event_id = f8
	 2 identifier = vc
	 2 event_id = f8
	 2 cmv_url = vc
	1 action_list_cnt = i2
	1 action_list[*]
	 2 ce_event_prsnl_id = f8
	 2 action_prsnl_id = f8 ;003
	 2 action_prsnl_position_cd = f8 ;003
	 2 action_prsnl_position_disp = vc ;003
	 2 action_status_cd_disp =vc
	 2 action_type_cd_disp = vc
	 2 action_prsnl_name_full = vc
	 2 action_dt_tm = dq8
	 2 action_dt_tm_disp = vc
	 2 action_comment = vc
)



select into "nl:"
from
	 clinical_event ce
	,encounter e
	,person p
plan ce
	where ce.clinical_event_id = $CE_EVENT_ID
join e
	where e.encntr_id = ce.encntr_id
join p
	where p.person_id = e.person_id
order by
	ce.parent_event_id
head ce.parent_event_id
	resultdata->event_cnt = (resultdata->event_cnt + 1)
	stat = alterlist(resultdata->event_list,resultdata->event_cnt)
	resultdata->event_list[resultdata->event_cnt].clinical_event_id	= ce.clinical_event_id
	resultdata->event_list[resultdata->event_cnt].event_id = ce.event_id
	resultdata->event_list[resultdata->event_cnt].parent_event_id = ce.parent_event_id
	patientdata->encntr_id = e.encntr_id
	patientdata->person_id = p.person_id
	call echo(resultdata->event_list[resultdata->event_cnt].clinical_event_id)
with nocounter

set resultdata->cmv_base = concat(
										"http://phsacdea.cerncd.com/"
										,"camm/"
										,trim(cnvtlower(curdomain))				
										;,trim(cnvtlower(b0783))
										,".phsa_cd.cerncd.com/service/mediaContent/"
								)
								
select into "nl:"
from
	 clinical_event ce
	,ce_blob_result cbr
	,(dummyt d1 with seq=resultdata->event_cnt)
plan d1
join ce
	where ce.clinical_event_id = resultdata->event_list[d1.seq].clinical_event_id
join cbr
	where cbr.event_id = ce.event_id
	and   cbr.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3)
order by
     ce.encntr_id
	,ce.event_id
	,ce.valid_from_dt_tm desc
head ce.event_id
	resultdata->event_list[d1.seq].identifier = cbr.blob_handle
	resultdata->event_list[d1.seq].event_id = ce.event_id
	resultdata->event_list[d1.seq].parent_event_id = ce.parent_event_id
	resultdata->event_list[d1.seq].cmv_url = concat(trim(resultdata->cmv_base)
		,trim(resultdata->event_list[d1.seq].identifier))
	/*resultdata->cmv_url =resultdata->event_list[resultdata->event_cnt].cmv_url
	resultdata->event_id =  resultdata->event_list[resultdata->event_cnt].event_id
	resultdata->parent_event_id =  resultdata->event_list[resultdata->event_cnt].parent_event_id
	resultdata->identifier =  resultdata->event_list[resultdata->event_cnt].identifier
	*/
	call echo(ce.event_id)
	
with nocounter


free record 3011001Request
record 3011001Request (
  1 Module_Dir = vc  
  1 Module_Name = vc  
  1 bAsBlob = i2   
) 

free record 3011001Reply
record 3011001Reply (
    1 info_line [* ]
      2 new_line = vc
    1 data_blob = gvc
    1 data_blob_size = i4
    1 status_data
      2 status = c1
      2 subeventstatus [1 ]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )

free record 3011002Request
record 3011002Request (
  1 source_dir = vc  
  1 source_filename = vc  
  1 nbrlines = i4   
  1 line [*]   
    2 lineData = vc  
  1 OverFlowPage [*]   
    2 ofr_qual [*]   
      3 ofr_line = vc  
  1 IsBlob = c1   
  1 document_size = i4   
  1 document = gvc   
) 

free record 3011002Reply
record 3011002Reply (
   1 info_line [* ]
     2 new_line = vc
   1 status_data
     2 status = c1
     2 subeventstatus [1 ]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 
 
declare html_output = vc with noconstant(" ")
declare cmv_url = vc with noconstant(" ")
declare action_list = vc with noconstant(" ")

set 3011001Request->Module_Dir = "ccluserdir:"
set 3011001Request->Module_Name = "rm_print_to_pdf_muliple_new.html";"simple.html"
set 3011001Request->bAsBlob = 1

execute eks_get_source with replace ("REQUEST" ,3011001Request ) , replace ("REPLY" ,3011001Reply )

if (3011001Reply->status_data.status = "S")
	set html_output = 3011001Reply->data_blob
else
	set html_output = "<html><body>Error with getting html source</body></html>"
endif

set html_output = replace(html_output,~@MESSAGE:[PATIENTDATA]~,cnvtrectojson(patientdata))
set html_output = replace(html_output,~@MESSAGE:[RESULTDATA]~,cnvtrectojson(resultdata))
;set html_output = replace(html_output,~@MESSAGE:[CMVURL]~,resultdata->cmv_url)


;call echo(html_output)

set 3011002Request->source_dir = $OUTDEV
set 3011002Request->IsBlob = "1"
set 3011002Request->document = html_output
set 3011002Request->document_size = size(3011002Request->document)

execute eks_put_source with replace ("REQUEST" ,3011002Request ) , replace ("REPLY" ,3011002Reply )

call echorecord(resultdata)

end go

