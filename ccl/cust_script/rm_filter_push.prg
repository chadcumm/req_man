drop program rm_filter_push go
create program rm_filter_push

prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to. 

with OUTDEV


call echo(build("loading script:",curprog))
declare nologvar = i2 with noconstant(0), protect	;do not create log = 1		, create log = 0
declare debug_ind = i2 with noconstant(0), protect	;0 = no debug, 1=basic debug with echo, 2=msgview debug ;000
declare rec_to_file = i2 with noconstant(0), protect

declare notfnd = vc with constant("<not found>"), protect
declare order_string = vc with noconstant(" "), protect
declare i = i2 with noconstant(0), protect
declare k = i2 with noconstant(0), protect
declare j = i2 with noconstant(0), protect
declare pos = i2 with noconstant(0), protect
declare t = i2 with noconstant(0), protect
declare m = i2 with noconstant(0), protect


record t_rec
(
    1 prompts
     2 outdev = vc
	1 cons
	 2 dummy = i2
	1 cnt = i4
	1 valid_cnt = i4
	1 qual[*]
	 2 prsnl_id = f8
	1 team_cnt = i2
	1 team[*]
	 2 team_name = vc
	 2 team_id 	 = f8
	 2 member_list = vc
	 2 member_cnt = i2
	 2 members[*]
	  3 member_id = f8
	  3 prsnl_id = f8
	  3 prsnl_name = vc
	  3 valid_ind = i2
	  3 username = vc
	 2 user_cnt = i2
	 2 users[*]
	  3 user_name = vc
	  3 user_id = f8
	  3 user_username = vc
	  3 user_prsnl_id = f8
	  3 valid_ind = i2
	1 template_cnt = i2
	1 templates[*]
		2 template_name = vc
		2 array_of_task_status_values		= vc
		2 array_of_clerical_status_values   = vc
		2 array_of_task_type_values         = vc
		2 array_of_task_subtype_values      = vc
		2 array_of_task_priority_values     = vc
		2 array_of_task_patient_values      = vc
		2 array_of_task_provider_values     = vc
		2 array_of_task_location_values     = vc
		2 value_of_taskreportrange          = vc
		2 value_of_requestedreportrange     = vc
		2 pwx_task_header_id                = vc
		2 pwx_task_sort_ind                 = vc
	1 filter_cnt = i2
	1 filters[*]
	 2 outdev = vc
	 2 prsnl_id = f8
	 2 filter_set_name = vc
	 2 filter_set_values = vc
	 2 valid_ind = i2
) with protect

%i cust_script:bc_play_routines.inc
%i cust_script:bc_play_req.inc

call bc_custom_code_set(0)
call bc_log_level(0)

call writeLog(build2("*************************************************************"))
call writeLog(build2("* START Getting Team Information ****************************"))

select into "nl:"
from
	 code_value cv1
	,code_value_group cvg1
	,code_value cv2
	,(dummyt d1)
plan cv1
	where cv1.code_set = bc_common->code_set
	and   cv1.active_ind = 1
	and   cv1.cdf_meaning = "TEAM"
join d1
join cvg1
	where cvg1.code_set = cv1.code_set
	and   cvg1.parent_code_value = cv1.code_value
join cv2
	where cv2.code_value = cvg1.child_code_value
	and   cv2.cdf_meaning in("MEMBER","USER")
	and   cv2.active_ind = 1
order by
	 cv1.display
	,cv2.display
	,cv1.code_value
	,cv2.code_value
head report
	call writeLog(build2("->starting team query"))
	i = 0
	j = 0
	k = 0
head cv1.code_value
	j = 0
	k = 0
	call writeLog(build2("-->New Team=",trim(cv1.display)))
	call writeLog(build2("-->New Team CV=",trim(cnvtstring(cv1.code_value))))
	i = (i + 1)
	stat = alterlist(t_rec->team,i)
	t_rec->team[i].team_id = cv1.code_value
	t_rec->team[i].team_name = cv1.display
;head cv2.code_value
detail
	if ((cv2.code_value > 0.0) and (cv2.cdf_meaning = "MEMBER"))
		call writeLog(build2("--->New Member=",trim(cv2.display)))
		call writeLog(build2("--->New Member CV=",trim(cnvtstring(cv2.code_value))))
		call writeLog(build2("--->New Member Username=",trim((cv2.definition))))
		j = (j + 1)
		stat = alterlist(t_rec->team[i].members,j)
		t_rec->team[i].members[j].member_id = cv2.code_value
		t_rec->team[i].members[j].username = cv2.definition
	endif
	if ((cv2.code_value > 0.0) and (cv2.cdf_meaning = "USER"))
		call writeLog(build2("--->New User=",trim(cv2.display)))
		call writeLog(build2("--->New User CV=",trim(cnvtstring(cv2.code_value))))
		call writeLog(build2("--->New User Username=",trim((cv2.definition))))
		k = (k + 1)
		stat = alterlist(t_rec->team[i].users,k)
		t_rec->team[i].users[k].user_id = cv2.code_value
		t_rec->team[i].users[k].user_username = cv2.definition
	endif
foot cv2.code_value
	null
foot cv1.code_value
	t_rec->team[i].member_cnt = j
	t_rec->team[i].user_cnt = k
	call writeLog(build2("-->Team Member Cnt=",trim(cnvtstring(t_rec->team[i].member_cnt))))
	call writeLog(build2("-->User Cnt=",trim(cnvtstring(t_rec->team[i].user_cnt))))
foot report
	call writeLog(build2("->Team Cnt=",trim(cnvtstring(t_rec->team_cnt))))
	t_rec->team_cnt = i
	call writeLog(build2("->ending team query"))
with nocounter,outerjoin=d1
	

call writeLog(build2("* END   Getting Team Information ****************************"))
call writeLog(build2("*************************************************************"))

call writeLog(build2("*************************************************************"))
call writeLog(build2("* START Getting User Information ****************************"))

select into "nl:"
from
	 (dummyt d1 with seq=t_rec->team_cnt)
	,(dummyt d2 with seq=1)
	,prsnl p
plan d1
	where maxrec(d2,t_rec->team[d1.seq].user_cnt)
join d2
join p
	where p.username = t_rec->team[d1.seq].users[d2.seq].user_username
	and   p.person_id > 0.0
order by
	 p.name_full_formatted
	,p.person_id
head report
	call writeLog(build2("->starting user query"))
detail
	call writeLog(build2("-->Found User=",p.name_full_formatted))
	call writeLog(build2("-->Found User Id=",p.person_id))
	t_rec->team[d1.seq].users[d2.seq].user_name = p.name_full_formatted
	t_rec->team[d1.seq].users[d2.seq].user_prsnl_id = p.person_id
	t_rec->team[d1.seq].users[d2.seq].valid_ind = 1
foot report
	call writeLog(build2("->ending user query"))
with nocounter

call writeLog(build2("* END   Getting User Information ****************************"))
call writeLog(build2("*************************************************************"))

call writeLog(build2("*************************************************************"))
call writeLog(build2("* START Getting Prsnl Information ***************************"))

select into "nl:"
from
	 (dummyt d1 with seq=t_rec->team_cnt)
	,(dummyt d2 with seq=1)
	,prsnl p
plan d1
	where maxrec(d2,t_rec->team[d1.seq].member_cnt)
join d2
join p
	where p.username = t_rec->team[d1.seq].members[d2.seq].username
	and   p.person_id > 0.0
order by
	 p.name_full_formatted
	,p.person_id
head report
	call writeLog(build2("->starting prsnl query"))
detail
	call writeLog(build2("-->Found Prsnl=",p.name_full_formatted))
	call writeLog(build2("-->Found Prsnl Id=",p.person_id))
	t_rec->team[d1.seq].members[d2.seq].prsnl_name = p.name_full_formatted
	t_rec->team[d1.seq].members[d2.seq].prsnl_id = p.person_id
	t_rec->team[d1.seq].members[d2.seq].valid_ind = 1
foot report
	call writeLog(build2("->ending prsnl query"))
with nocounter

call writeLog(build2("* END   Getting Prsnl Information ***************************"))
call writeLog(build2("*************************************************************"))

call writeLog(build2("*************************************************************"))
call writeLog(build2("* START Building Templates **********************************"))

set t_rec->template_cnt = 2
set i = 1
set stat = alterlist(t_rec->templates,t_rec->template_cnt)
set t_rec->templates[i].template_name = "All"
set t_rec->templates[i].array_of_task_status_values		  = concat(
																	"Pending"        ,",",
																	"Printed"	
																  )
set t_rec->templates[i].array_of_clerical_status_values   = concat(
																	"To Be Actioned"        ,",",
																	"Request Sent"          ,",",
																	"Pending Lab"           ,",",
																	"Pending Other"         ,",",
																	"Pending Diagnostic"    ,",",
																	"Secretary to Follow"   ,",",
																	"Clerk to Follow"       ,",",
																	"Complete"              ,",",
																	"Clinician Printed"     ,",",
																	"Requisition Modified"	
																  ) 
set t_rec->templates[i].array_of_task_type_values         = concat(
																	"Cardiology"        ,",",
																	"Laboratory"        ,",",
																	"Medical Imaging"	,",",
																	"Referral"          
																  )
set t_rec->templates[i].array_of_task_subtype_values      = concat(
																	"Cardiac ECG"                       ,",",
																	"Cardiac Echo"                      ,",",
																	"Cardiac Monitor"                   ,",",
																	"Pulmonary Tx/Procedures"           ,",",
																	"Bone Marrow Biopsy/ Aspirate"      ,",",
																	"Group and Screen"                  ,",",
																	"Outpatient Lab(s)"                 ,",",
																	"Bone Density"                      ,",",
																	"Computed Tomography"               ,",",
																	"Echo"                              ,",",
																	"Fluoroscopy"                       ,",",
																	"General Diagnostic"                ,",",
																	"Interventional Radiology"          ,",",
																	"Magnetic Resonance Imaging"        ,",",
																	"Mammography"                       ,",",
																	"Nuclear Medicine"                  ,",",
																	"PET"                               ,",",
																	"Ultrasound"                        ,",",
																	"Vascular Ultrasound"               ,",",
																	"Ambulatory Referrals"				
																	)
set t_rec->templates[i].array_of_task_priority_values     = concat(
																	"AM Draw"                       ,",",
																	"Routine"                       ,",",
																	"STAT"                          ,",",
																	"Timed"                         ,",",
																	"Urgent"                        ,",",
																	"Next Available Appointment"    ,",",
																	"Within 24 hours"               ,",",
																	"Within 48 hours"               ,",",
																	"Within 72 hours"               ,",",
																	"Within 1 Week"                 ,",",
																	"Within 2 Weeks"                ,",",
																	"Within 4 Weeks"                ,",",
																	"Within 6 Weeks"                ,",",
																	"Within 2 Months"               ,",",
																	"Within 3 Months"               ,",",
																	"Within 4 Months"               ,",",
																	"Within 6 Months"               ,",",
																	"Within 1 Year"                 ,",",
																	"As Per Special Instructions"
																	)
set t_rec->templates[i].array_of_task_patient_values      = concat("")
set t_rec->templates[i].array_of_task_provider_values     = concat("")
set t_rec->templates[i].array_of_task_location_values     = concat(
/*
;D0785 Values
cnvtstring(2716971271),",",
cnvtstring(2716971275),",",
cnvtstring(2577403165),",",
cnvtstring(2716971223),",",
cnvtstring(2716971227),",",
cnvtstring(2716971231),",",
cnvtstring(2716971235),",",
cnvtstring(2716971239),",",
cnvtstring(2716971279),",",
cnvtstring(2716971243),",",
cnvtstring(2716971255),",",
cnvtstring(2716971247),",",
cnvtstring(2716971251),",",
cnvtstring(2716971263),",",
cnvtstring(2716971267),",",
cnvtstring(2577412455),",",
cnvtstring(2577412597),",",
cnvtstring(2577354123),",",
cnvtstring(2577409213),",",
cnvtstring(2577360247),",",
cnvtstring(2577360271),",",
cnvtstring(2577360327),",",
cnvtstring(2577361393),",",
cnvtstring(2577385529),",",
cnvtstring(2577364489),",",
cnvtstring(2577364017),",",
cnvtstring(2577414579),",",
cnvtstring(2577364377),",",
cnvtstring(2577368831),",",
cnvtstring(2577369305),",",
cnvtstring(2577369563),",",
cnvtstring(2577364075),",",
cnvtstring(2577364179),",",
cnvtstring(2577363963),",",
cnvtstring(2577365663),",",
cnvtstring(2577414499),",",
cnvtstring(2577365833),",",
cnvtstring(2600476497),",",
cnvtstring(2577414489),",",
cnvtstring(2600476341),",",
cnvtstring(2577368469),",",
cnvtstring(2577370499),",",
cnvtstring(2577389513),",",
cnvtstring(2577459079),",",
cnvtstring(2716561347),",",
cnvtstring(2713620503),",",
cnvtstring(2713624087),",",
cnvtstring(2713624135),",",
cnvtstring(2713620537),",",
cnvtstring(2713620547),",",
cnvtstring(2713627613),",",
cnvtstring(2713620659),",",
cnvtstring(2713624149),",",
cnvtstring(2713700745),",",
cnvtstring(2713620673),",",
cnvtstring(2713624197),",",
cnvtstring(2713624207),",",
cnvtstring(2713624267),",",
cnvtstring(2577460239),",",
cnvtstring(2577469023),",",
cnvtstring(2577465705),",",
cnvtstring(2577469103),",",
cnvtstring(2577469189),",",
cnvtstring(2577465959),",",
cnvtstring(2577469659),",",
cnvtstring(2577467949),",",
cnvtstring(2577471349),",",
cnvtstring(2577473307),",",
cnvtstring(2577471525),",",
cnvtstring(2577471461),",",
cnvtstring(2577473329),",",
cnvtstring(2577471235),",",
cnvtstring(2577468145),",",
cnvtstring(2577468389),",",
cnvtstring(2577473069),",",
cnvtstring(2577468471),",",
cnvtstring(2577472833),",",
cnvtstring(2600476395),",",
cnvtstring(2577468581),",",
cnvtstring(2710693693),",",
cnvtstring(2710693663),",",
cnvtstring(2710691655),",",
cnvtstring(2698730657),",",
cnvtstring(2698724117),",",
cnvtstring(2710691729),",",
cnvtstring(2710691719),",",
cnvtstring(2710691805),",",
cnvtstring(2698727399),",",
cnvtstring(2698731379),",",
cnvtstring(2710691639),",",
cnvtstring(2698731465),",",
cnvtstring(2698731507),",",
cnvtstring(2698724307),",",
cnvtstring(2710691815),",",
cnvtstring(2698727861),",",
cnvtstring(2698725973),",",
cnvtstring(2710683767),",",
cnvtstring(2700299835),",",
cnvtstring(2698725017),",",
cnvtstring(2698728071),",",
cnvtstring(2698732479),",",
cnvtstring(2698732935),",",
cnvtstring(2710691769),",",
cnvtstring(2710691783),",",
cnvtstring(2698734049),",",
cnvtstring(2710683889),",",
cnvtstring(2698734241),",",
cnvtstring(2698734253),",",
cnvtstring(2577408783),",",
cnvtstring(2577414375),",",
cnvtstring(2577414387),",",
cnvtstring(2577413201),",",
cnvtstring(2700246825),",",
cnvtstring(2577396703),",",
cnvtstring(2704370689),",",
cnvtstring(2700277951),",",
cnvtstring(2710709571),",",
cnvtstring(2704355437),",",
cnvtstring(2577423569),",",
cnvtstring(2577387251),",",
cnvtstring(2577387299),",",
cnvtstring(2577387381),",",
cnvtstring(2577387495),",",
cnvtstring(2577383651),",",
cnvtstring(2577386719),",",
cnvtstring(2577387921),",",
cnvtstring(2577384581),",",
cnvtstring(2577384057),",",
cnvtstring(2577383965),",",
cnvtstring(2577384183),",",
cnvtstring(2577384517),",",
cnvtstring(2577388941),",",
cnvtstring(2577387799),",",
cnvtstring(2577383975),",",
cnvtstring(2600473891),",",
cnvtstring(2577387013),",",
cnvtstring(2600474031),",",
cnvtstring(2577388651),",",
cnvtstring(2577387975),",",
cnvtstring(2587628273),",",
cnvtstring(2587680959),",",
cnvtstring(2587694581),",",
cnvtstring(2587712199),",",
cnvtstring(2588015555)
/*
																		;BUILD values
																		cnvtstring(2608416131),",",
cnvtstring(2608416141),",",
cnvtstring(2568645353),",",
cnvtstring(2608415617),",",
cnvtstring(2608415633),",",
cnvtstring(2608415637),",",
cnvtstring(2608415643),",",
cnvtstring(2608415649),",",
cnvtstring(2608415755),",",
cnvtstring(2608415657),",",
cnvtstring(2608415927),",",
cnvtstring(2608415763),",",
cnvtstring(2608415767),",",
cnvtstring(2608416113),",",
cnvtstring(2608416119),",",
cnvtstring(2608415961),",",
cnvtstring(2608416123),",",
cnvtstring(2568645329),",",
cnvtstring(2568897307),",",
cnvtstring(2570885619),",",
cnvtstring(2570885795),",",
cnvtstring(2570809481),",",
cnvtstring(2570810311),",",
cnvtstring(2570810315),",",
cnvtstring(2570810319),",",
cnvtstring(2588925345),",",
cnvtstring(2570809567),",",
cnvtstring(2570809827),",",
cnvtstring(2570809689),",",
cnvtstring(2570894259),",",
cnvtstring(2570809799),",",
cnvtstring(2570809731),",",
cnvtstring(2570809885),",",
cnvtstring(2570809911),",",
cnvtstring(2570809723),",",
cnvtstring(2570809789),",",
cnvtstring(2570809673),",",
cnvtstring(2570809663),",",
cnvtstring(2570809817),",",
cnvtstring(2570930033),",",
cnvtstring(2580237547),",",
cnvtstring(2570809807),",",
cnvtstring(2580237539),",",
cnvtstring(2570809681),",",
cnvtstring(2570885671),",",
cnvtstring(2570885741),",",
cnvtstring(2570557539),",",
cnvtstring(2607406717),",",
cnvtstring(2601449029),",",
cnvtstring(2601449253),",",
cnvtstring(2601449499),",",
cnvtstring(2601449527),",",
cnvtstring(2601449557),",",
cnvtstring(2601449581),",",
cnvtstring(2601449569),",",
cnvtstring(2601449639),",",
cnvtstring(2601449635),",",
cnvtstring(2601449653),",",
cnvtstring(2601449661),",",
cnvtstring(2601449839),",",
cnvtstring(2570557947),",",
cnvtstring(2570569509),",",
cnvtstring(2570569515),",",
cnvtstring(2570569521),",",
cnvtstring(2570569527),",",
cnvtstring(2570569533),",",
cnvtstring(2588925349),",",
cnvtstring(2570569551),",",
cnvtstring(2570569737),",",
cnvtstring(2570569823),",",
cnvtstring(2570569869),",",
cnvtstring(2570569841),",",
cnvtstring(2570569833),",",
cnvtstring(2570569881),",",
cnvtstring(2570569765),",",
cnvtstring(2570569751),",",
cnvtstring(2570569777),",",
cnvtstring(2570569859),",",
cnvtstring(2570569795),",",
cnvtstring(2570577295),",",
cnvtstring(2580237557),",",
cnvtstring(2570569807),",",
cnvtstring(2600525643),",",
cnvtstring(2600525145),",",
cnvtstring(2600445661),",",
cnvtstring(2600525833),",",
cnvtstring(2599656051),",",
cnvtstring(2599656071),",",
cnvtstring(2600525651),",",
cnvtstring(2600525647),",",
cnvtstring(2600525687),",",
cnvtstring(2599656139),",",
cnvtstring(2599656075),",",
cnvtstring(2599748733),",",
cnvtstring(2599656079),",",
cnvtstring(2599656085),",",
cnvtstring(2599656089),",",
cnvtstring(2600525691),",",
cnvtstring(2599656093),",",
cnvtstring(2599656123),",",
cnvtstring(2599748829),",",
cnvtstring(2600399929),",",
cnvtstring(2599656101),",",
cnvtstring(2599656097),",",
cnvtstring(2599656105),",",
cnvtstring(2599656109),",",
cnvtstring(2600525663),",",
cnvtstring(2600525667),",",
cnvtstring(2599656127),",",
cnvtstring(2600525837),",",
cnvtstring(2599656131),",",
cnvtstring(2599656135),",",
cnvtstring(2570681367),",",
cnvtstring(2570681377),",",
cnvtstring(2570681327),",",
cnvtstring(2570681407),",",
cnvtstring(2600443911),",",
cnvtstring(2570662343),",",
cnvtstring(2600551547),",",
cnvtstring(2600394961),",",
cnvtstring(2600528427),",",
cnvtstring(2600554625),",",
cnvtstring(2570885889),",",
cnvtstring(2570681633),",",
cnvtstring(2570681639),",",
cnvtstring(2570681643),",",
cnvtstring(2570681647),",",
cnvtstring(2570681653),",",
cnvtstring(2588925361),",",
cnvtstring(2570681505),",",
cnvtstring(2570681681),",",
cnvtstring(2570894249),",",
cnvtstring(2570681817),",",
cnvtstring(2570681743),",",
cnvtstring(2570681825),",",
cnvtstring(2570681837),",",
cnvtstring(2570681673),",",
cnvtstring(2570681663),",",
cnvtstring(2570681755),",",
cnvtstring(2580237601),",",
cnvtstring(2570895523),",",
cnvtstring(2580237529),",",
cnvtstring(2570681763),",",
cnvtstring(2570681735),",",
cnvtstring(2580858055),",",
cnvtstring(2580874809),",",
cnvtstring(2580859021),",",
cnvtstring(2580874791),",",
cnvtstring(2580865309)
																		*/
																		;PROD Values
cnvtstring(2746657235),",",
cnvtstring(2746657287),",",
cnvtstring(2577403165),",",
cnvtstring(2746665421),",",
cnvtstring(2746662521),",",
cnvtstring(2746662535),",",
cnvtstring(2746662573),",",
cnvtstring(2746662693),",",
cnvtstring(2746665769),",",
cnvtstring(2746659423),",",
cnvtstring(2746659575),",",
cnvtstring(2746662833),",",
cnvtstring(2746662861),",",
cnvtstring(2746666247),",",
cnvtstring(2746662987),",",
cnvtstring(2746666467),",",
cnvtstring(2577412455),",",
cnvtstring(2577412597),",",
cnvtstring(2577354123),",",
cnvtstring(2577409213),",",
cnvtstring(2577360247),",",
cnvtstring(2577360271),",",
cnvtstring(2577360327),",",
cnvtstring(2577361393),",",
cnvtstring(2577385529),",",
cnvtstring(2577364489),",",
cnvtstring(2577364017),",",
cnvtstring(2577414579),",",
cnvtstring(2577364377),",",
cnvtstring(2577368831),",",
cnvtstring(2577369305),",",
cnvtstring(2577369563),",",
cnvtstring(2577364075),",",
cnvtstring(2577364179),",",
cnvtstring(2577363963),",",
cnvtstring(2577365663),",",
cnvtstring(2577414499),",",
cnvtstring(2577365833),",",
cnvtstring(2600476497),",",
cnvtstring(2577414489),",",
cnvtstring(2600476341),",",
cnvtstring(2577368469),",",
cnvtstring(2577370499),",",
cnvtstring(2577389513),",",
cnvtstring(2577459079),",",
cnvtstring(2725736953),",",
cnvtstring(2713624087),",",
cnvtstring(2713624135),",",
cnvtstring(2713620537),",",
cnvtstring(2713620547),",",
cnvtstring(2713627613),",",
cnvtstring(2713620659),",",
cnvtstring(2713624149),",",
cnvtstring(2713700745),",",
cnvtstring(2713620673),",",
cnvtstring(2713624197),",",
cnvtstring(2713624207),",",
cnvtstring(2713624267),",",
cnvtstring(2577460239),",",
cnvtstring(2577469023),",",
cnvtstring(2577465705),",",
cnvtstring(2577469103),",",
cnvtstring(2577469189),",",
cnvtstring(2577465959),",",
cnvtstring(2577469659),",",
cnvtstring(2577467949),",",
cnvtstring(2577471349),",",
cnvtstring(2577473307),",",
cnvtstring(2577471525),",",
cnvtstring(2577471461),",",
cnvtstring(2577473329),",",
cnvtstring(2577471235),",",
cnvtstring(2577468145),",",
cnvtstring(2577468389),",",
cnvtstring(2577473069),",",
cnvtstring(2577468471),",",
cnvtstring(2577472833),",",
cnvtstring(2600476395),",",
cnvtstring(2577468581),",",
cnvtstring(2710693693),",",
cnvtstring(2710693663),",",
cnvtstring(2710691655),",",
cnvtstring(2710683879),",",
cnvtstring(2698730657),",",
cnvtstring(2698724117),",",
cnvtstring(2710691729),",",
cnvtstring(2710691719),",",
cnvtstring(2710691805),",",
cnvtstring(2698727399),",",
cnvtstring(2698731379),",",
cnvtstring(2710691639),",",
cnvtstring(2698731465),",",
cnvtstring(2698731507),",",
cnvtstring(2698724307),",",
cnvtstring(2710691815),",",
cnvtstring(2698727861),",",
cnvtstring(2698725973),",",
cnvtstring(2710683767),",",
cnvtstring(2700299835),",",
cnvtstring(2698725017),",",
cnvtstring(2698728071),",",
cnvtstring(2698732479),",",
cnvtstring(2698732935),",",
cnvtstring(2710691769),",",
cnvtstring(2710691783),",",
cnvtstring(2698734049),",",
cnvtstring(2710683889),",",
cnvtstring(2698734241),",",
cnvtstring(2698734253),",",
cnvtstring(2577408783),",",
cnvtstring(2577414375),",",
cnvtstring(2577414387),",",
cnvtstring(2577413201),",",
cnvtstring(2700246825),",",
cnvtstring(2577396703),",",
cnvtstring(2704370689),",",
cnvtstring(2700277951),",",
cnvtstring(2710709571),",",
cnvtstring(2704355437),",",
cnvtstring(2577423569),",",
cnvtstring(2577387251),",",
cnvtstring(2577387299),",",
cnvtstring(2577387381),",",
cnvtstring(2577387495),",",
cnvtstring(2577383651),",",
cnvtstring(2577386719),",",
cnvtstring(2577387921),",",
cnvtstring(2577384581),",",
cnvtstring(2577384057),",",
cnvtstring(2577383965),",",
cnvtstring(2577384183),",",
cnvtstring(2577384517),",",
cnvtstring(2577388941),",",
cnvtstring(2577387799),",",
cnvtstring(2577383975),",",
cnvtstring(2600473891),",",
cnvtstring(2577387013),",",
cnvtstring(2600474031),",",
cnvtstring(2577388651),",",
cnvtstring(2577387975),",",
cnvtstring(2587628273),",",
cnvtstring(2587680959),",",
cnvtstring(2587694581),",",
cnvtstring(2587712199),",",
cnvtstring(2588015555)
																		
																	)
set t_rec->templates[i].value_of_taskreportrange          = concat("Any Date")
set t_rec->templates[i].value_of_requestedreportrange     = concat("Any Date")
set t_rec->templates[i].pwx_task_header_id                = "pwx_fcr_header_requesteddate_dt"
set t_rec->templates[i].pwx_task_sort_ind                 = "0"


set i = 2
set stat = alterlist(t_rec->templates,t_rec->template_cnt)
set t_rec->templates[i].template_name = "Incomplete"
set t_rec->templates[i].array_of_task_status_values		  = concat(
																	"Pending"        ,",",
																	"Printed"
																  )
set t_rec->templates[i].array_of_clerical_status_values   = concat(
																	"To Be Actioned"        ,",",
																	"Request Sent"          ,",",
																	"Pending Lab"           ,",",
																	"Pending Other"         ,",",
																	"Pending Diagnostic"    ,",",
																	"Secretary to Follow"   ,",",
																	"Clerk to Follow"       ,",",
																	;"Complete"              ,",",
																	;"Clinician Printed"     ,",",
																	"Requisition Modified"		
																  ) 
set t_rec->templates[i].array_of_task_type_values         = concat(
																	"Cardiology"        ,",",
																	"Laboratory"        ,",",
																	"Medical Imaging"	,",",
																	"Referral"          
																  )
set t_rec->templates[i].array_of_task_subtype_values      = concat(
																	"Cardiac ECG"                       ,",",
																	"Cardiac Echo"                      ,",",
																	"Cardiac Monitor"                   ,",",
																	"Pulmonary Tx/Procedures"           ,",",
																	"Bone Marrow Biopsy/ Aspirate"      ,",",
																	"Group and Screen"                  ,",",
																	"Outpatient Lab(s)"                 ,",",
																	"Bone Density"                      ,",",
																	"Computed Tomography"               ,",",
																	"Echo"                              ,",",
																	"Fluoroscopy"                       ,",",
																	"General Diagnostic"                ,",",
																	"Interventional Radiology"          ,",",
																	"Magnetic Resonance Imaging"        ,",",
																	"Mammography"                       ,",",
																	"Nuclear Medicine"                  ,",",
																	"PET"                               ,",",
																	"Ultrasound"                        ,",",
																	"Vascular Ultrasound"               ,",",
																	"Ambulatory Referrals"				
																	)
set t_rec->templates[i].array_of_task_priority_values     = concat(
																	"AM Draw"                       ,",",
																	"Routine"                       ,",",
																	"STAT"                          ,",",
																	"Timed"                         ,",",
																	"Urgent"                        ,",",
																	"Next Available Appointment"    ,",",
																	"Within 24 hours"               ,",",
																	"Within 48 hours"               ,",",
																	"Within 72 hours"               ,",",
																	"Within 1 Week"                 ,",",
																	"Within 2 Weeks"                ,",",
																	"Within 4 Weeks"                ,",",
																	"Within 6 Weeks"                ,",",
																	"Within 2 Months"               ,",",
																	"Within 3 Months"               ,",",
																	"Within 4 Months"               ,",",
																	"Within 6 Months"               ,",",
																	"Within 1 Year"                 ,",",
																	"As Per Special Instructions"
																	)
set t_rec->templates[i].array_of_task_patient_values      = concat("")
set t_rec->templates[i].array_of_task_provider_values     = concat("")
set t_rec->templates[i].array_of_task_location_values     = concat(
/*
;D0785 Values
cnvtstring(2716971271),",",
cnvtstring(2716971275),",",
cnvtstring(2577403165),",",
cnvtstring(2716971223),",",
cnvtstring(2716971227),",",
cnvtstring(2716971231),",",
cnvtstring(2716971235),",",
cnvtstring(2716971239),",",
cnvtstring(2716971279),",",
cnvtstring(2716971243),",",
cnvtstring(2716971255),",",
cnvtstring(2716971247),",",
cnvtstring(2716971251),",",
cnvtstring(2716971263),",",
cnvtstring(2716971267),",",
cnvtstring(2577412455),",",
cnvtstring(2577412597),",",
cnvtstring(2577354123),",",
cnvtstring(2577409213),",",
cnvtstring(2577360247),",",
cnvtstring(2577360271),",",
cnvtstring(2577360327),",",
cnvtstring(2577361393),",",
cnvtstring(2577385529),",",
cnvtstring(2577364489),",",
cnvtstring(2577364017),",",
cnvtstring(2577414579),",",
cnvtstring(2577364377),",",
cnvtstring(2577368831),",",
cnvtstring(2577369305),",",
cnvtstring(2577369563),",",
cnvtstring(2577364075),",",
cnvtstring(2577364179),",",
cnvtstring(2577363963),",",
cnvtstring(2577365663),",",
cnvtstring(2577414499),",",
cnvtstring(2577365833),",",
cnvtstring(2600476497),",",
cnvtstring(2577414489),",",
cnvtstring(2600476341),",",
cnvtstring(2577368469),",",
cnvtstring(2577370499),",",
cnvtstring(2577389513),",",
cnvtstring(2577459079),",",
cnvtstring(2716561347),",",
cnvtstring(2713620503),",",
cnvtstring(2713624087),",",
cnvtstring(2713624135),",",
cnvtstring(2713620537),",",
cnvtstring(2713620547),",",
cnvtstring(2713627613),",",
cnvtstring(2713620659),",",
cnvtstring(2713624149),",",
cnvtstring(2713700745),",",
cnvtstring(2713620673),",",
cnvtstring(2713624197),",",
cnvtstring(2713624207),",",
cnvtstring(2713624267),",",
cnvtstring(2577460239),",",
cnvtstring(2577469023),",",
cnvtstring(2577465705),",",
cnvtstring(2577469103),",",
cnvtstring(2577469189),",",
cnvtstring(2577465959),",",
cnvtstring(2577469659),",",
cnvtstring(2577467949),",",
cnvtstring(2577471349),",",
cnvtstring(2577473307),",",
cnvtstring(2577471525),",",
cnvtstring(2577471461),",",
cnvtstring(2577473329),",",
cnvtstring(2577471235),",",
cnvtstring(2577468145),",",
cnvtstring(2577468389),",",
cnvtstring(2577473069),",",
cnvtstring(2577468471),",",
cnvtstring(2577472833),",",
cnvtstring(2600476395),",",
cnvtstring(2577468581),",",
cnvtstring(2710693693),",",
cnvtstring(2710693663),",",
cnvtstring(2710691655),",",
cnvtstring(2698730657),",",
cnvtstring(2698724117),",",
cnvtstring(2710691729),",",
cnvtstring(2710691719),",",
cnvtstring(2710691805),",",
cnvtstring(2698727399),",",
cnvtstring(2698731379),",",
cnvtstring(2710691639),",",
cnvtstring(2698731465),",",
cnvtstring(2698731507),",",
cnvtstring(2698724307),",",
cnvtstring(2710691815),",",
cnvtstring(2698727861),",",
cnvtstring(2698725973),",",
cnvtstring(2710683767),",",
cnvtstring(2700299835),",",
cnvtstring(2698725017),",",
cnvtstring(2698728071),",",
cnvtstring(2698732479),",",
cnvtstring(2698732935),",",
cnvtstring(2710691769),",",
cnvtstring(2710691783),",",
cnvtstring(2698734049),",",
cnvtstring(2710683889),",",
cnvtstring(2698734241),",",
cnvtstring(2698734253),",",
cnvtstring(2577408783),",",
cnvtstring(2577414375),",",
cnvtstring(2577414387),",",
cnvtstring(2577413201),",",
cnvtstring(2700246825),",",
cnvtstring(2577396703),",",
cnvtstring(2704370689),",",
cnvtstring(2700277951),",",
cnvtstring(2710709571),",",
cnvtstring(2704355437),",",
cnvtstring(2577423569),",",
cnvtstring(2577387251),",",
cnvtstring(2577387299),",",
cnvtstring(2577387381),",",
cnvtstring(2577387495),",",
cnvtstring(2577383651),",",
cnvtstring(2577386719),",",
cnvtstring(2577387921),",",
cnvtstring(2577384581),",",
cnvtstring(2577384057),",",
cnvtstring(2577383965),",",
cnvtstring(2577384183),",",
cnvtstring(2577384517),",",
cnvtstring(2577388941),",",
cnvtstring(2577387799),",",
cnvtstring(2577383975),",",
cnvtstring(2600473891),",",
cnvtstring(2577387013),",",
cnvtstring(2600474031),",",
cnvtstring(2577388651),",",
cnvtstring(2577387975),",",
cnvtstring(2587628273),",",
cnvtstring(2587680959),",",
cnvtstring(2587694581),",",
cnvtstring(2587712199),",",
cnvtstring(2588015555)
/*
																		;BUILD Values
																		cnvtstring(2608416131),",",
cnvtstring(2608416141),",",
cnvtstring(2568645353),",",
cnvtstring(2608415617),",",
cnvtstring(2608415633),",",
cnvtstring(2608415637),",",
cnvtstring(2608415643),",",
cnvtstring(2608415649),",",
cnvtstring(2608415755),",",
cnvtstring(2608415657),",",
cnvtstring(2608415927),",",
cnvtstring(2608415763),",",
cnvtstring(2608415767),",",
cnvtstring(2608416113),",",
cnvtstring(2608416119),",",
cnvtstring(2608415961),",",
cnvtstring(2608416123),",",
cnvtstring(2568645329),",",
cnvtstring(2568897307),",",
cnvtstring(2570885619),",",
cnvtstring(2570885795),",",
cnvtstring(2570809481),",",
cnvtstring(2570810311),",",
cnvtstring(2570810315),",",
cnvtstring(2570810319),",",
cnvtstring(2588925345),",",
cnvtstring(2570809567),",",
cnvtstring(2570809827),",",
cnvtstring(2570809689),",",
cnvtstring(2570894259),",",
cnvtstring(2570809799),",",
cnvtstring(2570809731),",",
cnvtstring(2570809885),",",
cnvtstring(2570809911),",",
cnvtstring(2570809723),",",
cnvtstring(2570809789),",",
cnvtstring(2570809673),",",
cnvtstring(2570809663),",",
cnvtstring(2570809817),",",
cnvtstring(2570930033),",",
cnvtstring(2580237547),",",
cnvtstring(2570809807),",",
cnvtstring(2580237539),",",
cnvtstring(2570809681),",",
cnvtstring(2570885671),",",
cnvtstring(2570885741),",",
cnvtstring(2570557539),",",
cnvtstring(2607406717),",",
cnvtstring(2601449029),",",
cnvtstring(2601449253),",",
cnvtstring(2601449499),",",
cnvtstring(2601449527),",",
cnvtstring(2601449557),",",
cnvtstring(2601449581),",",
cnvtstring(2601449569),",",
cnvtstring(2601449639),",",
cnvtstring(2601449635),",",
cnvtstring(2601449653),",",
cnvtstring(2601449661),",",
cnvtstring(2601449839),",",
cnvtstring(2570557947),",",
cnvtstring(2570569509),",",
cnvtstring(2570569515),",",
cnvtstring(2570569521),",",
cnvtstring(2570569527),",",
cnvtstring(2570569533),",",
cnvtstring(2588925349),",",
cnvtstring(2570569551),",",
cnvtstring(2570569737),",",
cnvtstring(2570569823),",",
cnvtstring(2570569869),",",
cnvtstring(2570569841),",",
cnvtstring(2570569833),",",
cnvtstring(2570569881),",",
cnvtstring(2570569765),",",
cnvtstring(2570569751),",",
cnvtstring(2570569777),",",
cnvtstring(2570569859),",",
cnvtstring(2570569795),",",
cnvtstring(2570577295),",",
cnvtstring(2580237557),",",
cnvtstring(2570569807),",",
cnvtstring(2600525643),",",
cnvtstring(2600525145),",",
cnvtstring(2600445661),",",
cnvtstring(2600525833),",",
cnvtstring(2599656051),",",
cnvtstring(2599656071),",",
cnvtstring(2600525651),",",
cnvtstring(2600525647),",",
cnvtstring(2600525687),",",
cnvtstring(2599656139),",",
cnvtstring(2599656075),",",
cnvtstring(2599748733),",",
cnvtstring(2599656079),",",
cnvtstring(2599656085),",",
cnvtstring(2599656089),",",
cnvtstring(2600525691),",",
cnvtstring(2599656093),",",
cnvtstring(2599656123),",",
cnvtstring(2599748829),",",
cnvtstring(2600399929),",",
cnvtstring(2599656101),",",
cnvtstring(2599656097),",",
cnvtstring(2599656105),",",
cnvtstring(2599656109),",",
cnvtstring(2600525663),",",
cnvtstring(2600525667),",",
cnvtstring(2599656127),",",
cnvtstring(2600525837),",",
cnvtstring(2599656131),",",
cnvtstring(2599656135),",",
cnvtstring(2570681367),",",
cnvtstring(2570681377),",",
cnvtstring(2570681327),",",
cnvtstring(2570681407),",",
cnvtstring(2600443911),",",
cnvtstring(2570662343),",",
cnvtstring(2600551547),",",
cnvtstring(2600394961),",",
cnvtstring(2600528427),",",
cnvtstring(2600554625),",",
cnvtstring(2570885889),",",
cnvtstring(2570681633),",",
cnvtstring(2570681639),",",
cnvtstring(2570681643),",",
cnvtstring(2570681647),",",
cnvtstring(2570681653),",",
cnvtstring(2588925361),",",
cnvtstring(2570681505),",",
cnvtstring(2570681681),",",
cnvtstring(2570894249),",",
cnvtstring(2570681817),",",
cnvtstring(2570681743),",",
cnvtstring(2570681825),",",
cnvtstring(2570681837),",",
cnvtstring(2570681673),",",
cnvtstring(2570681663),",",
cnvtstring(2570681755),",",
cnvtstring(2580237601),",",
cnvtstring(2570895523),",",
cnvtstring(2580237529),",",
cnvtstring(2570681763),",",
cnvtstring(2570681735),",",
cnvtstring(2580858055),",",
cnvtstring(2580874809),",",
cnvtstring(2580859021),",",
cnvtstring(2580874791),",",
cnvtstring(2580865309)
																	 */	
																		;PROD Values
																		cnvtstring(2746657235),",",
cnvtstring(2746657287),",",
cnvtstring(2577403165),",",
cnvtstring(2746665421),",",
cnvtstring(2746662521),",",
cnvtstring(2746662535),",",
cnvtstring(2746662573),",",
cnvtstring(2746662693),",",
cnvtstring(2746665769),",",
cnvtstring(2746659423),",",
cnvtstring(2746659575),",",
cnvtstring(2746662833),",",
cnvtstring(2746662861),",",
cnvtstring(2746666247),",",
cnvtstring(2746662987),",",
cnvtstring(2746666467),",",
cnvtstring(2577412455),",",
cnvtstring(2577412597),",",
cnvtstring(2577354123),",",
cnvtstring(2577409213),",",
cnvtstring(2577360247),",",
cnvtstring(2577360271),",",
cnvtstring(2577360327),",",
cnvtstring(2577361393),",",
cnvtstring(2577385529),",",
cnvtstring(2577364489),",",
cnvtstring(2577364017),",",
cnvtstring(2577414579),",",
cnvtstring(2577364377),",",
cnvtstring(2577368831),",",
cnvtstring(2577369305),",",
cnvtstring(2577369563),",",
cnvtstring(2577364075),",",
cnvtstring(2577364179),",",
cnvtstring(2577363963),",",
cnvtstring(2577365663),",",
cnvtstring(2577414499),",",
cnvtstring(2577365833),",",
cnvtstring(2600476497),",",
cnvtstring(2577414489),",",
cnvtstring(2600476341),",",
cnvtstring(2577368469),",",
cnvtstring(2577370499),",",
cnvtstring(2577389513),",",
cnvtstring(2577459079),",",
cnvtstring(2725736953),",",
cnvtstring(2713624087),",",
cnvtstring(2713624135),",",
cnvtstring(2713620537),",",
cnvtstring(2713620547),",",
cnvtstring(2713627613),",",
cnvtstring(2713620659),",",
cnvtstring(2713624149),",",
cnvtstring(2713700745),",",
cnvtstring(2713620673),",",
cnvtstring(2713624197),",",
cnvtstring(2713624207),",",
cnvtstring(2713624267),",",
cnvtstring(2577460239),",",
cnvtstring(2577469023),",",
cnvtstring(2577465705),",",
cnvtstring(2577469103),",",
cnvtstring(2577469189),",",
cnvtstring(2577465959),",",
cnvtstring(2577469659),",",
cnvtstring(2577467949),",",
cnvtstring(2577471349),",",
cnvtstring(2577473307),",",
cnvtstring(2577471525),",",
cnvtstring(2577471461),",",
cnvtstring(2577473329),",",
cnvtstring(2577471235),",",
cnvtstring(2577468145),",",
cnvtstring(2577468389),",",
cnvtstring(2577473069),",",
cnvtstring(2577468471),",",
cnvtstring(2577472833),",",
cnvtstring(2600476395),",",
cnvtstring(2577468581),",",
cnvtstring(2710693693),",",
cnvtstring(2710693663),",",
cnvtstring(2710691655),",",
cnvtstring(2710683879),",",
cnvtstring(2698730657),",",
cnvtstring(2698724117),",",
cnvtstring(2710691729),",",
cnvtstring(2710691719),",",
cnvtstring(2710691805),",",
cnvtstring(2698727399),",",
cnvtstring(2698731379),",",
cnvtstring(2710691639),",",
cnvtstring(2698731465),",",
cnvtstring(2698731507),",",
cnvtstring(2698724307),",",
cnvtstring(2710691815),",",
cnvtstring(2698727861),",",
cnvtstring(2698725973),",",
cnvtstring(2710683767),",",
cnvtstring(2700299835),",",
cnvtstring(2698725017),",",
cnvtstring(2698728071),",",
cnvtstring(2698732479),",",
cnvtstring(2698732935),",",
cnvtstring(2710691769),",",
cnvtstring(2710691783),",",
cnvtstring(2698734049),",",
cnvtstring(2710683889),",",
cnvtstring(2698734241),",",
cnvtstring(2698734253),",",
cnvtstring(2577408783),",",
cnvtstring(2577414375),",",
cnvtstring(2577414387),",",
cnvtstring(2577413201),",",
cnvtstring(2700246825),",",
cnvtstring(2577396703),",",
cnvtstring(2704370689),",",
cnvtstring(2700277951),",",
cnvtstring(2710709571),",",
cnvtstring(2704355437),",",
cnvtstring(2577423569),",",
cnvtstring(2577387251),",",
cnvtstring(2577387299),",",
cnvtstring(2577387381),",",
cnvtstring(2577387495),",",
cnvtstring(2577383651),",",
cnvtstring(2577386719),",",
cnvtstring(2577387921),",",
cnvtstring(2577384581),",",
cnvtstring(2577384057),",",
cnvtstring(2577383965),",",
cnvtstring(2577384183),",",
cnvtstring(2577384517),",",
cnvtstring(2577388941),",",
cnvtstring(2577387799),",",
cnvtstring(2577383975),",",
cnvtstring(2600473891),",",
cnvtstring(2577387013),",",
cnvtstring(2600474031),",",
cnvtstring(2577388651),",",
cnvtstring(2577387975),",",
cnvtstring(2587628273),",",
cnvtstring(2587680959),",",
cnvtstring(2587694581),",",
cnvtstring(2587712199),",",
cnvtstring(2588015555)

																		
																	)
set t_rec->templates[i].value_of_taskreportrange          = concat("Any Date")
set t_rec->templates[i].value_of_requestedreportrange     = concat("Any Date")
set t_rec->templates[i].pwx_task_header_id                = "pwx_fcr_header_requesteddate_dt"
set t_rec->templates[i].pwx_task_sort_ind                 = "0"

call writeLog(build2("* END   Building Templates **********************************"))
call writeLog(build2("*************************************************************"))


call writeLog(build2("*************************************************************"))
call writeLog(build2("* START Building Lists **************************************"))

for (i=1 to t_rec->template_cnt)
	call writeLog(build2("->Template Name=",trim(t_rec->templates[i].template_name)))
	for (j=1 to t_rec->team_cnt)
		call writeLog(build2("-->Team Name=",trim(t_rec->team[j].team_name)))
		call writeLog(build2("-->Team Member Count=",cnvtstring(t_rec->team[j].member_cnt)))
		set pos = 0
		for (k=1 to t_rec->team[j].member_cnt)
			if (t_rec->team[j].members[k].valid_ind = 1)
				call writeLog(build2("--->Team Member=",cnvtstring(t_rec->team[j].members[k].prsnl_id)))
				if (pos = 0)
					set t_rec->team[j].member_list = cnvtstring(t_rec->team[j].members[k].prsnl_id)
				else
					set t_rec->team[j].member_list = concat(t_rec->team[j].member_list,",",cnvtstring(t_rec->team[j].members[k].prsnl_id))
				endif
				set pos = (pos + 1)
			endif
		endfor 
		for (t=1 to t_rec->team[j].user_cnt)
			call writeLog(build2("-->User Name=",trim(t_rec->team[j].users[t].user_name)))
			if (t_rec->team[j].users[t].valid_ind = 1)
				set m = t_rec->filter_cnt
				set m = (m + 1)
				set stat = alterlist(t_rec->filters,m)
				set t_rec->filters[m].outdev = "MINE"
				set t_rec->filters[m].prsnl_id = t_rec->team[j].users[t].user_prsnl_id
				set t_rec->filters[m].filter_set_name = concat(
																 t_rec->team[j].team_name,
																 " - ",
																 t_rec->templates[i].template_name
															  )
				set t_rec->filters[m].filter_set_values	= concat(
																t_rec->templates[i].array_of_task_status_values		  ,"|", 
																t_rec->templates[i].array_of_clerical_status_values   ,"|", 
																t_rec->templates[i].array_of_task_type_values         ,"|", 
																t_rec->templates[i].array_of_task_subtype_values      ,"|", 
																t_rec->templates[i].array_of_task_priority_values     ,"|", 
																t_rec->templates[i].array_of_task_patient_values      ,"|", 
																t_rec->team[j].member_list     						  ,"|", 
																t_rec->templates[i].array_of_task_location_values     ,"|", 
																t_rec->templates[i].value_of_taskreportrange          ,"|", 
																t_rec->templates[i].value_of_requestedreportrange     ,"|", 
																t_rec->templates[i].pwx_task_header_id                ,"|", 
																t_rec->templates[i].pwx_task_sort_ind                 
																)
				set t_rec->filters[m].valid_ind = 1
				set t_rec->filter_cnt = m
				
			endif
		endfor
	endfor
endfor

call writeLog(build2("* END   Building Lists **************************************"))
call writeLog(build2("*************************************************************"))


call writeLog(build2("*************************************************************"))
call writeLog(build2("* START Pushing Filter Sets *********************************"))

for (i=1 to t_rec->filter_cnt)
	if (t_rec->filters[i].valid_ind = 1)
		execute 2req_cust_mp_add_filter_set
	 			 t_rec->filters[i].outdev
				,t_rec->filters[i].prsnl_id
				,t_rec->filters[i].filter_set_name
				,t_rec->filters[i].filter_set_values
	endif
endfor

call writeLog(build2("* END   Pushing Filter Sets *********************************"))
call writeLog(build2("*************************************************************"))

call writeLog(build2("*************************************************************"))
call writeLog(build2("* START Getting Team Information ****************************"))

call writeLog(build2("* END   Getting Team Information ****************************"))
call writeLog(build2("*************************************************************"))


#exit_script
call echorecord(t_rec)
;;call echorecord(bc_common)

end
go

