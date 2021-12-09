/*****************************************************************************
******************************************************************************

  Author:             Chad Cummings
  Date Written:       03/01/2019
  Solution:           
  Source file name:   bc_all_mp_pdf_viewer.prg
  Object name:        bc_all_mp_pdf_viewer
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
004   02/15/2021  Chad Cummings			Added Document Status 
******************************************************************************/
drop program bc_all_mp_pdf_viewer go
create program bc_all_mp_pdf_viewer 

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
	1 status = vc ;004
	1 title = vc ;004
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

set resultdata->clinical_event_id = $CE_EVENT_ID

if (resultdata->clinical_event_id = 0.0)
	set resultdata->clinical_event_id = 230668007.00 ;TESTING
endif

select into "nl:"
from
	 clinical_event ce
	,encounter e
	,person p
plan ce
	where ce.clinical_event_id = resultdata->clinical_event_id
join e
	where e.encntr_id = ce.encntr_id
join p
	where p.person_id = e.person_id
detail
	patientdata->encntr_id = e.encntr_id
	patientdata->person_id = p.person_id
with nocounter


select into "nl:"
from
	 clinical_event ce
	,ce_blob_result cbr
plan ce
	where ce.clinical_event_id = resultdata->clinical_event_id
join cbr
	where cbr.event_id = ce.event_id
	and   cbr.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3)
order by
     ce.encntr_id
	,ce.event_id
	,ce.valid_from_dt_tm desc
head ce.encntr_id
	resultdata->identifier = cbr.blob_handle
	resultdata->event_id = ce.event_id
	resultdata->parent_event_id = ce.parent_event_id
with nocounter

;start 004
select into "nl:"
from
	 clinical_event ce
plan ce
	where ce.parent_event_id = resultdata->parent_event_id
	and   cnvtdatetime(curdate,curtime3) between ce.valid_from_dt_tm and ce.valid_until_dt_tm
	and   ce.view_level = 1
detail
	resultdata->title = ce.event_title_text
with nocounter

set resultdata->status = piece(resultdata->title,":",1,"")
if (resultdata->status not in("ACTIONED","MODIFIED","CANCELED"))		
	set resultdata->status = "PENDING"
endif
		
;end 004
		
set resultdata->cmv_base = concat(
										"http://phsacdeanp.cerncd.com/"
										,"camm/"
										,trim(cnvtlower(curdomain))				
										;,trim(cnvtlower(b0783))
										,".phsa_cd.cerncd.com/service/mediaContent/"
								)
;set resultdata->cmv_base = "http://phsacdeanp/camm-mpage/b0783.phsa_cd.cerncd.com/service/mediaContent/"
set resultdata->cmv_url = concat(trim(resultdata->cmv_base),trim(resultdata->identifier))

record 1120120request (
  1 event_qual [*]   
    2 event_id = f8   
) 

set stat = alterlist(1120120request->event_qual,1)
set 1120120request->event_qual[1].event_id = resultdata->parent_event_id

set stat = tdbexecute(600005, 1120006, 1120120, "REC", 1120120request, "REC", 1120120reply)

if (validate(1120120reply))
	call echorecord(1120120reply)
	if (1120120reply->status_data->status = "S")
		for (i=1 to size(1120120reply->rb_list,5))
			for (j=1 to size(1120120reply->rb_list[i].event_list,5))
				if (cnvtupper(1120120reply->rb_list[i].event_list[j].event_class_cd_disp) = "MDOC")
					call echo("mdoc found")
					select into "nl:"
						action_dt_tm = 1120120reply->rb_list[i].event_list[j].event_prsnl_list[d1.seq].action_dt_tm
					from
						(dummyt d1 with seq = size(1120120reply->rb_list[i].event_list[j].event_prsnl_list,5))
					plan d1
						/*start 033 */
						where 1120120reply->rb_list[i].event_list[j].event_prsnl_list[d1.seq].action_type_cd_disp
								in("Confirm","Order","Modify","Cancel","Unconfirm")
						/* end 003 */
						
					order by
						action_dt_tm desc
					head report
						k = 0
					detail
						k = (k + 1)
						stat = alterlist(resultdata->action_list,k)
						 resultdata->action_list[k].ce_event_prsnl_id = 
							1120120reply->rb_list[i].event_list[j].event_prsnl_list[d1.seq].ce_event_prsnl_id
						 resultdata->action_list[k].action_comment = 
							1120120reply->rb_list[i].event_list[j].event_prsnl_list[d1.seq].action_comment
						 resultdata->action_list[k].action_dt_tm = 
							1120120reply->rb_list[i].event_list[j].event_prsnl_list[d1.seq].action_dt_tm
						 resultdata->action_list[k].action_dt_tm_disp = 
							format(1120120reply->rb_list[i].event_list[j].event_prsnl_list[d1.seq].action_dt_tm,"dd-mmm-yyyy hh:mm;;d")
						 resultdata->action_list[k].action_prsnl_name_full = 
							1120120reply->rb_list[i].event_list[j].event_prsnl_list[d1.seq].action_prsnl_name_full
						 resultdata->action_list[k].action_status_cd_disp = 	
							1120120reply->rb_list[i].event_list[j].event_prsnl_list[d1.seq].action_status_cd_disp
						 resultdata->action_list[k].action_type_cd_disp = 
							1120120reply->rb_list[i].event_list[j].event_prsnl_list[d1.seq].action_type_cd_disp
						 /* start 003 */
						 resultdata->action_list[k].action_prsnl_id = 
						 	1120120reply->rb_list[i].event_list[j].event_prsnl_list[d1.seq].action_prsnl_id
						 if (resultdata->action_list[k].action_type_cd_disp in("Confirm"))
						 	resultdata->action_list[k].action_type_cd_disp = "Printed"
						 endif
						 /* end 003 */
						 /* start 004 */
						 if (resultdata->action_list[k].action_type_cd_disp in("Unconfirm"))
						 	resultdata->action_list[k].action_type_cd_disp = "Status Reverted to Pending"
						 endif
						 /* end 004 */
					foot report
						resultdata->action_list_cnt = k
					with nocounter
					
					/*002
					for (k=1 to size(1120120reply->rb_list[i].event_list[j].event_prsnl_list,5))
						set resultdata->action_list_cnt = (resultdata->action_list_cnt + 1)
						set stat = alterlist(resultdata->action_list,resultdata->action_list_cnt)
						set resultdata->action_list[resultdata->action_list_cnt].ce_event_prsnl_id = 
							1120120reply->rb_list[i].event_list[j].event_prsnl_list[k].ce_event_prsnl_id
						set resultdata->action_list[resultdata->action_list_cnt].action_comment = 
							1120120reply->rb_list[i].event_list[j].event_prsnl_list[k].action_comment
						set resultdata->action_list[resultdata->action_list_cnt].action_dt_tm = 
							1120120reply->rb_list[i].event_list[j].event_prsnl_list[k].action_dt_tm
						set resultdata->action_list[resultdata->action_list_cnt].action_dt_tm_disp = 
							format(1120120reply->rb_list[i].event_list[j].event_prsnl_list[k].action_dt_tm,"dd-mmm-yyyy hh:mm;;d")
						set resultdata->action_list[resultdata->action_list_cnt].action_prsnl_name_full = 
							1120120reply->rb_list[i].event_list[j].event_prsnl_list[k].action_prsnl_name_full
						set resultdata->action_list[resultdata->action_list_cnt].action_status_cd_disp = 	
							1120120reply->rb_list[i].event_list[j].event_prsnl_list[k].action_status_cd_disp
						set resultdata->action_list[resultdata->action_list_cnt].action_type_cd_disp = 
							1120120reply->rb_list[i].event_list[j].event_prsnl_list[k].action_type_cd_disp
					endfor
					;002 */
				endif
			endfor
		endfor
	endif
endif

select into "nl:"
from
	(dummyt d1 with seq=size(resultdata->action_list,5))
	,prsnl p1
plan d1
join p1
	where p1.person_id =  resultdata->action_list[d1.seq].action_prsnl_id
detail
	 resultdata->action_list[d1.seq].action_prsnl_position_cd = p1.position_cd
	 resultdata->action_list[d1.seq].action_prsnl_position_disp =
	 	uar_get_code_display(resultdata->action_list[d1.seq].action_prsnl_position_cd)
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
set 3011001Request->Module_Name = "ippdf_print_to_pdf_new.html"
set 3011001Request->bAsBlob = 1

execute eks_get_source with replace ("REQUEST" ,3011001Request ) , replace ("REPLY" ,3011001Reply )

if (3011001Reply->status_data.status = "S")
	set html_output = 3011001Reply->data_blob
else
	set html_output = "<html><body>Error with getting html source</body></html>"
endif

if (resultdata->action_list_cnt > 0)						
	for (i=1 to resultdata->action_list_cnt)
		if (even(i) = 1)
			set action_list = concat(	action_list,~<tr id="even">~	)
		else
			set action_list = concat(	action_list,~<tr id="odd">~	)
		endif
		
		set action_list = concat(	action_list
								,	~<td>~,resultdata->action_list[i].action_dt_tm_disp,~</td>~
								,	~<td>~,resultdata->action_list[i].action_type_cd_disp,~</td>~
								;,	~<td>~,cnvtcap(resultdata->action_list[i].action_status_cd_disp),~</td>~
								,	~<td>~,resultdata->action_list[i].action_prsnl_name_full,~</td>~
								,	~<td>~,resultdata->action_list[i].action_prsnl_position_disp,~</td>~
								;,	~<td>~,resultdata->action_list[i].action_comment,~</td>~
							)
		set action_list = concat(	action_list,~</tr>~	)
	endfor
endif

;testing only
;set cmv_url = concat(	"http://phsacdeanp.cerncd.com/camm/b0783.phsa_cd.cerncd.com/service/mediaContent/",
;						"{a6-a0-4e-5e-7a-0e-4b-20-b2-11-93-ac-fc-0c-2a-38}")

set html_output = replace(html_output,~@MESSAGE:[PATIENTDATA]~,cnvtrectojson(patientdata))
set html_output = replace(html_output,~@MESSAGE:[RESULTDATA]~,cnvtrectojson(resultdata))
set html_output = replace(html_output,~@MESSAGE:[CMVURL]~,resultdata->cmv_url)
set html_output = replace(html_output,~@MESSAGE:[ACTION_LIST]~,action_list)


call echo(html_output)

set 3011002Request->source_dir = $OUTDEV
set 3011002Request->IsBlob = "1"
set 3011002Request->document = html_output
set 3011002Request->document_size = size(3011002Request->document)

execute eks_put_source with replace ("REQUEST" ,3011002Request ) , replace ("REPLY" ,3011002Reply )


end go
