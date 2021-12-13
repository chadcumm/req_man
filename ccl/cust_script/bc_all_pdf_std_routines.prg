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
) with protect, persist

declare sIsDevelopmentMode(pScript=vc) = i2 with copy, persist
declare sValidatePatient(pPersonId=f8) = i2 with copy, persist
declare sPrinttoPDFCodeSet(null) = f8 with copy, persist
declare sPopulateRecVariables(null) = null with copy, persist
declare sPDFRoutineDebug(null) = i2 with copy, persist
declare sPDFRoutineLog(pMessage=vc,pParam=vc(value,'message')) = null with copy, persist

call sPopulateRecVariables(null)

;==========================================================================================
; Capture and reporting logging for debug and testing
; pMessage = Message to log
; pParam = if set to 'record' then the pMessage is a record structure to be echorecord
;==========================================================================================
subroutine sPDFRoutineLog(pMessage,pParam)
    declare vMessage = vc with constant(pMessage), protect
    declare vParam = vc with constant(pParam), protect
    declare vEchoParser = vc with noconstant(" "), protect

    if (sPDFRoutineDebug(0))
        if (cnvtupper(vParam) = cnvtupper('RECORD'))
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
; bc_all_pdf_std_routines by default
;==========================================================================================
subroutine sPopulateRecVariables(null)
    call sPDFRoutineLog(build2('start sPopulateRecVariables(',null,")"))
    set bc_all_pdf_std_variables->code_set.printtopdf = sPrinttoPDFCodeSet(null)

    call sPDFRoutineLog('bc_all_pdf_std_variables','record')
    call sPDFRoutineLog(build2('end sPopulateRecVariables(',null,")"))
end ;sPopulateRecVariables


;==========================================================================================
; Find and return the Print-to-PDF custom code set number
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
; encounter location and is only used to validate by name for development processing
; Print-to-PDF Code Set: 
; Reserved Variables Using Discern Explorer https://wiki.cerner.com/x/qx9kAQ
;==========================================================================================
subroutine sValidatePatient(pPersonId)
    call sPDFRoutineLog(build2('start sValidatePatient(',trim(cnvtstring(pPersonId)),")"))
    ;set the patient to valid by default
    declare sValidPatientInd = i2 with noconstant(TRUE), protect
    ;used to determine if script is running in a production domain.  Non-production domains will check for development patients
    declare sProductionEnvironment = i2 with noconstant(FALSE), protect
    ;record structure to hold the development patient name details
    free record temp_patient
    record temp_patient
        (
            1 last_name[*]
            2 value = vc
            1 first_name[*]
            2 value = vc
        ) with protect

    if (substring(1,1,cnvtupper(curdomain)) = "P")
        set sProductionEnvironment = TRUE
    endif
    call sPDFRoutineLog(build2('pPersonId=',pPersonId))
    call sPDFRoutineLog(build2('sProductionEnvironment=',sProductionEnvironment))
    if (sProductionEnvironment = FALSE)
        ;script is running in a non-production environment, check if script should considered development patients
        if (sIsDevelopmentMode(CURPROG) = TRUE)
            ;script is in development mode, get development patient definitions
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
            call sPDFRoutineLog('temp_patient','record')
        endif
    endif
    call sPDFRoutineLog(build2('end sValidatePatient(',trim(cnvtstring(pPersonId)),")"))
    return (sValidPatientInd)
end ;sValidatePatient


end
go