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

# Change Log
## JIRA
### CST-130820 Spec Diag - iPPDF Update to include outstanding Spec Diagnostic Requisitions
