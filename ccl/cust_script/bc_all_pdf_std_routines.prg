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
) with protect, persist

declare sIsDevelopmentMode(pScript=vc) = i2 with copy, persist
declare sValidatePatient(pPersonId=f8) = i2 with copy, persist
declare sPrinttoPDFCodeSet(null) = f8 with copy, persist
declare sPopulateRecVariables(null) = null with copy, persist
declare sPDFRoutineDebug(null) = i2 with copy, persist
declare sProductionEnvironment(null) = i2 with copy, persist
declare sPDFRoutineLog(pMessage=vc,pParam=vc(value,'message')) = null with copy, persist
declare sCAMMMediaServicesBase(pParam=vc(value,'mediaContent')) = vc with copy, persist

call sPopulateRecVariables(null)


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
    free record temp_patient
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