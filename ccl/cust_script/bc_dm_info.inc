 
/*********************************************
** Request Structure For GOLD MASTER INSERT **
*********************************************/
record atg_dminfo_reqi
(
    1 allow_partial_ind = i2
    1 info_domaini = i2
    1 info_namei = i2
    1 info_datei = i2
    1 info_daten = i2
    1 info_chari = i2
    1 info_charn = i2
    1 info_numberi = i2
    1 info_numbern = i2
    1 info_long_idi = i2
    1 qual[*]
      2 info_domain = c80
      2 info_name = c255
      2 info_date = dq8
      2 info_char = c255
      2 info_number = f8
      2 info_long_id = f8
)
 
/*********************************************
** Request Structure For GOLD MASTER UPDATE **
*********************************************/
record atg_dminfo_reqw
(
    1 allow_partial_ind = i2
    1 force_updt_ind = i2
    ;where_clause indicator fields
    1 info_domainw = i2
    1 info_namew = i2
    1 info_datew = i2
    1 info_charw = i2
    1 info_numberw = i2
    1 info_long_idw = i2
    1 updt_applctxw = i2
    1 updt_dt_tmw = i2
    1 updt_cntw = i2
    1 updt_idw = i2
    1 updt_taskw = i2
    1 info_domainf = i2
    1 info_namef = i2
    1 info_datef = i2
    1 info_charf = i2
    1 info_numberf = i2
    1 info_long_idf = i2
    1 updt_cntf = i2
    1 qual[*]
      2 info_domain = c80
      2 info_name = c255
      2 info_date = dq8
      2 info_char = c255
      2 info_number = f8
      2 info_long_id = f8
      2 updt_applctx = i4
      2 updt_dt_tm = dq8
      2 updt_cnt = i4
      2 updt_id = f8
      2 updt_task = i4
)
 
/*********************************************
** Request Structure For GOLD MASTER DELETE **
*********************************************/
record atg_dminfo_reqd
(
 1 allow_partial_ind = i2
 ;where_clause indicator fields
 1 info_domainw = i2
 1 info_namew = i2
 1 qual[*]
   2 info_domain = c80
   2 info_name = c255
)
 
 
/*********************************************
** Reply Structure For GOLD MASTER SCRIPTS  **
*********************************************/
record atg_dminfo_rep
(
   1 curqual = i4
   1 qual[*]
     2 status = i2
     2 error_num = i4
     2 error_msg = vc
    2 info_domain = c80
    2 info_name = c255
%i cclsource:status_block.inc
)
 
/**********************************************************
** Function GET_DMINFO_NUMBER()                          **
** ----------------------------                          **
** Returns the INFO_NUMBER for a given DOMAIN/NAME key.  **
** Parameters are for fields INFO_DOMAIN & INFO_NAME.    **
**********************************************************/
declare    get_dminfo_number(sdomain, sname) = f8
subroutine get_dminfo_number(sdomain, sname)
  declare datgdminfovalue 	= f8 with protect, noconstant(0.0)
 
  select into "nl"
  from dm_info di
  plan di
  where di.info_domain = sdomain
    and di.info_name   = sname
  detail
    datgdminfovalue = di.info_number
  with nocounter
 
  return (datgdminfovalue)
end
 
/**********************************************************
** Function GET_DMINFO_CHAR()                            **
** ----------------------------                          **
** Returns the INFO_CHAR for a given DOMAIN/NAME key.    **
** Parameters are for fields INFO_DOMAIN & INFO_NAME.    **
**********************************************************/
declare    get_dminfo_char(sdomain, sname) = c255
subroutine get_dminfo_char(sdomain, sname)
  declare satgdminfovalue 	= c255 with protect, noconstant("")
 
  select into "nl"
  from dm_info di
  plan di
  where di.info_domain = sdomain
    and di.info_name   = sname
  detail
    satgdminfovalue = di.info_char
  with nocounter
 
  return (satgdminfovalue)
end
 
/**********************************************************
** Function GET_DMINFO_DATE()                            **
** ----------------------------                          **
** Returns the INFO_DATE for a given DOMAIN/NAME key.    **
** Parameters are for fields INFO_DOMAIN & INFO_NAME.    **
**********************************************************/
declare    get_dminfo_date(sdomain, sname) = dq8
subroutine get_dminfo_date(sdomain, sname)
  declare dtatgdminfovalue 	= dq8 with protect, noconstant
 
  select into "nl"
  from dm_info di
  plan di
  where di.info_domain = sdomain
    and di.info_name   = sname
  detail
    dtatgdminfovalue = cnvtdatetime(di.info_date)
  with nocounter
 
  return (dtatgdminfovalue)
end
 
/**********************************************************
** Function GET_DMINFO_LONGID()                          **
** ----------------------------                          **
** Returns the INFO_LONG_ID for a given DOMAIN/NAME key. **
** Parameters are for fields INFO_DOMAIN & INFO_NAME.    **
**********************************************************/
declare    get_dminfo_longid(sdomain, sname) = f8
subroutine get_dminfo_longid(sdomain, sname)
  declare datgdminfovalue 	= f8 with protect, noconstant(0.0)
 
  select into "nl"
  from dm_info di
  plan di
  where di.info_domain = sdomain
    and di.info_name   = sname
  detail
    datgdminfovalue = di.info_long_id
  with nocounter
 
  return (datgdminfovalue)
end
 
/**********************************************************
** SET ROUTINE SET_DMINFO_NUMBER()                       **
** ----------------------------                          **
** SETs the INFO_NUMBER for a given DOMAIN/NAME key.     **
** Parameters are for fields INFO_DOMAIN & INFO_NAME     **
** And Value.  This routine will call the GOLD MASTER.   **
**********************************************************/
subroutine set_dminfo_number(sdomain, sname, dvalue)
 
  call clear_dminfo(null)
 
  select into "nl:"
  from dm_info di
  plan di
  where di.info_domain = sdomain
    and di.info_name   = sname
  with nocounter
 
  if (curqual = 0)
    set stat = alterlist(atg_dminfo_reqi->qual, 1)
    set atg_dminfo_reqi->qual[1]->info_domain 	= sdomain
    set atg_dminfo_reqi->qual[1]->info_name   	= sname
    set atg_dminfo_reqi->qual[1]->info_number 	= dvalue
    set atg_dminfo_reqi->info_domaini		= 1
    set atg_dminfo_reqi->info_namei 		= 1
    set atg_dminfo_reqi->info_numberi		= 1
    execute gm_i_dm_info2388 with replace("REQUEST","ATG_DMINFO_REQI"),
    				  replace("REPLY", "ATG_DMINFO_REP")
  else
    set stat = alterlist(atg_dminfo_reqw->qual, 1)
    set atg_dminfo_reqw->qual[1]->info_domain 	= sdomain
    set atg_dminfo_reqw->qual[1]->info_name   	= sname
    set atg_dminfo_reqw->qual[1]->info_number 	= dvalue
    set atg_dminfo_reqw->info_domainw		= 1
    set atg_dminfo_reqw->info_namew 		= 1
    set atg_dminfo_reqw->info_numberf		= 1
    set atg_dminfo_reqw->force_updt_ind		= 1
    execute gm_u_dm_info2388 with replace("REQUEST","ATG_DMINFO_REQW"),
    				  replace("REPLY", "ATG_DMINFO_REP")
  endif
 
  if (reqinfo->commit_ind = 1)
    commit
  endif
end
 
 
/**********************************************************
** SET ROUTINE SET_DMINFO_DATE()                         **
** ----------------------------                          **
** SETs the INFO_DATE for a given DOMAIN/NAME key.       **
** Parameters are for fields INFO_DOMAIN & INFO_NAME     **
** And Value.  This routine will call the GOLD MASTER.   **
**********************************************************/
subroutine set_dminfo_date(sdomain, sname, dtvalue)
 
  call clear_dminfo(null)
 
  select into "nl:"
  from dm_info di
  plan di
  where di.info_domain = sdomain
    and di.info_name   = sname
  with nocounter
 
 
  if (curqual = 0)
    set stat = alterlist(atg_dminfo_reqi->qual, 1)
    set atg_dminfo_reqi->qual[1]->info_domain 	= sdomain
    set atg_dminfo_reqi->qual[1]->info_name   	= sname
    set atg_dminfo_reqi->qual[1]->info_date 	= cnvtdatetime(dtvalue)
    set atg_dminfo_reqi->info_domaini		= 1
    set atg_dminfo_reqi->info_namei 		= 1
    set atg_dminfo_reqi->info_datei		= 1
    execute gm_i_dm_info2388 with replace("REQUEST","ATG_DMINFO_REQI"),
    				  replace("REPLY", "ATG_DMINFO_REP")
  else
    set stat = alterlist(atg_dminfo_reqw->qual, 1)
    set atg_dminfo_reqw->qual[1]->info_domain 	= sdomain
    set atg_dminfo_reqw->qual[1]->info_name   	= sname
    set atg_dminfo_reqw->qual[1]->info_date 	= cnvtdatetime(dtvalue)
    set atg_dminfo_reqw->info_domainw		= 1
    set atg_dminfo_reqw->info_namew 		= 1
    set atg_dminfo_reqw->info_datef		= 1
    set atg_dminfo_reqw->force_updt_ind		= 1
    execute gm_u_dm_info2388 with replace("REQUEST","ATG_DMINFO_REQW"),
    				  replace("REPLY", "ATG_DMINFO_REP")
  endif
 
  if (reqinfo->commit_ind = 1)
    commit
  endif
end
 
/**********************************************************
** SET ROUTINE SET_DMINFO_CHAR()                         **
** ----------------------------                          **
** SETs the INFO_CHAR for a given DOMAIN/NAME key.       **
** Parameters are for fields INFO_DOMAIN & INFO_NAME     **
** And Value.  This routine will call the GOLD MASTER.   **
**********************************************************/
subroutine set_dminfo_char(sdomain, sname, svalue)
 
  call clear_dminfo(null)
 
  select into "nl:"
  from dm_info di
  plan di
  where di.info_domain = sdomain
    and di.info_name   = sname
  with nocounter
 
 
  if (curqual = 0)
    set stat = alterlist(atg_dminfo_reqi->qual, 1)
    set atg_dminfo_reqi->qual[1]->info_domain 	= sdomain
    set atg_dminfo_reqi->qual[1]->info_name   	= sname
    set atg_dminfo_reqi->qual[1]->info_char 	= svalue
    set atg_dminfo_reqi->info_domaini		= 1
    set atg_dminfo_reqi->info_namei 		= 1
    set atg_dminfo_reqi->info_chari		= 1
    execute gm_i_dm_info2388 with replace("REQUEST","ATG_DMINFO_REQI"),
    				  replace("REPLY", "ATG_DMINFO_REP")
  else
    set stat = alterlist(atg_dminfo_reqw->qual, 1)
    set atg_dminfo_reqw->qual[1]->info_domain 	= sdomain
    set atg_dminfo_reqw->qual[1]->info_name   	= sname
    set atg_dminfo_reqw->qual[1]->info_char 	= svalue
    set atg_dminfo_reqw->info_domainw		= 1
    set atg_dminfo_reqw->info_namew 		= 1
    set atg_dminfo_reqw->info_charf		= 1
    set atg_dminfo_reqw->force_updt_ind		= 1
    execute gm_u_dm_info2388 with replace("REQUEST","ATG_DMINFO_REQW"),
    				  replace("REPLY", "ATG_DMINFO_REP")
  endif
 
  if (reqinfo->commit_ind = 1)
    commit
  endif
end
 
/**********************************************************
** SET ROUTINE SET_DMINFO_LONGID()                       **
** ----------------------------                          **
** SETs the INFO_LONG_ID for a given DOMAIN/NAME key.    **
** Parameters are for fields INFO_DOMAIN & INFO_NAME     **
** And Value.  This routine will call the GOLD MASTER.   **
**********************************************************/
subroutine set_dminfo_longid(sdomain, sname, dvalue)
 
  call clear_dminfo(null)
 
  select into "nl:"
  from dm_info di
  plan di
  where di.info_domain = sdomain
    and di.info_name   = sname
  with nocounter
 
 
  if (curqual = 0)
    set stat = alterlist(atg_dminfo_reqi->qual, 1)
    set atg_dminfo_reqi->qual[1]->info_domain 	= sdomain
    set atg_dminfo_reqi->qual[1]->info_name   	= sname
    set atg_dminfo_reqi->qual[1]->info_long_id 	= dvalue
    set atg_dminfo_reqi->info_domaini		= 1
    set atg_dminfo_reqi->info_namei 		= 1
    set atg_dminfo_reqi->info_long_idi		= 1
    execute gm_i_dm_info2388 with replace("REQUEST","ATG_DMINFO_REQI"),
    				  replace("REPLY", "ATG_DMINFO_REP")
  else
    set stat = alterlist(atg_dminfo_reqw->qual, 1)
    set atg_dminfo_reqw->qual[1]->info_domain 	= sdomain
    set atg_dminfo_reqw->qual[1]->info_name   	= sname
    set atg_dminfo_reqw->qual[1]->info_long_id 	= dvalue
    set atg_dminfo_reqw->info_domainw		= 1
    set atg_dminfo_reqw->info_namew 		= 1
    set atg_dminfo_reqw->info_long_idf		= 1
    set atg_dminfo_reqw->force_updt_ind		= 1
    execute gm_u_dm_info2388 with replace("REQUEST","ATG_DMINFO_REQW"),
    				  replace("REPLY", "ATG_DMINFO_REP")
  endif
 
  if (reqinfo->commit_ind = 1)
    commit
  endif
end
 
/**********************************************************
** REMOVE Routine REMOVE_DMINFO()                        **
** ----------------------------                          **
** This routine will delete a given DM_INFO row based on **
** the INFO_DOMAIN & INFO_NAME.                          **
**********************************************************/
subroutine remove_dminfo(sdomain, sname)
  call clear_dminfo(null)
 
  set stat = alterlist(atg_dminfo_reqd->qual, 1)
  set atg_dminfo_reqd->qual[1]->info_domain 	= sdomain
  set atg_dminfo_reqd->qual[1]->info_name   	= sname
  set atg_dminfo_reqd->info_domainw		= 1
  set atg_dminfo_reqd->info_namew 		= 1
  execute gm_d_dm_info2388 with replace("REQUEST","ATG_DMINFO_REQD"),
				replace("REPLY", "ATG_DMINFO_REP")
  if (reqinfo->commit_ind = 1)
    commit
  endif
end
 
/**********************************************************
** CLEAR Routine CLEAR_DMINFO()                        **
** ----------------------------                          **
** This is a PRIVATE ROUTINE and should NOT be called   **
** directly by your program. It is only to be called by **
** the functions above.                                 **
**********************************************************/
subroutine clear_dminfo(null)
  if (currev = 8)
    ;initrec only exists in rev 8.x
    set stat = initrec(atg_dminfo_reqi)
    set stat = initrec(atg_dminfo_reqw)
    set stat = initrec(atg_dminfo_reqd)
  else
    ;insert
    set stat = alterlist(atg_dminfo_reqi->qual, 0)
    set atg_dminfo_reqi->allow_partial_ind 	= 0
    set atg_dminfo_reqi->info_domaini 		= 0
    set atg_dminfo_reqi->info_namei 		= 0
    set atg_dminfo_reqi->info_datei 		= 0
    set atg_dminfo_reqi->info_daten 		= 0
    set atg_dminfo_reqi->info_chari 		= 0
    set atg_dminfo_reqi->info_charn 		= 0
    set atg_dminfo_reqi->info_numberi 		= 0
    set atg_dminfo_reqi->info_numbern 		= 0
    set atg_dminfo_reqi->info_long_idi 		= 0
 
    ;update
    set stat = alterlist(atg_dminfo_reqw->qual, 0)
    set atg_dminfo_reqw->allow_partial_ind 	= 0
    set atg_dminfo_reqw->force_updt_ind 	= 0
    set atg_dminfo_reqw->info_domainw 		= 0
    set atg_dminfo_reqw->info_namew 		= 0
    set atg_dminfo_reqw->info_datew 		= 0
    set atg_dminfo_reqw->info_charw 		= 0
    set atg_dminfo_reqw->info_numberw 		= 0
    set atg_dminfo_reqw->info_long_idw 		= 0
    set atg_dminfo_reqw->updt_applctxw 		= 0
    set atg_dminfo_reqw->updt_dt_tmw 		= 0
    set atg_dminfo_reqw->updt_cntw 		= 0
    set atg_dminfo_reqw->updt_idw 		= 0
    set atg_dminfo_reqw->updt_taskw 		= 0
    set atg_dminfo_reqw->info_domainf 		= 0
    set atg_dminfo_reqw->info_namef 		= 0
    set atg_dminfo_reqw->info_datef 		= 0
    set atg_dminfo_reqw->info_charf 		= 0
    set atg_dminfo_reqw->info_numberf 		= 0
    set atg_dminfo_reqw->info_long_idf 		= 0
    set atg_dminfo_reqw->updt_cntf 		= 0
 
    ;delete
    set stat = alterlist(atg_dminfo_reqd->qual, 0)
    set atg_dminfo_reqd->allow_partial_ind 	= 0
    set atg_dminfo_reqd->info_domainw 		= 0
    set atg_dminfo_reqd->info_namew 		= 0
 
  endif
end
 