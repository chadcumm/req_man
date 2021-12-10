/*****************************************************************************
******************************************************************************

  Author:             Chad Cummings
  Date Written:       03/01/2019
  Solution:           
  Source file name:   bc_mmf_publish_ce.prg
  Object name:        bc_mmf_publish_ce
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
001   10/22/2020  Chad Cummings			added normal_ref_range_txt
******************************************************************************/

DROP PROGRAM bc_mmf_publish_ce :dba GO
CREATE PROGRAM bc_mmf_publish_ce :dba
 IF ((validate (i18nuar_def ,999 ) = 999 ) )
  CALL echo ("Declaring i18nuar_def" )
  DECLARE i18nuar_def = i2 WITH persist
  SET i18nuar_def = 1
  DECLARE uar_i18nlocalizationinit ((p1 = i4 ) ,(p2 = vc ) ,(p3 = vc ) ,(p4 = f8 ) ) = i4 WITH
  persist
  DECLARE uar_i18ngetmessage ((p1 = i4 ) ,(p2 = vc ) ,(p3 = vc ) ) = vc WITH persist
  DECLARE uar_i18nbuildmessage () = vc WITH persist
  DECLARE uar_i18ngethijridate ((imonth = i2 (val ) ) ,(iday = i2 (val ) ) ,(iyear = i2 (val ) ) ,(
   sdateformattype = vc (ref ) ) ) = c50 WITH image_axp = "shri18nuar" ,image_aix =
  "libi18n_locale.a(libi18n_locale.o)" ,uar = "uar_i18nGetHijriDate" ,persist
  DECLARE uar_i18nbuildfullformatname ((sfirst = vc (ref ) ) ,(slast = vc (ref ) ) ,(smiddle = vc (
    ref ) ) ,(sdegree = vc (ref ) ) ,(stitle = vc (ref ) ) ,(sprefix = vc (ref ) ) ,(ssuffix = vc (
    ref ) ) ,(sinitials = vc (ref ) ) ,(soriginal = vc (ref ) ) ) = c250 WITH image_axp =
  "shri18nuar" ,image_aix = "libi18n_locale.a(libi18n_locale.o)" ,uar = "i18nBuildFullFormatName" ,
  persist
  DECLARE uar_i18ngetarabictime ((ctime = vc (ref ) ) ) = c20 WITH image_axp = "shri18nuar" ,
  image_aix = "libi18n_locale.a(libi18n_locale.o)" ,uar = "i18n_GetArabicTime" ,persist
 ENDIF
 IF ((validate (reply ) != 1 ) )
  RECORD reply (
    1 parenteventid = f8
    1 status_data
      2 status = c1
      2 subeventstatus [1 ]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 RECORD publishlist (
   1 objectlist [* ]
     2 displayname = vc
     2 mediaobjectid = vc
 )
 RECORD requestowner (
   1 media_object_identifier = vc
   1 ownership_uid = vc
 )
 RECORD replyowner (
   1 ownership_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus [1 ]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE logmsg ((p1 = i4 ) ,(p1 = vc ) ) = i4
 DECLARE postclinicalevent ((p1 = f8 ) ,(p2 = f8 ) ) = i4
 DECLARE geteventcode ((p1 = vc ) ) = f8
 DECLARE getformat ((p1 = vc ) ) = f8
 DECLARE getobjectname ((p1 = vc ) ) = vc
 DECLARE validateid ((p1 = vc ) ) = i4
 DECLARE debugflag = i4 WITH public ,noconstant (0 )
 IF ((request->debug > 0 ) )
  SET debugflag = 1
 ENDIF
 SET reply->status_data.status = "F"
 SET reply->status_data.subeventstatus[1 ].operationname = "PUBLISH"
 SET reply->status_data.subeventstatus[1 ].operationstatus = ""
 SET reply->status_data.subeventstatus[1 ].targetobjectname = "MMF_PUBLISH_CE.PRG"
 SET reply->status_data.subeventstatus[1 ].targetobjectvalue =
 "Error publishing the clinical event."
 CALL logmsg (debugflag ,concat ("start:" ,format (curdate ,"MM/DD/YYYY;;D" ) ," " ,format (curtime3
    ,"@TIMEWITHSECONDS" ) ) )
 CALL logmsg (debugflag ,build ("request->PersonId:" ,request->personid ) )
 CALL logmsg (debugflag ,build ("request->encounterId:" ,request->encounterid ) )
 CALL logmsg (debugflag ,build ("request->documentType_key:" ,request->documenttype_key ) )
 CALL logmsg (debugflag ,build ("request->title:" ,request->title ) )
 CALL logmsg (debugflag ,build ("request->service_dt_tm:" ,format (request->service_dt_tm ,
    "dd-mmm-yyyy hh:mm;;D" ) ) )
 CALL logmsg (debugflag ,build ("request->notetext:" ,request->notetext ) )
 CALL logmsg (debugflag ,build ("request->noteformat:" ,request->noteformat ) )
 CALL logmsg (debugflag ,build ("request->personnel size:" ,size (request->personnel ,5 ) ) )
 CALL logmsg (debugflag ,build ("request->mediaObjects size:" ,size (request->mediaobjects ,5 ) ) )
 CALL logmsg (debugflag ,build ("request->mediaobjectGroups size:" ,size (request->mediaobjectgroups
    ,5 ) ) )
 CALL logmsg (debugflag ,build ("request->publishasnote:" ,request->publishasnote ) )
 CALL postclinicalevent (request->personid ,request->encounterid )
 CALL logmsg (debugflag ,concat ("end:" ,format (curdate ,"MM/DD/YYYY;;D" ) ," " ,format (curtime3 ,
    "@TIMEWITHSECONDS" ) ) )
 SUBROUTINE  postclinicalevent (personid ,encntrid )
  DECLARE applicationid = i4 WITH constant (1000012 )
  DECLARE taskid = i4 WITH constant (1000012 )
  DECLARE requestid = i4 WITH constant (1000012 )
  DECLARE happ = i4 WITH noconstant (0 ) ,protect
  DECLARE htask = i4 WITH noconstant (0 ) ,protect
  DECLARE hstep = i4 WITH noconstant (0 ) ,protect
  DECLARE hreq = i4 WITH noconstant (0 ) ,protect
  DECLARE hcetype = i4 WITH noconstant (0 ) ,protect
  DECLARE hcestruct = i4 WITH noconstant (0 ) ,protect
  DECLARE hcetype2 = i4 WITH noconstant (0 ) ,protect
  DECLARE hcestruct2 = i4 WITH noconstant (0 ) ,protect
  DECLARE hmdoc = i4 WITH noconstant (0 ) ,protect
  DECLARE hdoc = i4 WITH noconstant (0 ) ,protect
  DECLARE hnote = i4 WITH noconstant (0 ) ,protect
  DECLARE hattachment = i4 WITH noconstant (0 ) ,protect
  DECLARE hbr = i4 WITH noconstant (0 ) ,protect
  DECLARE hblob = i4 WITH noconstant (0 ) ,protect
  DECLARE hrep = i4 WITH noconstant (0 ) ,protect
  DECLARE hrbhandle = i4 WITH protect ,noconstant (0 )
  DECLARE rb_list_cnt = i4 WITH protect ,noconstant (0 )
  DECLARE evtidx = i4 WITH protect ,noconstant (0 )
  DECLARE countmedia = i4 WITH noconstant (0 ) ,protect
  DECLARE istatus = i4 WITH noconstant (0 ) ,protect
  DECLARE srvstat = i4 WITH noconstant (0 ) ,protect
  DECLARE nviewprelimflowflag = i2
  DECLARE nviewholdflowflag = i2
  DECLARE nviewrejectflowflag = i2
  DECLARE hmrl = i4 WITH public ,noconstant (0 )
  DECLARE hprsnl = i4 WITH public ,noconstant (0 )
  DECLARE iindex = i4 WITH public ,noconstant (1 )
  DECLARE eventid = f8 WITH public ,noconstant (0.0 )
  DECLARE active_cd = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,48 ,"ACTIVE" ) )
  DECLARE auth_cd = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,8 ,"AUTH" ) )
  DECLARE inprogress_cd = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,8 ,"IN PROGRESS" )
   )
  DECLARE publish_status = f8 WITH protect ,noconstant (inprogress_cd )
  DECLARE blob_cd = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,25 ,"BLOB" ) )
  DECLARE compression_cd = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,120 ,"NOCOMP" ) )
  DECLARE current_date_time = dq8 WITH constant (cnvtdatetime (curdate ,curtime3 ) ) ,protect
  DECLARE passed_date_time = dq8 WITH noconstant (cnvtdatetime (curdate ,curtime3 ) ) ,protect
  DECLARE entry_method_cd = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,13 ,"CERNER" ) )
  DECLARE format_unkown_cd = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,23 ,"UNKNOWN" )
   )
  DECLARE format_xml_cd = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,23 ,"XML" ) )
  DECLARE format_jpg_cd = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,23 ,"JPEG" ) )
  DECLARE format_pdf_cd = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,23 ,"PDF" ) )
  DECLARE mmf_cd = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,25 ,"MMF" ) )
  DECLARE notetype_cd = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,14 ,"UNKNOWN" ) )
  DECLARE powerchart_cd = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,89 ,"POWERCHART" )
   )
  DECLARE root_cd = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,24 ,"ROOT" ) )
  DECLARE child_cd = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,24 ,"CHILD" ) )
  DECLARE succession_cd = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,63 ,"UNKNOWN" ) )
  DECLARE final_cd = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,63 ,"FINAL" ) )
  DECLARE verify_cd = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,21 ,"VERIFY" ) )
  DECLARE iret = i4 WITH protect ,noconstant (0 )
  DECLARE mdoc = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,53 ,"MDOC" ) )
  DECLARE clinicaldoc = f8 WITH protect ,noconstant (uar_get_code_by ("MEANING" ,53 ,"DOC" ) )
  DECLARE attachment = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,53 ,"ATTACHMENT" ) )
  DECLARE event_cd = f8 WITH protect ,noconstant (0.0 )
  DECLARE format_cd = f8 WITH protect ,noconstant (uar_get_code_by ("MEANING" ,23 ,"AH" ) )
  DECLARE publishas_cd = f8 WITH protect ,noconstant (0.0 )
  DECLARE parenteventid = f8 WITH protect ,noconstant (0.0 )
  DECLARE fprsnl = f8 WITH protect ,noconstant (0.0 )
  CALL logmsg (debugflag ,concat ("begin:" ,format (curdate ,"MM/DD/YYYY;;D" ) ," " ,format (
     curtime3 ,"@TIMEWITHSECONDS" ) ) )
  DECLARE i18nhandle = i4 WITH noconstant (0 )
  SET srvstat = uar_i18nlocalizationinit (i18nhandle ,curprog ,"" ,curcclrev )
  DECLARE snote = vc WITH noconstant (uar_i18ngetmessage (i18nhandle ,"documentimage" ,
    "Document includes an Image." ) )
  FOR (iindex = 1 TO size (request->personnel ,5 ) )
   IF ((nullterm (trim (request->personnel[iindex ].action ) ) = "VERIFY" )
   AND (nullterm (trim (request->personnel[iindex ].status ) ) = "COMPLETED" ) )
    SET publish_status = auth_cd
   ENDIF
  ENDFOR
  SET event_cd = geteventcode (request->documenttype_key )
  IF ((event_cd = 0.0 ) )
   SET reply->status_data.subeventstatus[1 ].targetobjectvalue = build (
    "Invalid request->documentType_key:" ,request->documenttype_key )
   CALL logmsg (debugflag ,build ("Invalid request->documentType_key:" ,request->documenttype_key ,
     ":" ,event_cd ) )
   RETURN
  ENDIF
  IF ((request->noteformat != "" ) )
   SET format_cd = uar_get_code_by ("MEANING" ,23 ,request->noteformat )
  ENDIF
  CALL logmsg (debugflag ,"****Start Post Clinical Event" )
  CALL logmsg (debugflag ,"****Start Post Clinical Event" )
  SET iret = uar_crmbeginapp (applicationid ,happ )
  IF ((iret != 0 ) )
   SET reply->status_data.subeventstatus[1 ].targetobjectvalue =
   "uar_CrmBeginApp failed in mmf_publish_ce::PostClinicalEvent"
   CALL logmsg (debugflag ,"uar_CrmBeginApp failed in mmf_publish_ce::PostClinicalEvent" )
   RETURN
  ENDIF
  SET iret = uar_crmbegintask (happ ,taskid ,htask )
  IF ((iret != 0 ) )
   SET reply->status_data.subeventstatus[1 ].targetobjectvalue =
   "uar_CrmBeginTask failed in mmf_publish_ce::PostClinicalEvent"
   CALL logmsg (debugflag ,"uar_CrmBeginTask failed in mmf_publish_ce::PostClinicalEvent" )
   RETURN
  ENDIF
  SET iret = uar_crmbeginreq (htask ,"" ,requestid ,hstep )
  IF ((iret != 0 ) )
   SET reply->status_data.subeventstatus[1 ].targetobjectvalue =
   "uar_CrmBeginReq failed in mmf_publish_ce::PostClinicalEvent"
   CALL logmsg (debugflag ,"uar_CrmBeginReq failed in mmf_publish_ce::PostClinicalEvent" )
   RETURN
  ENDIF
  CALL logmsg (debugflag ,build ("CURRENT_DATE_TIME:" ,format (current_date_time ,
     "dd-mmm-yyyy hh:mm;;D" ) ) )
  SET passed_date_time = request->service_dt_tm
  CALL logmsg (debugflag ,build ("request->dateofservice_dt_tm:" ,format (request->service_dt_tm ,
     "dd-mmm-yyyy hh:mm;;D" ) ) )
  CALL logmsg (debugflag ,build ("PASSED_DATE_TIME:" ,format (passed_date_time ,
     "dd-mmm-yyyy hh:mm;;D" ) ) )
  CALL logmsg (debugflag ,build ("person_id:" ,personid ) )
  SET hreq = uar_crmgetrequest (hstep )
  SET srvstat = uar_srvsetshort (hreq ,"ensure_type" ,1 )
  SET hmdoc = uar_srvgetstruct (hreq ,"clin_event" )
  SET srvstat = uar_srvsetshort (hmdoc ,"ensure_type" ,0 )
  SET srvstat = uar_srvsetshort (hmdoc ,"view_level_ind" ,0 )
  SET srvstat = uar_srvsetlong (hmdoc ,"view_level" ,1 )
  SET srvstat = uar_srvsetdouble (hmdoc ,"person_id" ,personid )
  SET srvstat = uar_srvsetdouble (hmdoc ,"encntr_id" ,encntrid )
  SET srvstat = uar_srvsetdouble (hmdoc ,"result_status_cd" ,publish_status )
  SET srvstat = uar_srvsetdouble (hmdoc ,"contributor_system_cd" ,powerchart_cd )
  SET srvstat = uar_srvsetshort (hmdoc ,"event_start_dt_tm_ind" ,0 )
  SET srvstat = uar_srvsetshort (hmdoc ,"event_end_dt_tm_ind" ,0 )
  SET srvstat = uar_srvsetstring (hmdoc ,"reference_nbr" ,request->reference_nbr )
  ;SET srvstat = uar_srvsetstring (hmdoc ,"normal_ref_range_txt" ,request->normal_ref_range_txt ) ;001
  
  SET srvstat = uar_srvsetdate (hmdoc ,"event_start_dt_tm" ,passed_date_time )
  CALL logmsg (debugflag ,build ("event dt tm:" ,srvstat ) )
  SET srvstat = uar_srvsetdate (hmdoc ,"event_end_dt_tm" ,passed_date_time )
  CALL logmsg (debugflag ,build ("event dt tm:" ,srvstat ) )
  SET srvstat = uar_srvsetshort (hmdoc ,"clinsig_updt_dt_tm_ind" ,0 )
  SET srvstat = uar_srvsetshort (hmdoc ,"clinsig_updt_dt_tm_flag" ,0 )
  SET srvstat = uar_srvsetdouble (hmdoc ,"event_class_cd" ,mdoc )
  SET srvstat = uar_srvsetdouble (hmdoc ,"event_cd" ,event_cd )
  SET srvstat = uar_srvsetdouble (hmdoc ,"event_reltn_cd" ,root_cd )
  SET srvstat = uar_srvsetdouble (hmdoc ,"record_status_cd" ,active_cd )
  SET srvstat = uar_srvsetshort (hmdoc ,"authenticat_flag_ind" ,0 )
  SET srvstat = uar_srvsetshort (hmdoc ,"authenticat_flag" ,1 )
  SET srvstat = uar_srvsetshort (hmdoc ,"publish_flag_ind" ,0 )
  SET srvstat = uar_srvsetshort (hmdoc ,"publish_flag" ,1 )
  SET srvstat = uar_srvsetstring (hmdoc ,"collating_seq" ,"1" )
  IF ((request->title != "" ) )
   SET srvstat = uar_srvsetstring (hmdoc ,"event_title_text" ,nullterm (request->title ) )
  ELSE
   SET srvstat = uar_srvsetstring (hmdoc ,"event_title_text" ,"Default Title" )
  ENDIF
  SET srvstat = uar_srvsetstring (hmdoc ,"collating_seq" ," " )
  SET srvstat = uar_srvsetdate (hmdoc ,"performed_dt_tm" ,current_date_time )
  FOR (iindex = 1 TO size (request->personnel ,5 ) )
   SET hprsnl = uar_srvadditem (hmdoc ,"event_prsnl_list" )
   CALL logmsg (debugflag ,build ("hPrsnl:" ,hprsnl ) )
   IF (hprsnl )
    SET stat = uar_srvsetshort (hprsnl ,"ensure_type" ,0 )
    SET stat = uar_srvsetdouble (hprsnl ,"person_id" ,personid )
    if (request->personnel[iindex ].action = "AUTHOR")
     SET stat = uar_srvsetstring (hprsnl ,"action_comment" ,"To Be Actioned" )	
    endif
    SET stat = uar_srvsetdouble (hprsnl ,"action_type_cd" ,uar_get_code_by ("MEANING" ,21 ,request->
      personnel[iindex ].action ) )
    SET stat = uar_srvsetdate (hprsnl ,"action_dt_tm" ,current_date_time )
    SET stat = uar_srvsetdouble (hprsnl ,"action_prsnl_id" ,request->personnel[iindex ].id )
    SET stat = uar_srvsetdouble (hprsnl ,"action_status_cd" ,uar_get_code_by ("MEANING" ,103 ,request
      ->personnel[iindex ].status ) )
   ENDIF
  ENDFOR
  SET hcetype = uar_srvcreatetypefrom (hreq ,"clin_event" )
  SET hcestruct = uar_srvgetstruct (hreq ,"clin_event" )
  CALL uar_srvbinditemtype (hcestruct ,"child_event_list" ,hcetype )
  CALL logmsg (debugflag ,build ("hDOC hCEType:" ,hcetype ) )
  CALL logmsg (debugflag ,build ("hDOC hCESruct:" ,hcestruct ) )
  SET hdoc = uar_srvadditem (hcestruct ,"child_event_list" )
  CALL uar_srvbinditemtype (hdoc ,"child_event_list" ,hcetype )
  IF (hcetype )
   CALL uar_srvdestroytype (hcetype )
   SET hcetype = 0
  ENDIF
  SET srvstat = uar_srvsetdouble (hdoc ,"event_reltn_cd" ,child_cd )
  SET srvstat = uar_srvsetshort (hdoc ,"ensure_type" ,0 )
  SET srvstat = uar_srvsetdouble (hdoc ,"person_id" ,personid )
  SET srvstat = uar_srvsetdouble (hdoc ,"encntr_id" ,encntrid )
  SET srvstat = uar_srvsetdouble (hdoc ,"result_status_cd" ,publish_status )
  SET srvstat = uar_srvsetdouble (hdoc ,"contributor_system_cd" ,powerchart_cd )
  SET srvstat = uar_srvsetdouble (hdoc ,"event_class_cd" ,clinicaldoc )
  SET srvstat = uar_srvsetshort (hdoc ,"event_start_dt_tm_ind" ,1 )
  SET srvstat = uar_srvsetdouble (hdoc ,"record_status_cd" ,active_cd )
  SET srvstat = uar_srvsetshort (hdoc ,"event_start_dt_tm_ind" ,0 )
  SET srvstat = uar_srvsetdate (hdoc ,"event_start_dt_tm" ,passed_date_time )
  CALL logmsg (debugflag ,build ("Start SrvSetDate srvStat:" ,srvstat ) )
  SET srvstat = uar_srvsetshort (hdoc ,"event_end_dt_tm_ind" ,0 )
  SET srvstat = uar_srvsetdate (hdoc ,"event_end_dt_tm" ,passed_date_time )
  SET srvstat = uar_srvsetlong (hdoc ,"view_level" ,0 )
  SET srvstat = uar_srvsetshort (hdoc ,"publish_flag_ind" ,0 )
  SET srvstat = uar_srvsetshort (hdoc ,"publish_flag" ,1 )
  SET srvstat = uar_srvsetshort (hdoc ,"authentic_flag" ,1 )
  SET srvstat = uar_srvsetdouble (hdoc ,"event_cd" ,event_cd )
  SET srvstat = uar_srvsetstring (hdoc ,"collating_seq" ,"1" )
  IF ((request->notetext != "" ) )
   SET snote = request->notetext
  ENDIF
  IF ((request->publishasnote = 0 ) )
   SET hbr = uar_srvadditem (hdoc ,"blob_result" )
   CALL echo (build ("hBR:" ,hbr ) )
   SET stat = uar_srvsetdouble (hbr ,"person_id" ,personid )
   SET srvstat = uar_srvsetdouble (hbr ,"storage_cd" ,blob_cd )
   SET srvstat = uar_srvsetdouble (hbr ,"format_cd" ,format_cd )
   SET srvstat = uar_srvsetdouble (hbr ,"succession_type_cd" ,succession_cd )
   SET hblob = uar_srvadditem (hbr ,"blob" )
   CALL echo (build ("hBlob:" ,hblob ) )
   IF (hblob )
    SET srvstat = uar_srvsetdouble (hblob ,"compression_cd" ,compression_cd )
    SET srvstat = uar_srvsetasis (hblob ,"blob_contents" ,nullterm (trim (snote ) ) ,size (trim (
       snote ) ) )
    SET srvstat = uar_srvsetlong (hblob ,"blob_length" ,size (trim (snote ) ) )
   ENDIF
  ENDIF
  CALL logmsg (debugflag ,build ("sNote:" ,snote ) )
  IF ((request->title != "" ) )
   SET srvstat = uar_srvsetstring (hdoc ,"event_title_text" ,nullterm (trim (request->title ) ) )
  ELSE
   SET srvstat = uar_srvsetstring (hdoc ,"event_title_text" ,"Default ATTACHMENT Title" )
  ENDIF
  SET istatus = alterlist (publishlist->objectlist ,size (request->mediaobjects ,5 ) )
  FOR (iindex = 1 TO size (request->mediaobjects ,5 ) )
   SET publishlist->objectlist[iindex ].displayname = nullterm (request->mediaobjects[iindex ].
    display )
   IF ((publishlist->objectlist[iindex ].displayname = "" ) )
    SET publishlist->objectlist[iindex ].displayname = getobjectname (request->mediaobjects[iindex ].
     identifier )
   ENDIF
   IF ((validateid (request->mediaobjects[iindex ].identifier ) = 1 ) )
    SET publishlist->objectlist[iindex ].mediaobjectid = nullterm (request->mediaobjects[iindex ].
     identifier )
   ELSE
    SET reply->status_data.subeventstatus[1 ].targetobjectvalue = "invalid identifier"
    CALL logmsg (debugflag ,build ("invalid identifier:" ,request->mediaobjects[iindex ].identifier
      ) )
    RETURN
   ENDIF
  ENDFOR
  FOR (iindex = 1 TO size (request->mediaobjectgroups ,5 ) )
   CALL logmsg (debugflag ,build (iindex ,": group identifier : " ,request->mediaobjectgroups[iindex
     ].identifier ) )
   IF ((validateid (request->mediaobjectgroups[iindex ].identifier ) = 0 ) )
    SET reply->status_data.subeventstatus[1 ].targetobjectvalue = "invalid identifier"
    CALL logmsg (debugflag ,build ("invalid identifier:" ,request->mediaobjectgroups[iindex ].
      identifier ) )
    RETURN
   ENDIF
   SET countmedia = size (request->mediaobjects ,5 )
   IF ((trim (request->mediaobjectgroups[iindex ].identifier ) != "" ) )
    SELECT INTO "nl:"
     FROM (dms_media_identifier d1 ),
      (dms_media_instance d2 ),
      (dms_media_identifier d3 )
     PLAN (d1
      WHERE (d1.media_object_identifier = request->mediaobjectgroups[iindex ].identifier ) )
      JOIN (d2
      WHERE (d2.dms_media_identifier_group_id = d1.dms_media_identifier_id )
      AND (d2.dms_media_identifier_group_id != d2.dms_media_identifier_id ) )
      JOIN (d3
      WHERE (d3.dms_media_identifier_id = d2.dms_media_identifier_id ) )
     DETAIL
      countmedia = (countmedia + 1 ) ,
      istatus = alterlist (publishlist->objectlist ,countmedia ) ,
      publishlist->objectlist[countmedia ].displayname = d2.name ,
      publishlist->objectlist[countmedia ].mediaobjectid = d3.media_object_identifier
    ;end select
   ENDIF
  ENDFOR
  CALL logmsg (debugflag ,build ("publishList->objectList:" ,size (publishlist->objectlist ,5 ) ) )
  FOR (iindex = 1 TO size (publishlist->objectlist ,5 ) )
   CALL logmsg (debugflag ,build (publishlist->objectlist[iindex ].mediaobjectid ,":" ,publishlist->
     objectlist[iindex ].displayname ) )
   IF ((request->publishasnote = 0 ) )
    SET hcetype2 = uar_srvcreatetypefrom (hdoc ,"child_event_list" )
    SET hattachment = uar_srvadditem (hdoc ,"child_event_list" )
    CALL uar_srvbinditemtype (hattachment ,"child_event_list" ,hcetype2 )
    IF (hcetype2 )
     CALL uar_srvdestroytype (hcetype2 )
     SET hcetype2 = 0
    ENDIF
    CALL logmsg (debugflag ,build ("hATTACHMENT:" ,hattachment ) )
    SET srvstat = uar_srvsetshort (hattachment ,"ensure_type" ,0 )
    SET srvstat = uar_srvsetdouble (hattachment ,"person_id" ,personid )
    SET srvstat = uar_srvsetdouble (hattachment ,"encntr_id" ,encntrid )
    SET srvstat = uar_srvsetstring (hattachment ,"collating_seq" ,nullterm (build (iindex ) ) )
    SET srvstat = uar_srvsetdouble (hattachment ,"result_status_cd" ,publish_status )
    SET srvstat = uar_srvsetdouble (hattachment ,"contributor_system_cd" ,powerchart_cd )
    SET srvstat = uar_srvsetdouble (hattachment ,"event_class_cd" ,attachment )
    SET srvstat = uar_srvsetdouble (hattachment ,"record_status_cd" ,active_cd )
    SET srvstat = uar_srvsetshort (hattachment ,"event_start_dt_tm_ind" ,0 )
    SET srvstat = uar_srvsetdate (hattachment ,"event_start_dt_tm" ,passed_date_time )
    SET srvstat = uar_srvsetshort (hattachment ,"event_end_dt_tm_ind" ,0 )
    SET srvstat = uar_srvsetdate (hattachment ,"event_end_dt_tm" ,passed_date_time )
    SET srvstat = uar_srvsetlong (hattachment ,"view_level" ,0 )
    SET srvstat = uar_srvsetshort (hattachment ,"publish_flag" ,1 )
    SET srvstat = uar_srvsetshort (hattachment ,"authentic_flag" ,1 )
    SET srvstat = uar_srvsetdouble (hattachment ,"event_cd" ,event_cd )
    SET srvstat = uar_srvsetstring (hattachment ,"event_title_text" ,nullterm (publishlist->
      objectlist[iindex ].displayname ) )
    SET hbr = uar_srvadditem (hattachment ,"blob_result" )
   ELSE
    SET hbr = uar_srvadditem (hdoc ,"blob_result" )
    SET hattachment = hdoc
   ENDIF
   SET stat = uar_srvsetdouble (hbr ,"person_id" ,personid )
   SET srvstat = uar_srvsetdouble (hbr ,"storage_cd" ,mmf_cd )
   IF ((request->publishasnote = 0 ) )
    SET srvstat = uar_srvsetdouble (hbr ,"format_cd" ,format_unkown_cd )
   ELSE
    SET publishas_cd = getformat (publishlist->objectlist[iindex ].mediaobjectid )
    IF ((publishas_cd = 0.0 ) )
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1 ].targetobjectvalue = build (
      "Invalid media type for publishasNote" )
     CALL logmsg (debugflag ,reply->status_data.subeventstatus[1 ].targetobjectvalue )
     RETURN (0 )
    ENDIF
    SET srvstat = uar_srvsetdouble (hbr ,"format_cd" ,publishas_cd )
   ENDIF
   SET srvstat = uar_srvsetstring (hbr ,"collating_seq" ,nullterm (build (iindex ) ) )
   SET srvstat = uar_srvsetstring (hbr ,"blob_handle" ,nullterm (trim (publishlist->objectlist[
      iindex ].mediaobjectid ) ) )
   SET srvstat = uar_srvsetdouble (hbr ,"succession_type_cd" ,final_cd )
   IF ((request->publishasnote = 0 ) )
    SET hblob = uar_srvadditem (hbr ,"blob" )
    CALL logmsg (debugflag ,build ("hBlob:" ,hblob ) )
    IF (hblob )
     SET srvstat = uar_srvsetdouble (hblob ,"compression_cd" ,compression_cd )
     SET srvstat = uar_srvsetasis (hblob ,"blob_contents" ,nullterm (trim (snote ) ) ,size (trim (
        snote ) ) )
     SET srvstat = uar_srvsetlong (hblob ,"blob_length" ,size (trim (snote ) ) )
    ENDIF
   ENDIF
  ENDFOR
  SET iret = uar_crmperform (hstep )
  CALL logmsg (debugflag ,build (" uar_CrmPerform:" ,iret ) )
  IF ((iret = 0 ) )
   SET hrep = uar_crmgetreply (hstep )
   CALL logmsg (debugflag ,build ("hrep:" ,hrep ) )
   IF ((hrep > 0 ) )
    SET rb_list_cnt = uar_srvgetitemcount (hrep ,nullterm ("rb_list" ) )
    CALL logmsg (debugflag ,build ("rb_list_cnt:" ,rb_list_cnt ) )
    FOR (evtidx = 0 TO (rb_list_cnt - 1 ) )
     SET hrbhandle = uar_srvgetitem (hrep ,nullterm ("rb_list" ) ,evtidx )
     SET eventid = uar_srvgetdouble (hrbhandle ,nullterm ("event_id" ) )
     SET parenteventid = uar_srvgetdouble (hrbhandle ,nullterm ("parent_event_id" ) )
     IF ((parenteventid = eventid ) )
      SET reply->parenteventid = parenteventid
      CALL logmsg (debugflag ,build ("index:" ,evtidx ,"  reply->parentEventId:" ,reply->
        parenteventid ) )
      SET reply->status_data.status = "S"
      SET reply->status_data.subeventstatus[1 ].targetobjectvalue = "Objects successfully published"
     ENDIF
    ENDFOR
    SET requestowner->ownership_uid = build ("urn:cerner:mid:mmf.mom.clinical_event" ,":" ,cnvtupper
     (curdomain ) ,":" ,reply->parenteventid )
    CALL logmsg (debugflag ,build ("   requestOwner->ownership_uid:" ,requestowner->ownership_uid )
     )
    IF ((reply->status_data.status = "S" ) )
     FOR (iindex = 1 TO size (publishlist->objectlist ,5 ) )
      SET requestowner->media_object_identifier = publishlist->objectlist[iindex ].mediaobjectid
      CALL logmsg (debugflag ,build ("   requestOwner->media_object_identifier:" ,requestowner->
        media_object_identifier ) )
      EXECUTE mmf_add_ownership WITH replace ("REQUEST" ,"REQUESTOWNER" ) ,
      replace ("REPLY" ,"REPLYOWNER" )
      CALL logmsg (debugflag ,build ("reqinfo->commit_ind" ,reqinfo->commit_ind ) )
      IF ((reqinfo->commit_ind = 1 ) )
       COMMIT
      ENDIF
      IF ((replyowner->status_data.status = "F" ) )
       SET reply->status_data.status = "F"
       SET reply->status_data.subeventstatus[1 ].targetobjectvalue = build (
        "Unable to set ownership for " ,requestowner->media_object_identifier )
      ENDIF
     ENDFOR
    ENDIF
   ENDIF
  ENDIF
  CALL logmsg (debugflag ,build ("uar_CrmPerform returned:" ,iret ) )
  CALL logmsg (debugflag ,build ("****End Post Clinical Event, Return Code: " ,iret ) )
  IF (hstep )
   CALL uar_crmendreq (hstep )
   SET hstep = 0
  ENDIF
  IF (htask )
   CALL uar_crmendtask (htask )
   SET htask = 0
  ENDIF
  IF (happ )
   CALL uar_crmendapp (happ )
   SET happ = 0
  ENDIF
  RETURN (0 )
 END ;Subroutine
 SUBROUTINE  logmsg (flag ,message )
  DECLARE sfiledate = vc WITH protect ,noconstant ("" )
  DECLARE smsgtime = vc WITH protect ,noconstant ("" )
  DECLARE logfilename = vc WITH protect ,noconstant ("" )
  DECLARE slogmsg = vc WITH protect ,noconstant ("" )
  IF ((flag = 0 ) )
   RETURN (0 )
  ENDIF
  SET sfiledate = format (curdate ,"mmdd;;d" )
  SET smsgtime = substring (1 ,5 ,format (curtime3 ,"SS.CC;;S" ) )
  SET logfilename = fillstring (132 ," " )
  IF ((cursys = "AIX" ) )
   SET logfilename = concat ("cer_log:mmf_publish" ,trim (sfiledate ) ,".log" )
  ELSE
   SET logfilename = concat ("cer_log:mmf_publish" ,trim (sfiledate ) ,".log" )
  ENDIF
  SET slogmsg = fillstring (132 ," " )
  SET slogmsg = substring (1 ,80 ,build (smsgtime ,":" ,message ) )
  SELECT INTO value (logfilename )
   output = trim (slogmsg )
   WITH append ,format = stream ,noheading
  ;end select
  IF ((curqual > 0 ) )
   RETURN (1 )
  ELSE
   RETURN (- (1 ) )
  ENDIF
  CALL echo (slogmsg )
 END ;Subroutine
 SUBROUTINE  geteventcode (cvkey )
  CALL logmsg (debugflag ,"In getEventCode()" )
  DECLARE begin_date_time = dq8 WITH constant (cnvtdatetime (curdate ,curtime3 ) ) ,private
  DECLARE eventcd = f8 WITH protect ,noconstant (0.0 )
  DECLARE contributorsourcecd = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,73 ,
    "POWERCHART" ) )
  IF ((cvkey = "" ) )
   RETURN (eventcd )
  ENDIF
  SELECT INTO "nl:"
   FROM (code_value cv )
   WHERE (cv.code_set = 72 )
   AND (cv.display_key = cvkey )
   AND (cv.active_ind = 1 )
   DETAIL
    eventcd = cv.code_value
   WITH nocounter
  ;end select
  CALL logmsg (debugflag ,build ("Exit getEventCode():" ,eventcd ) )
  RETURN (eventcd )
 END ;Subroutine
 SUBROUTINE  getformat (identifier )
  CALL logmsg (debugflag ,"In getformat()" )
  DECLARE formatcd = f8 WITH protect ,noconstant (0.0 )
  DECLARE mediatype = vc WITH protect ,noconstant ("" )
  SET mediatype = ""
  SET formatcd = 0.0
  SELECT INTO "nl:"
   FROM (dms_media_identifier d1 ),
    (dms_media_instance d2 )
   PLAN (d1
    WHERE (d1.media_object_identifier = identifier ) )
    JOIN (d2
    WHERE (d2.dms_media_identifier_id = d1.dms_media_identifier_id ) )
   DETAIL
    mediatype = d2.media_type
   WITH maxqual (d1 ,1 )
  ;end select
  IF ((((findstring ("PDF" ,cnvtupper (mediatype ) ) > 0 ) ) OR ((cnvtupper (mediatype ) = "PDF" )
  )) )
   SET formatcd = format_pdf_cd
  ELSEIF ((((findstring ("XML" ,cnvtupper (mediatype ) ) > 0 ) ) OR ((cnvtupper (mediatype ) = "XML"
  ) )) )
   SET formatcd = format_xml_cd
  ENDIF
  CALL logmsg (debugflag ,build ("mediaType:" ,mediatype ,"  Code_value:" ,formatcd ) )
  RETURN (formatcd )
 END ;Subroutine
 SUBROUTINE  getobjectname (identifier )
  CALL logmsg (debugflag ,"In getObjectName()" )
  DECLARE medianame = vc WITH protect ,noconstant ("" )
  SET mediatype = ""
  SELECT INTO "nl:"
   FROM (dms_media_identifier d1 ),
    (dms_media_instance d2 )
   PLAN (d1
    WHERE (d1.media_object_identifier = identifier ) )
    JOIN (d2
    WHERE (d2.dms_media_identifier_id = d1.dms_media_identifier_id ) )
   DETAIL
    medianame = d2.name
   WITH maxqual (d1 ,1 )
  ;end select
  CALL logmsg (debugflag ,build ("object Name:" ,medianame ) )
  RETURN (medianame )
 END ;Subroutine
 SUBROUTINE  validateid (identifier )
  CALL logmsg (debugflag ,"In validateId()" )
  DECLARE validated = i4 WITH protect ,noconstant (0 )
  SELECT INTO "nl:"
   FROM (dms_media_identifier d1 )
   WHERE (d1.media_object_identifier = identifier )
   DETAIL
    validated = 1
   WITH maxqual (d1 ,1 )
  ;end select
  RETURN (validated )
 END ;Subroutine
END GO
