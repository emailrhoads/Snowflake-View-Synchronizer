
CREATE OR REPLACE VIEW "RESOURCE_CAPACITY"."PNMAC"."VW_ACTUALS_V2" AS 
SELECT
    ifnull(effort_id,redline_project_identifier) as effort_id
    ,billed_department_id
    ,billed_sub_division_id
    ,billed_division_id
    ,redline_application_id as application_id
    ,redline_application_name as application_name
    ,billable_hours
    ,capitalized
    ,work_category
    
    ,year
    ,quarter
    ,month
    ,week
    ,entry_date
    
    ,employee_id
    ,network_login
    ,working_team_sub_division_id
    
    ,redline_project
    ,redline_issue
    ,redline_issue_subject
    ,break_fix_lights_on_enhancement
    ,redline_primary_delivery_team
FROM (
  select 
     rc.effort_id
     ,rc.billed_sub_division_id
     ,rc.billed_department_id
     ,rc.billed_division_id
     ,rc.working_team_sub_division_id
     ,rc.year
     ,rc.quarter
     ,rc.month
     ,rc.week
     ,rc.entry_date
     ,rc.employee_id
     ,e.networklogin as network_login
     ,rc.billable_hours
     ,rc.capitalized as capitalized
     ,'Google Sheets Timetracking (N/A)' as redline_project
     ,'Google Sheets Timetracking (N/A)' as redline_project_identifier
     ,'0' as redline_issue
     ,'Google Sheets Timetracking (N/A)' as redline_issue_subject
     ,'NULL' as redline_application_id
     ,'NULL' as redline_application_name
     ,'NULL' as redline_project_billed_department_id
     ,'NULL' as redline_project_billed_department_name
    ,rc.work_category
    ,'N/A' as break_fix_lights_on_enhancement
    ,'N/A' as redline_primary_delivery_team
  from "RESOURCE_CAPACITY"."PNMAC"."VW_RCACTUALS_V2" rc
  LEFT JOIN "DW_ORG"."PNMAC"."VW_ONE_ROW_PER_EMPLOYEE" e ON lower(trim(rc.employee_id)) = lower(trim(e.employeeid))

  UNION ALL

  select 
      effort_id
      ,'NULL' as billed_sub_division_id
      ,(CASE WHEN work_category in ('OOO','ADMIN') THEN employee_departmentid else redline_project_billed_department_id end) as billed_department_id
      ,(CASE WHEN work_category in ('OOO','ADMIN') THEN employee_divisionid else redline_project_billed_division_id end) as billed_division_id
      ,'NULL' as working_team_id
      ,year
      ,quarter
      ,month
      ,week
      ,entry_date
      ,employee_id
      ,network_login
      ,billable_hours
      ,redline_capitalization as capitalized
      ,redline_project
      ,redline_project_identifier
      ,to_char(redline_issue) as redline_issue
      ,redline_issue_subject
      ,redline_application_id
      ,redline_application_name
      ,redline_project_billed_department_id
      ,redline_project_billed_department_name
      ,work_category
      ,break_fix_lights_on_enhancement
      ,redline_primary_delivery_team
  from "RESOURCE_CAPACITY"."PNMAC"."VW_REDLINEACTUALS_V2"
);
