/*****************************************************************************
******************************************************************************

  Author:             Chad Cummings
  Date Written:       03/01/2019
  Solution:           
  Source file name:   bc_all_mp_patient_banner.prg
  Object name:        bc_all_mp_patient_banner
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
******************************************************************************/
drop program bc_all_mp_patient_banner:dba go
create program bc_all_mp_patient_banner:dba
 
prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
 
with OUTDEV
 
free record patient_banner
record patient_banner
(
	1 person_id		= f8
	1 encntr_id		= f8
	1 name_full		= vc
	1 dob			= vc
	1 age			= vc
	1 sex			= vc
	1 encntr_type	= vc
	1 encntr_status	= vc
	1 loc_facility	= vc
	1 loc_unit		= vc
	1 loc_room_bed	= vc
	1 mrn			= vc
	1 fin			= vc
	1 phn			= vc
)
 
;set _memory_reply_string = ""
 
if (validate(request->blob_in))
    if (request->blob_in > " ")
        set stat =  cnvtjsontorec(request->blob_in)
        if (validate(patientdata->person_id))
        	set patient_banner->person_id = patientdata->person_id
        endif
        if (validate(patientdata->encntr_id))
        	set patient_banner->encntr_id = patientdata->encntr_id
        endif
    else
        set _memory_reply_string = "request->blob_in NOT valid."
        go to exit_script
    endif
else
    set _memory_reply_string = "request->blob_in NOT valid."
    go to exit_script
endif
 
if (patient_banner->encntr_id > 0.0)
	select into "nl:"
	from
		 encounter e
		,person p
	plan e
		where e.encntr_id = patient_banner->encntr_id
	join p
		where p.person_id = e.person_id
	head report
		row +0
	detail
		patient_banner->encntr_id 		= e.encntr_id
		patient_banner->person_id 		= p.person_id
		patient_banner->encntr_type 	= trim(uar_get_code_display(e.encntr_type_cd))
		patient_banner->encntr_status 	= trim(uar_get_code_display(e.encntr_status_cd))
		patient_banner->loc_facility	= trim(uar_get_code_display(e.loc_facility_cd))
		
		if (trim(uar_get_code_display(e.loc_bed_cd)) > " ")
     		patient_banner->loc_room_bed = concat(
													trim(uar_get_code_display(e.loc_room_cd)),"-",
													trim(uar_get_code_display(e.loc_bed_cd))
												)
		else
			patient_banner->loc_room_bed = concat(trim(uar_get_code_display(e.loc_room_cd)))
		endif
		
		if (patient_banner->loc_room_bed > " ")
			patient_banner->loc_room_bed = concat(";",trim(patient_banner->loc_room_bed))
		endif
		
		patient_banner->loc_unit		= trim(uar_get_code_display(e.loc_nurse_unit_cd))
		patient_banner->name_full		= trim(p.name_full_formatted)
		patient_banner->sex				= trim(uar_get_code_display(p.sex_cd))
		patient_banner->dob				= trim(format(cnvtdatetimeutc(datetimezone(p.birth_dt_tm,p.birth_tz),1),'dd-mmm-yyyy;;q'))
		patient_banner->age				= trim(cnvtage(p.birth_dt_tm))
	foot report
		row +0
	with nocounter
 
	select into "nl:"
	from
		encntr_alias ea
	plan ea
		where ea.encntr_id = patient_banner->encntr_id
		and   cnvtdatetime(curdate,curtime3) between ea.beg_effective_dt_tm and ea.end_effective_dt_tm
		and   ea.active_ind = 1
		and   ea.encntr_alias_type_cd in(
											 value(uar_get_code_by("MEANING",319,"MRN"))
											,value(uar_get_code_by("MEANING",319,"FIN NBR"))
										)
	order by
		 ea.encntr_id
		,ea.encntr_alias_type_cd
		,ea.beg_effective_dt_tm desc
	head report
		row +0
	head ea.encntr_alias_type_cd
		case (uar_get_code_meaning(ea.encntr_alias_type_cd))
			of "MRN":		patient_banner->mrn = cnvtalias(ea.alias,ea.alias_pool_cd)
			of "FIN NBR":	patient_banner->fin = cnvtalias(ea.alias,ea.alias_pool_cd)
		endcase
	foot ea.encntr_alias_type_cd
		row +0
	foot report
		row +0
	with nocounter
	
	select into "nl:"
	from
		person_alias ea
	plan ea
		where ea.person_id = patient_banner->person_id
		and   cnvtdatetime(curdate,curtime3) between ea.beg_effective_dt_tm and ea.end_effective_dt_tm
		and   ea.active_ind = 1
		and   ea.person_alias_type_cd in(
											 value(uar_get_code_by("MEANING",4,"NHIN"))
										)
	order by
		 ea.person_id
		,ea.person_alias_type_cd
		,ea.beg_effective_dt_tm desc
	head report
		row +0
	head ea.person_alias_type_cd
		case (uar_get_code_meaning(ea.person_alias_type_cd))
			of "NHIN":		patient_banner->phn = cnvtalias(ea.alias,ea.alias_pool_cd)
		endcase
	foot ea.person_alias_type_cd
		row +0
	foot report
		row +0
	with nocounter
endif
set _memory_reply_string = cnvtrectojson(patient_banner)

call echorecord(patient_banner)
call echo(_memory_reply_string)

#exit_script
end go
 
