
create or replace view "REDLINE"."PNMAC"."VW_REDLINEWORKSTUDY" as
select 
    i.id
    ,'https://redline2.pnmac.com/issues/'|| i.id as redline_url
    ,i.subject
    ,s.name as issue_status
    ,ic.name as issue_category
    ,i.created_on
    ,i.updated_on
    ,i.start_date
    ,i.closed_on
    ,t.name as tracker_name
    ,p.name as project_name
    ,cv_rltype.value as project_type
    ,(CASE WHEN p.status = '1' then 'Open' else 'Closed/Archived' END) as project_status
    ,sa.firstname||' '||sa.lastname as system_analyst
    ,qa.firstname||' '||qa.lastname as qa_analyst
    ,dev.firstname||' '||dev.lastname as developer
    
    ,(CASE 
      WHEN s.name in ('In Analysis') THEN ifnull(sa.firstname||' '||sa.lastname,assignee.firstname||' '||assignee.lastname)
      WHEN s.name in ('Ready for Development','In Development') THEN ifnull(dev.firstname||' '||dev.lastname,assignee.firstname||' '||assignee.lastname)
      WHEN s.name in ('Ready for QA','In QA','Waiting for UAT Approval','Ready for UAT', 'In UAT') THEN ifnull(qa.firstname||' '||qa.lastname ,assignee.firstname||' '||assignee.lastname)
      /* WHEN s.name in () THEN ifnull(uat.firstname||' '||uat.lastname,'Waiting for Assignee') */
      WHEN ifnull(assignee.firstname,'NULL') <> 'NULL' THEN assignee.firstname||' '||assignee.lastname
      ELSE 'Unassigned' END) as currently_active_resource
      
    ,(CASE 
      WHEN s.name in ('In Analysis') THEN to_number(ifnull(cfe_sa.name,0))
      WHEN s.name in ('Ready for Development','In Development') THEN to_number(ifnull(cfe_dev.name,0))
      WHEN s.name in ('Ready for QA','In QA','Waiting for UAT Approval','Ready for UAT', 'In UAT') THEN to_number(ifnull(cfe_qa.name,0))
      ELSE 0 END) as currently_active_story_points
      
   
    ,(CASE WHEN sbc.value in ('BDL Operations','BDL Pricing') THEN 'MFD/BDL'
       WHEN sbc.value in ('CDL Business Development','CDL Business Support','MFD Business Support','MFD Operations','MFD Shared Services') THEN 'MFD/CDL'
       WHEN sbc.value in ('CDL Compliance','MFD Compliance') THEN 'Compliance'
       WHEN sbc.value in ('CDL Pricing') THEN 'Pricing'
       WHEN sbc.value in ('CDL Sales') THEN 'Sales'
       WHEN sbc.value in ('CDL Marketing') THEN 'Marketing'
       ELSE 'Other' END ) as sponsoring_business_channel
       
    ,sbc.value as sponsoring_business_channel_detail
    ,pv.name||' - '||v.name as version_name
    ,pv.name as version_project
    ,v.name as version
    
    ,ifnull(lcss_in_analysis.days_in_status,0) as days_in_analysis
    ,ifnull(lcss_rdy_for_dev.days_in_status,0) as days_in_ready_for_dev
    ,ifnull(lcss_in_dev.days_in_status,0) as days_in_dev
    ,ifnull(lcss_rdy_for_qa.days_in_status,0) as days_in_ready_for_qa
    ,ifnull(lcss_in_qa.days_in_status,0) as days_in_qa
    ,ifnull(lcss_rdy_for_uat.days_in_status,0) as days_in_ready_for_uat
    ,ifnull(lcss_wait_for_uat.days_in_status,0) as days_in_waiting_for_uat_approval
    ,ifnull(lcss_uat_approved.days_in_status ,0) as days_in_uat_approved
    ,ifnull(lcss_rdy_for_release.days_in_status,0) as days_in_ready_for_release
    ,ifnull(lcss_wait_for_clar.days_in_status ,0) as days_in_waiting_for_clarification
    ,ifnull(lcss_on_hold.days_in_status,0) as days_in_hold
    ,ifnull(lcss_in_progress.days_in_status,0) as days_in_progress
    ,ifnull(lcss_guesstimate.days_in_status,0) as days_in_guesstimate

    ,ifnull(lcss_rdy_for_dev.days_in_status,0) + ifnull(lcss_in_dev.days_in_status,0) as days_in_development_possession
    ,ifnull(lcss_rdy_for_qa.days_in_status,0) + ifnull(lcss_in_qa.days_in_status,0) as days_in_qa_possession
    ,ifnull(lcss_rdy_for_uat.days_in_status,0) + ifnull(lcss_wait_for_uat.days_in_status,0) as days_in_uat_possession
    ,ifnull(lcss_uat_approved.days_in_status,0) + ifnull(lcss_rdy_for_release.days_in_status,0) as days_in_release_possession
    ,ifnull(lcss_wait_for_clar.days_in_status,0) + ifnull(lcss_on_hold.days_in_status,0) as days_in_hold_or_clarification_posession

    ,lcss_in_analysis.first_day_in_status as first_day_in_analysis
    ,lcss_rdy_for_dev.first_day_in_status as first_day_in_ready_for_dev
    ,lcss_in_dev.first_day_in_status as first_day_in_dev
    ,lcss_rdy_for_qa.first_day_in_status as first_day_in_ready_for_qa
    ,lcss_in_qa.first_day_in_status as first_day_in_qa
    ,lcss_rdy_for_uat.first_day_in_status as first_day_in_ready_for_uat
    ,lcss_wait_for_uat.first_day_in_status as first_day_in_waiting_for_uat_approval
    ,lcss_uat_approved.first_day_in_status as first_day_in_uat_approved
    ,lcss_rdy_for_release.first_day_in_status as first_day_in_ready_for_release
    ,lcss_wait_for_clar.first_day_in_status as first_day_in_waiting_for_clarification
    ,lcss_on_hold.first_day_in_status as first_day_in_hold
    ,lcss_in_progress.first_day_in_status as first_day_in_progress
    
    ,DATEDIFF('day'
        ,ifnull(lcss_in_analysis.first_day_in_status,ifnull(lcss_rdy_for_dev.first_day_in_status,ifnull(lcss_in_dev.first_day_in_status,i.created_on)))
        ,ifnull(lcss_prod_verification.first_day_in_status,ifnull(i.closed_on,current_timestamp))
        ) + 1
      - DATEDIFF('week'
        ,ifnull(lcss_in_analysis.first_day_in_status,ifnull(lcss_rdy_for_dev.first_day_in_status,ifnull(lcss_in_dev.first_day_in_status,i.created_on)))
        ,ifnull(lcss_prod_verification.first_day_in_status,ifnull(i.closed_on,current_timestamp))
        ) * 2
      - (CASE WHEN DAYNAME(ifnull(lcss_in_analysis.first_day_in_status,ifnull(lcss_rdy_for_dev.first_day_in_status,ifnull(lcss_in_dev.first_day_in_status,i.created_on)))) = 'Sun' THEN 1 ELSE 0 END)
      - (CASE WHEN DAYNAME(ifnull(lcss_prod_verification.first_day_in_status,ifnull(i.closed_on,current_timestamp))) = 'Sun' THEN 1 ELSE 0 END) 
        as delivery_time
    
    ,ifnull(ifnull(ifnull(lcss_rdy_for_dev.first_day_in_status,lcss_in_dev.first_day_in_status),lcss_rdy_for_qa.first_day_in_status),lcss_in_qa.first_day_in_status)
        as first_under_development_date
    
    ,e.name as priority
    ,cv_hold.value as on_hold
    ,cv_clarify.value as clarify
    ,cv_uat_delivery.value as uat_target_date
    ,uat.firstname||' '||uat.lastname as uat_approver
    ,trim(split_part(pdt.value,'(',1)) as primary_delivery_team
    ,mtwt.value as main_tracker_work_type
    ,( CASE WHEN mtwt.value in ('Enhancement','Enhancement/New Functionality','New Functionality') Then 'Enhancement/New Functionality'
        WHEN mtwt.value in ('Lights On','Lights On Maintenance/BAU','Lights On Maintenance/BAU/Production Suppport','Lights On Maintenance/BAU/Production Support','Production Support (TICKET ONLY)','Support') Then 'Production Support/BAU/Lights On Maintenance'
        ELSE mtwt.value END
     ) as main_tracker_work_type_summary
    
    ,to_number(ifnull(cfe_sa.name,0)) as sa_story_points
    ,to_number(ifnull(cfe_qa.name,0)) as qa_story_points
    ,to_number(ifnull(cfe_dev.name,0)) as dev_story_points
    
    ,p.name || ifnull(p2.name,'') || ifnull(p3.name,'') || ifnull(p4.name,'') || ifnull(p5.name,'') || ifnull(p6.name,'') as project_hierarchy
    ,p.identifier || ifnull(p2.identifier,'') || ifnull(p3.identifier,'') || ifnull(p4.identifier,'') || ifnull(p5.identifier,'') || ifnull(p6.identifier,'') as project_identifier_hierarchy
    ,v.updated_on as version_updated_on
    ,assignee.firstname||' '||assignee.lastname as assignee
    ,v.status as version_status
    ,last_status.created_on as time_last_status_was_changed
    ,TIMESTAMPDIFF( 'day' , last_status.created_on , current_timestamp ) as days_since_status_changed
from 
"REDLINE"."PNMAC"."ISSUES" i
 JOIN "REDLINE"."PNMAC"."PROJECTS" p ON i.project_id = p.id
 LEFT JOIN "REDLINE"."PNMAC"."ISSUE_STATUSES" s ON i.status_id = s.id
 LEFT JOIN "REDLINE"."PNMAC"."ISSUE_CATEGORIES" ic ON i.category_id = ic.id
 LEFT JOIN "REDLINE"."PNMAC"."TRACKERS" t ON i.tracker_id = t.id
 LEFT JOIN "REDLINE"."PNMAC"."ENUMERATIONS" e ON i.priority_id = e.id
 LEFT JOIN "REDLINE"."PNMAC"."USERS" assignee ON i.assigned_to_id = assignee.id
 /* Project Hierarchy Joins */
 LEFT JOIN "REDLINE"."PNMAC"."PROJECTS" p2 ON p.parent_id = p2.id
 LEFT JOIN "REDLINE"."PNMAC"."PROJECTS" p3 ON p2.parent_id = p3.id
 LEFT JOIN "REDLINE"."PNMAC"."PROJECTS" p4 ON p3.parent_id = p4.id
 LEFT JOIN "REDLINE"."PNMAC"."PROJECTS" p5 ON p4.parent_id = p5.id
 LEFT JOIN "REDLINE"."PNMAC"."PROJECTS" p6 ON p5.parent_id = p6.id
 /* Custom Fields */
 LEFT JOIN "REDLINE"."PNMAC"."CUSTOM_VALUES" sbc ON i.id = sbc.customized_id and sbc.custom_field_id = '35' /*Sponsoring Business Channel*/
 LEFT JOIN "REDLINE"."PNMAC"."CUSTOM_VALUES" mtwt ON i.id = mtwt.customized_id and mtwt.custom_field_id = '41' /*Main Tracker Work Type*/
 LEFT JOIN "REDLINE"."PNMAC"."CUSTOM_VALUES" pdt ON p.id = pdt.customized_id and pdt.custom_field_id = '109' /*Primary Delivery Team*/
 LEFT JOIN "REDLINE"."PNMAC"."CUSTOM_VALUES" rank ON i.id = rank.customized_id and rank.custom_field_id = '1' /*Rank*/
 LEFT JOIN "REDLINE"."PNMAC"."CUSTOM_VALUES" cv_hold on i.id = cv_hold.customized_id and cv_hold.custom_field_id = '44' /* Hold */
 LEFT JOIN "REDLINE"."PNMAC"."CUSTOM_VALUES" cv_clarify on i.id = cv_clarify.customized_id and cv_clarify.custom_field_id = '45' /*Awaiting Clarification*/
 LEFT JOIN "REDLINE"."PNMAC"."CUSTOM_VALUES" cv_rltype on p.id = cv_rltype.customized_id and cv_rltype.custom_field_id = '105' /*Redline Parent Type*/
 /* Story Point Fields */
 LEFT JOIN "REDLINE"."PNMAC"."CUSTOM_VALUES" sa_story_points ON i.id = sa_story_points.customized_id and sa_story_points.custom_field_id = '261' /* SA Story Points */
 LEFT JOIN "REDLINE"."PNMAC"."CUSTOM_FIELD_ENUMERATIONS" cfe_sa ON (CASE WHEN length(trim(sa_story_points.value)) = 0 THEN 0 ELSE sa_story_points.value END) = cfe_sa.id
 LEFT JOIN "REDLINE"."PNMAC"."CUSTOM_VALUES" dev_story_points ON i.id = dev_story_points.customized_id and dev_story_points.custom_field_id = '262' /* Dev Story Points */
 LEFT JOIN "REDLINE"."PNMAC"."CUSTOM_FIELD_ENUMERATIONS" cfe_dev ON (CASE WHEN length(trim(dev_story_points.value)) = 0 THEN 0 ELSE dev_story_points.value END) = cfe_dev.id
 LEFT JOIN "REDLINE"."PNMAC"."CUSTOM_VALUES" qa_story_points ON i.id = qa_story_points.customized_id and qa_story_points.custom_field_id = '263' /* QA Story Points */
 LEFT JOIN "REDLINE"."PNMAC"."CUSTOM_FIELD_ENUMERATIONS" cfe_qa ON (CASE WHEN length(trim(qa_story_points.value)) = 0 THEN 0 ELSE qa_story_points.value END) = cfe_qa.id
 /* Custom User Fields */
 LEFT JOIN "REDLINE"."PNMAC"."CUSTOM_VALUES" sa_id ON sa_id.custom_field_id = '152' /*SA*/ and i.id = sa_id.customized_id
 LEFT JOIN "REDLINE"."PNMAC"."USERS" sa ON sa.id = (CASE WHEN length(trim(sa_id.value)) = '0' THEN -1 else ifnull(sa_id.value,-1) END) 
 LEFT JOIN "REDLINE"."PNMAC"."CUSTOM_VALUES" qa_id ON qa_id.custom_field_id = '151' /* QA Engineer */ and i.id = qa_id.customized_id
 LEFT JOIN "REDLINE"."PNMAC"."USERS" qa ON qa.id = (CASE WHEN length(trim(qa_id.value)) = '0' THEN -1 else ifnull(qa_id.value,-1) END) 
 LEFT JOIN "REDLINE"."PNMAC"."CUSTOM_VALUES" dev_id ON dev_id.custom_field_id = '51' /* Developer */ and i.id = dev_id.customized_id
 LEFT JOIN "REDLINE"."PNMAC"."USERS" dev ON dev.id = (CASE WHEN length(trim(dev_id.value)) = '0' THEN -1 else ifnull(dev_id.value,-1) END) 
 LEFT JOIN "REDLINE"."PNMAC"."CUSTOM_VALUES" cv_uat_user on i.id = cv_uat_user.customized_id and cv_uat_user.custom_field_id = '182' /* UAT Approver Id */
 LEFT JOIN "REDLINE"."PNMAC"."USERS" uat ON (CASE WHEN length(trim(cv_uat_user.value)) = '0' THEN -1 else ifnull(cv_uat_user.value,-1) END)  = uat.id
 /* Release Info */
 LEFT JOIN "REDLINE"."PNMAC"."VERSIONS" v ON i.fixed_version_id = v.id
 LEFT JOIN "REDLINE"."PNMAC"."PROJECTS" pv ON v.project_id = pv.id
 LEFT JOIN "REDLINE"."PNMAC"."CUSTOM_VALUES" cv_uat_delivery on i.id = cv_uat_delivery.customized_id and cv_uat_delivery.custom_field_id = '180' /* UAT Delivery Date */
 /* Issue Lifecycle Info */
 LEFT JOIN "REDLINE"."PNMAC"."MVW_STATUSLIFECYCLESUMMARY" lcss_in_analysis ON i.id = lcss_in_analysis.issue and lcss_in_analysis.status_name = 'In Analysis'
 LEFT JOIN "REDLINE"."PNMAC"."MVW_STATUSLIFECYCLESUMMARY" lcss_rdy_for_dev ON i.id = lcss_rdy_for_dev.issue and lcss_rdy_for_dev.status_name = 'Ready for Development'
 LEFT JOIN "REDLINE"."PNMAC"."MVW_STATUSLIFECYCLESUMMARY" lcss_in_dev ON i.id = lcss_in_dev.issue and lcss_in_dev.status_name = 'In Development'
 LEFT JOIN "REDLINE"."PNMAC"."MVW_STATUSLIFECYCLESUMMARY" lcss_rdy_for_qa ON i.id = lcss_rdy_for_qa.issue and lcss_rdy_for_qa.status_name = 'Ready for QA'
 LEFT JOIN "REDLINE"."PNMAC"."MVW_STATUSLIFECYCLESUMMARY" lcss_in_qa ON i.id = lcss_in_qa.issue and lcss_in_qa.status_name = 'In QA'
 LEFT JOIN "REDLINE"."PNMAC"."MVW_STATUSLIFECYCLESUMMARY" lcss_rdy_for_uat ON i.id = lcss_rdy_for_uat.issue and lcss_rdy_for_uat.status_name = 'Ready for UAT'
 LEFT JOIN "REDLINE"."PNMAC"."MVW_STATUSLIFECYCLESUMMARY" lcss_wait_for_uat ON i.id = lcss_wait_for_uat.issue and lcss_wait_for_uat.status_name = 'Waiting for UAT Approval'
 LEFT JOIN "REDLINE"."PNMAC"."MVW_STATUSLIFECYCLESUMMARY" lcss_uat_approved ON i.id = lcss_uat_approved.issue and lcss_uat_approved.status_name = 'UAT Approved'
 LEFT JOIN "REDLINE"."PNMAC"."MVW_STATUSLIFECYCLESUMMARY" lcss_rdy_for_release ON i.id = lcss_rdy_for_release.issue and lcss_rdy_for_release.status_name = 'Ready for Release'
 LEFT JOIN "REDLINE"."PNMAC"."MVW_STATUSLIFECYCLESUMMARY" lcss_wait_for_clar ON i.id = lcss_wait_for_clar.issue and lcss_wait_for_clar.status_name = 'Waiting for Clarification'
 LEFT JOIN "REDLINE"."PNMAC"."MVW_STATUSLIFECYCLESUMMARY" lcss_on_hold ON i.id = lcss_on_hold.issue and lcss_on_hold.status_name = 'Hold'
 LEFT JOIN "REDLINE"."PNMAC"."MVW_STATUSLIFECYCLESUMMARY" lcss_prod_verification ON i.id = lcss_prod_verification.issue and lcss_prod_verification.status_name = 'Production Verification' 
 LEFT JOIN "REDLINE"."PNMAC"."MVW_STATUSLIFECYCLESUMMARY" lcss_in_progress ON i.id = lcss_in_progress.issue and lcss_in_progress.status_name = 'In Progress' /* For ticket statuses */
 LEFT JOIN "REDLINE"."PNMAC"."MVW_STATUSLIFECYCLESUMMARY" lcss_guesstimate ON i.id = lcss_guesstimate.issue and lcss_guesstimate.status_name = 'Guesstimate' /* For ticket statuses */
 /* How long since status has changed? */
 LEFT JOIN "REDLINE"."PNMAC"."VW_LASTSTATUSCHANGEJOURNALENTRY" lscje ON i.id = lscje.journalized_id
 LEFT JOIN "REDLINE"."PNMAC"."JOURNALS" last_status ON lscje.lastest_journal_id = last_status.id
;
