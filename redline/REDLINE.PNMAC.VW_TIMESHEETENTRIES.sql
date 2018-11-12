
CREATE OR REPLACE VIEW "REDLINE"."PNMAC"."VW_TIMESHEETENTRIES" AS 
SELECT 
  CASE WHEN LENGTH(trim(cvi1.value)) >= 3 THEN cvi1.value ELSE cvp.value END as itid
  ,pr1.id                        as project_id
  ,pr1.name                      as project_name
  ,pr1.description               as project_description
  ,pr1.identifier                as project_identifier
  ,trim(replace(split_part(cvp4.value,'(',1 ),')')) as project_impacted_application
  ,replace(
  (CASE WHEN length(trim(split_part(cvp4.value ,'(',3 ))) > 0 THEN trim(split_part(cvp4.value ,'(',3 ))
   ELSE trim(split_part(cvp4.value ,'(',2 )) END)
  ,')') as project_impacted_application_id
  ,cvp.value                    as project_itid
  ,ifnull(cfe1.name,cvp2.value) as project_billed_department_name
  ,replace((CASE WHEN length(trim(split_part(cfe1.name ,'(',3 ))) > 0 THEN trim(split_part(cfe1.name ,'(',3 ))
   ELSE trim(split_part(cfe1.name ,'(',2 )) END)
  ,')') as project_billed_department_id
  ,cvp3.value                   as project_work_team_id
  ,trim(split_part(project_work_team_id,'(',1)) as primary_delivery_team
  ,trim(replace(split_part(cvi3.value,'(',1 ),')')) as issue_impacted_application
  ,replace((CASE WHEN length(trim(split_part(cvi3.value ,'(',3 ))) > 0 THEN trim(split_part(cvi3.value ,'(',3 ))
   ELSE trim(split_part(cvi3.value ,'(',2 )) END)
  ,')') as issue_impacted_application_id
  ,i1.id                        as issue_id
  ,i1.subject                   as issue_subject
  ,i1.description               as issue_description
  ,i1.start_date                as issue_start_date
  ,i1.due_date                  as issue_due_date
  ,i1.done_ratio                as issue_done_ratio
  ,i1.estimated_hours           as issue_estimated_hours
  ,i1.created_on                as issue_created_on
  ,i1.closed_on                 as issue_closed_on
  ,i1.priority_id               as issue_priority_id
  ,e1.name                      as issue_priority_name
  ,cvi1.value                   as issue_itid
  ,i1.tracker_id                as issue_tracker_id
  ,t1.name                      as issue_tracker_name
  ,cvi2.value                   as issue_type
    ,(CASE WHEN cvi2.value in ('New Functionality','Enhancement/New Functionality','Enhancement') THEN 'Enhancement/New Functionality'
        WHEN cvi2.value in ('Support','Production Support (TICKET ONLY)','Lights On Maintenance/BAU','Lights On','Lights On Maintenance/BAU/Production Support') THEN 'Lights On Maintenance/BAU/Production Support' 
        WHEN cvi2.value in ('Defect') THEN 'Defect/Break-fix'
        WHEN cvi2.value in ('Research & Analysis (TICKET ONLY)') THEN 'Research & Analysis'
        ELSE 'N/A' END ) break_fix_lights_on_enhancement
  ,is1.id                       as issue_status_id
  ,is1.name                     as issue_status_name
  ,te1.hours                    as unadjusted_entry_hours
  ,ceil(te1.hours / (ifnull(cvic.issue_application_count,1) * ifnull(cvpc.project_application_count,1) ),6) as entry_hours
  ,te1.spent_on                 as entry_date
  ,te1.user_id                  as entry_user_id
  ,te1.tweek                    as entry_week
  ,te1.tyear                    as entry_year
  ,te1.tmonth                   as entry_month
  ,te1.activity_id              as entry_id
  ,te1.updated_on               as entry_last_updated
  ,datediff('day',te1.spent_on,te1.updated_on) as entry_days_between
  ,u1.firstname                 as user_first_name
  ,u1.lastname                  as user_last_name
  ,u1.login                     as user_login
  ,e2.name                      as entry_activity
  ,cvic.issue_application_count     as issue_application_count
  ,cvpc.project_application_count   as project_application_count
  ,cvp5.value                   as redline_project_category
FROM
    REDLINE.PNMAC.time_entries te1 
    LEFT JOIN REDLINE.PNMAC.issues i1 ON te1.issue_id = i1.id 
    LEFT JOIN REDLINE.PNMAC.projects pr1 ON te1.project_id = pr1.id 
    LEFT JOIN REDLINE.PNMAC.custom_values cvi1 ON i1.id = cvi1.customized_id and cvi1.CUSTOM_FIELD_ID = '70' /* 70  = Issue ITID */
    LEFT JOIN REDLINE.PNMAC.custom_values cvi2 ON i1.id = cvi2.customized_id and cvi2.CUSTOM_FIELD_ID = '41' /* 41  = Main Tracker Work Type */
    LEFT JOIN REDLINE.PNMAC.custom_values cvi3 ON i1.id = cvi3.customized_id and cvi3.CUSTOM_FIELD_ID = '212' /* 212  = Impacted Application */
    LEFT JOIN REDLINE.PNMAC.issue_statuses is1 ON i1.status_id = is1.id 
    LEFT JOIN REDLINE.PNMAC.enumerations e1 ON i1.priority_id = e1.id
    LEFT JOIN REDLINE.PNMAC.trackers t1 on i1.tracker_id = t1.id
    LEFT JOIN REDLINE.PNMAC.custom_values cvp ON pr1.id = cvp.customized_id and cvp.CUSTOM_FIELD_ID = '106' /* 106 = Project ITID */
    LEFT JOIN REDLINE.PNMAC.custom_values cvp2 ON pr1.id = cvp2.customized_id and cvp2.CUSTOM_FIELD_ID = '257' /* 257 = Billed Sub-division */
    LEFT JOIN REDLINE.PNMAC.custom_field_enumerations cfe1 ON cvp2.value = cfe1.id /* Billed Sub-division is an enumeration */
    LEFT JOIN REDLINE.PNMAC.custom_values cvp3 ON pr1.id = cvp3.customized_id and cvp3.CUSTOM_FIELD_ID = '109' /* 109 = Primary Delivery Team */
    LEFT JOIN REDLINE.PNMAC.custom_values cvp4 ON pr1.id = cvp4.customized_id and cvp4.CUSTOM_FIELD_ID = '242' /* 242 = Impacted Application */
    LEFT JOIN REDLINE.PNMAC.custom_values cvp5 ON pr1.id = cvp5.customized_id and cvp5.CUSTOM_FIELD_ID = '105' /* 105 = Redline Project Type */
    LEFT JOIN REDLINE.PNMAC.users u1 ON te1.user_id = u1.id
    LEFT JOIN REDLINE.PNMAC.enumerations e2 ON te1.activity_id = e2.id
    LEFT JOIN (select customized_id, count(*) as issue_application_count from REDLINE.PNMAC.custom_values where custom_field_id = '212' group by customized_id) cvic ON i1.id = cvic.customized_id
    LEFT JOIN (select customized_id, count(*) as project_application_count from REDLINE.PNMAC.custom_values where custom_field_id = '242' group by customized_id) cvpc ON pr1.id = cvpc.customized_id
WHERE
    year(te1.created_on) >= '2017';
