drop program bc_combine_req_ops go
create program bc_combine_req_ops

%i cust_script:bc_dm_info.inc

if (not(validate(reply,0)))
	record  reply
	(
		1 text = vc
		1 status_data
		 2 status = c1
		 2 subeventstatus[1]
		  3 operationname = c15
		  3 operationstatus = c1
		  3 targetobjectname = c15
		  3 targetobjectvalue = c100
	) with protect
endif

set reply->status_data.status = "F"

record b_rec
(
	1 dminfo_date
	 2 current
	  3 sdomain		= vc
	  3 sname		= vc
	  3 dtvalue		= dq8		
	 2 updated
	  3 sdomain		= vc
	  3 sname		= vc
	  3 dtvalue		= dq8
	1 dates
	 2 start_dt_tm	= dq8
	 2 end_dt_tm 	= dq8
	;set_dminfo_date(sdomain, sname, dtvalue)
	;get_dminfo_date(sdomain, sname)
	1 pc_cnt				= i2
	1 pc_qual[*]	
	  2 person_combine_id	= f8
	  2 from_person_id		= f8
	  2 to_person_id		= f8
	  2 cmb_dt_tm			= dq8
	  2 ucb_dt_tm			= dq8
	  2 active_ind			= i2
) with protect

declare link_encntrid 	= f8 with noconstant(0.0), protect
declare link_personid 	= f8 with noconstant(0.0), protect
declare i 				= i2 with noconstant(0), protect
declare k 				= i2 with noconstant(0), protect
declare pos				= i2 with noconstant(0), protect

set b_rec->dminfo_date.current.sdomain 	= "REQUISITION_MANAGER"
set b_rec->dminfo_date.current.sname	= "COMBINE_OPS"
set b_rec->dminfo_date.current.dtvalue	= get_dminfo_date(b_rec->dminfo_date.current.sdomain,b_rec->dminfo_date.current.sname)

set b_rec->dates.end_dt_tm = cnvtdatetime(curdate,curtime3)
if (b_rec->dminfo_date.current.dtvalue = 0.0)
	set b_rec->dates.start_dt_tm = cnvtdatetime(curdate,curtime3)
else
	set b_rec->dates.start_dt_tm = b_rec->dminfo_date.current.dtvalue
endif


select into "nl:"
from
	person_combine pc
plan pc
	where pc.updt_dt_tm 
							between cnvtdatetime(b_rec->dates.start_dt_tm) 
							and 	cnvtdatetime(b_rec->dates.end_dt_tm)
head report
	b_rec->pc_cnt = 0
	j = 0
detail
	pos = locateval(j,1,b_rec->pc_cnt,pc.to_person_id,b_rec->pc_qual[j].to_person_id)
	if (pos = 0)
		b_rec->pc_cnt = (b_rec->pc_cnt + 1)
		stat = alterlist(b_rec->pc_qual,b_rec->pc_cnt)
		b_rec->pc_qual[b_rec->pc_cnt].active_ind			= pc.active_ind
		b_rec->pc_qual[b_rec->pc_cnt].cmb_dt_tm				= pc.cmb_dt_tm
		b_rec->pc_qual[b_rec->pc_cnt].from_person_id		= pc.from_person_id
		b_rec->pc_qual[b_rec->pc_cnt].person_combine_id		= pc.person_combine_id
		b_rec->pc_qual[b_rec->pc_cnt].to_person_id			= pc.to_person_id
		b_rec->pc_qual[b_rec->pc_cnt].ucb_dt_tm				= pc.ucb_dt_tm
	endif
with nocounter

set b_rec->dminfo_date.updated.sname 	= b_rec->dminfo_date.current.sname
set b_rec->dminfo_date.updated.sdomain 	= b_rec->dminfo_date.current.sdomain
set b_rec->dminfo_date.updated.dtvalue	= b_rec->dates.end_dt_tm

if (b_rec->pc_cnt = 0)
	set reply->status_data.status = "Z"
endif

call echo(build("executing bc_eks_combine_reqs"))
for (i=1 to b_rec->pc_cnt)
	set link_encntrid	= 0.0
	set link_personid	= 0.0
	if (b_rec->pc_qual[i].to_person_id > 0.0)
		set link_encntrid	= 0.0
		set link_personid	= b_rec->pc_qual[i].to_person_id
		execute bc_eks_combine_reqs 
	endif
endfor


set reply->status_data.status = "S"

if (reply->status_data.status = "S")
	call set_dminfo_date(b_rec->dminfo_date.updated.sdomain, b_rec->dminfo_date.updated.sname, b_rec->dminfo_date.updated.dtvalue)
endif
#exit_script 
call echorecord(b_rec)

end 
go
