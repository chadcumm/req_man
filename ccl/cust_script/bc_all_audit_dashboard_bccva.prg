/*****************************************************************************
******************************************************************************
 
  Author:             Chad Cummings
  Date Written:       07/20/2021
  Solution:
  Source file name:   bc_all_audit_dashboard_bccva.prg
  Object name:        bc_all_audit_dashboard_bccva
  Request #:
 
  Program purpose:
 
  Executing from:
 
  Special Notes:
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod   Mod Date    Developer              Comment
---   ----------  --------------------  --------------------------------------
000   07/20/2021  Chad Cummings			Initial Release
001   09/09/2021  Miro Kralovic			CST-138570 - added generated_on column
002   11/29/2021  Miro Kralovic			CST-138570 - Adding FTP Output
003   12/08/2021  Chad Cummings			CST-131815 - Added Dashboard view
******************************************************************************/
drop program bc_all_audit_dashboard_bccva go
create program bc_all_audit_dashboard_bccva
 
prompt
	"Output to File/Printer/MINE" = "MINE"
	, "Send To File" = 0
 
with OUTDEV, SENDTOFILE
 
 
EXECUTE BC_ALL_ALL_DATE_ROUTINES
EXECUTE BC_ALL_ALL_STD_ROUTINES
 
;CREATE THE RECORD STRUCTURE THAT CCLIO() USES
FREE RECORD FREC
RECORD FREC(
     1 FILE_DESC = I4
     1 FILE_OFFSET = I4
     1 FILE_DIR = I4
     1 FILE_NAME = VC
     1 FILE_BUF = VC
)
 
 RECORD output_data (
   1 cnt = i4
   1 yesterday_start_dt_tm = dq8
   1 yesterday_end_dt_tm = dq8
   1 qual [* ]
     2 parent_event_id = f8
     2 ordered_dt_tm = dq8
     2 ordered_dt = vc
     2 requested_dt_tm = dq8
     2 requested_dt = vc
     2 requisition_type = vc
     2 printed_ind = i2
     2 printed_dt_tm = dq8
     2 printed_dt = vc
     2 processed_yesterday_ind = i2
     2 net_new_yesterday_ind = i2
     2 processed_ind = i2
     2 overdue_ind = i2
     2 current_req_status = vc
     2 req_status_dt_tm = dq8
     2 req_status_dt = vc
     2 calc_requested_dt_tm = dq8
     2 calc_request_dt = vc
     2 completed_dt_tm = dq8
     2 completed_dt = vc
     2 priority = vc
     2 unit = vc
     2 mrn = vc
     2 subtype = vc
     2 req_title = vc
     2 ordering_provider = vc
     2 ordering_provider_id = f8
     2 ordering_position = vc
     2 comment = vc
 ) with PERSISTSCRIPT
 
;start 003
record dashboard
(
	1 cnt = i2
	1 total_title = vc
	1 total_unproccessed = i2
	1 overdue = f8
	1 overdue_cnt = i2
	1 net_new_yesterday = i2
	1 processed_yesterday = i2
	1 qual[*]
	 2 requisition_type = vc
	 2 total_unproccessed = i2
	 2 overdue = f8
	 2 overdue_cnt = i2
	 2 net_new_yesterday = i2
	 2 processed_yesterday = i2
	 2 sort_order = i2
) with presistscript
 
;end 003
 
;SFTP variables
DECLARE vEXTRACT_FOLDER = VC WITH NOCONSTANT("reqstats/"), PROTECT
DECLARE vEXTRACT_NAME = VC WITH NOCONSTANT("BC_ALL_RM_BCCVA_DASH"), PROTECT ;003
DECLARE vEXTRACT_DT = VC WITH PROTECT
DECLARE vEXTRACT_EXT = VC WITH NOCONSTANT(".csv"), PROTECT
DECLARE vEXTRACT_FULL = VC WITH PROTECT
DECLARE vFILE_NAME = C32 WITH PROTECT
DECLARE vDELIM = VC WITH NOCONSTANT(","), PROTECT
DECLARE vCRLF = VC WITH NOCONSTANT(CONCAT(CHAR(13),CHAR(10))), PROTECT
DECLARE vFILEERROR = VC WITH NOCONSTANT(""), PROTECT
DECLARE vPRINT_LINE = VC WITH PROTECT
 
SET vEXTRACT_DT = FORMAT(SYSDATE, "YYYYMMDD;;Q")
SET vFILE_NAME = CONCAT(vEXTRACT_NAME, "_", vEXTRACT_DT)
 
 
 
 
execute 2req_cust_mp_req_by_loc_dt
 
^NOFORMS^,
15058148.0,
441.0,
^01-Jan-1900^,
^01-Jan-1900^,
^01-Jan-1900^,
^01-Jan-1900^,
value(2746657235,
2746657287,
2577403165,
2746665421,
2746662521,
2746662535,
2746662573,
2746662693,
2746665769,
2746659423,
2746659575,
2746662833,
2746662861,
2746666247,
2746662987,
2746666467,
2577412455,
2577412597,
2577354123,
2577409213,
2577360247,
2577360271,
2577360327,
2577361393,
2577385529,
2577364489,
2577364017,
2577414579,
2577364377,
2577368831,
2577369305,
2577369563,
2577364075,
2577364179,
2577363963,
2577365663,
2577414499,
2577365833,
2600476497,
2577414489,
2600476341,
2577368469,
2577370499,
2577389513,
2577459079,
2725736953,
2713624087,
2713624135,
2713620537,
2713620547,
2713627613,
2713620659,
2713624149,
2713700745,
2713620673,
2713624197,
2713624207,
2713624267,
2577460239,
2577469023,
2577465705,
2577469103,
2577469189,
2577465959,
2577469659,
2577467949,
2577471349,
2577473307,
2577471525,
2577471461,
2577473329,
2577471235,
2577468145,
2577468389,
2577473069,
2577468471,
2577472833,
2600476395,
2577468581,
2710693693,
2710693663,
2710691655,
2710683879,
2698730657,
2698724117,
2710691729,
2710691719,
2710691805,
2698727399,
2698731379,
2710691639,
2698731465,
2698731507,
2698724307,
2710691815,
2698727861,
2698725973,
2710683767,
2700299835,
2698725017,
2698728071,
2698732479,
2698732935,
2710691769,
2710691783,
2698734049,
2710683889,
2698734241,
2698734253,
2577408783,
2577414375,
2577414387,
2577413201,
2700246825,
2577396703,
2704370689,
2700277951,
2710709571,
2704355437,
2577423569,
2577387251,
2577387299,
2577387381,
2577387495,
2577383651,
2577386719,
2577387921,
2577384581,
2577384057,
2577383965,
2577384183,
2577384517,
2577388941,
2577387799,
2577383975,
2600473891,
2577387013,
2600474031,
2577388651,
2577387975,
2587628273,
2587680959,
2587694581,
2587712199,
2588015555),
value(0),
value(0),
^Any Date^,
^Any Date^
 
;start 003
select into "nl:"
	req_type = substring(1,100,output_data->qual[d1.seq].requisition_type)
from
		(dummyt d1 with seq=output_data->cnt)
	plan d1
		;where output_data->qual[d1.seq].processed_ind in(0 )
		;and   output_data->qual[d1.seq].overdue_ind in(0, 1)
		;and   output_data->qual[d1.seq].subtype > " "
		;and   output_data->qual[d1.seq].priority > " "
order by
	req_type
head report
	i = 0
head req_type
	i = (i + 1)
	stat = alterlist(dashboard->qual,i)
	dashboard->qual[i].requisition_type = output_data->qual[d1.seq].requisition_type
	dashboard->qual[i].sort_order = i
foot report
	dashboard->cnt = i
with nocounter
 
 
declare unp = i4 with noconstant(0)
declare overdue = i4 with noconstant(0)
 
for (i=1 to dashboard->cnt)
	select into "nl:"
	from
		(dummyt d1 with seq=output_data->cnt)
	plan d1
		where output_data->qual[d1.seq].processed_ind in(0,1 )
		and   output_data->qual[d1.seq].overdue_ind in(0, 1)
		and   output_data->qual[d1.seq].subtype > " "
		and   output_data->qual[d1.seq].priority > " "
		and   output_data->qual[d1.seq].requisition_type = dashboard->qual[i].requisition_type
	head report
		unp = 0
		overdue = 0
		/*
		2 requisition_type = vc
	 	2 total_unproccessed = i2
	 	2 overdue = f8
		2 net_new_yesterday = i2
		2 processed_yesterday = i2
	 	*/
	detail
		if (output_data->qual[d1.seq].processed_ind = 0)
			dashboard->qual[i].total_unproccessed = (dashboard->qual[i].total_unproccessed + 1)
		endif
		if (output_data->qual[d1.seq].overdue_ind = 1)
			dashboard->qual[i].overdue_cnt = (dashboard->qual[i].overdue_cnt + 1)
		endif
		if (output_data->qual[d1.seq].processed_yesterday_ind = 1)
			dashboard->qual[i].processed_yesterday = (dashboard->qual[i].processed_yesterday + 1)
		endif
		if (output_data->qual[d1.seq].net_new_yesterday_ind = 1)
			dashboard->qual[i].net_new_yesterday = (dashboard->qual[i].net_new_yesterday + 1)
		endif
	foot report
		dashboard->qual[i].overdue = ((1.0*dashboard->qual[i].overdue_cnt) / (1.0*dashboard->qual[i].total_unproccessed))
		call echo((1.0*dashboard->qual[i].overdue_cnt) / (1.0*dashboard->qual[i].total_unproccessed))
	with nocounter
 
	set dashboard->total_unproccessed = (dashboard->total_unproccessed + dashboard->qual[i].total_unproccessed)
	set dashboard->processed_yesterday = (dashboard->processed_yesterday + dashboard->qual[i].processed_yesterday)
	set dashboard->net_new_yesterday = (dashboard->net_new_yesterday + dashboard->qual[i].net_new_yesterday)
 
endfor
 
set	i = (dashboard->cnt + 1)
set	stat = alterlist(dashboard->qual,i)
set	dashboard->qual[i].requisition_type = "Total"
set	dashboard->qual[i].sort_order = i
set	dashboard->qual[i].total_unproccessed = dashboard->total_unproccessed
set	dashboard->qual[i].processed_yesterday = dashboard->processed_yesterday
set	dashboard->qual[i].net_new_yesterday = dashboard->net_new_yesterday
set dashboard->cnt = (dashboard->cnt + 1)
call echorecord(dashboard)
 
IF($SENDTOFILE = 0) ;display mode
	select into $OUTDEV
		 requisition_type		= substring(1,75,dashboard->qual[d1.seq].requisition_type)
		,total_unproccessed		= dashboard->qual[d1.seq].total_unproccessed
		,overdue				= dashboard->qual[d1.seq].overdue
		,net_new_yesterday		= dashboard->qual[d1.seq].net_new_yesterday
		,processed_yesterday	= dashboard->qual[d1.seq].processed_yesterday
	from
		(dummyt d1 with seq=dashboard->cnt)
	plan d1
	with format,separator= " "
ELSE
	select into "NL:"
		 requisition_type		= substring(1,75,dashboard->qual[d1.seq].requisition_type)
		,total_unproccessed		= dashboard->qual[d1.seq].total_unproccessed
		,overdue				= dashboard->qual[d1.seq].overdue
		,net_new_yesterday		= dashboard->qual[d1.seq].net_new_yesterday
		,processed_yesterday	= dashboard->qual[d1.seq].processed_yesterday
	from
		(dummyt d1 with seq=dashboard->cnt)
	plan d1
 
	HEAD REPORT
		FREC->FILE_NAME = sSFTP_FileNameTmp(TRIM(vEXTRACT_FOLDER, 3), TRIM(vFILE_NAME, 3))
		FREC->FILE_BUF = "w"
		STAT = CCLIO("OPEN", FREC)
		FREC->FILE_BUF = " "
 
		vPRINT_LINE = CONCAT( "REQUISITION_TYPE", vDELIM
							, "TOTAL_UNPROCCESSED", vDELIM
							, "OVERDUE", vDELIM
							, "NET_NEW_YESTERDAY", vDELIM
							, "PROCESSED_YESTERDAY", vCRLF
							)
 
		FREC->FILE_BUF = vPRINT_LINE
		STAT = CCLIO("PUTS", FREC)
 
	DETAIL
		vPRINT_LINE = " "
		vPRINT_LINE = CONCAT(vPRINT_LINE, ^"^, TRIM(requisition_type, 3), ^"^, vDELIM)
		vPRINT_LINE = CONCAT(vPRINT_LINE, ^"^, cnvtstring(total_unproccessed, 3), ^"^, vDELIM)
		vPRINT_LINE = CONCAT(vPRINT_LINE, ^"^, cnvtstring(overdue, 3), ^"^, vDELIM)
		vPRINT_LINE = CONCAT(vPRINT_LINE, ^"^, cnvtstring(net_new_yesterday, 3), ^"^, vDELIM)
		vPRINT_LINE = CONCAT(vPRINT_LINE, ^"^, cnvtstring(processed_yesterday, 3), ^"^, vCRLF)
 
		FREC->FILE_BUF = vPRINT_LINE
		STAT = CCLIO("PUTS", FREC)
 
	FOOT REPORT
		;close file
		STAT = CCLIO("CLOSE",FREC)
 
		IF (FREC->FILE_BUF != " " AND STAT = 0)
			vFILEERROR = CONCAT (vFILEERROR,",",TRIM(FREC->FILE_NAME,3))
		ELSE
			CALL sSFTP_RenameExt( TRIM(vEXTRACT_FOLDER, 3), TRIM(vFILE_NAME, 3), TRIM(vEXTRACT_EXT, 3) )
			vEXTRACT_FULL = BUILD( TRIM(vEXTRACT_FOLDER, 3), TRIM(vFILE_NAME, 3), TRIM(vEXTRACT_EXT, 3) )
			vFILEERROR = "None"
		ENDIF
 
 
	with format,separator= " "
 
	;DISPLAY CONFIRMATION
 	SELECT INTO $OUTDEV
    FROM DUMMYT D
    DETAIL
		COL 1, "Extract Complete"
		ROW + 1
		COL 1, "File > "
		ROW + 1
		COL 4, vEXTRACT_FULL
		row + 1
		COL 1, "Error(s) > "
		ROW + 1
		COL 4, vFILEERROR
		ROW + 1
 
    WITH NOCOUNTER, NOHEADING, NOFORMAT
ENDIF
;end 003
 
/*
 
IF($SENDTOFILE = 0) ;display mode
	select into $OUTDEV
		 mrn					= substring(1,50,output_data->qual[d1.seq].mrn)
		,requisition_type		= substring(1,75,output_data->qual[d1.seq].requisition_type)
		,subtype				= substring(1,75,output_data->qual[d1.seq].subtype)
		,priority				= substring(1,50,output_data->qual[d1.seq].priority)
		,requisition_title		= substring(1,200,output_data->qual[d1.seq].req_title)
		,ordered_dt				= substring(1,12,output_data->qual[d1.seq].ordered_dt)
		,requested_dt			= substring(1,12,output_data->qual[d1.seq].requested_dt)
		,overdue_ind			= output_data->qual[d1.seq].overdue_ind
		,generated_on			= FORMAT(sysdate,"DD-MMM-YYYY HH:MM:SS;;Q") ;001
	from
		(dummyt d1 with seq=output_data->cnt)
	plan d1
		where output_data->qual[d1.seq].processed_ind in(0 )
		and   output_data->qual[d1.seq].overdue_ind in(0, 1)
		and   output_data->qual[d1.seq].subtype > " "
		and   output_data->qual[d1.seq].priority > " "
	with format,separator= " "
ELSE
	select into "NL:"
		 mrn					= substring(1,50,output_data->qual[d1.seq].mrn)
		,requisition_type		= substring(1,75,output_data->qual[d1.seq].requisition_type)
		,subtype				= substring(1,75,output_data->qual[d1.seq].subtype)
		,priority				= substring(1,50,output_data->qual[d1.seq].priority)
		,requisition_title		= substring(1,200,output_data->qual[d1.seq].req_title)
		,ordered_dt				= substring(1,12,output_data->qual[d1.seq].ordered_dt)
		,requested_dt			= substring(1,12,output_data->qual[d1.seq].requested_dt)
		,overdue_ind			= IF(output_data->qual[d1.seq].overdue_ind=1) "1" ELSE "0" ENDIF
		,generated_on			= FORMAT(sysdate,"DD-MMM-YYYY HH:MM:SS;;Q") ;001
	from
		(dummyt d1 with seq=output_data->cnt)
	plan d1
		where output_data->qual[d1.seq].processed_ind in(0 )
		and   output_data->qual[d1.seq].overdue_ind in(0, 1)
		and   output_data->qual[d1.seq].subtype > " "
		and   output_data->qual[d1.seq].priority > " "
 
	HEAD REPORT
		FREC->FILE_NAME = sSFTP_FileNameTmp(TRIM(vEXTRACT_FOLDER, 3), TRIM(vFILE_NAME, 3))
		FREC->FILE_BUF = "w"
		STAT = CCLIO("OPEN", FREC)
		FREC->FILE_BUF = " "
 
		vPRINT_LINE = CONCAT( "MRN", vDELIM
							, "REQUISITION_TYPE", vDELIM
							, "SUBTYPE", vDELIM
							, "PRIORITY", vDELIM
							, "REQUISITION_TITLE", vDELIM
							, "ORDERED_DT", vDELIM
							, "REQUESTED_DT", vDELIM
							, "OVERDUE_IND", vDELIM
							, "GENERATED_ON", vCRLF
							)
 
		FREC->FILE_BUF = vPRINT_LINE
		STAT = CCLIO("PUTS", FREC)
 
	DETAIL
		vPRINT_LINE = " "
		vPRINT_LINE = CONCAT(vPRINT_LINE, ^"^, TRIM(MRN, 3), ^"^, vDELIM)
		vPRINT_LINE = CONCAT(vPRINT_LINE, ^"^, TRIM(REQUISITION_TYPE, 3), ^"^, vDELIM)
		vPRINT_LINE = CONCAT(vPRINT_LINE, ^"^, TRIM(SUBTYPE, 3), ^"^, vDELIM)
		vPRINT_LINE = CONCAT(vPRINT_LINE, ^"^, TRIM(PRIORITY, 3), ^"^, vDELIM)
		vPRINT_LINE = CONCAT(vPRINT_LINE, ^"^, TRIM(REQUISITION_TITLE, 3), ^"^, vDELIM)
		vPRINT_LINE = CONCAT(vPRINT_LINE, ^"^, TRIM(ORDERED_DT, 3), ^"^, vDELIM)
		vPRINT_LINE = CONCAT(vPRINT_LINE, ^"^, TRIM(REQUESTED_DT, 3), ^"^, vDELIM)
		vPRINT_LINE = CONCAT(vPRINT_LINE, ^"^, TRIM(OVERDUE_IND, 3), ^"^, vDELIM)
		vPRINT_LINE = CONCAT(vPRINT_LINE, ^"^, TRIM(GENERATED_ON, 3), ^"^, vCRLF)
 
		FREC->FILE_BUF = vPRINT_LINE
		STAT = CCLIO("PUTS", FREC)
 
	FOOT REPORT
		;close file
		STAT = CCLIO("CLOSE",FREC)
 
		IF (FREC->FILE_BUF != " " AND STAT = 0)
			vFILEERROR = CONCAT (vFILEERROR,",",TRIM(FREC->FILE_NAME,3))
		ELSE
			CALL sSFTP_RenameExt( TRIM(vEXTRACT_FOLDER, 3), TRIM(vFILE_NAME, 3), TRIM(vEXTRACT_EXT, 3) )
			vEXTRACT_FULL = BUILD( TRIM(vEXTRACT_FOLDER, 3), TRIM(vFILE_NAME, 3), TRIM(vEXTRACT_EXT, 3) )
			vFILEERROR = "None"
		ENDIF
 
 
	with format,separator= " "
 
	;DISPLAY CONFIRMATION
 	SELECT INTO $OUTDEV
    FROM DUMMYT D
    DETAIL
		COL 1, "Extract Complete"
		ROW + 1
		COL 1, "File > "
		ROW + 1
		COL 4, vEXTRACT_FULL
		row + 1
		COL 1, "Error(s) > "
		ROW + 1
		COL 4, vFILEERROR
		ROW + 1
 
    WITH NOCOUNTER, NOHEADING, NOFORMAT
ENDIF
*/
end go
 