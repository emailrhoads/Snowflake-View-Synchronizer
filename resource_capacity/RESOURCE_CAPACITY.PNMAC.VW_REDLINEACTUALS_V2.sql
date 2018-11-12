
CREATE OR REPLACE VIEW "RESOURCE_CAPACITY"."PNMAC"."VW_REDLINEACTUALS_V2" AS
SELECT
    /* Employee Info */
    rl.user_login as network_login
    ,dwo.employeeid as employee_id
    ,dwo.departmentid as employee_departmentid
    ,dept_emp.divisionid as employee_divisionid
    
    /* Time Entry Features */
    ,(CASE WHEN length(trim(rl.itid)) < 3 THEN rl.project_identifier else trim(rl.itid) END) as effort_id
    ,(CASE WHEN rl.entry_activity = 'Capitalized' THEN 'Yes' ELSE 'No' END) as redline_capitalization
    
    /* Time info */
    ,rl.entry_year as year
    ,'Q'||extract(quarter from rl.entry_date) as quarter
    ,extract(month from rl.entry_date)  as month
    ,rl.entry_week as week
    ,rl.entry_date as entry_date
    ,rl.entry_hours as billable_hours
    
    /* Redline Selections */
    ,rl.project_name as redline_project
    ,rl.project_identifier as redline_project_identifier
    ,TO_CHAR(rl.issue_id) as redline_issue
    ,TO_CHAR(rl.issue_subject) as redline_issue_subject
    ,ifnull(rl.issue_impacted_application_id,rl.project_impacted_application_id) as redline_application_id
    ,ifnull((CASE WHEN rl.issue_impacted_application = '<None>' THEN null END),rl.project_impacted_application) as redline_application_name
    ,rl.break_fix_lights_on_enhancement
    ,rl.primary_delivery_team as redline_primary_delivery_team
    
    /* Billed To */
    ,s.sub_division_id as billed_sub_division_id
    ,ifnull(s.department_id,(CASE WHEN length(rl.project_billed_department_id) = 4 THEN rl.project_billed_department_id ELSE null END)) as redline_project_billed_department_id
    ,(CASE WHEN length(rl.project_billed_department_id) = 4 THEN rl.project_billed_department_name ELSE null END) as redline_project_billed_department_name  
    ,ifnull(s.division_id,(CASE WHEN length(rl.project_billed_department_id) = 3 THEN rl.project_billed_department_id ELSE dept.divisionid END)) as redline_project_billed_division_id    
    ,(CASE WHEN length(rl.project_billed_department_id) = 3 THEN rl.project_billed_department_name ELSE div.name END) as redline_project_billed_division_name
    
    /* Calculations and Logic */
    ,(CASE
        WHEN rl.itid = 'OOO' THEN 'OOO'
        WHEN rl.redline_project_category = 'Maintenance' THEN 'MAINT'
        WHEN rl.project_identifier = 'administration' THEN 'ADMIN'
        WHEN rl.itid in ('WK068','WK075','WK096','WK118','WK122','WK128','WK131','WK154',
                'WK165','WK174','WK175','WK176','WK177','WK178','WK179','WK180',
                'WK181','WK182','WK183','WK184','WK185','WK186','WK187','WK188',
                'WK190','WK181','WK194','WK197','WK198','WK201','WK202','WK209','WK228','WK237',
                'WK232','WK234','WK247','WK318','WK911','WK913') THEN 'ADMIN'
        WHEN left(trim(rl.itid),2) = 'WK' THEN 'MAINT'
        ELSE 'PROJ' END) as WORK_CATEGORY
           
  FROM "REDLINE"."PNMAC"."VW_TIMESHEETENTRIES" rl
  LEFT JOIN
       "DW_ORG"."PNMAC"."VW_ONE_ROW_PER_EMPLOYEE" dwo ON trim(lower(rl.USER_LOGIN)) = trim(lower(dwo.networklogin)) and dwo.rowcurrentflag = 'Y'
  LEFT JOIN "RESOURCE_CAPACITY"."PNMAC"."VW_EFFORTLISTING" el ON (CASE WHEN length(trim(rl.itid)) < 3 THEN rl.project_identifier else trim(rl.itid) END) = el.effort_id and rl.entry_year = el.year
  LEFT JOIN "RESOURCE_CAPACITY"."PNMAC"."SUB_DIVISIONS" s ON el.billable_to_sub_division_id = s.sub_division_id
  LEFT JOIN "DW_ORG"."PNMAC"."DEPARTMENT" dept ON rl.project_billed_department_id = dept.departmentid
  LEFT JOIN "DW_ORG"."PNMAC"."DIVISION" div ON dept.divisionid = div.divisionid
  LEFT JOIN "DW_ORG"."PNMAC"."DEPARTMENT" dept_emp ON dwo.DEPARTMENTID = dept_emp.DEPARTMENTID
  WHERE
   (
    (lower(rl.USER_LOGIN) not in ('ssharma','dpandurangi','sverma') and rl.ENTRY_LAST_UPDATED >= '2018-07-02')
      OR 
     (lower(rl.USER_LOGIN) in ('ssharma','dpandurangi','sverma') and rl.ENTRY_LAST_UPDATED >= '2018-07-15')
   )
   AND
   /* We need to ignore certain parts of Redline2 ... */
   rl.project_identifier <> 'servdata';
