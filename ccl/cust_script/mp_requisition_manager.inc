DECLARE addcodetolist ((p1 = f8 (val ) ) ,(p2 = vc (ref ) ) ) = null WITH protect
DECLARE addpersonneltolist ((p1 = f8 (val ) ) ,(p2 = vc (ref ) ) ) = null WITH protect
DECLARE addpersonneltolistwithdate ((p1 = f8 (val ) ) ,(p2 = vc (ref ) ) ,(p3 = f8 (val ) ) ) = null WITH protect
DECLARE addphonestolist ((p1 = f8 (val ) ) ,(p2 = vc (ref ) ) ) = null WITH protect
DECLARE putjsonrecordtofile ((p1 = vc (ref ) ) ) = null WITH protect
DECLARE putstringtofile ((p1 = vc (val ) ) ) = null WITH protect
DECLARE outputcodelist ((p1 = vc (ref ) ) ) = null WITH protect
DECLARE outputpersonnellist ((p1 = vc (ref ) ) ) = null WITH protect
DECLARE outputphonelist ((p1 = vc (ref ) ) ,(p2 = vc (ref ) ) ) = null WITH protect
DECLARE getparametervalues ((p1 = i4 (val ) ) ,(p2 = vc (ref ) ) ) = null WITH protect
DECLARE getlookbackdatebytype ((p1 = i4 (val ) ) ,(p2 = i4 (val ) ) ) = dq8 WITH protect
DECLARE getcodevaluesfromcodeset ((p1 = vc (ref ) ) ,(p2 = vc (ref ) ) ) = null WITH protect
DECLARE geteventsetnamesfromeventsetcds ((p1 = vc (ref ) ) ,(p2 = vc (ref ) ) ) = null WITH protect
DECLARE returnviewertype ((p1 = f8 (val ) ) ,(p2 = f8 (val ) ) ) = vc WITH protect
DECLARE cnvtisodttmtodq8 ((p1 = vc ) ) = dq8 WITH protect
DECLARE cnvtdq8toisodttm ((p1 = f8 ) ) = vc WITH protect
DECLARE getorgsecurityflag (null ) = i2 WITH protect
DECLARE getcomporgsecurityflag ((p1 = vc (val ) ) ) = i2 WITH protect
DECLARE populateauthorizedorganizations ((p1 = f8 (val ) ) ,(p2 = vc (ref ) ) ) = null WITH protect
DECLARE getuserlogicaldomain ((p1 = f8 ) ) = f8 WITH protect
DECLARE getpersonneloverride ((ppr_cd = f8 (val ) ) ) = i2 WITH protect
DECLARE cclimpersonation (null ) = null WITH protect
DECLARE error_message ((logstatusblockind = i2 ) ) = i2
DECLARE check_log_level ((arg_log_level = i4 ) ) = i2
DECLARE getbedrocksettings ((parentid = f8 ) ) = null WITH protect
DECLARE generatestaticcontentreqs (null ) = null WITH protect
DECLARE generatepagehtml (null ) = vc WITH protect
DECLARE checkcriterion (null ) = null WITH protect
DECLARE gatherlocations ((persid = f8 ) ) = null WITH protect ,copy
DECLARE gatheruserprefs ((prsnl_id = f8 ) ,(pref_id = vc ) ) = null WITH protect ,copy
DECLARE gatherviewprefs ((poscd = f8 ) ) = null WITH protect ,copy
DECLARE getlocaledata (null ) = null WITH protect
DECLARE error_and_zero_check ((qualnum = i4 ) ,(opname = vc ) ,(logmsg = vc ) ,(errorforceexit = i2) ,(zeroforceexit = i2 ) ) = i2
DECLARE error_and_zero_check_rec ((qualnum = i4 ) ,(opname = vc ) ,(logmsg = vc )
	,(errorforceexit = i2 ) ,(zeroforceexit = i2 ) ,(recorddata = vc (ref ) ) ) = i2
DECLARE populate_subeventstatus_rec ((operationname = vc (value ) ) ,(operationstatus = vc (value ))
	,(targetobjectname = vc (value ) ) ,(targetobjectvalue = vc (value ) ) ,(recorddata = vc (ref )) ) = i2
DECLARE populate_subeventstatus ((operationname = vc (value ) ) ,(operationstatus = vc (value ) )
	,(targetobjectname = vc (value ) ) ,(targetobjectvalue = vc (value ) ) ) = i2
DECLARE populate_subeventstatus_msg ((operationname = vc (value ) ) ,(operationstatus = vc (value ))
	,(targetobjectname = vc (value ) ) ,(targetobjectvalue = vc (value ) ) ,(loglevel = i2 (value )) ) = i2
 
SUBROUTINE  populate_subeventstatus_msg (operationname ,operationstatus ,targetobjectname ,targetobjectvalue ,loglevel )
  CALL populate_subeventstatus (operationname ,operationstatus ,targetobjectname ,targetobjectvalue)
  CALL log_message (targetobjectvalue ,loglevel )
END ;Subroutine
 
SUBROUTINE  check_log_level (arg_log_level )
  IF ((((crsl_msg_level >= arg_log_level ) ) OR ((log_override_ind = 1 ) )) )
   RETURN (1 )
  ELSE
   RETURN (0 )
  ENDIF
END ;Subroutine
 
SUBROUTINE  populate_subeventstatus (operationname ,operationstatus ,targetobjectname , targetobjectvalue )
  CALL populate_subeventstatus_rec (operationname ,operationstatus ,targetobjectname , targetobjectvalue ,reply )
END ;Subroutine
 
SUBROUTINE  populate_subeventstatus_rec (operationname ,operationstatus ,targetobjectname ,
  targetobjectvalue ,recorddata )
  IF ((validate (recorddata->status_data.status ,"-1" ) != "-1" ) )
   SET lcrslsubeventcnt = size (recorddata->status_data.subeventstatus ,5 )
   SET lcrslsubeventsize = size (trim (recorddata->status_data.subeventstatus[lcrslsubeventcnt ].
     operationname ) )
   SET lcrslsubeventsize = (lcrslsubeventsize + size (trim (recorddata->status_data.subeventstatus[
     lcrslsubeventcnt ].operationstatus ) ) )
   SET lcrslsubeventsize = (lcrslsubeventsize + size (trim (recorddata->status_data.subeventstatus[
     lcrslsubeventcnt ].targetobjectname ) ) )
   SET lcrslsubeventsize = (lcrslsubeventsize + size (trim (recorddata->status_data.subeventstatus[
     lcrslsubeventcnt ].targetobjectvalue ) ) )
   IF ((lcrslsubeventsize > 0 ) )
    SET lcrslsubeventcnt = (lcrslsubeventcnt + 1 )
    SET icrslloggingstat = alter (recorddata->status_data.subeventstatus ,lcrslsubeventcnt )
   ENDIF
   SET recorddata->status_data.subeventstatus[lcrslsubeventcnt ].operationname = substring (1 ,25 ,
    operationname )
   SET recorddata->status_data.subeventstatus[lcrslsubeventcnt ].operationstatus = substring (1 ,1 ,
    operationstatus )
   SET recorddata->status_data.subeventstatus[lcrslsubeventcnt ].targetobjectname = substring (1 ,25
    ,targetobjectname )
   SET recorddata->status_data.subeventstatus[lcrslsubeventcnt ].targetobjectvalue =
   targetobjectvalue
  ENDIF
END ;Subroutine
 
SUBROUTINE  error_and_zero_check (qualnum ,opname ,logmsg ,errorforceexit ,zeroforceexit )
  RETURN (error_and_zero_check_rec (qualnum ,opname ,logmsg ,errorforceexit ,zeroforceexit ,reply ) )
END ;Subroutine
 
SUBROUTINE  error_and_zero_check_rec (qualnum ,opname ,logmsg ,errorforceexit ,zeroforceexit ,
  recorddata )
  SET icrslerroroccured = 0
  SET ierrcode = error (serrmsg ,0 )
  WHILE ((ierrcode > 0 ) )
   SET icrslerroroccured = 1
   CALL log_message (serrmsg ,log_level_audit )
   CALL populate_subeventstatus_rec (opname ,"F" ,serrmsg ,logmsg ,recorddata )
   SET ierrcode = error (serrmsg ,0 )
  ENDWHILE
  IF ((icrslerroroccured = 1 )
  AND (errorforceexit = 1 ) )
   SET recorddata->status_data.status = "F"
   GO TO exit_script
  ENDIF
  IF ((qualnum = 0 )
  AND (zeroforceexit = 1 ) )
   SET recorddata->status_data.status = "Z"
   CALL populate_subeventstatus_rec (opname ,"Z" ,"No records qualified" ,logmsg ,recorddata )
   GO TO exit_script
  ENDIF
  RETURN (icrslerroroccured )
END ;Subroutine
 
SUBROUTINE  addcodetolist (code_value ,record_data )
  IF ((code_value != 0 ) )
   IF ((((codelistcnt = 0 ) ) OR ((locateval (code_idx ,1 ,codelistcnt ,code_value ,record_data->
    codes[code_idx ].code ) <= 0 ) )) )
    SET codelistcnt = (codelistcnt + 1 )
    SET stat = alterlist (record_data->codes ,codelistcnt )
    SET record_data->codes[codelistcnt ].code = code_value
    SET record_data->codes[codelistcnt ].sequence = uar_get_collation_seq (code_value )
    SET record_data->codes[codelistcnt ].meaning = uar_get_code_meaning (code_value )
    SET record_data->codes[codelistcnt ].display = uar_get_code_display (code_value )
    SET record_data->codes[codelistcnt ].description = uar_get_code_description (code_value )
    SET record_data->codes[codelistcnt ].code_set = uar_get_code_set (code_value )
   ENDIF
  ENDIF
END ;Subroutine
 
SUBROUTINE  outputcodelist (record_data )
  CALL log_message ("In OutputCodeList() @deprecated" ,log_level_debug )
END ;Subroutine
 
SUBROUTINE  addpersonneltolist (prsnl_id ,record_data )
  CALL addpersonneltolistwithdate (prsnl_id ,record_data ,current_date_time )
END ;Subroutine
 
 
SUBROUTINE  addpersonneltolistwithdate (prsnl_id ,record_data ,active_date )
  DECLARE personnel_cd = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,213 ,"PRSNL" ) )
  IF ((((active_date = null ) ) OR ((active_date = 0.0 ) )) )
   SET active_date = current_date_time
  ENDIF
  IF ((prsnl_id != 0 ) )
   IF ((((prsnllistcnt = 0 ) ) OR ((locateval (prsnl_idx ,1 ,prsnllistcnt ,prsnl_id ,record_data->
    prsnl[prsnl_idx ].id ,active_date ,record_data->prsnl[prsnl_idx ].active_date ) <= 0 ) )) )
    SET prsnllistcnt = (prsnllistcnt + 1 )
    IF ((prsnllistcnt > size (record_data->prsnl ,5 ) ) )
     SET stat = alterlist (record_data->prsnl ,(prsnllistcnt + 9 ) )
    ENDIF
    SET record_data->prsnl[prsnllistcnt ].id = prsnl_id
    IF ((validate (record_data->prsnl[prsnllistcnt ].active_date ) != 0 ) )
     SET record_data->prsnl[prsnllistcnt ].active_date = active_date
    ENDIF
   ENDIF
  ENDIF
END ;Subroutine
 
SUBROUTINE  outputpersonnellist (report_data )
  CALL log_message ("In OutputPersonnelList()" ,log_level_debug )
  DECLARE begin_date_time = dq8 WITH constant (cnvtdatetime (curdate ,curtime3 ) ) ,private
  DECLARE prsnl_name_type_cd = f8 WITH constant (uar_get_code_by ("MEANING" ,213 ,"PRSNL" ) ) , protect
  DECLARE active_date_ind = i2 WITH protect ,noconstant (0 )
  DECLARE filteredcnt = i4 WITH protect ,noconstant (0 )
  DECLARE prsnl_seq = i4 WITH protect ,noconstant (0 )
  DECLARE idx = i4 WITH protect ,noconstant (0 )
  IF ((prsnllistcnt > 0 ) )
   SELECT INTO "nl:"
    FROM (prsnl p ),
     (left
     JOIN person_name pn ON (pn.person_id = p.person_id )
     AND (pn.name_type_cd = prsnl_name_type_cd )
     AND (pn.active_ind = 1 ) )
    PLAN (p
     WHERE expand (idx ,1 ,size (report_data->prsnl ,5 ) ,p.person_id ,report_data->prsnl[idx ].id )
     )
     JOIN (pn )
    ORDER BY p.person_id ,
     pn.end_effective_dt_tm DESC
    HEAD REPORT
     prsnl_seq = 0 ,
     active_date_ind = validate (report_data->prsnl[1 ].active_date ,0 )
    HEAD p.person_id
     IF ((active_date_ind = 0 ) ) prsnl_seq = locateval (idx ,1 ,prsnllistcnt ,p.person_id ,
       report_data->prsnl[idx ].id ) ,
      IF ((pn.person_id > 0 ) ) report_data->prsnl[prsnl_seq ].provider_name.name_full = trim (pn
        .name_full ,3 ) ,report_data->prsnl[prsnl_seq ].provider_name.name_first = trim (pn
        .name_first ,3 ) ,report_data->prsnl[prsnl_seq ].provider_name.name_middle = trim (pn
        .name_middle ,3 ) ,report_data->prsnl[prsnl_seq ].provider_name.name_last = trim (pn
        .name_last ,3 ) ,report_data->prsnl[prsnl_seq ].provider_name.username = trim (p.username ,3
        ) ,report_data->prsnl[prsnl_seq ].provider_name.initials = trim (pn.name_initials ,3 ) ,
       report_data->prsnl[prsnl_seq ].provider_name.title = trim (pn.name_initials ,3 )
      ELSE report_data->prsnl[prsnl_seq ].provider_name.name_full = trim (p.name_full_formatted ,3 )
      ,report_data->prsnl[prsnl_seq ].provider_name.name_first = trim (p.name_first ,3 ) ,report_data
       ->prsnl[prsnl_seq ].provider_name.name_last = trim (p.name_last ,3 ) ,report_data->prsnl[
       prsnl_seq ].provider_name.username = trim (p.username ,3 )
      ENDIF
     ENDIF
    DETAIL
     IF ((active_date_ind != 0 ) ) prsnl_seq = locateval (idx ,1 ,prsnllistcnt ,p.person_id ,
       report_data->prsnl[idx ].id ) ,
      WHILE ((prsnl_seq > 0 ) )
       IF ((report_data->prsnl[prsnl_seq ].active_date BETWEEN pn.beg_effective_dt_tm AND pn
       .end_effective_dt_tm ) )
        IF ((pn.person_id > 0 ) ) report_data->prsnl[prsnl_seq ].person_name_id = pn.person_name_id ,
         report_data->prsnl[prsnl_seq ].beg_effective_dt_tm = pn.beg_effective_dt_tm ,report_data->
         prsnl[prsnl_seq ].end_effective_dt_tm = pn.end_effective_dt_tm ,report_data->prsnl[
         prsnl_seq ].provider_name.name_full = trim (pn.name_full ,3 ) ,report_data->prsnl[prsnl_seq
         ].provider_name.name_first = trim (pn.name_first ,3 ) ,report_data->prsnl[prsnl_seq ].
         provider_name.name_middle = trim (pn.name_middle ,3 ) ,report_data->prsnl[prsnl_seq ].
         provider_name.name_last = trim (pn.name_last ,3 ) ,report_data->prsnl[prsnl_seq ].
         provider_name.username = trim (p.username ,3 ) ,report_data->prsnl[prsnl_seq ].provider_name
         .initials = trim (pn.name_initials ,3 ) ,report_data->prsnl[prsnl_seq ].provider_name.title
         = trim (pn.name_initials ,3 )
        ELSE report_data->prsnl[prsnl_seq ].provider_name.name_full = trim (p.name_full_formatted ,3
          ) ,report_data->prsnl[prsnl_seq ].provider_name.name_first = trim (p.name_first ,3 ) ,
         report_data->prsnl[prsnl_seq ].provider_name.name_last = trim (pn.name_last ,3 ) ,
         report_data->prsnl[prsnl_seq ].provider_name.username = trim (p.username ,3 )
        ENDIF
        ,
        IF ((report_data->prsnl[prsnl_seq ].active_date = current_date_time ) ) report_data->prsnl[
         prsnl_seq ].active_date = 0
        ENDIF
       ENDIF
       ,prsnl_seq = locateval (idx ,(prsnl_seq + 1 ) ,prsnllistcnt ,p.person_id ,report_data->prsnl[
        idx ].id )
      ENDWHILE
     ENDIF
    FOOT REPORT
     stat = alterlist (report_data->prsnl ,prsnllistcnt )
    WITH nocounter
   ;end select
   CALL error_and_zero_check_rec (curqual ,"PRSNL" ,"OutputPersonnelList" ,1 ,0 ,report_data )
   IF ((active_date_ind != 0 ) )
    SELECT INTO "nl:"
     end_effective_dt_tm = report_data->prsnl[d.seq ].end_effective_dt_tm ,
     person_name_id = report_data->prsnl[d.seq ].person_name_id ,
     prsnl_id = report_data->prsnl[d.seq ].id
     FROM (dummyt d WITH seq = size (report_data->prsnl ,5 ) )
     ORDER BY end_effective_dt_tm DESC ,
      person_name_id ,
      prsnl_id
     HEAD REPORT
      filteredcnt = 0 ,
      idx = size (report_data->prsnl ,5 ) ,
      stat = alterlist (report_data->prsnl ,(idx * 2 ) )
     HEAD end_effective_dt_tm
      donothing = 0
     HEAD prsnl_id
      idx = (idx + 1 ) ,filteredcnt = (filteredcnt + 1 ) ,report_data->prsnl[idx ].id = report_data->
      prsnl[d.seq ].id ,report_data->prsnl[idx ].person_name_id = report_data->prsnl[d.seq ].
      person_name_id ,
      IF ((report_data->prsnl[d.seq ].person_name_id > 0.0 ) ) report_data->prsnl[idx ].
       beg_effective_dt_tm = report_data->prsnl[d.seq ].beg_effective_dt_tm ,report_data->prsnl[idx ]
       .end_effective_dt_tm = report_data->prsnl[d.seq ].end_effective_dt_tm
      ELSE report_data->prsnl[idx ].beg_effective_dt_tm = cnvtdatetime ("01-JAN-1900" ) ,report_data
       ->prsnl[idx ].end_effective_dt_tm = cnvtdatetime ("31-DEC-2100" )
      ENDIF
      ,report_data->prsnl[idx ].provider_name.name_full = report_data->prsnl[d.seq ].provider_name.
      name_full ,report_data->prsnl[idx ].provider_name.name_first = report_data->prsnl[d.seq ].
      provider_name.name_first ,report_data->prsnl[idx ].provider_name.name_middle = report_data->
      prsnl[d.seq ].provider_name.name_middle ,report_data->prsnl[idx ].provider_name.name_last =
      report_data->prsnl[d.seq ].provider_name.name_last ,report_data->prsnl[idx ].provider_name.
      username = report_data->prsnl[d.seq ].provider_name.username ,report_data->prsnl[idx ].
      provider_name.initials = report_data->prsnl[d.seq ].provider_name.initials ,report_data->prsnl[
      idx ].provider_name.title = report_data->prsnl[d.seq ].provider_name.title
     FOOT REPORT
      stat = alterlist (report_data->prsnl ,idx ) ,
      stat = alterlist (report_data->prsnl ,filteredcnt ,0 )
     WITH nocounter
    ;end select
    CALL error_and_zero_check_rec (curqual ,"PRSNL" ,"FilterPersonnelList" ,1 ,0 ,report_data )
   ENDIF
  ENDIF
  CALL log_message (build ("Exit OutputPersonnelList(), Elapsed time in seconds:" ,datetimediff (
     cnvtdatetime (curdate ,curtime3 ) ,begin_date_time ,5 ) ) ,log_level_debug )
END ;Subroutine
 
SUBROUTINE  addphonestolist (prsnl_id ,record_data )
  IF ((prsnl_id != 0 ) )
   IF ((((phonelistcnt = 0 ) ) OR ((locateval (phone_idx ,1 ,phonelistcnt ,prsnl_id ,record_data->
    phone_list[prsnl_idx ].person_id ) <= 0 ) )) )
    SET phonelistcnt = (phonelistcnt + 1 )
    IF ((phonelistcnt > size (record_data->phone_list ,5 ) ) )
     SET stat = alterlist (record_data->phone_list ,(phonelistcnt + 9 ) )
    ENDIF
    SET record_data->phone_list[phonelistcnt ].person_id = prsnl_id
    SET prsnl_cnt = (prsnl_cnt + 1 )
   ENDIF
  ENDIF
END ;Subroutine
 
SUBROUTINE  outputphonelist (report_data ,phone_types )
  CALL log_message ("In OutputPhoneList()" ,log_level_debug )
  DECLARE begin_date_time = dq8 WITH constant (cnvtdatetime (curdate ,curtime3 ) ) ,private
  DECLARE personcnt = i4 WITH protect ,constant (size (report_data->phone_list ,5 ) )
  DECLARE idx = i4 WITH protect ,noconstant (0 )
  DECLARE idx2 = i4 WITH protect ,noconstant (0 )
  DECLARE idx3 = i4 WITH protect ,noconstant (0 )
  DECLARE phonecnt = i4 WITH protect ,noconstant (0 )
  DECLARE prsnlidx = i4 WITH protect ,noconstant (0 )
  IF ((phonelistcnt > 0 ) )
   SELECT
    IF ((size (phone_types->phone_codes ,5 ) = 0 ) )
     phone_sorter = ph.phone_id
     FROM (phone ph )
     WHERE expand (idx ,1 ,personcnt ,ph.parent_entity_id ,report_data->phone_list[idx ].person_id )
     AND (ph.parent_entity_name = "PERSON" )
     AND (ph.beg_effective_dt_tm <= cnvtdatetime (curdate ,curtime3 ) )
     AND (ph.end_effective_dt_tm >= cnvtdatetime (curdate ,curtime3 ) )
     AND (ph.active_ind = 1 )
     AND (ph.phone_type_seq = 1 )
     ORDER BY ph.parent_entity_id ,
      phone_sorter
    ELSE
     phone_sorter = locateval (idx2 ,1 ,size (phone_types->phone_codes ,5 ) ,ph.phone_type_cd ,
      phone_types->phone_codes[idx2 ].phone_cd )
     FROM (phone ph )
     WHERE expand (idx ,1 ,personcnt ,ph.parent_entity_id ,report_data->phone_list[idx ].person_id )
     AND (ph.parent_entity_name = "PERSON" )
     AND (ph.beg_effective_dt_tm <= cnvtdatetime (curdate ,curtime3 ) )
     AND (ph.end_effective_dt_tm >= cnvtdatetime (curdate ,curtime3 ) )
     AND (ph.active_ind = 1 )
     AND expand (idx2 ,1 ,size (phone_types->phone_codes ,5 ) ,ph.phone_type_cd ,phone_types->
      phone_codes[idx2 ].phone_cd )
     AND (ph.phone_type_seq = 1 )
     ORDER BY ph.parent_entity_id ,
      phone_sorter
    ENDIF
    INTO "nl:"
    HEAD ph.parent_entity_id
     phonecnt = 0 ,prsnlidx = locateval (idx3 ,1 ,personcnt ,ph.parent_entity_id ,report_data->
      phone_list[idx3 ].person_id )
    HEAD phone_sorter
     phonecnt = (phonecnt + 1 ) ,
     IF ((size (report_data->phone_list[prsnlidx ].phones ,5 ) < phonecnt ) ) stat = alterlist (
       report_data->phone_list[prsnlidx ].phones ,(phonecnt + 5 ) )
     ENDIF
     ,report_data->phone_list[prsnlidx ].phones[phonecnt ].phone_id = ph.phone_id ,report_data->
     phone_list[prsnlidx ].phones[phonecnt ].phone_type_cd = ph.phone_type_cd ,report_data->
     phone_list[prsnlidx ].phones[phonecnt ].phone_type = uar_get_code_display (ph.phone_type_cd ) ,
     report_data->phone_list[prsnlidx ].phones[phonecnt ].phone_num = formatphonenumber (ph
      .phone_num ,ph.phone_format_cd ,ph.extension )
    FOOT  ph.parent_entity_id
     stat = alterlist (report_data->phone_list[prsnlidx ].phones ,phonecnt )
    WITH nocounter ,expand = value (evaluate (floor (((personcnt - 1 ) / 30 ) ) ,0 ,0 ,1 ) )
   ;end select
   SET stat = alterlist (report_data->phone_list ,prsnl_cnt )
   CALL error_and_zero_check_rec (curqual ,"PHONE" ,"OutputPhoneList" ,1 ,0 ,report_data )
  ENDIF
  CALL log_message (build ("Exit OutputPhoneList(), Elapsed time in seconds:" ,datetimediff (
     cnvtdatetime (curdate ,curtime3 ) ,begin_date_time ,5 ) ) ,log_level_debug )
END ;Subroutine
 
SUBROUTINE  putstringtofile (svalue )
  CALL log_message ("In PutStringToFile()" ,log_level_debug )
  DECLARE begin_date_time = dq8 WITH constant (cnvtdatetime (curdate ,curtime3 ) ) ,private
  IF ((validate (_memory_reply_string ) = 1 ) )
   SET _memory_reply_string = svalue
  ELSE
   FREE RECORD putrequest
   RECORD putrequest (
     1 source_dir = vc
     1 source_filename = vc
     1 nbrlines = i4
     1 line [* ]
       2 linedata = vc
     1 overflowpage [* ]
       2 ofr_qual [* ]
         3 ofr_line = vc
     1 isblob = c1
     1 document_size = i4
     1 document = gvc
   )
   SET putrequest->source_dir =  $OUTDEV
   SET putrequest->isblob = "1"
   SET putrequest->document = svalue
   SET putrequest->document_size = size (putrequest->document )
   EXECUTE eks_put_source WITH replace ("REQUEST" ,putrequest ) ,
   replace ("REPLY" ,putreply )
  ENDIF
  CALL log_message (build ("Exit PutStringToFile(), Elapsed time in seconds:" ,datetimediff (
     cnvtdatetime (curdate ,curtime3 ) ,begin_date_time ,5 ) ) ,log_level_debug )
END ;Subroutine
 
SUBROUTINE  putjsonrecordtofile (record_data )
  CALL log_message ("In PutJSONRecordToFile()" ,log_level_debug )
  DECLARE begin_date_time = dq8 WITH constant (cnvtdatetime (curdate ,curtime3 ) ) ,private
  CALL putstringtofile (cnvtrectojson (record_data ) )
  CALL log_message (build ("Exit PutJSONRecordToFile(), Elapsed time in seconds:" ,datetimediff (
     cnvtdatetime (curdate ,curtime3 ) ,begin_date_time ,5 ) ) ,log_level_debug )
END ;Subroutine
 
SUBROUTINE  getparametervalues (index ,value_rec )
  DECLARE par = vc WITH noconstant ("" ) ,protect
  DECLARE lnum = i4 WITH noconstant (0 ) ,protect
  DECLARE num = i4 WITH noconstant (1 ) ,protect
  DECLARE cnt = i4 WITH noconstant (0 ) ,protect
  DECLARE cnt2 = i4 WITH noconstant (0 ) ,protect
  DECLARE param_value = f8 WITH noconstant (0.0 ) ,protect
  DECLARE param_value_str = vc WITH noconstant ("" ) ,protect
  SET par = reflect (parameter (index ,0 ) )
  IF ((validate (debug_ind ,0 ) = 1 ) )
   CALL echo (par )
  ENDIF
  IF ((((par = "F8" ) ) OR ((par = "I4" ) )) )
   SET param_value = parameter (index ,0 )
   IF ((param_value > 0 ) )
    SET value_rec->cnt = (value_rec->cnt + 1 )
    SET stat = alterlist (value_rec->qual ,value_rec->cnt )
    SET value_rec->qual[value_rec->cnt ].value = param_value
   ENDIF
  ELSEIF ((substring (1 ,1 ,par ) = "C" ) )
   SET param_value_str = parameter (index ,0 )
   IF ((trim (param_value_str ,3 ) != "" ) )
    SET value_rec->cnt = (value_rec->cnt + 1 )
    SET stat = alterlist (value_rec->qual ,value_rec->cnt )
    SET value_rec->qual[value_rec->cnt ].value = trim (param_value_str ,3 )
   ENDIF
  ELSEIF ((substring (1 ,1 ,par ) = "L" ) )
   SET lnum = 1
   WHILE ((lnum > 0 ) )
    SET par = reflect (parameter (index ,lnum ) )
    IF ((par != " " ) )
     IF ((((par = "F8" ) ) OR ((par = "I4" ) )) )
      SET param_value = parameter (index ,lnum )
      IF ((param_value > 0 ) )
       SET value_rec->cnt = (value_rec->cnt + 1 )
       SET stat = alterlist (value_rec->qual ,value_rec->cnt )
       SET value_rec->qual[value_rec->cnt ].value = param_value
      ENDIF
      SET lnum = (lnum + 1 )
     ELSEIF ((substring (1 ,1 ,par ) = "C" ) )
      SET param_value_str = parameter (index ,lnum )
      IF ((trim (param_value_str ,3 ) != "" ) )
       SET value_rec->cnt = (value_rec->cnt + 1 )
       SET stat = alterlist (value_rec->qual ,value_rec->cnt )
       SET value_rec->qual[value_rec->cnt ].value = trim (param_value_str ,3 )
      ENDIF
      SET lnum = (lnum + 1 )
     ENDIF
    ELSE
     SET lnum = 0
    ENDIF
   ENDWHILE
  ENDIF
  IF ((validate (debug_ind ,0 ) = 1 ) )
   CALL echorecord (value_rec )
  ENDIF
END ;Subroutine
 
SUBROUTINE  getlookbackdatebytype (units ,flag )
  DECLARE looback_date = dq8 WITH noconstant (cnvtdatetime ("01-JAN-1800 00:00:00" ) )
  IF ((units != 0 ) )
   CASE (flag )
    OF 1 :
     SET looback_date = cnvtlookbehind (build (units ,",H" ) ,cnvtdatetime (curdate ,curtime3 ) )
    OF 2 :
     SET looback_date = cnvtlookbehind (build (units ,",D" ) ,cnvtdatetime (curdate ,curtime3 ) )
    OF 3 :
     SET looback_date = cnvtlookbehind (build (units ,",W" ) ,cnvtdatetime (curdate ,curtime3 ) )
    OF 4 :
     SET looback_date = cnvtlookbehind (build (units ,",M" ) ,cnvtdatetime (curdate ,curtime3 ) )
    OF 5 :
     SET looback_date = cnvtlookbehind (build (units ,",Y" ) ,cnvtdatetime (curdate ,curtime3 ) )
   ENDCASE
  ENDIF
  RETURN (looback_date )
END ;Subroutine
 
SUBROUTINE  getcodevaluesfromcodeset (evt_set_rec ,evt_cd_rec )
  DECLARE csidx = i4 WITH noconstant (0 )
  SELECT DISTINCT INTO "nl:"
   FROM (v500_event_set_explode vese )
   WHERE expand (csidx ,1 ,evt_set_rec->cnt ,vese.event_set_cd ,evt_set_rec->qual[csidx ].value )
   DETAIL
    evt_cd_rec->cnt = (evt_cd_rec->cnt + 1 ) ,
    stat = alterlist (evt_cd_rec->qual ,evt_cd_rec->cnt ) ,
    evt_cd_rec->qual[evt_cd_rec->cnt ].value = vese.event_cd
   WITH nocounter
  ;end select
END ;Subroutine
 
 
SUBROUTINE  geteventsetnamesfromeventsetcds (evt_set_rec ,evt_set_name_rec )
  DECLARE index = i4 WITH protect ,noconstant (0 )
  DECLARE pos = i4 WITH protect ,noconstant (0 )
  SELECT INTO "nl:"
   FROM (v500_event_set_code v )
   WHERE expand (index ,1 ,evt_set_rec->cnt ,v.event_set_cd ,evt_set_rec->qual[index ].value )
   HEAD REPORT
    cnt = 0 ,
    evt_set_name_rec->cnt = evt_set_rec->cnt ,
    stat = alterlist (evt_set_name_rec->qual ,evt_set_rec->cnt )
   DETAIL
    pos = locateval (index ,1 ,evt_set_rec->cnt ,v.event_set_cd ,evt_set_rec->qual[index ].value ) ,
    WHILE ((pos > 0 ) )
     cnt = (cnt + 1 ) ,evt_set_name_rec->qual[pos ].value = v.event_set_name ,pos = locateval (index
      ,(pos + 1 ) ,evt_set_rec->cnt ,v.event_set_cd ,evt_set_rec->qual[index ].value )
    ENDWHILE
   FOOT REPORT
    pos = locateval (index ,1 ,evt_set_name_rec->cnt ,"" ,evt_set_name_rec->qual[index ].value ) ,
    WHILE ((pos > 0 ) )
     evt_set_name_rec->cnt = (evt_set_name_rec->cnt - 1 ) ,stat = alterlist (evt_set_name_rec->qual ,
      evt_set_name_rec->cnt ,(pos - 1 ) ) ,pos = locateval (index ,pos ,evt_set_name_rec->cnt ,"" ,
      evt_set_name_rec->qual[index ].value )
    ENDWHILE
    ,evt_set_name_rec->cnt = cnt ,
    stat = alterlist (evt_set_name_rec->qual ,evt_set_name_rec->cnt )
   WITH nocounter ,expand = value (evaluate (floor (((evt_set_rec->cnt - 1 ) / 30 ) ) ,0 ,0 ,1 ) )
  ;end select
END ;Subroutine
 
SUBROUTINE  returnviewertype (eventclasscd ,eventid )
  CALL log_message ("In returnViewerType()" ,log_level_debug )
  DECLARE begin_date_time = dq8 WITH constant (cnvtdatetime (curdate ,curtime3 ) ) ,private
  IF ((eventclasscdpopulated = 0 ) )
   SET mpc_ap_type_cd = uar_get_code_by ("MEANING" ,53 ,"AP" )
   SET mpc_doc_type_cd = uar_get_code_by ("MEANING" ,53 ,"DOC" )
   SET mpc_mdoc_type_cd = uar_get_code_by ("MEANING" ,53 ,"MDOC" )
   SET mpc_rad_type_cd = uar_get_code_by ("MEANING" ,53 ,"RAD" )
   SET mpc_txt_type_cd = uar_get_code_by ("MEANING" ,53 ,"TXT" )
   SET mpc_num_type_cd = uar_get_code_by ("MEANING" ,53 ,"NUM" )
   SET mpc_immun_type_cd = uar_get_code_by ("MEANING" ,53 ,"IMMUN" )
   SET mpc_med_type_cd = uar_get_code_by ("MEANING" ,53 ,"MED" )
   SET mpc_date_type_cd = uar_get_code_by ("MEANING" ,53 ,"DATE" )
   SET mpc_done_type_cd = uar_get_code_by ("MEANING" ,53 ,"DONE" )
   SET mpc_mbo_type_cd = uar_get_code_by ("MEANING" ,53 ,"MBO" )
   SET mpc_procedure_type_cd = uar_get_code_by ("MEANING" ,53 ,"PROCEDURE" )
   SET mpc_grp_type_cd = uar_get_code_by ("MEANING" ,53 ,"GRP" )
   SET mpc_hlatyping_type_cd = uar_get_code_by ("MEANING" ,53 ,"HLATYPING" )
   SET eventclasscdpopulated = 1
  ENDIF
  DECLARE sviewerflag = vc WITH protect ,noconstant ("" )
  CASE (eventclasscd )
   OF mpc_ap_type_cd :
    SET sviewerflag = "AP"
   OF mpc_doc_type_cd :
   OF mpc_mdoc_type_cd :
   OF mpc_rad_type_cd :
    SET sviewerflag = "DOC"
   OF mpc_txt_type_cd :
   OF mpc_num_type_cd :
   OF mpc_immun_type_cd :
   OF mpc_med_type_cd :
   OF mpc_date_type_cd :
   OF mpc_done_type_cd :
    SET sviewerflag = "EVENT"
   OF mpc_mbo_type_cd :
    SET sviewerflag = "MICRO"
   OF mpc_procedure_type_cd :
    SET sviewerflag = "PROC"
   OF mpc_grp_type_cd :
    SET sviewerflag = "GRP"
   OF mpc_hlatyping_type_cd :
    SET sviewerflag = "HLA"
   ELSE
    SET sviewerflag = "STANDARD"
  ENDCASE
  IF ((eventclasscd = mpc_mdoc_type_cd ) )
   SELECT INTO "nl:"
    c2.*
    FROM (clinical_event c1 ),
     (clinical_event c2 )
    PLAN (c1
     WHERE (c1.event_id = eventid ) )
     JOIN (c2
     WHERE (c1.parent_event_id = c2.event_id )
     AND (c2.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100" ) ) )
    HEAD c2.event_id
     IF ((c2.event_class_cd = mpc_ap_type_cd ) ) sviewerflag = "AP"
     ENDIF
    WITH nocounter
   ;end select
  ENDIF
  CALL log_message (build ("Exit returnViewerType(), Elapsed time in seconds:" ,datetimediff (
     cnvtdatetime (curdate ,curtime3 ) ,begin_date_time ,5 ) ) ,log_level_debug )
  RETURN (sviewerflag )
END ;Subroutine
 
SUBROUTINE  cnvtisodttmtodq8 (isodttmstr )
  DECLARE converteddq8 = dq8 WITH protect ,noconstant (0 )
  SET converteddq8 = cnvtdatetimeutc2 (substring (1 ,10 ,isodttmstr ) ,"YYYY-MM-DD" ,substring (12 ,
    8 ,isodttmstr ) ,"HH:MM:SS" ,4 ,curtimezonedef )
  RETURN (converteddq8 )
END ;Subroutine
 
SUBROUTINE  cnvtdq8toisodttm (dq8dttm )
  DECLARE convertedisodttm = vc WITH protect ,noconstant ("" )
  IF ((dq8dttm > 0.0 ) )
   SET convertedisodttm = build (replace (datetimezoneformat (cnvtdatetime (dq8dttm ) ,
      datetimezonebyname ("UTC" ) ,"yyyy-MM-dd HH:mm:ss" ,curtimezonedef ) ," " ,"T" ,1 ) ,"Z" )
  ELSE
   SET convertedisodttm = nullterm (convertedisodttm )
  ENDIF
  RETURN (convertedisodttm )
END ;Subroutine
 
SUBROUTINE  getorgsecurityflag (null )
  DECLARE org_security_flag = i2 WITH noconstant (0 ) ,protect
  SELECT INTO "nl:"
   FROM (dm_info di )
   WHERE (di.info_domain = "SECURITY" )
   AND (di.info_name = "SEC_ORG_RELTN" )
   HEAD REPORT
    org_security_flag = 0
   DETAIL
    org_security_flag = cnvtint (di.info_number )
   WITH nocounter
  ;end select
  RETURN (org_security_flag )
 END ;Subroutine
 
SUBROUTINE  getcomporgsecurityflag (dminfo_name )
  DECLARE org_security_flag = i2 WITH noconstant (0 ) ,protect
  SELECT INTO "nl:"
   FROM (dm_info di )
   WHERE (di.info_domain = "SECURITY" )
   AND (di.info_name = dminfo_name )
   HEAD REPORT
    org_security_flag = 0
   DETAIL
    org_security_flag = cnvtint (di.info_number )
   WITH nocounter
  ;end select
  RETURN (org_security_flag )
END ;Subroutine
 
SUBROUTINE  populateauthorizedorganizations (personid ,value_rec )
  DECLARE organization_cnt = i4 WITH noconstant (0 ) ,protect
  SELECT INTO "nl:"
   FROM (prsnl_org_reltn por )
   WHERE (por.person_id = personid )
   AND (por.active_ind = 1 )
   AND (por.beg_effective_dt_tm BETWEEN cnvtdatetime (lower_bound_date ) AND cnvtdatetime (curdate ,
    curtime3 ) )
   AND (por.end_effective_dt_tm BETWEEN cnvtdatetime (curdate ,curtime3 ) AND cnvtdatetime (
    upper_bound_date ) )
   ORDER BY por.organization_id
   HEAD REPORT
    organization_cnt = 0
   DETAIL
    organization_cnt = (organization_cnt + 1 ) ,
    IF ((mod (organization_cnt ,20 ) = 1 ) ) stat = alterlist (value_rec->organizations ,(
      organization_cnt + 19 ) )
    ENDIF
    ,value_rec->organizations[organization_cnt ].organizationid = por.organization_id
   FOOT REPORT
    value_rec->cnt = organization_cnt ,
    stat = alterlist (value_rec->organizations ,organization_cnt )
   WITH nocounter
  ;end select
  IF ((validate (debug_ind ,0 ) = 1 ) )
   CALL echorecord (value_rec )
  ENDIF
END ;Subroutine
 
SUBROUTINE  getuserlogicaldomain (id )
  DECLARE returnid = f8 WITH protect ,noconstant (0.0 )
  SELECT INTO "nl:"
   FROM (prsnl p )
   WHERE (p.person_id = id )
   DETAIL
    returnid = p.logical_domain_id
   WITH nocounter
  ;end select
  RETURN (returnid )
END ;Subroutine
 
SUBROUTINE  getpersonneloverride (ppr_cd )
  DECLARE override_ind = i2 WITH protect ,noconstant (0 )
  IF ((ppr_cd <= 0.0 ) )
   RETURN (0 )
  ENDIF
  SELECT INTO "nl:"
   FROM (code_value_extension cve )
   WHERE (cve.code_value = ppr_cd )
   AND (cve.code_set = 331 )
   AND (((cve.field_value = "1" ) ) OR ((cve.field_value = "2" ) ))
   AND (cve.field_name = "Override" )
   DETAIL
    override_ind = 1
   WITH nocounter
  ;end select
  RETURN (override_ind )
END ;Subroutine
 
SUBROUTINE  cclimpersonation (null )
  CALL log_message ("In cclImpersonation()" ,log_level_debug )
  DECLARE begin_date_time = dq8 WITH constant (cnvtdatetime (curdate ,curtime3 ) ) ,private
  EXECUTE secrtl
  DECLARE uar_secsetcontext ((hctx = i4 ) ) = i2 WITH image_axp = "secrtl" ,image_aix =
  "libsec.a(libsec.o)" ,uar = "SecSetContext" ,persist
  DECLARE seccntxt = i4 WITH public
  DECLARE namelen = i4 WITH public
  DECLARE domainnamelen = i4 WITH public
  SET namelen = (uar_secgetclientusernamelen () + 1 )
  SET domainnamelen = (uar_secgetclientdomainnamelen () + 2 )
  SET stat = memalloc (name ,1 ,build ("C" ,namelen ) )
  SET stat = memalloc (domainname ,1 ,build ("C" ,domainnamelen ) )
  SET stat = uar_secgetclientusername (name ,namelen )
  SET stat = uar_secgetclientdomainname (domainname ,domainnamelen )
  SET setcntxt = uar_secimpersonate (nullterm (name ) ,nullterm (domainname ) )
  CALL log_message (build ("Exit cclImpersonation(), Elapsed time in seconds:" ,datetimediff (
     cnvtdatetime (curdate ,curtime3 ) ,begin_date_time ,5 ) ) ,log_level_debug )
END ;Subroutine
 
SUBROUTINE  log_message (logmsg ,loglvl )
  SET icrslloglvloverrideind = 0
  SET scrsllogtext = ""
  SET scrsllogevent = ""
  SET scrsllogtext = concat ("{{Script::" ,value (log_program_name ) ,"}} " ,logmsg )
  IF ((log_override_ind = 0 ) )
   SET icrslholdloglevel = loglvl
  ELSE
   IF ((crsl_msg_level < loglvl ) )
    SET icrslholdloglevel = crsl_msg_level
    SET icrslloglvloverrideind = 1
   ELSE
    SET icrslholdloglevel = loglvl
   ENDIF
  ENDIF
  IF ((icrslloglvloverrideind = 1 ) )
   SET scrsllogevent = "Script_Override"
  ELSE
   CASE (icrslholdloglevel )
    OF log_level_error :
     SET scrsllogevent = "Script_Error"
    OF log_level_warning :
     SET scrsllogevent = "Script_Warning"
    OF log_level_audit :
     SET scrsllogevent = "Script_Audit"
    OF log_level_info :
     SET scrsllogevent = "Script_Info"
    OF log_level_debug :
     SET scrsllogevent = "Script_Debug"
   ENDCASE
  ENDIF
  SET lcrsluarmsgwritestat = uar_msgwrite (crsl_msg_default ,0 ,nullterm (scrsllogevent ) ,
   icrslholdloglevel ,nullterm (scrsllogtext ) )
  CALL echo (logmsg )
END ;Subroutine
 
 
SUBROUTINE  error_message (logstatusblockind )
  SET icrslerroroccured = 0
  SET ierrcode = error (serrmsg ,0 )
  WHILE ((ierrcode > 0 ) )
   SET icrslerroroccured = 1
   IF (validate (reply ) )
    SET reply->status_data.status = "F"
   ENDIF
   CALL log_message (serrmsg ,log_level_audit )
   IF ((logstatusblockind = 1 ) )
    IF (validate (reply ) )
     CALL populate_subeventstatus ("EXECUTE" ,"F" ,"CCL SCRIPT" ,serrmsg )
    ENDIF
   ENDIF
   SET ierrcode = error (serrmsg ,0 )
  ENDWHILE
  RETURN (icrslerroroccured )
END ;Subroutine
 
SUBROUTINE  checkcriterion (null )
  CALL log_message ("In CheckCriterion()" ,log_level_debug )
  DECLARE begin_date_time = q8 WITH constant (cnvtdatetime (curdate ,curtime3 ) ) ,private
  IF ((size (trim (criterion->static_content ,3 ) ) = 0 ) )
   SELECT INTO "nl"
    FROM (dm_info di )
    WHERE (di.info_name = "FE_WH" )
    DETAIL
     vcstaticcontent = trim (di.info_char )
    WITH nocounter
   ;end select
   CALL error_and_zero_check_rec (curqual ,"STATIC_CONTENT" ,"GetStaticContentLoc" ,1 ,0 ,criterion
    )
   SET vcstaticcontent = replace (vcstaticcontent ,"/" ,"\\" ,0 )
   SET vcstaticcontent = replace (vcstaticcontent ,"\" ,"\\" ,0 )
   SET vcstaticcontent = concat (vcstaticcontent ,"\\custom_mpage_content\requisition_manager" )
   SET criterion->static_content = vcstaticcontent
  ENDIF
  CALL log_message (build ("Exit CheckCriterion(), Elapsed time in seconds:" ,datetimediff (
     cnvtdatetime (curdate ,curtime3 ) ,begin_date_time ,5 ) ) ,log_level_debug )
END ;Subroutine
 
SUBROUTINE  getbedrocksettings (parentid )
  CALL log_message ("In GetBedrockSettings()" ,log_level_debug )
  DECLARE begin_date_time = q8 WITH constant (cnvtdatetime (curdate ,curtime3 ) ) ,private
  SET position_bedrock_settings = 0
  SELECT INTO "nl:"
   FROM (br_datamart_category bdc ),
    (br_datamart_report br ),
    (br_datamart_report_filter_r bfr ),
    (br_datamart_filter bf ),
    (br_datamart_value bv ),
    (br_datamart_flex bx )
   PLAN (bdc
    WHERE (bdc.category_mean = "MP_CUSTOM_AMB_VIEW" ) )
    JOIN (br
    WHERE (br.br_datamart_category_id = bdc.br_datamart_category_id )
    AND (br.report_mean = "MP_CUSTOM_AMB_VIEW_PAGE" ) )
    JOIN (bfr
    WHERE (bfr.br_datamart_report_id = br.br_datamart_report_id ) )
    JOIN (bf
    WHERE (bf.br_datamart_filter_id = bfr.br_datamart_filter_id ) )
    JOIN (bv
    WHERE (bv.br_datamart_category_id = bf.br_datamart_category_id )
    AND (bv.br_datamart_filter_id = bf.br_datamart_filter_id ) )
    JOIN (bx
    WHERE (bx.br_datamart_flex_id = bv.br_datamart_flex_id )
    AND (bx.parent_entity_id = parentid ) )
   ORDER BY bf.filter_mean ,
    bv.value_seq ,
    bv.br_datamart_value_id
   HEAD REPORT
    a_status = 0 ,
    form_cnt = 0
   DETAIL
    CASE (bf.filter_mean )
     OF "AMB_VIEW_HELP" :
      criterion->pwx_help_link = trim (bv.freetext_desc )
     OF "AMB_VIEW_HELP_REFLAB" :
      criterion->pwx_reflab_help_link = trim (bv.freetext_desc )
     OF "AMB_VIEW_PATSUM_PRG" :
      criterion->pwx_patient_summ_prg = trim (bv.freetext_desc )
     OF "AMB_VIEW_LIST_TYPE_REFLAB" :
      criterion->pwx_reflab_list_disp = cnvtint (trim (bv.freetext_desc ) )
     OF "AMB_VIEW_LIST_TYPE_TASKS" :
      criterion->pwx_task_list_disp = cnvtint (trim (bv.freetext_desc ) )
     OF "AMB_VIEW_ADV_PRINT" :
      criterion->pwx_adv_print = cnvtint (trim (bv.freetext_desc ) )
    ENDCASE
   WITH nocounter
  ;end select
  IF ((cnvtint (curqual ) > 0 ) )
   SET position_bedrock_settings = 1
  ENDIF
  CALL error_and_zero_check_rec (curqual ,"BEDROCK SETTINGS" ,"GetBedrockSettings" ,1 ,0 ,criterion
   )
  CALL log_message (build ("Exit GetBedrockSettings(), Elapsed time in seconds:" ,datetimediff (
     cnvtdatetime (curdate ,curtime3 ) ,begin_date_time ,5 ) ) ,log_level_debug )
END ;Subroutine
 
SUBROUTINE  gatherlocations (persid )
  CALL log_message ("In GatherLocations()" ,log_level_debug )
  DECLARE begin_date_time = dq8 WITH constant (cnvtdatetime (curdate ,curtime3 ) ) ,private
 
  SELECT DISTINCT
   location_cd = l3.location_cd ,
   location = trim (uar_get_code_description (l3.location_cd ) ),
   facility = trim (uar_get_code_description (l.location_cd ) )
   FROM (prsnl_org_reltn por ),
    (organization org ),
    (location l ),
    (location_group lg ),
    (location l2 ),
    (location_group lg2 ),
    (location l3 ),
    (code_value cv1)
   PLAN (por
    WHERE (por.person_id = persid )
    AND (por.beg_effective_dt_tm < cnvtdatetime (curdate ,curtime3 ) )
    AND (por.end_effective_dt_tm >= cnvtdatetime (curdate ,curtime3 ) )
    AND (por.active_ind = 1 ) )
    JOIN (org
    WHERE (org.organization_id = por.organization_id )
    AND (org.beg_effective_dt_tm < cnvtdatetime (curdate ,curtime3 ) )
    AND (org.end_effective_dt_tm >= cnvtdatetime (curdate ,curtime3 ) )
    AND (org.active_ind = 1 ) )
    JOIN (l
    WHERE (l.organization_id = org.organization_id )
    AND (l.location_type_cd = value(uar_get_code_by_cki ("CKI.CODEVALUE!2844" ) ))
    AND (l.beg_effective_dt_tm < cnvtdatetime (curdate ,curtime3 ) )
    AND (l.end_effective_dt_tm >= cnvtdatetime (curdate ,curtime3 ) )
    AND (l.active_ind = 1 ) )
 
    join (cv1
    where (cv1.code_value = l.location_cd)
    and   (cv1.display in("BCC*","SPH*")))
 
    JOIN (lg
    WHERE (lg.parent_loc_cd = l.location_cd )
    AND (lg.root_loc_cd = 0 )
    AND (lg.beg_effective_dt_tm < cnvtdatetime (curdate ,curtime3 ) )
    AND (lg.end_effective_dt_tm >= cnvtdatetime (curdate ,curtime3 ) )
    AND (lg.active_ind = 1 ) )
    JOIN (l2
    WHERE (l2.location_cd = lg.child_loc_cd )
    AND (l2.beg_effective_dt_tm < cnvtdatetime (curdate ,curtime3 ) )
    AND (l2.end_effective_dt_tm >= cnvtdatetime (curdate ,curtime3 ) )
    AND (l2.active_ind = 1 ) )
    JOIN (lg2
    WHERE (lg.child_loc_cd = lg2.parent_loc_cd )
    AND (lg2.root_loc_cd = 0 )
    AND (lg2.beg_effective_dt_tm < cnvtdatetime (curdate ,curtime3 ) )
    AND (lg2.end_effective_dt_tm >= cnvtdatetime (curdate ,curtime3 ) )
    AND (lg2.active_ind = 1 ) )
    JOIN (l3
    WHERE (l3.location_cd = lg2.child_loc_cd )
    AND (l3.beg_effective_dt_tm < cnvtdatetime (curdate ,curtime3 ) )
    AND (l3.end_effective_dt_tm >= cnvtdatetime (curdate ,curtime3 ) )
    AND (l3.active_ind = 1 )
    ;and l3.location_cd = 2561582141 ;REMOVE location specific
    AND (l3.location_type_cd IN ((	SELECT
								     cv.code_value
								     FROM (code_value cv )
								     WHERE (cv.cdf_meaning IN ("AMBULATORY" ,
								     "NURSEUNIT"  ) ) ) )
			) )
   ORDER BY
   	facility ,
   	location,
   	l.location_cd,
    l3.location_cd
   HEAD REPORT
    org_cnt = 0 ,
    unit_cnt = 0,
    temp_string = ""
   ;HEAD l3.location_cd
   ;head l.location_cd
   head facility
	;call echo(build2("l.location_cd=",l.location_cd))
	;call echo(build2("facility=",facility))
 
    unit_cnt = 0,
    temp_string = ""
    org_cnt = (org_cnt + 1 ) ,
    IF ((mod (org_cnt ,10 ) = 1 ) )
    	stat = alterlist (criterion->loc_list ,(org_cnt + 9 ) )
    ENDIF
    temp_string = replace (facility ,char (10 ) ," " )
    criterion->loc_list[org_cnt ].org_name = replace (temp_string ,char (13 ) ," " )
    criterion->loc_list[org_cnt ].org_id = l.location_cd
   ;head l3.location_cd
   head location
   	;call echo(build2("l3.location_cd=",l3.location_cd))
   	;call echo(build2("location=",location))
   	unit_cnt = (unit_cnt + 1)
   	stat = alterlist (criterion->loc_list[org_cnt].unit,unit_cnt )
   	temp_string = replace (location ,char (10 ) ," " )
   	criterion->loc_list[org_cnt ].unit[unit_cnt].unit_name = replace (temp_string ,char (13 ) ," " )
   	criterion->loc_list[org_cnt ].unit[unit_cnt].unit_id = l3.location_cd
   FOOT REPORT
    stat = alterlist (criterion->loc_list ,org_cnt )
   WITH nocounter
  ;end select
  CALL error_and_zero_check_rec (curqual ,"PWX_MP_TASK_ORG_DRIVER" ,"GatherLocations" ,1 ,0 ,
   criterion )
  CALL log_message (build ("Exit GatherLocations(), Elapsed time in seconds:" ,datetimediff (
     cnvtdatetime (curdate ,curtime3 ) ,begin_date_time ,5 ) ) ,log_level_debug )
END ;Subroutine
 
 
 
SUBROUTINE  gatheruserprefs (prsnl_id ,pref_id )
  CALL log_message ("In GatherUserPrefs()" ,log_level_debug )
  DECLARE begin_date_time = dq8 WITH constant (cnvtdatetime (curdate ,curtime3 ) ) ,private
  SET user_pref_string = ""
  SET user_pref_found = 0
  SELECT INTO "nl:"
   FROM (app_prefs a ),
    (name_value_prefs n )
   PLAN (a
    WHERE (a.prsnl_id = prsnl_id ) )
    JOIN (n
    WHERE (n.parent_entity_id = a.app_prefs_id )
    AND (n.parent_entity_name = "APP_PREFS" )
    AND (n.pvc_name = "TEST_*" ) )
   ORDER BY n.sequence
   DETAIL
    user_pref_found = 1 ,
    user_pref_string = trim (n.pvc_value )
   WITH nocounter
  ;end select
  CALL error_and_zero_check_rec (curqual ,"AMB_CUST_TASK_ORG_DRIVER" ,"GatherUserPrefs" ,1 ,0 ,
   criterion )
  CALL log_message (build ("Exit GatherUserPrefs(), Elapsed time in seconds:" ,datetimediff (
     cnvtdatetime (curdate ,curtime3 ) ,begin_date_time ,5 ) ) ,log_level_debug )
END ;Subroutine
 
SUBROUTINE  gatherviewprefs (poscd )
  CALL log_message ("In GatherViewPrefs()" ,log_level_debug )
  DECLARE begin_date_time = dq8 WITH constant (cnvtdatetime (curdate ,curtime3 ) ) ,private
  SELECT INTO "nl:"
   FROM (view_prefs v ),
    (name_value_prefs nvp )
   PLAN (v
    WHERE (v.position_cd = poscd )
    AND (v.application_number = 600005 )
    AND (v.frame_type = "CHART" )
    AND (v.active_ind = 1 ) )
    JOIN (nvp
    WHERE (nvp.parent_entity_id = v.view_prefs_id )
    AND (nvp.parent_entity_name = "VIEW_PREFS" )
    AND (nvp.pvc_name IN ("VIEW_CAPTION" ,
    "DISPLAY_SEQ" ) ) )
   ORDER BY v.view_prefs_id
   HEAD REPORT
    vcnt = 0
   HEAD v.view_prefs_id
    vcnt = (vcnt + 1 ) ,stat = alterlist (criterion->vpref ,vcnt )
   DETAIL
    IF ((nvp.pvc_name = "VIEW_CAPTION" ) ) criterion->vpref[vcnt ].view_caption = trim (nvp
      .pvc_value )
    ELSEIF ((nvp.pvc_name = "DISPLAY_SEQ" ) ) criterion->vpref[vcnt ].view_seq = cnvtint (trim (nvp
       .pvc_value ) )
    ENDIF
   WITH nocounter
  ;end select
  CALL error_and_zero_check_rec (curqual ,"AMB_CUST_TASK_ORG_DRIVER" ,"GatherViewPrefs" ,1 ,0 ,
   criterion )
  CALL log_message (build ("Exit GatherViewPrefs(), Elapsed time in seconds:" ,datetimediff (
     cnvtdatetime (curdate ,curtime3 ) ,begin_date_time ,5 ) ) ,log_level_debug )
END ;Subroutine
 
SUBROUTINE  getlocaledata (null )
  CALL log_message ("In GetLocaleData()" ,log_level_debug )
  DECLARE begin_date_time = dq8 WITH constant (cnvtdatetime (curdate ,curtime3 ) ) ,private
  DECLARE locale = vc WITH protect ,noconstant ("" )
  DECLARE lang_id = vc WITH noconstant ("" ) ,protect
  DECLARE lang_locale_id = vc WITH noconstant ("" ) ,protect
  SET locale = cnvtupper (logical ("CCL_LANG" ) )
  IF ((locale = "" ) )
   SET locale = cnvtupper (logical ("LANG" ) )
  ENDIF
  SET criterion->locale_id = locale
  SET lang_id = cnvtlower (substring (1 ,2 ,locale ) )
  SET lang_locale_id = cnvtlower (substring (4 ,2 ,locale ) )
  CASE (lang_id )
   OF "en" :
    IF ((lang_locale_id = "au" ) )
     SET localefilename = "locale.en_AU"
     SET localeobjectname = "en_AU"
    ELSEIF ((lang_locale_id = "gb" ) )
     SET localefilename = "locale.en_GB"
     SET localeobjectname = "en_GB"
    ELSE
     SET localefilename = "locale"
     SET localeobjectname = "en_US"
    ENDIF
   OF "es" :
    SET localefilename = "locale.es"
    SET localeobjectname = "es_ES"
   OF "de" :
    SET localefilename = "locale.de"
    SET localeobjectname = "de_DE"
   OF "fr" :
    SET localefilename = "locale.fr"
    SET localeobjectname = "fr_FR"
   ELSE
    SET localefilename = "locale"
    SET localeobjectname = "en_US"
  ENDCASE
  CALL log_message (build ("Exit GetLocaleData(), Elapsed time in seconds:" ,datetimediff (
     cnvtdatetime (curdate ,curtime3 ) ,begin_date_time ,5 ) ) ,log_level_debug )
END ;Subroutine
 