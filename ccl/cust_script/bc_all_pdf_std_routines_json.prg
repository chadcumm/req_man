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
drop program bc_all_pdf_std_routines_json go
create program bc_all_pdf_std_routines_json

execute bc_all_pdf_std_routines
set stat = copyrec(bc_all_pdf_std_variables,record_data,1)
set _memory_reply_string = cnvtrectojson(record_data)

end
go