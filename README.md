# req_man
Requisition Manager and Integrated Print-to-PDF


## PDF Generation

### Preformatting

#### PFMT_BC_PRINT_TO_PDF_REQ
#### PFMT_BC_PRINT_TO_PDF_REQA
#### PFMT_BC_S_PRINT_TO_PDF_REQ

### Multimedia Foundations
#### BC_MMF_PUBLISH_CE

### Operations
#### BC_COMBINE_REQ_OPS

### Discern Expert
#### BC_EKS_COMBINE_REQS

### Common Files
### bc_dm_info.inc
#### bc_play_routines.inc
#### bc_play_req.inc

## Integrated Print-to-PDF (iPPDF)

### Discern Explorer
#### BC_ALL_MP_GET_PDF
#### BC_ALL_MP_GET_PDF_DEV
#### BC_ALL_MP_GET_PDF_RM
#### BC_ALL_MP_PDF_VIEWER 
#### BC_ALL_MP_PATIENT_BANNER
#### DEV_ALL_MP_ADD_PRINT_STATUS

### HTML
#### ippdf_print_to_pdf_new.html

### Javascript
#### custom-components.js

### CSS
#### custom-components.css

## Requisition Manager
### Discern Explorer
#### MP_REQUISITION_MANAGER
#### REQ_CUST_MP_GET_PERSON
#### RM_ALL_MP_PDF_VIEWER
#### BC_ALL_MP_PATIENT_BANNER 
    Also used in iPPDF
#### REQ_CUST_MP_FILTER_SETS
#### REQ_CUST_MP_ADD_FILTER_SET
#### REQ_CUST_MP_DEL_FILTER_SET
#### REQ_CUST_MP_REQ_BY_LOC_DT
#### BC_ALL_MP_ADD_REQ_COMMENT
#### BC_ALL_MP_ADD_REQ_STATUS
#### DEV_ALL_MP_PDF_URL
#### DEV_CUST_MP_GET_COMMENT_HIST
#### BC_ALL_MP_MULTI_PDF_VIEWER
#### BC_ALL_MP_ADD_PRINT_STATUS

#### Common Files
##### bc_play_routines.inc
##### bc_play_req.inc
##### req_cust_mp_task_by_loc_dt.inc
##### mp_requisition_manager.inc

### HTML
#### rm_print_to_pdf_new.html
#### rm_print_to_pdf_muliple_new.html

### Javascript
#### 

### CSS
#### 

## Support Tools

### RM_SUPPORT_TOOLS
    Primary script responsible for generating HTML and pulling in proper JS
#### RM_OEF_MANAGER
    Handles Order Entry Format settings
#### RM_LOCATION_MANAGER
    Handles Location View and Updates
#### RM_FILTER_MANAGER
    Shows filter settings for users
#### BC_PRINT_REQ_MANAGE
    Used to batch print requisitions during cutover

## Reporting

### Discern Expert

#### 2REQ_CUST_MP_REQ_BY_LOC_DT
    Driver for many reports.  This replicates the execution of RM.  Needs new naming convention
#### BC_ALL_AUDIT_DASHBOARD_BCCVA
#### RM_FULL_ORDER_REQ_AUDIT  
#### BC_ALL_MP_GET_PDF_AUDIT


## Miscellaneous 

### RM_REG_REQ_BY_CONVERSATION
    Regenerate Requisitions by order conversation ID
### RM_REG_REQ_BY_PATHWAY
    Regenerate Requisitions by pathway ID
### RM_FILTER_PUSH     
### BC_ALL_PDF_STD_ROUTINES
    Standard set of routines that are shared across the scripts
### BC_ALL_PDF_STD_ROUTINES_JSON
    Returns the data from the routines in JSON format for MPages

# Change Log
## JIRA
### CST-130820 Spec Diag - iPPDF Update to include outstanding Spec Diagnostic Requisitions
### CST-138481 Add iPPDF Logic to AMB_PED_NEURO_TES Requisition
### CST-140781 LAB - Create a Notification for Lab Orders with External Requisition
### CST-144290 iPPDF/RM - Modify code to include "Paper Referral (See Reference Text)
### CST-145166 Lab: Update Lab Requisition Logic to Separate Lab Orders by Collection Date (iPPDF/Requisition Manager)
## Branches
### SUP-20211214 Support Tools Update

# Install / Migration Steps
## release/1.0.1.12
### Files to Move
- A: ccl/cust_script/bc_all_pdf_std_routines.prg
- A: ccl/cust_script/bc_all_pdf_std_routines_json.prg

- M: ccl/cust_script/bc_all_mp_multi_pdf_viewer.prg
- M: ccl/cust_script/bc_all_mp_pdf_viewer.prg
- M: ccl/cust_script/dev_all_mp_pdf_url.prg
- M: ccl/cust_script/dev_all_mp_pdf_viewer.prg
- M: ccl/cust_script/rm_all_mp_pdf_viewer.prg
- A: ccl/cust_script/support_tools.html
- M: ccl/cust_script/rm_support_tools.prg
- A: ccl/cust_script/rm_audit_manager.prg
- M: ccl/cust_script/rm_location_manager.prg
- A: ccl/cust_script/rm_req_manager.prg
- A: support_tools/js/jsgrid.min.js
- A: support_tools/css/jsgrid-theme.min.css
- A: support_tools/css/jsgrid.min.css
- U: support_tools/css/support_tools.css
- U: support_tools/js/support_tools.js    
- M: requisition_manager/js/core.js
- M: requisition_manager/js/manager.js    
- M: ccl/cust_script/pfmt_bc_print_to_pdf_req.prg
- M: ccl/cust_script/pfmt_bc_print_to_pdf_reqa.prg
- M: ccl/cust_script/pfmt_bc_s_print_to_pdf_req.prg
### Include / Overwrite Steps
1. Include bc_all_pdf_std_routines
2. Include bc_all_pdf_std_routines_json
3. Run test file

1. Include dev_all_mp_pdf_url
2. Include bc_all_mp_multi_pdf_viewer
3. Include rm_all_mp_pdf_viewer
4. Include bc_all_mp_pdf_viewer
5. Include dev_all_mp_pdf_viewer
6. Include rm_audit_manager
7. Include rm_location_manager
8. Include rm_req_manager
9. Include rm_support_tools
10. Include pfmt_bc_print_to_pdf_req
11. Include pfmt_bc_print_to_pdf_reqa
12. Include pfmt_bc_s_print_to_pdf_req
