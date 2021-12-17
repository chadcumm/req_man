/***********************************************************************************************************************
Source Code File: bc_all_pdf_std_routines.PRG
Original Author:  Chad Cummings
Date Written:     December 2021
 
Comments: Include File which holds frequently used PDF Standard Sub-routines
 
 
************************************************************************************************************************
												*MODIFICATION HISTORY*
************************************************************************************************************************
 
Rev  Date         Jira       Programmer             Comment
---  -----------  ---------  ---------------------  --------------------------------------------------------------------
000  13-Dec-2021  CST-145166 Chad Cummings          Inital Release with subroutines relevant to JIRA
***********************************************************************************************************************/
drop program bc_all_pdf_std_routines go
create program bc_all_pdf_std_routines


record bc_all_pdf_std_variables
(
    1 code_set
     2 printtopdf = f8
    1 domain 
     2 production_ind = i2
    1 urls
     2 camm_base = vc
     2 camm_content = vc
     2 camm_store = vc
    1 status_data
     2 status = c1
) with protect, persist

declare sIsDevelopmentMode(pScript=vc) = i2 with copy, persist
declare sValidatePatient(pPersonId=f8) = i2 with copy, persist
declare sPrinttoPDFCodeSet(null) = f8 with copy, persist
declare sPopulateRecVariables(null) = null with copy, persist
declare sPDFRoutineDebug(null) = i2 with copy, persist
declare sProductionEnvironment(null) = i2 with copy, persist
declare sPDFRoutineLog(pMessage=vc,pParam=vc(value,'message')) = null with copy, persist
declare sCAMMMediaServicesBase(pParam=vc(value,'mediaContent')) = vc with copy, persist
declare sSchedulingOEFieldID(null) = vc with copy, persist
declare sSchedulingOEFieldValue(null) = vc with copy, persist
declare sIsSchedulingField(pOEFieldId=f8) = i2 with copy, persist
declare sIsSchedulingValueCD(pOEFieldValueCD=f8) = i2 with copy, persist
declare sGetRequisitionDefinitions(null) = vc with copy, persist
declare sCheckforPaperRequisition(pRequisitionFormatCD=f8) = i2 with copy, persist
declare sGetLocationHierarchy(null) = vc with copy, persist

call sPopulateRecVariables(null)


;==========================================================================================
; Return a JSON
;
; USAGE: call sGetLocationHierarchy(null) 
;==========================================================================================
subroutine sGetLocationHierarchy(null)
    call sPDFRoutineLog(build2('start sGetLocationHierarchy(',null,")"))
    declare i=i2 with noconstant(0), protect
    declare temp_string = vc with noconstant(""), protect

    record location_hierarchy
    (
        1 cnt = i2
        1 qual[*]
         2 location_cd = f8
         2 facility_name = vc
         2 facility_cd = f8
         2 unit_cnt = i2
         2 unit_qual[*]
          3 unit_name = vc
          3 unit_cd = f8
          3 code_value = f8
          3 type = vc
          3 ippdf_only = i2
    )

    select distinct
        location_cd = l3.location_cd ,
        location = trim(uar_get_code_display(l3.location_cd)),
        facility = trim(uar_get_code_description(l.location_cd))
    from 
        location l,
        location_group lg,
        location l2,
        location_group lg2,
        location l3,
        code_value cv1,
        code_value cv2,
        code_value cv3,
        dummyt d1
    plan l
        where l.location_type_cd = value(uar_get_code_by_cki("CKI.CODEVALUE!2844"))
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
        and   cv3.cdf_meaning in("LOCATION","LOCATION_LTD") 
        and   cv3.active_ind = 1
        and   cv3.display = cv2.display
    order by
        facility,
        location,
        l.location_cd,
        l3.location_cd
    head report
        org_cnt = 0 ,
        unit_cnt = 0,
        temp_string = ""
    head facility
        call sPDFRoutineLog(build2('-facility=',facility))
        call sPDFRoutineLog(build2('-l.location_cd=',l.location_cd))

        unit_cnt = 0,
        temp_string = ""
        org_cnt = (org_cnt + 1) ,
    
        if ((mod(org_cnt ,10) = 1))
            stat = alterlist(location_hierarchy->qual ,(org_cnt + 9))
        endif
        temp_string = replace (facility ,char(10)," ")
        location_hierarchy->qual[org_cnt].facility_name = replace (temp_string ,char (13 ) ," " )
        location_hierarchy->qual[org_cnt].facility_cd = l.location_cd
    head location
        call sPDFRoutineLog(build2('--l3.location_cd=',l3.location_cd))
        call sPDFRoutineLog(build2('--location=',location))
        unit_cnt = (unit_cnt + 1)
        stat = alterlist (location_hierarchy->qual[org_cnt].unit_qual,unit_cnt )
        temp_string = replace (location ,char (10 ) ," " )
        location_hierarchy->qual[org_cnt].unit_qual[unit_cnt].unit_name = replace (temp_string ,char (13 ) ," " )
        location_hierarchy->qual[org_cnt].unit_qual[unit_cnt].unit_cd = l3.location_cd
        location_hierarchy->qual[org_cnt].unit_qual[unit_cnt].code_value = cv3.code_value
        location_hierarchy->qual[org_cnt].unit_qual[unit_cnt].type = cv3.cdf_meaning
        location_hierarchy->qual[org_cnt].unit_cnt = unit_cnt
    foot report
        stat = alterlist (location_hierarchy->qual,org_cnt)
        location_hierarchy->cnt = org_cnt
    with nocounter, outerjoin = d1

    call sPDFRoutineLog('location_hierarchy','record')

    return (cnvtrectojson(location_hierarchy))
    call sPDFRoutineLog(build2('end sGetLocationHierarchy(',null,")"))
end ;sGetLocationHierarchy


;==========================================================================================
; Return a TRUE or FALSE if the provided OE_FIELD_VALUE_CD passes the Scheduling Location OEF
; Value validation
;
; USAGE: call sIsSchedulingValueCD(OE_FIELD_VALUE_CD) 
;==========================================================================================
subroutine sIsSchedulingValueCD(pOEFieldValueCD)
    call sPDFRoutineLog(build2('start sIsSchedulingValueCD(',pOEFieldValueCD,")"))
    declare pOEFieldValueCDValid = i2 with noconstant(0), protect
    declare i=i2 with noconstant(0), protect

    set stat = cnvtjsontorec(sSchedulingOEFieldValue(null)) 
    
    for (i=1 to scheduling_oefvalue->cnt)
        if (scheduling_oefvalue->qual[i].oe_field_value_cd = pOEFieldValueCD)
            set pOEFieldValueCDValid = 1
        endif
    endfor
    call sPDFRoutineLog(build2('->pOEFieldValueCDValid=',pOEFieldValueCDValid))
    return (pOEFieldValueCDValid)
    call sPDFRoutineLog(build2('end sIsSchedulingValueCD(',pOEFieldValueCD,")"))
end ;sIsSchedulingValueCD

;==========================================================================================
; Return a TRUE or FALSE if the requisition format is set to check for the paper referral 
; OEF field.  Uses SCHED_LOC_CHECK code value extension in custom code set.
;
; USAGE: call sCheckforPaperRequisition(REQUISITION_FORMAT_CD)
;==========================================================================================
subroutine sGetRequisitionDefinitions(null)
    call sPDFRoutineLog(build2('start sGetRequisitionDefinitions(',null,")"))
    declare i=i2 with noconstant(0), protect
    declare j=i2 with noconstant(0), protect

    record requisition_list
        (
            1 cnt = i2
            1 qual[*]
             2 code_value = f8
             2 display = vc
             2 description = vc
             2 definition = vc
             2 requisition_format_cd = f8
             2 sched_loc_check = i2
             2 orders_per_req_ind = i2
             2 rm_priority_group = i2
             2 rm_priority_oem = vc
             2 rm_type_display = vc
             2 subtype_processing = vc
             2 exclude_date_start = vc
             2 exclude_date_end = vc
        ) with protect

    select into "nl:"
    from    
         code_value cv1
        ,code_value_extension cve1
    plan cv1 
        where   cv1.code_set = bc_all_pdf_std_variables->code_set.printtopdf
        and     cv1.cdf_meaning = "REQUISITION"
        and     cv1.active_ind = 1
    join cve1   
        where   cve1.code_value = outerjoin(cv1.code_value)
    order by   
        cv1.code_value
    head cv1.code_value
        requisition_list->cnt = (requisition_list->cnt + 1)
        stat = alterlist(requisition_list->qual,requisition_list->cnt)
        requisition_list->qual[requisition_list->cnt].code_value       = cv1.code_value
        requisition_list->qual[requisition_list->cnt].display          = cv1.display
        requisition_list->qual[requisition_list->cnt].description      = cv1.description
        requisition_list->qual[requisition_list->cnt].definition       = cv1.definition
        requisition_list->qual[requisition_list->cnt].orders_per_req_ind = cv1.collation_seq
        requisition_list->qual[requisition_list->cnt].requisition_format_cd = 
                uar_get_code_by("MEANING",6002,trim(cnvtupper(cv1.description)))
    detail
        case (cve1.field_name)
            of "SCHED_LOC_CHECK":   requisition_list->qual[requisition_list->cnt].sched_loc_check = cnvtint(cve1.field_value)
            of "RM_PRIORITY_GROUP": requisition_list->qual[requisition_list->cnt].rm_priority_group = cnvtint(cve1.field_value)
            of "RM_PRIORITY_OEM": requisition_list->qual[requisition_list->cnt].rm_priority_oem = cve1.field_value
            of "RM_TYPE_DISPLAY": requisition_list->qual[requisition_list->cnt].rm_type_display = cve1.field_value
            of "SUBTYPE_PROCESSING": requisition_list->qual[requisition_list->cnt].subtype_processing = cve1.field_value
            of "EXCLUDE_DATE_START": requisition_list->qual[requisition_list->cnt].exclude_date_start = cve1.field_value
            of "EXCLUDE_DATE_END": requisition_list->qual[requisition_list->cnt].exclude_date_end = cve1.field_value
            of "SUBTYPE_PROCESSING": requisition_list->qual[requisition_list->cnt].subtype_processing = cve1.field_value
            of "SCHED_LOC_CHECK": requisition_list->qual[requisition_list->cnt].sched_loc_check = cnvtint(cve1.field_value)
        endcase
    with nocounter

    select into "nl:"
    from   
        code_value cv1
    plan cv1    
        where cv1.code_set = 6002
        and   cv1.active_ind = 1
    order by   
        cv1.code_value
    head cv1.code_value
        if (locateval(j,1,requisition_list->cnt,cv1.code_value,requisition_list->qual[j].requisition_format_cd)=0)
            requisition_list->cnt = (requisition_list->cnt + 1)
            stat = alterlist(requisition_list->qual,requisition_list->cnt)
            requisition_list->qual[requisition_list->cnt].requisition_format_cd       = cv1.code_value
            requisition_list->qual[requisition_list->cnt].display                     = cv1.display
            requisition_list->qual[requisition_list->cnt].description                 = cv1.cdf_meaning
            requisition_list->qual[requisition_list->cnt].definition                  = cv1.cdf_meaning
        endif
    with nocounter

	call sPDFRoutineLog('requisition_list','record')
    
    return (cnvtrectojson(requisition_list))
    call sPDFRoutineLog(build2('end sGetRequisitionDefinitions(',null,')'))
end ;sGetRequisitionDefinitions


;==========================================================================================
; Return a TRUE or FALSE if the requisition format is set to check for the paper referral 
; OEF field.  Uses SCHED_LOC_CHECK code value extension in custom code set.
;
; USAGE: call sCheckforPaperRequisition(REQUISITION_FORMAT_CD)
;==========================================================================================
subroutine sCheckforPaperRequisition(pRequisitionFormatCD)
    call sPDFRoutineLog(build2('start sCheckforPaperRequisition(',pRequisitionFormatCD,")"))
    declare i=i2 with noconstant(0), protect
    declare vPaperCheckInd = i2 with noconstant(0), protect

    set stat = cnvtjsontorec(sGetRequisitionDefinitions(null)) 

    call sPDFRoutineLog(build2('-requisition_list->cnt=',requisition_list->cnt))
    for (i=1 to requisition_list->cnt)
        if (requisition_list->qual[i].code_value > 0.0)
            call sPDFRoutineLog(build2('--checking description=',requisition_list->qual[i].description))
            if (requisition_list->qual[i].requisition_format_cd = pRequisitionFormatCD)
                call sPDFRoutineLog(build2('---matched pRequisitionFormatCD=',pRequisitionFormatCD))
                call sPDFRoutineLog(build2('---check sched_loc_check=',requisition_list->qual[i].sched_loc_check))
                if (requisition_list->qual[i].sched_loc_check = 1)
                    set vPaperCheckInd = 1
                endif
            endif
        endif
    endfor

    call sPDFRoutineLog(build2('-vPaperCheckInd=',vPaperCheckInd))
    return (vPaperCheckInd)
    call sPDFRoutineLog(build2('end sCheckforPaperRequisition(',pRequisitionFormatCD,')'))
end ;sCheckforPaperRequisition


;==========================================================================================
; Return a JSON object named SCHEDULING_OEFVALUE that has a list of the Scheduling Order Entry Fields
;
; USAGE: call sSchedulingOEFieldValue(null) 
;==========================================================================================
subroutine sSchedulingOEFieldValue(null)
    call sPDFRoutineLog(build2('start sSchedulingOEFieldValue(',null,")"))
    declare i=i2 with noconstant(0), protect

    record scheduling_oefvalue
        (
            1 cnt = i2
            1 qual[*]
             2 oe_field_value_cd = f8
             2 oe_field_value_display = vc
        ) with protect

    select into "nl:"
    from    
        code_value cv
    plan cv 
        where  (
                    ((cv.code_set = 100301 ) and (cv.display_key = "PRINTTOPAPER"))    
                or  ((cv.code_set = 100173 ) and (cv.display_key = "PAPERREFERRAL"))
                or  ((cv.code_set = 100173 ) and (cv.display_key = "PAPERREFERRALSEEREFERENCETEXT"))
            )
        and cv.active_ind = 1
    order by   
        cv.code_value
    head cv.code_value
        scheduling_oefvalue->cnt = (scheduling_oefvalue->cnt + 1)
        stat = alterlist(scheduling_oefvalue->qual,scheduling_oefvalue->cnt)
        scheduling_oefvalue->qual[scheduling_oefvalue->cnt].oe_field_value_cd       = cv.code_value
        scheduling_oefvalue->qual[scheduling_oefvalue->cnt].oe_field_value_display  = cv.display
    with nocounter
    
    /*
    set scheduling_oefvalue->cnt = 3
    set stat = alterlist(scheduling_oefvalue->qual,scheduling_oefvalue->cnt)

    set scheduling_oefvalue->qual[1].oe_field_value_cd = uar_get_code_by("DISPLAY_KEY",100301,"PRINTTOPAPER")
    set scheduling_oefvalue->qual[2].oe_field_value_cd = uar_get_code_by("DISPLAY_KEY",100173,"PAPERREFERRAL")
    set scheduling_oefvalue->qual[3].oe_field_value_cd = uar_get_code_by("DISPLAY_KEY",100173,"PAPERREFERRALSEEREFERENCETEXT")

    for (i=1 to scheduling_oefvalue->cnt)
        set scheduling_oefvalue->qual[i].oe_field_value_display 
            = uar_get_code_display(scheduling_oefvalue->qual[i].oe_field_value_cd)
    endfor
    */
    
	call sPDFRoutineLog('scheduling_oefvalue','record')
    return (cnvtrectojson(scheduling_oefvalue))
    call sPDFRoutineLog(build2('end sSchedulingOEFieldValue(',null,')'))
end ;sSchedulingOEFieldValue

;==========================================================================================
; Return a TRUE or FALSE if the provided OE_FIELD_ID passes the Scheduling Location OEF
; validation
;
; USAGE: call sIsSchedulingField(OE_FIELD_ID) 
;==========================================================================================
subroutine sIsSchedulingField(pOEFieldId)
    call sPDFRoutineLog(build2('start sIsSchedulingField(',pOEFieldId,")"))
    declare pOEFFieldValid = i2 with noconstant(0), protect
    declare i=i2 with noconstant(0), protect

    set stat = cnvtjsontorec(sSchedulingOEFieldID(null)) 
    
    for (i=1 to scheduling_oefid->cnt)
        if (scheduling_oefid->qual[i].oe_field_id = pOEFieldId)
            set pOEFFieldValid = 1
        endif
    endfor
    call sPDFRoutineLog(build2('->pOEFFieldValid=',pOEFFieldValid))
    return (pOEFFieldValid)
    call sPDFRoutineLog(build2('end sIsSchedulingField(',pOEFieldId,")"))
end ;sIsSchedulingField

;==========================================================================================
; Return a JSON object named SCHEDULING_OEFID that has a list of the Scheduling Order Entry Fields
;
; USAGE: call sSchedulingOEFieldID(null) 
;==========================================================================================
subroutine sSchedulingOEFieldID(null)
    call sPDFRoutineLog(build2('start sSchedulingOEFieldID(',null,")"))

    record scheduling_oefid
        (
            1 cnt = i2
            1 qual[*]
             2 oe_field_id = f8
             2 description = vc
        ) with protect

    select into "nl:"
	from 
        order_entry_fields o
	plan o
	    where o.description = "Scheduling Location"
	    and o.codeset = 100301
    detail
	   scheduling_oefid->cnt = (scheduling_oefid->cnt + 1)
       stat = alterlist(scheduling_oefid->qual,scheduling_oefid->cnt)
       scheduling_oefid->qual[scheduling_oefid->cnt].oe_field_id = o.oe_field_id
       scheduling_oefid->qual[scheduling_oefid->cnt].description = o.description
	with nocounter
 
    select into "nl:"
	from 
        order_entry_fields o
	plan o
	    where o.description = "Scheduling Locations - Non Radiology"
	    and o.codeset = 100173
    detail
	   scheduling_oefid->cnt = (scheduling_oefid->cnt + 1)
       stat = alterlist(scheduling_oefid->qual,scheduling_oefid->cnt)
       scheduling_oefid->qual[scheduling_oefid->cnt].oe_field_id = o.oe_field_id
       scheduling_oefid->qual[scheduling_oefid->cnt].description = o.description
	with nocounter
	call sPDFRoutineLog('scheduling_oefid','record')
    return (cnvtrectojson(scheduling_oefid))
    call sPDFRoutineLog(build2('end sSchedulingOEFieldID(',null,")"))
end ;sSchedulingOEFieldID

;==========================================================================================
; Return TRUE or FALSE if the current domain is a production domain determined by the doamin
; logical.
;
; USAGE: call sProductionEnvironment(null) 
;==========================================================================================
subroutine sProductionEnvironment(null)
    call sPDFRoutineLog(build2('start sProductionEnvironment(',null,")"))
    declare vProductionEnvironment = i2 with noconstant(FALSE), protect

    if (substring(1,1,cnvtupper(curdomain)) = "P")
        set vProductionEnvironment = TRUE
    endif

    return (vProductionEnvironment)
    call sPDFRoutineLog(build2('end sProductionEnvironment(',null,")"))
end ;sProductionEnvironment

;==========================================================================================
; Return URL for CAMM Media Services for specifc end points or base
; pMessage = Message to log
; pParam = if set to 'record' then the pMessage is a record structure to be echorecord
; 
; USAGE: call sPopulateRecVariables(pParam) 
; OPTIONS: pParams: store, mediaContent
;==========================================================================================
subroutine sCAMMMediaServicesBase(pParam)
    call sPDFRoutineLog(build2('start sCAMMMediaServicesBase(',pParam,")"))
    
    call sPDFRoutineLog(build2('->pParam=',pParam))

    declare sCMVBaseURL = vc with noconstant(" "), protect
    declare sCMVReturnURL = vc with noconstant(" "), protect

    if (sProductionEnvironment(null) = TRUE)
        set sCMVBaseURL = "http://phsacdea.cerncd.com/"
    else
        set sCMVBaseURL = "http://phsacdeanp.cerncd.com/"
    endif

    set sCMVBaseURL = concat(
                                 trim(sCMVBaseURL)
                                ,"camm/"
                                ,trim(cnvtlower(curdomain))
                                ,".phsa_cd.cerncd.com/service/"
                            )

    case (cnvtlower(pParam))
        of "store":         set sCMVReturnURL = concat(sCMVBaseURL,"PDF_REQUISITION/store")
        of "mediacontent":  set sCMVReturnURL = concat(sCMVBaseURL,"mediaContent/")    
        else
                            set sCMVReturnURL = sCMVBaseURL
    endcase
    call sPDFRoutineLog(build2('->sCMVBaseURL=',sCMVBaseURL))
    call sPDFRoutineLog(build2('->sCMVReturnURL=',sCMVReturnURL))
    return (sCMVReturnURL)
    call sPDFRoutineLog(build2('end sCAMMMediaServicesBase(',pParam,")"))
end ;sCAMMMediaServicesBase


;==========================================================================================
; Capture and report logging for debug and testing
; pMessage = Message to log
; pParam = if set to 'record' then the pMessage is a record structure to be echorecord
; 
; USAGE: call sPDFRoutineLog("record_structure","RECORD") 
;        call sPDFRoutineLog("Log Message") 
;==========================================================================================
subroutine sPDFRoutineLog(pMessage,pParam)
    declare vMessage = vc with constant(pMessage), protect
    declare vParam = vc with constant(pParam), protect
    declare vEchoParser = vc with noconstant(" "), protect

    if (sPDFRoutineDebug(0)) ;check to make sure debug is on first
        if (cnvtupper(vParam) = cnvtupper('RECORD')) ;check to see if the message is actually a record structure
            set vEchoParser = concat(^call echorecord(^,trim(vMessage),^) go^)
            call echo(trim(vEchoParser))
            call parser(vEchoParser)
        else
            call echo(trim(vMessage))
        endif
    endif
end ;sPDFRoutineLog


;==========================================================================================
; Check if the debug_ind variable is defined and set to 1 to turn on echos
; 
; USAGE: set DEBUG = sPDFRoutineDebug(null)
;==========================================================================================
subroutine sPDFRoutineDebug(null)
    declare pDebugVar = f8 with noconstant(FALSE), protect

    if (validate(debug_ind))
        if (debug_ind > 0)
            set pDebugVar = TRUE
        endif
    endif
    return (pDebugVar)
end ;sPDFRoutineDebug


;==========================================================================================
; Complete the bc_all_pdf_std_variables record structure.  This subroutine is executed with
; bc_all_pdf_std_routines by default and sets up variables to be used in the calling scripts
;
; USAGE: call sPopulateRecVariables(null)
;==========================================================================================
subroutine sPopulateRecVariables(null)
    call sPDFRoutineLog(build2('start sPopulateRecVariables(',null,")"))
    set bc_all_pdf_std_variables->code_set.printtopdf = sPrinttoPDFCodeSet(null)
    set bc_all_pdf_std_variables->domain.production_ind = sProductionEnvironment(null)
    set bc_all_pdf_std_variables->urls.camm_base = sCAMMMediaServicesBase()
    set bc_all_pdf_std_variables->urls.camm_store = sCAMMMediaServicesBase('store')
    set bc_all_pdf_std_variables->urls.camm_content = sCAMMMediaServicesBase('mediaContent')
    set bc_all_pdf_std_variables->status_data.status = "S"
    
    call sPDFRoutineLog('bc_all_pdf_std_variables','record')
    call sPDFRoutineLog(build2('end sPopulateRecVariables(',null,")"))
end ;sPopulateRecVariables


;==========================================================================================
; Find and return the Print-to-PDF custom code set number
;
; USAGE: set CODE_SET = sPrinttoPDFCodeSet(null)
;==========================================================================================
subroutine sPrinttoPDFCodeSet(null)
    call sPDFRoutineLog(build2('start sPrinttoPDFCodeSet(',null,")"))
    declare sprinttopdfCS = f8 with noconstant(0.0), protect
    select into "nl:"
	from
		code_value_set cvs
	plan cvs
		where cvs.definition = "PRINTTOPDF"
		and   cvs.code_set > 0.0
	order by
		 cvs.updt_dt_tm desc
		,cvs.code_set
	head report
		stat = 0
	head cvs.code_set
		sprinttopdfCS = cvs.code_set
	with nocounter
    call sPDFRoutineLog(build2('->sprinttopdfCS=',sprinttopdfCS))
    call sPDFRoutineLog(build2('end sPrinttoPDFCodeSet(',null,")"))
    return (sprinttopdfCS)
end ;sPrinttoPDFCodeSet

;==========================================================================================
; Determine if the script is considered a development script.  Used to validate patients
; when running in development mode
;
; USAGE: call sIsDevelopmentMode('SCRIPT NAME')
;==========================================================================================
subroutine sIsDevelopmentMode(pScript)
    call sPDFRoutineLog(build2('start sIsDevelopmentMode(',trim(pScript),")"))
    declare sDevelopmentInd = i2 with noconstant(FALSE), protect
    call sPDFRoutineLog(build2('->pScript=',pScript))
    if (cnvtlower(pScript) in(
                         ^pfmt_dev_print_to_pdf_req^
                        ,^pfmt_dev_s_print_to_pdf_req^
                        ,^eks_call_compile^
                    )           )
        set sDevelopmentInd = TRUE
    endif
    call sPDFRoutineLog(build2('->sDevelopmentInd=',sDevelopmentInd))
    call sPDFRoutineLog(build2('end sIsDevelopmentMode(',trim(pScript),")"))
    return (sDevelopmentInd)
end ;sIsDevelopmentMode

;==========================================================================================
; Determine if the patient is valid patient for processing.  This does not reference
; encounter location and is only used to validate by name for development processing.  
;
; USAGE: set VALID = sValidatePatient(person_id) 
; 
; Print-to-PDF Code Set: 
;   Requires as least one active code value with the following CDF
;   meaning and Description to process: VALIDATION, LAST_NAME; VALIDATION, FIRST_NAME
;   The Definition of each code value will be used to match the patient name.  If both the 
;   first and last name of the patient match (wildards acceptable) and the current script is
;   a development script the patient is valid.  If the script is not a development script and the
;   name matches the patient is not marked as valid.  
; 
;==========================================================================================
subroutine sValidatePatient(pPersonId)
    call sPDFRoutineLog(build2('start sValidatePatient(',trim(cnvtstring(pPersonId)),")"))
    ;set the patient to valid by default
    declare sValidPatientInd = i2 with noconstant(TRUE), protect

    ;variables used to determine if the patient name matches the development definition
    declare vDevLastNameMath = i2 with noconstant(0), protect
    declare vDevFirstNameMath = i2 with noconstant(0), protect

    ;record structure to hold the development patient name details
    record temp_patient
        (
            1 current_first_name = vc
            1 current_last_name = vc
            1 last_name[*]
                2 value = vc
            1 first_name[*]
                2 value = vc
        ) with protect

    declare d1seq = i4 with noconstant(0), protect

    call sPDFRoutineLog(build2('pPersonId=',pPersonId))
    call sPDFRoutineLog(build2('sProductionEnvironment(null)=',sProductionEnvironment(null)))
    if (sProductionEnvironment(null) = FALSE)
        ;script is running in a non-production environment, get development patient definitions
        set stat = initrec(temp_patient)
        select into "nl:"
        from
            code_value cv
        plan cv 
            where cv.code_set = bc_all_pdf_std_variables->code_set.printtopdf
            and   cv.cdf_meaning in(^VALIDATION^)
            and   cv.description in(
                                         ^LAST_NAME^
                                        ,^FIRST_NAME^
                                    )
            and   cv.active_ind = 1
        order by
             cv.description
            ,cv.code_value
        head report
            i = 0
            j = 0
            macro (AddLastName)
                j = (j + 1)
                stat = alterlist(temp_patient->last_name,j)
                temp_patient->last_name[j].value = cv.definition
            endmacro

            macro (AddFirstName)
                i = (i + 1)
                stat = alterlist(temp_patient->first_name,i)
                temp_patient->first_name[i].value = cv.definition
            endmacro
        detail  
            case (cv.description)  
                of ^FIRST_NAME^:    AddFirstName
                of ^LAST_NAME^:     AddLastName
            endcase
        with nocounter

        if ((size(temp_patient->last_name,5) = 0) or (size(temp_patient->first_name,5) = 0))  
            call sPDFRoutineLog(build2('->no validation patient definitions found'))  
            call sPDFRoutineLog(build2('end sValidatePatient(',trim(cnvtstring(pPersonId)),")"))
            return (sValidPatientInd)
        endif

        ;Pull in name from the database based on the person_id
        select into "nl:"
        from    
            person p
        plan p
            where p.person_id = pPersonId
        detail
            temp_patient->current_first_name = p.name_first_key
            temp_patient->current_last_name = p.name_last_key
        with nocounter

        ;determine if the last name matches one of the defined valiation patients
        select into "nl:"
        from
             (dummyt d1 with seq=size(temp_patient->last_name,5))
        plan d1
            where initarray(d1seq,d1.seq)
            and   operator(temp_patient->current_last_name,"LIKE",notrim(patstring(temp_patient->last_name[d1.seq].value,0)))
        detail
              vDevLastNameMath = TRUE
            call sPDFRoutineLog(build2('->last_name match=',temp_patient->last_name[d1.seq].value))
        with nocounter

        ;determine if the first name matches one of the defined valiation patients
        select into "nl:"
        from
             (dummyt d1 with seq=size(temp_patient->first_name,5))
        plan d1
            where initarray(d1seq,d1.seq)
            and   operator(temp_patient->current_first_name,"LIKE",notrim(patstring(temp_patient->first_name[d1.seq].value,0)))
        detail  
            vDevFirstNameMath = TRUE
            call sPDFRoutineLog(build2('->first_name match=',temp_patient->first_name[d1.seq].value))
        with nocounter

        call sPDFRoutineLog(build2('->vDevFirstNameMath=',vDevFirstNameMath))
        call sPDFRoutineLog(build2('->vDevLastNameMath=',vDevLastNameMath))

        if (sIsDevelopmentMode(CURPROG) = TRUE)
            if ((vDevFirstNameMath = FALSE) or (vDevLastNameMath = FALSE))
                set sValidPatientInd = FALSE
            endif
        else
            if ((vDevFirstNameMath = TRUE) and (vDevLastNameMath = TRUE))
                set sValidPatientInd = FALSE
            endif
        endif
        call sPDFRoutineLog('temp_patient','record')
    endif ;sProductionEnvironment = FALSE
    call sPDFRoutineLog(build2('->sValidPatientInd=',sValidPatientInd))
    call sPDFRoutineLog(build2('end sValidatePatient(',trim(cnvtstring(pPersonId)),")"))
    return (sValidPatientInd)
end ;sValidatePatient

end
go