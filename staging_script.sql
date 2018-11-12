/* drop objects */
DROP VIEW IF EXISTS RESOURCE_CAPACITY.STAGE.VW_RCACTUALS_V2;
DROP VIEW IF EXISTS DW_ORG.STAGE.VW_LASTESTRECORD;
DROP VIEW IF EXISTS DW_ORG.STAGE.VW_LASTESTEMPRECORDS;
DROP VIEW IF EXISTS DW_ORG.STAGE.VW_ONE_ROW_PER_EMPLOYEE;
DROP VIEW IF EXISTS RESOURCE_CAPACITY.STAGE.VW_PROJECTMILESTONEINFO;
DROP VIEW IF EXISTS RESOURCE_CAPACITY.STAGE.VW_RELEASEITEMINFO;
DROP VIEW IF EXISTS RESOURCE_CAPACITY.STAGE.VW_EFFORTLISTING;
DROP VIEW IF EXISTS REDLINE.STAGE.VW_TIMESHEETENTRIES;
DROP VIEW IF EXISTS RESOURCE_CAPACITY.STAGE.VW_REDLINEACTUALS_V2;
DROP VIEW IF EXISTS RESOURCE_CAPACITY.STAGE.VW_ACTUALS_V2;
DROP VIEW IF EXISTS RESOURCE_CAPACITY.STAGE.VW_ASOFDATE;
DROP VIEW IF EXISTS RESOURCE_CAPACITY.STAGE.VW_FORECAST_V2;
DROP VIEW IF EXISTS RESOURCE_CAPACITY.STAGE.VW_FORECAST_AND_ACTUAL_COMBINED_V2;
DROP VIEW IF EXISTS DW_ORG.STAGE.VW_EMPLOYEE_HIERARCHY;
DROP VIEW IF EXISTS RESOURCE_CAPACITY.STAGE.VW_FORECAST_AND_ACTUAL_COMBINED_INFO_V2A;
DROP VIEW IF EXISTS RESOURCE_CAPACITY.STAGE.VW_WEEKLYTOTALSBYEMP;
DROP VIEW IF EXISTS RESOURCE_CAPACITY.STAGE.VW_FORECAST_AND_ACTUAL_COMBINED_INFO_V2B;
DROP VIEW IF EXISTS RESOURCE_CAPACITY.STAGE.VW_FORECASTANDACTUALCOMBINEDINFO;
DROP TABLE IF EXISTS RESOURCE_CAPACITY.STAGE.MVW_FORECASTANDACTUALCOMBINEDINFO;
DROP VIEW IF EXISTS RESOURCE_CAPACITY.STAGE.VW_MISSINGTIMESHEETENTRIES;
DROP TABLE IF EXISTS RESOURCE_CAPACITY.STAGE.MVW_MISSINGTIMESHEETENTRIES;
DROP VIEW IF EXISTS DW_ORG.STAGE.VW_MONTHTABLE;
DROP VIEW IF EXISTS REDLINE.STAGE.VW_MONTHTABLE;
DROP VIEW IF EXISTS DW_ORG.STAGE.VW_MONTHLY_EMPLOYEES;
DROP VIEW IF EXISTS DW_ORG.STAGE.VW_MONTHLY_EMPLOYEES_WITH_BUDGET;
DROP VIEW IF EXISTS DW_ORG.STAGE.VW_MOSTRECENTEMPLOYEERECORDBYLOGIN;
DROP TABLE IF EXISTS DW_ORG.STAGE.MVW_MONTHLY_EMPLOYEES_WITH_BUDGET;
DROP VIEW IF EXISTS REDLINE.STAGE.VW_CLARIFICATIONCOUNT;
DROP VIEW IF EXISTS REDLINE.STAGE.VW_EMPLOYEE_LISTING;
DROP VIEW IF EXISTS REDLINE.STAGE.VW_RECENTJOURNALDETAILS;
DROP VIEW IF EXISTS REDLINE.STAGE.VW_HOLDANDCLARIFICATIONCHANGE;
DROP VIEW IF EXISTS REDLINE.STAGE.VW_HOLDCLARIFYLIFECYCLE;
DROP VIEW IF EXISTS REDLINE.STAGE.VW_HOLDCOUNT;
DROP VIEW IF EXISTS REDLINE.STAGE.VW_ISSUESTATUSLATEST;
DROP VIEW IF EXISTS REDLINE.STAGE.VW_JOURNALANDDETAILS;
DROP VIEW IF EXISTS REDLINE.STAGE.VW_LASTSTATUSCHANGEJOURNALENTRY;
DROP VIEW IF EXISTS REDLINE.STAGE.VW_LASTUPDATE;
DROP VIEW IF EXISTS REDLINE.STAGE.VW_NEXTSTATUSCHANGE;
DROP VIEW IF EXISTS REDLINE.STAGE.VW_PROJECTMETADATA;
DROP VIEW IF EXISTS REDLINE.STAGE.VW_PROJECT_ROLE_ASSIGNMENTS;
DROP VIEW IF EXISTS REDLINE.STAGE.VW_READONLYACCESSREVIEW;
DROP VIEW IF EXISTS REDLINE.STAGE.VW_REDLINEARTIFACTS;
DROP VIEW IF EXISTS REDLINE.STAGE.VW_REDLINEARTIFACTSPARENTSONLY;
DROP VIEW IF EXISTS REDLINE.STAGE.VW_REDLINEISSUESANDPROJECTS;
DROP VIEW IF EXISTS REDLINE.STAGE.VW_REDLINESDLC;
DROP VIEW IF EXISTS REDLINE.STAGE.VW_REDLINESDLCALL;
DROP VIEW IF EXISTS REDLINE.STAGE.VW_STATUSLIFECYCLE;
DROP VIEW IF EXISTS REDLINE.STAGE.VW_STATUSLIFECYCLESUMMARY;
DROP TABLE IF EXISTS REDLINE.STAGE.MVW_STATUSLIFECYCLESUMMARY;
DROP VIEW IF EXISTS REDLINE.STAGE.VW_REDLINEWORKSTUDY;
DROP VIEW IF EXISTS REDLINE.STAGE.VW_REDLINEWORKSTUDYMONTHLY;
DROP VIEW IF EXISTS REDLINE.STAGE.VW_REDLINEWORKSTUDYWITHHOURS;
DROP VIEW IF EXISTS REDLINE.STAGE.VW_USERPROJECTACCESSREVIEW;
DROP TABLE IF EXISTS REDLINE.STAGE.MVW_REDLINEWORKSTUDY;
DROP TABLE IF EXISTS REDLINE.STAGE.MVW_REDLINEWORKSTUDYMONTHLY;
DROP TABLE IF EXISTS REDLINE.STAGE.MVW_REDLINEWORKSTUDYWITHHOURS;


/* create objects in order */

CREATE OR REPLACE VIEW "RESOURCE_CAPACITY"."STAGE"."VW_RCACTUALS_V2" AS
SELECT
  trim(b.effort_id) as effort_id
  ,(CASE WHEN b.effort_id = 'OOO' AND ( trim(ifnull(b.sub_division_id,'NULL')) = 'NULL' OR length(trim(b.sub_division_id)) = 0 ) THEN ifnull(trim(b.team),trim(e.sub_division_id))
    ELSE trim(b.sub_division_id) END ) as billed_sub_division_id
  ,trim(s.division_id) as billed_division_id
  ,s.department_id as billed_department_id
  ,trim(b.team) as working_team_sub_division_id
  ,b.year as year
  ,'Q'||extract(quarter from dateadd(day,-6-date_part(weekday, dateadd(week, 1, date_from_parts(b.year,1,1))), dateadd(week, b.week, date_from_parts(b.year,1,1))))
    as quarter
  ,extract(month from dateadd(day,-6-date_part(weekday, dateadd(week, 1, date_from_parts(b.year,1,1))), dateadd(week, b.week, date_from_parts(b.year,1,1))))
    as month
  ,b.week as week
  ,dateadd(day, 7*(b.week - 1) - 
             (CASE WHEN date_part('dow', date_from_parts(b.year, 1, 1)) = 0 THEN -1
              ELSE date_part('dow', date_from_parts(b.year, 1, 1))-1 END), date_from_parts(b.year, 1, 1) ) as entry_date
  ,trim(b.employee_id) as employee_id
  ,b.billable_hours as billable_hours
  ,null as capitalized /* billable_hours.capitalized is NOT trust-worthy! */
  ,(CASE 
        WHEN b.effort_id = 'OOO' THEN 'OOO'
        
        WHEN b.effort_id in ('WK068','WK075','WK096','WK118','WK122','WK128','WK131','WK154',
                'WK165','WK174','WK175','WK176','WK177','WK178','WK179','WK180',
                'WK181','WK182','WK183','WK184','WK185','WK186','WK187','WK188',
                'WK190','WK181','WK194','WK197','WK198','WK201','WK202','WK209','WK228','WK237',
                'WK232','WK234','WK247','WK318','WK911','WK913') THEN 'ADMIN'
        WHEN left(b.effort_id,2) = 'WK' THEN 'MAINT'
        ELSE 'PROJ' END) as WORK_CATEGORY
FROM "RESOURCE_CAPACITY"."PNMAC"."BILLABLE_HOURS" b
LEFT JOIN "RESOURCE_CAPACITY"."PNMAC"."SUB_DIVISIONS" s ON ifnull(trim(b.sub_division_id),trim(b.team)) = s.sub_division_id
LEFT JOIN "RESOURCE_CAPACITY"."PNMAC"."EMPLOYEES" e ON trim(b.employee_id) = trim(e.employee_id)
WHERE
 b.year >= 2015;



create or replace view "DW_ORG"."STAGE"."VW_LASTESTRECORD" as
select max((CASE WHEN employmentstatus = 'Active' THEN '1' ELSE 0 END)||UPDATEDDATETIME||employeekey) as employeekeycode, lower(trim(networklogin)) as networklogin from "DW_ORG"."PNMAC"."EMPLOYEE" 
/* use udpatetime to do a sort  and bias towards active records */
where rowcurrentflag = 'Y'
and employeeid not in ('001025')
/* Some updates for records need to be removed! */
group by lower(trim(networklogin));



create or replace view "DW_ORG"."STAGE"."VW_LASTESTEMPRECORDS" as
select * from  "DW_ORG"."PNMAC"."EMPLOYEE" 
where (CASE WHEN employmentstatus = 'Active' THEN '1' ELSE 0 END)||UPDATEDDATETIME||employeekey in (select employeekeycode from "DW_ORG"."STAGE"."VW_LASTESTRECORD");



create or replace view "DW_ORG"."STAGE"."VW_ONE_ROW_PER_EMPLOYEE" as
select * from  "DW_ORG"."PNMAC"."EMPLOYEE" 
where employeekey in (select employeekey from "DW_ORG"."STAGE"."VW_LASTESTEMPRECORDS");



CREATE OR REPLACE VIEW "RESOURCE_CAPACITY"."STAGE"."VW_PROJECTMILESTONEINFO" AS 
select
            pm.project_milestone_id as effort_id
            ,pm.milestone_item_name as effort_name
            ,pm.project_id
            ,p.project_name
            ,project_milestone_id as milestone_id
            ,pm.milestone_item_name as milestone_name
            ,project_milestone_id as phase_id
            ,pm.milestone_item_name as phase_name
            ,project_milestone_id as release_id
            ,pm.milestone_item_name as release_name
            ,project_milestone_id as item_id
            ,pm.milestone_item_name as item_name
            ,pm.year as year
            ,CASE
              WHEN pm.capitalized ='Y' THEN 'Yes'
              WHEN pm.capitalized ='N' THEN 'No'
              WHEN pm.capitalized = null THEN 'No'
              END as capitalized
             ,pm.application_id as application_id
            ,pm.billable_to_sub_division_id as billable_to_sub_division_id
          from
            "RESOURCE_CAPACITY"."PNMAC"."PROJECT_MILESTONES" pm, "RESOURCE_CAPACITY"."PNMAC"."PROJECTS" p
          where
            pm.year = p.year and lower(trim(pm.project_id)) = lower(trim(p.project_id))
            and pm.year >= 2015;



CREATE OR REPLACE VIEW "RESOURCE_CAPACITY"."STAGE"."VW_RELEASEITEMINFO" AS 
select
          ri.item_id as effort_id
          ,ri.item_name as effort_name
          ,ri.project_id as project_id
          ,p.project_name as project_name
          ,ri.milestone_id as milestone_id
          ,pm.milestone_item_name as milestone_name
          ,ri.phase_id as phase_id
          ,pp.phases_name as phase_name
          ,ri.release_id as release_id
          ,pr.release_name as release_name
          ,ri.item_id as item_id
          ,ri.item_name as item_name
          ,ri.year as year
          ,CASE
              WHEN ri.capitalized ='Y' THEN 'Yes'
              WHEN ri.capitalized ='N' THEN 'No'
              WHEN ri.capitalized = null THEN 'No'
              END as capitalized
           ,pm.application_id as application_id
           ,ri.billable_to_sub_division_id as billable_to_sub_division_id
          from "RESOURCE_CAPACITY"."PNMAC"."RELEASE_ITEMS" ri
          LEFT JOIN "RESOURCE_CAPACITY"."PNMAC"."PROJECTS" p ON ri.year = p.year and lower(trim(ri.project_id)) =lower(trim( p.project_id))
          LEFT JOIN "RESOURCE_CAPACITY"."PNMAC"."PROJECT_MILESTONES" pm ON ri.year = pm.year and lower(trim(ri.milestone_id)) = lower(trim(pm.project_milestone_id))
          LEFT JOIN "RESOURCE_CAPACITY"."PNMAC"."PROJECT_MILESTONE_PHASES" pp ON ri.year = pp.year and lower(trim(ri.phase_id)) = lower(trim(pp.phase_id)) 
          LEFT JOIN "RESOURCE_CAPACITY"."PNMAC"."PROJECT_MILESTONE_RELEASES" pr ON ri.year = pr.year and lower(trim(ri.release_id)) = lower(trim(pr.release_id))
          where ri.year >= 2015;



CREATE OR REPLACE VIEW "RESOURCE_CAPACITY"."STAGE"."VW_EFFORTLISTING" AS
select distinct
          effort_id 
          ,effort_name
          ,project_id
          ,project_name
          ,milestone_id
          ,milestone_name
          ,phase_id
          ,phase_name
          ,release_id
          ,release_name
          ,item_id
          ,item_name
          ,year
          ,capitalized
          ,application_id
          ,billable_to_sub_division_id
          from "RESOURCE_CAPACITY"."STAGE"."VW_RELEASEITEMINFO"

         UNION 

          select distinct
            effort_id
          ,effort_name
          ,project_id
          ,project_name
          ,milestone_id
          ,milestone_name
          ,phase_id
          ,phase_name
          ,release_id
          ,release_name
          ,item_id
          ,item_name
          ,year
          ,capitalized
          ,application_id
          ,billable_to_sub_division_id
          from
            "RESOURCE_CAPACITY"."STAGE"."VW_PROJECTMILESTONEINFO"

          UNION 

          select distinct
            project_id as effort_id
            ,project_name as effort_name
            ,project_id
            ,project_name
            ,project_id as milestone_id
            ,project_name as milestone_name
            ,project_id as phase_id
            ,project_name as phase_name
            ,project_id as release_id
            ,project_name as release_name
            ,project_id as item_id
            ,project_name as item_name
            ,year as year
            ,'No' as capitalized
            ,application_id as application_id
            ,billable_to_sub_division_id
          from "RESOURCE_CAPACITY"."PNMAC"."PROJECTS"
          where year >= 2015

          UNION 

          select distinct
            work_item_id as effort_id
            ,work_item_name as effort_name
            ,work_item_id as project_id
            ,work_item_name as project_name
            ,work_item_id as milestone_id
            ,work_item_name as milestone_name
            ,work_item_id as phase_id
            ,work_item_name as phase_name
            ,work_item_id as release_id
            ,work_item_name as release_name
            ,work_item_id as item_id
            ,work_item_name as item_name
            ,year as year
            ,'No' as capitalized
            ,application_id as application_id
            ,billable_to_sub_division_id
          from "RESOURCE_CAPACITY"."PNMAC"."WORK_ITEMS"
          where year >= 2015
          
          UNION
            select distinct
               'OOO' as effort_id
              ,'Out of Office' as effort_name
              ,'OOO' as project_id
              ,'Out of Office' as project_name
              ,'OOO' as milestone_id
              ,'Out of Office' as milestone_name
              ,'OOO' as phase_id
             ,'Out of Office' as phase_name
             ,'OOO' as release_id
             ,'Out of Office' as release_name
             ,'OOO' as item_id
             ,'Out of Office' as item_name
             ,y.year as year
              ,'No' as capitalized
              ,'NOAPP' as application_id
              , null as billable_to_sub_division_id
              from (select distinct year from "RESOURCE_CAPACITY"."PNMAC"."WEEKS_INFO") y;



CREATE OR REPLACE VIEW "REDLINE"."STAGE"."VW_TIMESHEETENTRIES" AS 
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



CREATE OR REPLACE VIEW "RESOURCE_CAPACITY"."STAGE"."VW_REDLINEACTUALS_V2" AS
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
           
  FROM "REDLINE"."STAGE"."VW_TIMESHEETENTRIES" rl
  LEFT JOIN
       "DW_ORG"."STAGE"."VW_ONE_ROW_PER_EMPLOYEE" dwo ON trim(lower(rl.USER_LOGIN)) = trim(lower(dwo.networklogin)) and dwo.rowcurrentflag = 'Y'
  LEFT JOIN "RESOURCE_CAPACITY"."STAGE"."VW_EFFORTLISTING" el ON (CASE WHEN length(trim(rl.itid)) < 3 THEN rl.project_identifier else trim(rl.itid) END) = el.effort_id and rl.entry_year = el.year
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



CREATE OR REPLACE VIEW "RESOURCE_CAPACITY"."STAGE"."VW_ACTUALS_V2" AS 
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
  from "RESOURCE_CAPACITY"."STAGE"."VW_RCACTUALS_V2" rc
  LEFT JOIN "DW_ORG"."STAGE"."VW_ONE_ROW_PER_EMPLOYEE" e ON lower(trim(rc.employee_id)) = lower(trim(e.employeeid))

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
  from "RESOURCE_CAPACITY"."STAGE"."VW_REDLINEACTUALS_V2"
);



CREATE OR REPLACE VIEW "RESOURCE_CAPACITY"."STAGE"."VW_ASOFDATE" AS 
select
max(
dateadd(day,-2-date_part(weekday, dateadd(week, 1, date_from_parts(b.year,1,1))), dateadd(week, b.week, date_from_parts(b.year,1,1)))
   
  ) as as_of_date
from "RESOURCE_CAPACITY"."STAGE"."VW_REDLINEACTUALS_V2" b
where year between extract(year,CURRENT_DATE)-1 and extract(year,CURRENT_DATE)+1;



CREATE OR REPLACE VIEW "RESOURCE_CAPACITY"."STAGE"."VW_FORECAST_V2" AS 
SELECT
  f.effort_id as effort_id
  ,f.billable_to_sub_division_id as billed_sub_division_id
  ,s.department_id as billed_department_id
  ,s.division_id as billed_division_id
  ,null as application_id
  ,null as application_name

  ,CASE WHEN (select count(week) from PNMAC.weeks_info wi where wi.year = f.year and 'Q'||wi.quarter = f.quarter) = 0 then 0 
  ELSE forecast/(select count(week) from PNMAC.weeks_info wi where wi.year = f.year and 'Q'||wi.quarter = f.quarter) END forecast
  ,(CASE WHEN pm.capitalized ='Y' THEN 'Yes' ELSE 'No' END) as capitalized

  ,f.year
  ,f.quarter
  ,w.month as month
  ,w.week as week
  ,dateadd(day, 7*(w.week - 1) - 
     (CASE WHEN date_part('dow', date_from_parts(w.year, 1, 1)) = 0 THEN -1
      ELSE date_part('dow', date_from_parts(w.year, 1, 1))-1 END), date_from_parts(w.year, 1, 1) ) as entry_date

  ,'Forecast' as employee_id
  ,'Forecast' as network_login
  ,f.sub_division_id as working_team_sub_division_id

  ,'Forecast' as redline_project
  ,'0' as redline_issue
  ,'Forecast' as redline_issue_subject
  ,(CASE 
        WHEN f.effort_id = 'OOO' THEN 'OOO'
        
        WHEN f.effort_id in ('WK068','WK075','WK096','WK118','WK122','WK128','WK131','WK154',
                'WK165','WK174','WK175','WK176','WK177','WK178','WK179','WK180',
                'WK181','WK182','WK183','WK184','WK185','WK186','WK187','WK188',
                'WK190','WK181','WK194','WK197','WK198','WK201','WK202','WK209','WK228','WK237',
                'WK232','WK234','WK247','WK318','WK911','WK913') THEN 'ADMIN'
        WHEN left(f.effort_id,2) = 'WK' THEN 'MAINT'
        ELSE 'PROJ' END) as WORK_CATEGORY

  FROM "RESOURCE_CAPACITY"."PNMAC"."FTE_FORECAST" f
  LEFT JOIN "RESOURCE_CAPACITY"."PNMAC"."SUB_DIVISIONS" s ON f.billable_to_sub_division_id = s.sub_division_id
  LEFT JOIN "RESOURCE_CAPACITY"."PNMAC"."PROJECT_MILESTONES" pm ON f.effort_id = pm.project_milestone_id and f.year = pm.year
  ,"RESOURCE_CAPACITY"."PNMAC"."WEEKS_INFO" w
  WHERE
    f.year >= 2015
    and w.year = f.year
    and f.quarter = 'Q'||w.quarter;



CREATE OR REPLACE VIEW "RESOURCE_CAPACITY"."STAGE"."VW_FORECAST_AND_ACTUAL_COMBINED_V2" AS 
SELECT 
  EFFORT_ID
  ,BILLED_DIVISION_ID
  ,BILLED_DEPARTMENT_ID
  ,BILLED_SUB_DIVISION_ID
  ,APPLICATION_ID
  ,APPLICATION_NAME
  ,BILLABLE_HOURS
  ,CAPITALIZED
  ,WORK_CATEGORY
  ,YEAR
  ,QUARTER
  ,MONTH
  ,WEEK
  ,ENTRY_DATE
  ,EMPLOYEE_ID
  ,NETWORK_LOGIN
  ,WORKING_TEAM_SUB_DIVISION_ID
  ,REDLINE_PROJECT
  ,to_char(REDLINE_ISSUE) as REDLINE_ISSUE
  ,REDLINE_ISSUE_SUBJECT
  ,0 as FORECAST
  ,break_fix_lights_on_enhancement
  ,redline_primary_delivery_team
FROM "RESOURCE_CAPACITY"."STAGE"."VW_ACTUALS_V2"
UNION ALL
SELECT 
  EFFORT_ID
  
  ,BILLED_DIVISION_ID
  ,BILLED_DEPARTMENT_ID
  ,BILLED_SUB_DIVISION_ID

  ,APPLICATION_ID
  ,APPLICATION_NAME
  ,0 as BILLABLE_HOURS
  ,CAPITALIZED
  ,WORK_CATEGORY
  ,YEAR
  ,QUARTER
  ,MONTH
  ,WEEK
  ,ENTRY_DATE
  ,EMPLOYEE_ID
  ,NETWORK_LOGIN
  ,WORKING_TEAM_SUB_DIVISION_ID
  ,REDLINE_PROJECT
  ,TO_CHAR(REDLINE_ISSUE) AS REDLINE_ISSUE
  ,REDLINE_ISSUE_SUBJECT
  ,FORECAST
  ,'N/A' as break_fix_lights_on_enhancement
  ,'Forecast' as redline_primary_delivery_team
FROM "RESOURCE_CAPACITY"."STAGE"."VW_FORECAST_V2";



CREATE OR REPLACE VIEW "DW_ORG"."STAGE"."VW_EMPLOYEE_HIERARCHY" AS 
SELECT
    CASE WHEN ifnull(e8.preferredname,'NULL') = 'NULL' THEN '' ELSE e8.preferredname||' > ' END ||
        CASE WHEN ifnull(e7.preferredname,'NULL') = 'NULL' THEN '' ELSE e7.preferredname||' > ' END ||
        CASE WHEN ifnull(e6.preferredname,'NULL') = 'NULL' THEN '' ELSE e6.preferredname||' > ' END ||
        CASE WHEN ifnull(e5.preferredname,'NULL') = 'NULL' THEN '' ELSE e5.preferredname||' > ' END ||
        CASE WHEN ifnull(e4.preferredname,'NULL') = 'NULL' THEN '' ELSE e4.preferredname||' > ' END ||
        CASE WHEN ifnull(e3.preferredname,'NULL') = 'NULL' THEN '' ELSE e3.preferredname||' > ' END ||
        CASE WHEN ifnull(e2.preferredname,'NULL') = 'NULL' THEN '' ELSE e2.preferredname||' > ' END ||
        e1.preferredname as management_hierarchy
    ,e1.employeeid                  as employee_id
    ,e1.preferredname     as employee_name
    ,e2.preferredname     as employee_manager_1
    ,e3.preferredname     as employee_manager_2
    ,e4.preferredname     as employee_manager_3
    ,e5.preferredname     as employee_manager_4
    ,e6.preferredname     as employee_manager_5
    ,e7.preferredname     as employee_manager_6
    ,e8.preferredname     as employee_manager_7
FROM vw_employee_current e1 
LEFT JOIN vw_employee_current e2 ON e1.manageremployeeid = e2.employeeid
LEFT JOIN vw_employee_current e3 ON e2.manageremployeeid = e3.employeeid
LEFT JOIN vw_employee_current e4 ON e3.manageremployeeid = e4.employeeid
LEFT JOIN vw_employee_current e5 ON e4.manageremployeeid = e5.employeeid
LEFT JOIN vw_employee_current e6 ON e5.manageremployeeid = e6.employeeid
LEFT JOIN vw_employee_current e7 ON e6.manageremployeeid = e7.employeeid
LEFT JOIN vw_employee_current e8 ON e7.manageremployeeid = e8.employeeid;



CREATE OR REPLACE VIEW "RESOURCE_CAPACITY"."STAGE"."VW_FORECAST_AND_ACTUAL_COMBINED_INFO_V2A" AS
SELECT

   /* Effort/Timecode Info */
  faac.EFFORT_ID
  ,ifnull(faac.BILLED_DEPARTMENT_ID,s_effort_get_dept.department_id) as billed_department_id
  ,ifnull(faac.BILLED_DIVISION_ID,s_effort_get_dept.division_id) as billed_division_id
  ,ifnull(faac.BILLED_SUB_DIVISION_ID,rc_employee.sub_division_id) as billed_sub_division_id
  ,faac.WORK_CATEGORY
  
  /* Application Mapping */
  ,ifnull(effort_listing.application_id,faac.APPLICATION_ID) as application_id
  ,ifnull(applications.application_name,faac.APPLICATION_NAME) as application_name
  
  /* Entry Hours */
  ,faac.FORECAST
  ,faac.BILLABLE_HOURS
  ,ifnull(ifnull(faac.CAPITALIZED,effort_listing.capitalized),'No') as capitalized
  
  /* Entry Timing */
  ,faac.YEAR
  ,faac.QUARTER
  ,faac.MONTH
  ,faac.WEEK
  ,faac.ENTRY_DATE
  
  /* Date Maths */
  ,date_from_parts(faac.year,faac.month,1) as first_of_the_month
  ,dateadd(day, 7*(faac.WEEK - 1) - 
    (CASE WHEN date_part('dow', date_from_parts(faac.YEAR, 1, 1)) = 0 THEN -1
          ELSE date_part('dow', date_from_parts(faac.YEAR, 1, 1))-1 END), 
         date_from_parts(faac.YEAR, 1, 1) ) as week_start_date
  ,dateadd(day, 7*(faac.WEEK) - 
    (CASE WHEN date_part('dow', date_from_parts(faac.YEAR, 1, 1)) = 0 THEN -1
          ELSE date_part('dow', date_from_parts(faac.YEAR, 1, 1))-1 END),
          date_from_parts(faac.YEAR, 1, 1) ) as week_end_date  
          
  /* Employee Info */
  ,faac.EMPLOYEE_ID
  ,(CASE WHEN faac.EMPLOYEE_ID = 'Forecast' THEN 'Forecast' ELSE employee.preferredname END) as employee_preferred_name
  ,employee.email as employee_email
  ,faac.NETWORK_LOGIN
  ,ifnull(faac.WORKING_TEAM_SUB_DIVISION_ID,rc_employee.sub_division_id) as employee_working_team_id
  ,employee.departmentid as employee_department_id
  ,employee_dept.divisionid as employee_division_id
  ,employee_dept.name as employee_department_name
  ,employee.title as employee_title
  ,employee.orgtierdescription as employee_title_short
  ,employee.employmentstatus as employee_employment_status
  ,employee.employmenttype as employee_employment_type
  ,ifnull(employee.HIREDATE,employee.CREATEDDATETIME) as employee_start_date
  ,employee.terminationdate as employee_termination_date
  ,(CASE 
       WHEN IFNULL(employee.EMPLOYMENTSTATUS,'Null') <> 'Terminated' THEN TRUE
       WHEN YEAR(employee.TERMINATIONDATE)||MONTH(employee.TERMINATIONDATE) = YEAR(CURRENT_DATE)||MONTH(CURRENT_DATE) THEN TRUE 
       WHEN YEAR(employee.TERMINATIONDATE)||MONTH(employee.TERMINATIONDATE)-1 = YEAR(CURRENT_DATE)||MONTH(CURRENT_DATE) THEN TRUE
       ELSE FALSE END) as employee_recently_termed_or_currently_employed
  ,emp_hierarchy.management_hierarchy as management_hierarchy
  
  /*Manager Info */
  ,manager.employeeid as manager_employee_id
  ,manager.preferredname as manager_preferred_name
  ,manager.networklogin as manager_network_login
  ,manager.email as manager_email
  ,manager.departmentid as manager_department_id
  ,manager_dept.name as manager_department_name
  
  /* Redline Ticket and Issue Info */
  ,faac.REDLINE_PROJECT
  ,faac.REDLINE_ISSUE
  ,faac.REDLINE_ISSUE_SUBJECT
  ,faac.break_fix_lights_on_enhancement
  ,faac.redline_primary_delivery_team
  
  /* Effort Parts */
  ,split_part(faac.EFFORT_ID, '.', 1) as effort_project_number
  ,split_part(replace(faac.EFFORT_ID,'[A-z]'), '.', 2) as effort_milestone_number /* Strip out the A's and B's for capitalization */
  ,split_part(faac.EFFORT_ID, '.', 3) as effort_phase_number
  ,split_part(faac.EFFORT_ID, '.', 4) as effort_release_number
  
  /* Effort Cascade */
  ,ifnull(effort_listing.project_id,split_part(faac.EFFORT_ID, '.', 1)) as project_id
  ,ifnull(effort_listing.project_name,faac.redline_project) as project_name
  ,effort_listing.milestone_id as milestone_id
  ,ifnull(effort_listing.milestone_name,faac.redline_project) as milestone_name
  ,effort_listing.phase_id as phase_id
  ,ifnull(effort_listing.phase_name,faac.redline_project) as phase_name
  ,effort_listing.release_id as release_id
  ,ifnull(effort_listing.release_name,faac.redline_project) as release_name
  ,ifnull(effort_listing.effort_name,faac.redline_project) as effort_name
  
  /* Employee Classifiers */
  ,(CASE 
        WHEN left(faac.EMPLOYEE_ID,1) = '0' THEN 'PennyMac'
        WHEN left(faac.EMPLOYEE_ID,1) = 'C' THEN 'Contractor'
        WHEN left(faac.EMPLOYEE_ID,2) = 'OS' THEN 'Sonata'
        WHEN left(faac.EMPLOYEE_ID,2) = 'OI' THEN 'Infosys'
        ELSE 'Unknown - '||left(faac.EMPLOYEE_ID,2) END) as employee_service_provider
  ,(CASE 
        WHEN left(faac.EMPLOYEE_ID,1) = '0' THEN 'Employee'
        WHEN left(faac.EMPLOYEE_ID,1) = 'C' THEN 'Contractor'
        ELSE 'Outsourced' END) as employee_outsourced
 FROM  "RESOURCE_CAPACITY"."STAGE"."VW_FORECAST_AND_ACTUAL_COMBINED_V2" faac
 LEFT JOIN "DW_ORG"."STAGE"."VW_ONE_ROW_PER_EMPLOYEE" employee ON faac.employee_id = employee.employeeid and faac.employee_id <> 'Forecast'
 LEFT JOIN "DW_ORG"."STAGE"."VW_ONE_ROW_PER_EMPLOYEE" manager ON employee.manageremployeeid = manager.employeeid
 LEFT JOIN "RESOURCE_CAPACITY"."PNMAC"."EMPLOYEES" rc_employee ON faac.employee_id = rc_employee.employee_id
 LEFT JOIN "RESOURCE_CAPACITY"."PNMAC"."SUB_DIVISIONS" s_effort_get_dept ON ifnull(faac.BILLED_SUB_DIVISION_ID,rc_employee.sub_division_id) = s_effort_get_dept.sub_division_id /* if rc, get info here */
 LEFT JOIN "RESOURCE_CAPACITY"."PNMAC"."SUB_DIVISIONS" s_working_team ON faac.WORKING_TEAM_SUB_DIVISION_ID = s_working_team.sub_division_id
 LEFT JOIN "RESOURCE_CAPACITY"."STAGE"."VW_EFFORTLISTING" effort_listing ON lower(trim(faac.EFFORT_ID)) = lower(trim(effort_listing.effort_id)) and faac.YEAR = effort_listing.year
 LEFT JOIN "RESOURCE_CAPACITY"."PNMAC"."APPLICATIONS" applications ON effort_listing.application_id = applications.application_id
 LEFT JOIN "DW_ORG"."PNMAC"."DEPARTMENT" employee_dept ON employee.departmentid = employee_dept.departmentid
 LEFT JOIN "DW_ORG"."PNMAC"."DEPARTMENT" manager_dept  ON manager.departmentid = manager_dept.departmentid
 LEFT JOIN "DW_ORG"."STAGE"."VW_EMPLOYEE_HIERARCHY" emp_hierarchy ON faac.employee_id = emp_hierarchy.employee_id;



CREATE OR REPLACE VIEW "RESOURCE_CAPACITY"."STAGE"."VW_WEEKLYTOTALSBYEMP" AS 
        select 
        employee_id
        ,year
        ,week
        ,ceil(sum(billable_hours),1) as total_weekly_hours
        ,(CASE WHEN ceil(sum(billable_hours),1) >= 40 THEN 40 ELSE ceil(sum(billable_hours),1) END) as capped_weekly_hours
     FROM
    "RESOURCE_CAPACITY"."STAGE"."VW_ACTUALS_V2"
    group by 
    employee_id
        ,year
        ,week;



CREATE OR REPLACE VIEW "RESOURCE_CAPACITY"."STAGE"."VW_FORECAST_AND_ACTUAL_COMBINED_INFO_V2B" AS
select
  EFFORT_ID
  ,faac.BILLED_DEPARTMENT_ID
  ,billed_department.name as BILLED_DEPARTMENT_NAME
  ,ifnull(faac.billed_division_id,billed_division.divisionid) as BILLED_DIVISION_ID
  ,billed_division.name as BILLED_DIVISION_NAME
  ,ifnull(faac.BILLED_SUB_DIVISION_ID,'Please use divison and department') as BILLED_SUB_DIVISION_ID
  ,ifnull(billed_sub_division.sub_division_name,'Please use division and department') as BILLED_SUB_DIVISION_NAME
  ,faac.APPLICATION_ID
  ,faac.APPLICATION_NAME
  ,faac.FORECAST
  ,CAST(faac.BILLABLE_HOURS AS NUMERIC(36,4)) AS BILLABLE_HOURS
  ,CAST(weekly_totals.total_weekly_hours AS NUMERIC(36,4)) AS total_weekly_hours
  ,CAST(weekly_totals.capped_weekly_hours AS NUMERIC(36,4)) AS capped_weekly_hours
  ,CAST((CASE
        WHEN faac.EMPLOYEE_OUTSOURCED = 'Outsourced' THEN faac.BILLABLE_HOURS
        WHEN weekly_totals.capped_weekly_hours = 40 THEN faac.BILLABLE_HOURS / weekly_totals.total_weekly_hours * 40
        ELSE faac.BILLABLE_HOURS END ) AS NUMERIC(36,4)) as billable_hours_scaled
  ,faac.CAPITALIZED
  ,faac.YEAR
  ,faac.QUARTER
  ,faac.MONTH
  ,faac.WEEK
  ,faac.ENTRY_DATE
  ,faac.FIRST_OF_THE_MONTH
  ,faac.WEEK_START_DATE
  ,faac.WEEK_END_DATE
  ,date_from_parts(faac.year,month(faac.WEEK_START_DATE),1) as MONTH_OF_WEEK_START_DATE
  ,faac.EMPLOYEE_ID
  ,faac.EMPLOYEE_PREFERRED_NAME
  ,faac.EMPLOYEE_EMAIL
  ,faac.NETWORK_LOGIN
  ,ifnull(faac.EMPLOYEE_WORKING_TEAM_ID,'Please use department') as EMPLOYEE_WORKING_TEAM_ID
  ,ifnull(team_sub_division.sub_division_name,'Please use department') as EMPLOYEE_WORKING_TEAM
  ,faac.EMPLOYEE_DEPARTMENT_ID
  ,faac.EMPLOYEE_DEPARTMENT_NAME
  ,faac.EMPLOYEE_TITLE
  ,faac.EMPLOYEE_TITLE_SHORT
  ,faac.EMPLOYEE_EMPLOYMENT_STATUS
  ,faac.EMPLOYEE_START_DATE
  ,faac.EMPLOYEE_TERMINATION_DATE
  ,faac.EMPLOYEE_RECENTLY_TERMED_OR_CURRENTLY_EMPLOYED
  ,faac.EMPLOYEE_EMPLOYMENT_TYPE
  ,faac.MANAGEMENT_HIERARCHY
  ,faac.MANAGER_EMPLOYEE_ID
  ,faac.MANAGER_PREFERRED_NAME
  ,faac.MANAGER_NETWORK_LOGIN
  ,faac.MANAGER_EMAIL
  ,faac.MANAGER_DEPARTMENT_ID
  ,faac.MANAGER_DEPARTMENT_NAME
  ,faac.REDLINE_PROJECT
  ,faac.REDLINE_ISSUE
  ,faac.REDLINE_ISSUE_SUBJECT
  ,faac.EFFORT_PROJECT_NUMBER
  ,faac.EFFORT_MILESTONE_NUMBER
  ,faac.EFFORT_PHASE_NUMBER
  ,faac.EFFORT_RELEASE_NUMBER
  ,upper(faac.PROJECT_ID) as PROJECT_ID
  ,faac.PROJECT_NAME
  ,UPPER((CASE WHEN faac.MILESTONE_ID is not null then faac.MILESTONE_ID
         WHEN length(faac.EFFORT_MILESTONE_NUMBER) > 0 THEN faac.EFFORT_PROJECT_NUMBER||'.'||faac.EFFORT_MILESTONE_NUMBER
        ELSE faac.EFFORT_PROJECT_NUMBER END)) as milestone_id
  ,faac.MILESTONE_NAME
  ,UPPER((CASE WHEN faac.PHASE_ID is not null then faac.PHASE_ID
    ELSE 
        faac.PROJECT_ID ||  
        (CASE WHEN length(faac.EFFORT_MILESTONE_NUMBER) > 0 THEN '.'||faac.EFFORT_MILESTONE_NUMBER ELSE '' END  ) ||
        (CASE WHEN length(faac.EFFORT_PHASE_NUMBER) > 0 THEN '.'||faac.EFFORT_PHASE_NUMBER ELSE '' END )
     END)) as PHASE_ID
  ,faac.PHASE_NAME
  ,UPPER((CASE WHEN faac.RELEASE_ID is not null then faac.PHASE_ID
    ELSE 
        faac.PROJECT_ID ||  
        (CASE WHEN length(faac.EFFORT_MILESTONE_NUMBER) > 0 THEN '.'||faac.EFFORT_MILESTONE_NUMBER ELSE '' END  ) ||
        (CASE WHEN length(faac.EFFORT_PHASE_NUMBER) > 0 THEN '.'||faac.EFFORT_PHASE_NUMBER ELSE '' END ) || 
        (CASE WHEN length(faac.EFFORT_RELEASE_NUMBER) > 0 THEN '.'||faac.EFFORT_RELEASE_NUMBER ELSE '' END )
     END)) as RELEASE_ID
  ,faac.RELEASE_NAME
  ,faac.EFFORT_NAME
  ,faac.WORK_CATEGORY
  ,faac.EMPLOYEE_SERVICE_PROVIDER
  ,faac.EMPLOYEE_OUTSOURCED
  ,CAST((CASE 
       WHEN left(faac.EMPLOYEE_ID,1) in ('0','C') THEN 77.88
       ELSE 36.05 END )  AS NUMERIC(36,2)) as EMPLOYEE_HOURLY_RATE
  ,rl_sbc.value as REDLINE_SPONSORING_BUSINESS_CHANNEL
  ,faac.break_fix_lights_on_enhancement
  /*,rl_pdt.value as REDLINE_PRIMARY_DELIVERY_TEAM*/
  ,faac.redline_primary_delivery_team
  ,v.name as redline_version_name
  ,vp.name as redline_version_project_name
  ,vp.name||' - '||v.name as redline_version
from "RESOURCE_CAPACITY"."STAGE"."VW_FORECAST_AND_ACTUAL_COMBINED_INFO_V2A" faac
LEFT JOIN "RESOURCE_CAPACITY"."PNMAC"."SUB_DIVISIONS" billed_sub_division ON faac.BILLED_SUB_DIVISION_ID = billed_sub_division.sub_division_id
LEFT JOIN "RESOURCE_CAPACITY"."PNMAC"."SUB_DIVISIONS" team_sub_division ON faac.EMPLOYEE_WORKING_TEAM_ID = team_sub_division.sub_division_id
LEFT JOIN "DW_ORG"."PNMAC"."DEPARTMENT" billed_department ON faac.BILLED_DEPARTMENT_ID = billed_department.departmentid
LEFT JOIN "RESOURCE_CAPACITY"."STAGE"."VW_WEEKLYTOTALSBYEMP" weekly_totals 
    ON faac.employee_id = weekly_totals.employee_id and faac.year = weekly_totals.year and faac.week = weekly_totals.week and faac.employee_id <> 'Forecast'
LEFT JOIN "REDLINE"."PNMAC"."CUSTOM_VALUES" rl_sbc ON faac.REDLINE_ISSUE = rl_sbc.customized_id and rl_sbc.custom_field_id = '35' /* Sponsoring Business Channel */
LEFT JOIN "REDLINE"."PNMAC"."ISSUES" rl_issue ON faac.REDLINE_ISSUE = rl_issue.id
LEFT JOIN "REDLINE"."PNMAC"."VERSIONS" v ON rl_issue.fixed_version_id = v.id
LEFT JOIN "REDLINE"."PNMAC"."PROJECTS" vp ON v.project_id = vp.id
/* LEFT JOIN "REDLINE"."PNMAC"."CUSTOM_VALUES" rl_pdt ON rl_issue.project_id = rl_pdt.customized_id and rl_pdt.custom_field_id = '109' /* Primary Delivery Team */
LEFT JOIN "DW_ORG"."PNMAC"."DIVISION" billed_division ON (faac.billed_division_id = billed_division.divisionid OR (faac.billed_division_id is null and billed_sub_division.division_id = billed_division.divisionid) ) and billed_division.companyid <> 2009
;



CREATE OR REPLACE VIEW "RESOURCE_CAPACITY"."STAGE"."VW_FORECASTANDACTUALCOMBINEDINFO" AS SELECT
EFFORT_ID
,EFFORT_NAME
,PROJECT_ID
,PROJECT_NAME
,MILESTONE_ID
,MILESTONE_NAME
,PHASE_ID
,PHASE_NAME
,RELEASE_ID
,RELEASE_NAME
,EFFORT_ID as ITEM_ID
,EFFORT_NAME as ITEM_NAME
,EMPLOYEE_WORKING_TEAM_ID as WORKING_TEAM_SUB_DIVISION_ID
,EMPLOYEE_WORKING_TEAM as WORKING_TEAM_SUB_DIVISION_NAME
,BILLED_SUB_DIVISION_ID as BILLABLE_TO_SUB_DIVISION_ID
,BILLED_SUB_DIVISION_NAME as BILLABLE_TO_SUB_DIVISION_NAME
,null as EFFORT_TYPE
,YEAR
,QUARTER
,MONTH
,WEEK
,ENTRY_DATE as WEEK_DATE
,FIRST_OF_THE_MONTH
,EMPLOYEE_ID
,EMPLOYEE_PREFERRED_NAME
,(CASE WHEN EMPLOYEE_SERVICE_PROVIDER in ('PennyMac','Contractor') THEN 'Full Time' 
  WHEN EMPLOYEE_SERVICE_PROVIDER in ('Infosys','Sonata') THEN 'Offshore'
  ELSE 'Unknown' END ) as EMPLOYEE_TYPE
,EMPLOYEE_TITLE
,EMPLOYEE_TITLE_SHORT
,EMPLOYEE_EMPLOYMENT_TYPE
,EMPLOYEE_SERVICE_PROVIDER
,EMPLOYEE_WORKING_TEAM_ID as EMPLOYEE_SUB_DIVISION_ID
,(CASE WHEN EMPLOYEE_EMPLOYMENT_STATUS in ('Active','LOA') THEN 'Y' ELSE 'N' END) as EMPLOYEE_ACTIVE
,EMPLOYEE_EMPLOYMENT_STATUS
,EMPLOYEE_EMAIL
,EMPLOYEE_DEPARTMENT_ID
,NETWORK_LOGIN as EMPLOYEE_NETWORK_LOGIN
,null as EMPLOYEE_ONSITE_OFFSITE
,null EMPLOYEE_ONSHORE_OFFSHORE
,null EMPLOYEE_CHANNEL_ID
,MANAGER_PREFERRED_NAME as MANAGER_NAME
,MANAGER_DEPARTMENT_ID
,null as MANAGER_SUB_DIVISION_ID
,null as FORECAST_FTES
,BILLABLE_HOURS
,TOTAL_WEEKLY_HOURS as WEEKLY_TOTAL_BILLABLE_HOURS
,BILLABLE_HOURS_SCALED
,CAST(BILLABLE_HOURS_SCALED/40 AS NUMERIC(36,4)) as HEADCOUNT_SCALED
,(CASE
    WHEN left(trim(effort_id),2) = 'WK' THEN 'No'
    WHEN WORK_CATEGORY <> 'PROJ' THEN 'No' ELSE CAPITALIZED END
    ) as CAPITALIZED
,EMPLOYEE_WORKING_TEAM AS EMPLOYEE_SUB_DIVISION_NAME
,null as MANAGER_SUB_DIVISION_NAME
,EMPLOYEE_DEPARTMENT_NAME
,MANAGER_DEPARTMENT_NAME
,EMPLOYEE_HOURLY_RATE
,null as WORKING_TEAM_SUB_DIVISION_SHORT_NAME
,null as BILLED_SUB_DIVISION_SHORT_NAME
,null as EMPLOYEE_SUB_DIVISION_SHORT_NAME
,null as MANAGER_TEAM_SUB_DIVISION_SHORT_NAME
,APPLICATION_ID
,APPLICATION_NAME
,null as BILLED_CHANNEL_ID
,null as BILLED_CHANNEL_NAME
,null as EMPLOYEE_CHANNEL_NAME
,null as APPLICATION_SUB_DIVISION_NAME
,null as APPLICATION_SUB_DIVISION_SHORT_NAME
,null as APPLICATION_CHANNEL_NAME
,REDLINE_PROJECT
,TO_CHAR(REDLINE_ISSUE) AS REDLINE_ISSUE
,REDLINE_ISSUE_SUBJECT
,REDLINE_SPONSORING_BUSINESS_CHANNEL
,EMPLOYEE_TITLE_SHORT as EMPLOYEE_ORG_TIER_DESCRIPTION
,EMPLOYEE_TERMINATION_DATE
,EMPLOYEE_START_DATE
,EMPLOYEE_RECENTLY_TERMED_OR_CURRENTLY_EMPLOYED
,WEEK_START_DATE
,WEEK_END_DATE
,MONTH_OF_WEEK_START_DATE
,MANAGEMENT_HIERARCHY
,MANAGER_EMAIL
,WORK_CATEGORY
,BILLED_DEPARTMENT_ID
,BILLED_DEPARTMENT_NAME
,BREAK_FIX_LIGHTS_ON_ENHANCEMENT
,BILLED_DIVISION_ID
,BILLED_DIVISION_NAME
,REDLINE_PRIMARY_DELIVERY_TEAM
,REDLINE_VERSION_NAME
,redline_version_project_name
,redline_version
FROM "RESOURCE_CAPACITY"."STAGE"."VW_FORECAST_AND_ACTUAL_COMBINED_INFO_V2B";


DROP TABLE IF EXISTS RESOURCE_CAPACITY.STAGE.MVW_FORECASTANDACTUALCOMBINEDINFO;
CREATE TABLE RESOURCE_CAPACITY.STAGE.MVW_FORECASTANDACTUALCOMBINEDINFO AS SELECT * FROM RESOURCE_CAPACITY.STAGE.VW_FORECASTANDACTUALCOMBINEDINFO;


CREATE OR REPLACE VIEW "RESOURCE_CAPACITY"."STAGE"."VW_MISSINGTIMESHEETENTRIES" AS 
SELECT
    year_week_count_by_id.employee_network_login
    ,year_week_count_by_id.week
    ,year_week_count_by_id.week_start_date
    ,year_week_count_by_id.year
    ,year_week_count_by_id.hours
    ,year_week_count_by_id.time_reporting_status
    
    ,employee_detail.PREFERREDNAME as employee_preferred_name
    ,employee_detail.email as employee_email
    ,employee_detail.EMPLOYMENTSTATUS as employee_active
    ,employee_detail.EMPLOYMENTTYPE as employee_type
    ,employee_detail.DEPARTMENTID as employee_department_id
    ,employee_detail.title as employee_title
    ,employee_detail.hiredate as employee_hiredate
    ,employee_detail.terminationdate as employee_terminationdate
    ,employee_detail.employeeid
    ,(CASE WHEN left(employee_detail.employeeid,2) = 'OI' THEN 'Infosys'
        WHEN left(employee_detail.employeeid,2) = 'OS' THEN 'Sonata'
        ELSE 'PennyMac and Contractors' END
     ) as employee_service_provider
    ,(CASE WHEN ifnull(contains(lower(employee_detail.title),'fixed bid'),-1) > -1 THEN 'TRUE' else 'FALSE' END) as fixed_bid_found_in_title
    ,(CASE WHEN ifnull(contains(lower(employee_detail.EMPLOYMENTTYPE),'fixed bid'),-1) > -1 THEN 'TRUE' else 'FALSE' END) as fixed_bid_found_in_employee_type

    ,department.name as employee_department_name
    
    ,manager.email as manager_email
    
FROM
(select 
    vw.employee_network_login
    ,date.week
    ,date.year
    ,date.week_start_date
    ,ceil(ifnull(sum(hours.billable_hours),0),1) hours
    ,(CASE WHEN ceil(ifnull(sum(hours.billable_hours),0),1) >= 79 THEN 'Too Many Hours Entered'
            WHEN ceil(ifnull(sum(hours.billable_hours),0),1) >= 40 THEN'40+ Hours Entered' 
            ELSE '<40 Hours Entered' END) as time_reporting_status
from 
    (select distinct lower(trim(vwfaci.employee_network_login)) as employee_network_login from "RESOURCE_CAPACITY"."STAGE"."MVW_FORECASTANDACTUALCOMBINEDINFO" vwfaci 
     where vwfaci.employee_id <> 'Forecast'
        AND lower(trim(vwfaci.employee_employment_type)) <> 'fixed bid' and lower(trim(vwfaci.employee_title)) not like '%fixed bid%') as vw
LEFT JOIN
    (select distinct year, week, week_start_date  from "RESOURCE_CAPACITY"."STAGE"."MVW_FORECASTANDACTUALCOMBINEDINFO" where week_start_date <= current_timestamp) date
LEFT JOIN 
    "RESOURCE_CAPACITY"."STAGE"."MVW_FORECASTANDACTUALCOMBINEDINFO" hours 
        ON lower(trim(vw.employee_network_login)) = lower(trim(hours.employee_network_login)) and date.week = hours.week and date.year = hours.year
group by 
    vw.employee_network_login
    ,hours.employee_department_name
    ,date.week
    ,date.year
    ,date.week_start_date
    ) year_week_count_by_id  
    LEFT JOIN "DW_ORG"."STAGE"."VW_LASTESTEMPRECORDS" employee_detail ON lower(trim(year_week_count_by_id.employee_network_login)) = lower(trim(employee_detail.networklogin)) AND employee_detail.ROWCURRENTFLAG = 'Y' and employee_detail.employmentstatus = 'Active'
    LEFT JOIN "DW_ORG"."PNMAC"."DEPARTMENT" department ON employee_detail.DEPARTMENTID = department.departmentid
    LEFT JOIN "DW_ORG"."PNMAC"."EMPLOYEE" manager ON employee_detail.manageremployeeid = manager.employeeid AND manager.ROWCURRENTFLAG = 'Y'
    WHERE year_week_count_by_id.week_start_date between ifnull(employee_detail.hiredate,'1900-01-01') and ifnull(employee_detail.terminationdate,current_timestamp);


DROP TABLE IF EXISTS RESOURCE_CAPACITY.STAGE.MVW_MISSINGTIMESHEETENTRIES;
CREATE TABLE RESOURCE_CAPACITY.STAGE.MVW_MISSINGTIMESHEETENTRIES AS SELECT * FROM RESOURCE_CAPACITY.STAGE.VW_MISSINGTIMESHEETENTRIES;


CREATE OR REPLACE VIEW "DW_ORG"."STAGE"."VW_MONTHTABLE" AS 
SELECT 
 dateadd(month,row_number() over (ORDER BY seq4())-1,date_from_parts(year(current_timestamp)-2,'01','28')) as date
 FROM table(generator(rowCount => 48));



CREATE OR REPLACE VIEW "REDLINE"."STAGE"."VW_MONTHTABLE" AS 
SELECT 
    date_start
    ,dateadd('day',-1, add_months(date_start,1)) as date_end
 FROM
(SELECT /* Table of all months from 2014 to 2023 */
 dateadd(month,row_number() over (ORDER BY seq4())-1,add_months(date_from_parts(year(current_timestamp()), month(current_timestamp()), 1),-12)) as date_start
FROM table(generator(rowCount => 14))) generator;



CREATE OR REPLACE VIEW "DW_ORG"."STAGE"."VW_MONTHLY_EMPLOYEES" AS 
SELECT
    translate(org_emp.employeekey,'�','') as employeekey
    ,translate(org_emp.employeeid,'�','') as employeeid
    ,translate(org_emp.lastname,'�','') as lastname
    ,translate(org_emp.firstname,'�','') as firstname
    ,translate(org_emp.preferredname,'�','') as preferredname
    ,translate(org_emp.email,'�','') as email
    ,org_emp.rowstartdate
    ,org_emp.rowenddate
    ,translate(org_emp.title,'�','') as title
    ,translate(org_emp.employmentstatus,'�','')  as employmentstatus
    ,translate(org_emp.networklogin,'�','')  as networklogin
    ,translate(org_emp.orgtierdescription,'�','')  as orgtierdescription
    ,org_emp.officelocation as officelocation
    ,org_emp.employmenttype as employmenttype
    ,org_emp.departmentid as departmentid
    ,org_emp.MANAGEREMPLOYEEID as MANAGEREMPLOYEEID
    ,org_mgr.preferredname as manager
    ,dept.departmentid as dept_departmentid
    ,dept.name as dept_departmentname
    ,(CASE 
       WHEN LEFT(org_emp.employeeid,2) in ('OI','OS') THEN 'Y'
       ELSE 'N'
       END) as outsourced
    ,(CASE WHEN month_table.date BETWEEN org_emp.rowstartdate 
        AND ifnull(
                ifnull(org_emp.rowenddate,org_emp.terminationdate), 
                (CASE WHEN org_emp.employmentstatus = 'Terminated' 
                    THEN org_emp.UPDATEDDATETIME 
                    ELSE datefromparts(extract(year,CURRENT_DATE()),extract(month,CURRENT_DATE()),28) END)
                )
          THEN org_emp.employeeid else 'Inactive' END) as Active
    ,(CASE
       WHEN translate(org_emp.orgtierdescription,'�','') = 'Intern' THEN 'Intern'
       WHEN org_emp.employmenttype = 'Fixed Bid' THEN 'Fixed Bid'
       WHEN dept.departmentid = '0650' THEN 'SSE'
       WHEN dept.departmentid in ('0600','0601','0602','0603','0604','0605','0651') THEN 'CORE'
       ELSE 'Other' END) app_dev_budget_category
    ,month_table.date as month28th
    ,datefromparts(extract(year,month_table.date),extract(month,month_table.date),1) as monthstart
FROM
    PNMAC.employee org_emp
    LEFT JOIN "DW_ORG"."PNMAC"."VW_EMPLOYEE_CURRENT" org_mgr ON org_emp.manageremployeeid = org_mgr.employeeid
    LEFT JOIN "DW_ORG"."PNMAC"."DEPARTMENT" dept ON org_emp.departmentid = dept.departmentid
  ,(SELECT date FROM "DW_ORG"."STAGE"."VW_MONTHTABLE") month_table
WHERE 
    (CASE WHEN month_table.date BETWEEN org_emp.rowstartdate 
        AND ifnull(
                ifnull(org_emp.rowenddate,org_emp.terminationdate), 
                (CASE WHEN org_emp.employmentstatus = 'Terminated' 
                    THEN org_emp.UPDATEDDATETIME 
                    ELSE datefromparts(extract(year,CURRENT_DATE()),extract(month,CURRENT_DATE()),28) END)
                )
          THEN org_emp.employeeid else 'Inactive' END) <> 'Inactive';



CREATE OR REPLACE VIEW "DW_ORG"."STAGE"."VW_MONTHLY_EMPLOYEES_WITH_BUDGET" AS 
SELECT 
    me.*
    ,bd.headcountbudgeted
    from "DW_ORG"."STAGE"."VW_MONTHLY_EMPLOYEES" me
    LEFT JOIN "DW_ORG"."PNMAC"."DEPARTMENT_BUDGET" bd ON me.app_dev_budget_category = bd.category and me.outsourced = bd.outsourced and me.monthstart = bd.month;



create or replace view "DW_ORG"."STAGE"."VW_MOSTRECENTEMPLOYEERECORDBYLOGIN" as
select max(employeekey) as employeekeycode, networklogin from "DW_ORG"."PNMAC"."EMPLOYEE" 
where rowcurrentflag = 'Y'
and employeeid not in ('001025')
/* Some updates for records need to be removed! */
group by networklogin;


DROP TABLE IF EXISTS DW_ORG.STAGE.MVW_MONTHLY_EMPLOYEES_WITH_BUDGET;
CREATE TABLE DW_ORG.STAGE.MVW_MONTHLY_EMPLOYEES_WITH_BUDGET AS SELECT * FROM DW_ORG.STAGE.VW_MONTHLY_EMPLOYEES_WITH_BUDGET;


create or replace view "REDLINE"."STAGE"."VW_CLARIFICATIONCOUNT" as 
select 
    count(*) as clarification_count
    ,j.journalized_id
from journals j
    JOIN journal_details jd ON jd.journal_id = j.id 
        and jd.property = 'cf'
        and jd.prop_key = '45'
        and value in ('1','Yes')
    group by 
     j.journalized_id;



create or replace view "REDLINE"."STAGE"."VW_EMPLOYEE_LISTING" as

select 
    rlu.login as redline_login
    ,rlu.firstname as redline_first_name
    ,rlu.lastname as redline_last_name
    ,rlu.firstname || ' '|| rlu.lastname as redline_full_name
    ,vwec.*
    ,mgr.email as manager_email
    ,mgr.preferredname as manager_name
from 
    "DW_ORG"."PNMAC"."VW_EMPLOYEE_CURRENT" vwec
    LEFT JOIN "REDLINE"."PNMAC"."USERS" rlu ON lower(trim(vwec.networklogin)) = lower(trim(rlu.login))
    LEFT JOIN "DW_ORG"."PNMAC"."VW_EMPLOYEE_CURRENT" mgr ON vwec.manageremployeeid = mgr.employeeid;



CREATE OR REPLACE VIEW "REDLINE"."STAGE"."VW_RECENTJOURNALDETAILS" AS
select min(jd.id) as min_id from "REDLINE"."PNMAC"."JOURNAL_DETAILS" jd
JOIN "REDLINE"."PNMAC"."JOURNALS" j ON j.id = jd.journal_id
AND j.created_on >= add_months(current_timestamp,-18);



CREATE OR REPLACE VIEW "REDLINE"."STAGE"."VW_HOLDANDCLARIFICATIONCHANGE" AS
select 
    min(jd1.id) as second_entry
    ,jd0.id as first_entry
from "REDLINE"."PNMAC"."JOURNALS" j0
JOIN "REDLINE"."STAGE"."VW_RECENTJOURNALDETAILS" rjd
JOIN "REDLINE"."PNMAC"."JOURNAL_DETAILS" jd0 ON j0.id = jd0.journal_id and jd0.property = 'cf' and to_char(jd0.prop_key) in ('44','45') and rjd.min_id <= jd0.id and jd0.value in ('1','Yes')
JOIN "REDLINE"."PNMAC"."JOURNALS" j1 ON j0.journalized_id = j1.journalized_id and j0.id < j1.id
JOIN "REDLINE"."PNMAC"."JOURNAL_DETAILS" jd1 ON rjd.min_id <= jd1.id and jd1.property = 'cf' and j1.id = jd1.journal_id and to_char(jd1.prop_key) = to_char(jd0.prop_key) and to_char(jd1.old_value) in ('1','Yes')
group by 
    jd0.id;



CREATE OR REPLACE VIEW "REDLINE"."STAGE"."VW_HOLDCLARIFYLIFECYCLE" AS
SELECT
    j0.journalized_id as issue
    ,to_char(cf0.name) as status_name
    ,j0.created_on as status_begin
    ,j1.created_on as status_end
    ,DATEDIFF('day'
        ,j0.created_on
        ,j1.created_on
        ) + 0
      - DATEDIFF('week'
        ,j0.created_on
        ,j1.created_on
        ) * 2
      as days_in_status
    /*,timestampdiff('day',j0.created_on,j1.created_on) as days_in_status */
FROM "REDLINE"."STAGE"."VW_HOLDANDCLARIFICATIONCHANGE" hcc
JOIN "REDLINE"."PNMAC"."JOURNAL_DETAILS" jd0 ON hcc.first_entry = jd0.id
JOIN "REDLINE"."PNMAC"."CUSTOM_FIELDS" cf0 ON to_char(jd0.prop_key) = to_char(cf0.id)
JOIN "REDLINE"."PNMAC"."JOURNALS" j0 ON jd0.journal_id = j0.id
JOIN "REDLINE"."PNMAC"."JOURNAL_DETAILS" jd1 ON hcc.second_entry = jd1.id
JOIN "REDLINE"."PNMAC"."JOURNALS" j1 ON jd1.journal_id = j1.id;



create or replace view "REDLINE"."STAGE"."VW_HOLDCOUNT" as 
select 
    count(*) as hold_count
    ,j.journalized_id
from journals j
    JOIN journal_details jd ON jd.journal_id = j.id 
        and jd.property = 'cf'
        and jd.prop_key = '44'
        and value in ('1','Yes')
    group by 
     j.journalized_id;



create or replace view "REDLINE"."STAGE"."VW_ISSUESTATUSLATEST" as 
select 
    max(j.created_on) as last_on
    ,j.journalized_id
    ,jd.property
    ,jd.prop_key
    ,jd.value as new_value
from "REDLINE"."PNMAC"."JOURNALS" j
    LEFT JOIN "REDLINE"."PNMAC"."JOURNAL_DETAILS" jd ON jd.journal_id = j.id and jd.prop_key = 'status_id'
    group by 
     j.journalized_id
    ,jd.property
    ,jd.prop_key
    ,jd.value;



create or replace view "REDLINE"."STAGE"."VW_JOURNALANDDETAILS" as 
select 
    j.id
    ,j.journalized_id
    ,j.created_on
    ,jd.property
    ,jd.prop_key
    ,jd.old_value
    ,jd.value as new_value
from "REDLINE"."PNMAC"."JOURNALS" j
    LEFT JOIN "REDLINE"."PNMAC"."JOURNAL_DETAILS" jd ON jd.journal_id = j.id;



create or replace view "REDLINE"."STAGE"."VW_LASTSTATUSCHANGEJOURNALENTRY" as 
select 
    max(j.id) as lastest_journal_id
    ,j.journalized_id
from "REDLINE"."PNMAC"."JOURNALS" j
    JOIN "REDLINE"."PNMAC"."JOURNAL_DETAILS" jd 
    ON jd.journal_id = j.id
    where jd.prop_key = 'status_id'
group by
    j.journalized_id;



CREATE OR REPLACE VIEW "REDLINE"."STAGE"."VW_LASTUPDATE" AS 
select max(updated_on) last_issue_update_on from "REDLINE"."PNMAC"."ISSUES";



CREATE OR REPLACE VIEW "REDLINE"."STAGE"."VW_NEXTSTATUSCHANGE" AS
select 
    jd0.id as first_entry
    ,min(jd1.id) as second_entry
from "REDLINE"."PNMAC"."JOURNALS" j0
JOIN "REDLINE"."STAGE"."VW_RECENTJOURNALDETAILS" rjd
JOIN "REDLINE"."PNMAC"."JOURNAL_DETAILS" jd0 ON j0.id = jd0.journal_id and to_char(jd0.prop_key) = 'status_id' and rjd.min_id <= jd0.id
LEFT JOIN "REDLINE"."PNMAC"."JOURNALS" j1 ON j0.journalized_id = j1.journalized_id and j0.id < j1.id
LEFT JOIN "REDLINE"."PNMAC"."JOURNAL_DETAILS" jd1 ON rjd.min_id <= jd1.id and j1.id = jd1.journal_id and to_char(jd1.prop_key) = 'status_id' and to_char(jd1.old_value) = to_char(jd0.value)
group by 
    jd0.id;



CREATE OR REPLACE VIEW "REDLINE"."STAGE"."VW_PROJECTMETADATA" AS 
select 
    p.*
    ,itid.value as itid
    ,spid.value as spid
    ,efforts.effort_name as effort_name
    ,parent1.name as first_parent
    ,parent2.name as second_parent
    ,parent3.name as third_parent
    ,parent4.name as fourth_parent
    ,parent5.name as fifth_parent
from projects p
left join custom_values itid ON p.id = itid.customized_id and itid.custom_field_id = 106
left join custom_values spid ON p.id = spid.customized_id and spid.custom_field_id = 107
left join projects parent1 on p.parent_id = parent1.id
left join projects parent2 on parent1.parent_id = parent2.id
left join projects parent3 on parent2.parent_id = parent3.id
left join projects parent4 on parent3.parent_id = parent4.id
left join projects parent5 on parent4.parent_id = parent5.id
left join "RESOURCE_CAPACITY"."STAGE"."VW_EFFORTLISTING" efforts on itid.value = efforts.effort_id
where p.status = 1;



create or replace view "REDLINE"."STAGE"."VW_PROJECT_ROLE_ASSIGNMENTS" as
SELECT
  p.name                as project_name
  ,p.identifier         as project_identifier
  ,p.is_public          as project_is_public
  ,p.created_on         as project_created_on
  ,u.login              as user_login
  ,u.firstname          as user_firstname
  ,u.lastname           as user_lastname
  ,u.admin              as is_user_admin
  ,u.status             as user_status
  ,u.last_login_on      as user_last_login
  ,r.name               as role_name
  ,r.issues_visibility  as role_issues_visibility
  ,r.time_entries_visibility as role_timeentries_visibility
  ,count(j.id)          as comments_on_project
FROM
  "REDLINE"."PNMAC"."MEMBERS" m
  ,"REDLINE"."PNMAC"."PROJECTS" p
  ,"REDLINE"."PNMAC"."USERS" u
  ,"REDLINE"."PNMAC"."MEMBER_ROLES" mr
  ,"REDLINE"."PNMAC"."ROLES" r
  ,"REDLINE"."PNMAC"."JOURNALS" j
  ,"REDLINE"."PNMAC"."ISSUES" i
where
    m.user_id = u.id
    and p.id=m.project_id
    and m.id = mr.member_id
    and r.id = mr.role_id
    and j.user_id = u.id
    and i.id = j.journalized_id
    and i.project_id = p.id
group by 
  p.name                
  ,p.identifier         
  ,p.is_public          
  ,p.created_on         
  ,u.login              
  ,u.firstname          
  ,u.lastname           
  ,u.admin              
  ,u.status             
  ,u.last_login_on      
  ,r.name               
  ,r.issues_visibility  
  ,r.time_entries_visibility;



create or replace view "REDLINE"."STAGE"."VW_READONLYACCESSREVIEW" as
SELECT 
    projects.name
    ,projects.id
    ,projects.identifier
    ,(CASE WHEN ifnull(members.user_id,-1) = -1 THEN 'Please Add "Read-Only" group to this project.' ELSE 'Read-only added' END) as action_needed
    ,'https://redline2.pnmac.com/projects/' || projects.identifier ||'/settings/members' as redline_url
from 
"REDLINE"."PNMAC"."PROJECTS" projects 
LEFT JOIN "REDLINE"."PNMAC"."MEMBERS" members 
    on projects.id = members.project_id 
    and members.user_id = '726' /* Read Only Group */
WHERE projects.status = 1;



CREATE OR REPLACE VIEW "REDLINE"."STAGE"."VW_REDLINEARTIFACTS" AS
SELECT 
  ifnull(cvi1.value,cvp1.value)                                         as itid
  ,pr1.id                                                               as project_id
  ,pr1.name                                                             as project_name
  ,pr1.description                                                      as project_description
  ,pr1.IDENTIFIER                                                       as project_identifier
  ,pr1.impacted_application                                             as project_impacted_application
  ,cvp1.value                                                           as project_itid
  ,cvp2.value                                                           as project_primary_delivery_team
  ,cvp3.value                                                           as project_outsource_company
  ,i1.id                                                                as issue_id
  ,i1.subject                                                           as issue_subject
  ,i1.description                                                       as issue_description
  ,i1.start_date                                                        as issue_start_date
  ,i1.due_date                                                          as issue_due_date
  ,i1.done_ratio                                                        as issue_done_ratio
  ,i1.estimated_hours                                                   as issue_estimated_hours
  ,i1.created_on                                                        as issue_created_on
  ,i1.closed_on                                                         as issue_closed_on
  ,i1.priority_id                                                       as issue_priority_id
  ,e1.name                                                              as issue_priority_name
  ,cvi1.value                                                           as issue_itid
  ,cvi3.value                                                           as issue_technical_change_only
  ,i1.tracker_id                                                        as issue_tracker_id
  ,t1.name                                                              as issue_tracker_name
  ,cvi2.value                                                           as issue_type
  ,is1.id                                                               as issue_status_id
  ,is1.name                                                             as issue_status_name
  ,a1qa.filename                                                        as qa_artifact_filename
  ,a1qa.content_type                                                    as qa_artifact_contenttype
  ,a1qa.container_id                                                    as qa_artifact_id_number
  ,'https://redline2.pnmac.com/download_from_s3/'||a1qa.id    as qa_artifact_link
  ,uqa.firstname||' '||uqa.lastname                                     as qa_author_name
  ,a1qa.created_on                                                      as qa_created_on
  ,a1uat.filename                                                       as uat_artifact_filename
  ,a1uat.content_type                                                   as uat_artifact_contenttype
  ,a1uat.container_id                                                   as uat_artifact_id_number
  ,'https://redline2.pnmac.com/download_from_s3/'||a1uat.id   as uat_artifact_link
  ,uuat.firstname||' '||uuat.lastname                                   as uat_author_name
  ,a1uat.created_on                                                     as uat_created_on
FROM
    "REDLINE"."PNMAC"."ISSUES" i1
    LEFT JOIN "REDLINE"."PNMAC"."CUSTOM_VALUES" cvi1 ON i1.id = cvi1.customized_id and cvi1.CUSTOM_FIELD_ID = '70' /* 70  = Issue ITID */
    LEFT JOIN "REDLINE"."PNMAC"."CUSTOM_VALUES" cvi2 ON i1.id = cvi2.customized_id and cvi2.CUSTOM_FIELD_ID = '41' /* 41  = Maint Tracker Work Type */
    LEFT JOIN "REDLINE"."PNMAC"."CUSTOM_VALUES" cvi3 ON i1.id = cvi3.customized_id and cvi3.CUSTOM_FIELD_ID = '68' /* 68 = Technical Change Only? */
    LEFT JOIN "REDLINE"."PNMAC"."ISSUE_STATUSES" is1 ON i1.status_id = is1.id 
    LEFT JOIN "REDLINE"."PNMAC"."ENUMERATIONS" e1 ON i1.priority_id = e1.id
    LEFT JOIN "REDLINE"."PNMAC"."TRACKERS" t1 on i1.tracker_id = t1.id
    LEFT JOIN "REDLINE"."PNMAC"."PROJECTS" pr1 ON i1.project_id = pr1.id 
    LEFT JOIN "REDLINE"."PNMAC"."CUSTOM_VALUES" cvp1 ON pr1.id = cvp1.customized_id and cvp1.CUSTOM_FIELD_ID = '106' /* 106 = Project ITID */
    LEFT JOIN "REDLINE"."PNMAC"."CUSTOM_VALUES" cvp2 ON pr1.id = cvp2.customized_id and cvp2.CUSTOM_FIELD_ID = '109' /* 109 = Primary Delivery Team */
    LEFT JOIN "REDLINE"."PNMAC"."CUSTOM_VALUES" cvp3 ON pr1.id = cvp3.customized_id and cvp3.CUSTOM_FIELD_ID = '104' /* 104 = Outsource Company */
    LEFT JOIN "REDLINE"."PNMAC"."ATTACHMENTS" a1qa  ON i1.id = a1qa.container_id and LEFT(a1qa.filename ,13) = 'QA Artifact -' 
    LEFT JOIN "REDLINE"."PNMAC"."USERS" uqa on a1qa.author_id = uqa.id
    LEFT JOIN "REDLINE"."PNMAC"."ATTACHMENTS" a1uat ON i1.id = a1uat.container_id and LEFT(a1uat.filename ,14) = 'UAT Artifact -'
    LEFT JOIN "REDLINE"."PNMAC"."USERS" uuat on a1uat.author_id = uuat.id
WHERE
    year(i1.created_on) > 2017;



CREATE OR REPLACE VIEW "REDLINE"."STAGE"."VW_REDLINEARTIFACTSPARENTSONLY" AS 
SELECT 
  ifnull(cvi1.value,cvp1.value)                                         as itid
  ,pr1.id                                                               as project_id
  ,pr1.name                                                             as project_name
  ,pr1.description                                                      as project_description
  ,pr1.IDENTIFIER                                                       as project_identifier
  ,pr1.impacted_application                                             as project_impacted_application
  ,cvp1.value                                                           as project_itid
  ,cvp2.value                                                           as project_primary_delivery_team
  ,cvp3.value                                                           as project_outsource_company
  ,i1.id                                                                as issue_id
  ,i1.subject                                                           as issue_subject
  ,i1.description                                                       as issue_description
  ,i1.start_date                                                        as issue_start_date
  ,i1.due_date                                                          as issue_due_date
  ,i1.done_ratio                                                        as issue_done_ratio
  ,i1.estimated_hours                                                   as issue_estimated_hours
  ,i1.created_on                                                        as issue_created_on
  ,i1.closed_on                                                         as issue_closed_on
  ,i1.updated_on                                                        as issue_last_updated_on
  ,i1.priority_id                                                       as issue_priority_id
  ,e1.name                                                              as issue_priority_name
  ,cvi1.value                                                           as issue_itid
  ,cvi3.value                                                           as issue_technical_change_only
  ,i1.tracker_id                                                        as issue_tracker_id
  ,t1.name                                                              as issue_tracker_name
  ,cvi2.value                                                           as issue_type
  ,is1.id                                                               as issue_status_id
  ,is1.name                                                             as issue_status_name
  ,a1qa.filename                                                        as qa_artifact_filename
  ,a1qa.content_type                                                    as qa_artifact_contenttype
  ,a1qa.container_id                                                    as qa_artifact_id_number
  ,'https://redline2.pnmac.com/download_from_s3/'||a1qa.id              as qa_artifact_link
  ,uqa.firstname||' '||uqa.lastname                                     as qa_author_name
  ,a1qa.created_on                                                      as qa_created_on
  ,a1uat.filename                                                       as uat_artifact_filename
  ,a1uat.content_type                                                   as uat_artifact_contenttype
  ,a1uat.container_id                                                   as uat_artifact_id_number
  ,'https://redline2.pnmac.com/download_from_s3/'||a1uat.id             as uat_artifact_link
  ,uuat.firstname||' '||uuat.lastname                                   as uat_author_name
  ,a1uat.created_on                                                     as uat_created_on
FROM
    "REDLINE"."PNMAC"."ISSUES" i1
    LEFT JOIN "REDLINE"."PNMAC"."CUSTOM_VALUES" cvi1 ON i1.id = cvi1.customized_id and cvi1.CUSTOM_FIELD_ID = '70' /* 70  = Issue ITID */
    LEFT JOIN "REDLINE"."PNMAC"."CUSTOM_VALUES" cvi2 ON i1.id = cvi2.customized_id and cvi2.CUSTOM_FIELD_ID = '41' /* 41  = Maint Tracker Work Type */
    LEFT JOIN "REDLINE"."PNMAC"."CUSTOM_VALUES" cvi3 ON i1.id = cvi3.customized_id and cvi3.CUSTOM_FIELD_ID = '68' /* 68 = Technical Change Only? */
    LEFT JOIN "REDLINE"."PNMAC"."ISSUE_STATUSES" is1 ON i1.status_id = is1.id 
    LEFT JOIN "REDLINE"."PNMAC"."ENUMERATIONS" e1 ON i1.priority_id = e1.id
    LEFT JOIN "REDLINE"."PNMAC"."TRACKERS" t1 on i1.tracker_id = t1.id
    LEFT JOIN "REDLINE"."PNMAC"."PROJECTS" pr1 ON i1.project_id = pr1.id 
    LEFT JOIN "REDLINE"."PNMAC"."CUSTOM_VALUES" cvp1 ON pr1.id = cvp1.customized_id and cvp1.CUSTOM_FIELD_ID = '106' /* 106 = Project ITID */
    LEFT JOIN "REDLINE"."PNMAC"."CUSTOM_VALUES" cvp2 ON pr1.id = cvp2.customized_id and cvp2.CUSTOM_FIELD_ID = '109' /* 109 = Primary Delivery Team */
    LEFT JOIN "REDLINE"."PNMAC"."CUSTOM_VALUES" cvp3 ON pr1.id = cvp3.customized_id and cvp3.CUSTOM_FIELD_ID = '104' /* 104 = Outsource Company */
    LEFT JOIN "REDLINE"."PNMAC"."ATTACHMENTS" a1qa  ON i1.id = a1qa.container_id and LEFT(a1qa.filename ,13) = 'QA Artifact -' 
    LEFT JOIN "REDLINE"."PNMAC"."USERS" uqa on a1qa.author_id = uqa.id
    LEFT JOIN "REDLINE"."PNMAC"."ATTACHMENTS" a1uat ON i1.id = a1uat.container_id and LEFT(a1uat.filename ,14) = 'UAT Artifact -'
    LEFT JOIN "REDLINE"."PNMAC"."USERS" uuat on a1uat.author_id = uuat.id
WHERE
    i1.parent_id is null;



CREATE OR REPLACE VIEW "REDLINE"."STAGE"."VW_REDLINEISSUESANDPROJECTS" AS 
SELECT 
  ifnull(cvi1.value,cvp1.value) as itid
  ,pr1.id                        as project_id
  ,pr1.name                      as project_name
  ,pr1.description               as project_description
  ,pr1.IDENTIFIER                as project_identifier
  ,pr1.impacted_application      as project_impacted_application
  ,cvp1.value                    as project_itid
  ,cvp2.value                    as project_primary_delivery_team
  ,cvp3.value                    as project_outsource_company
  ,i1.id                        as l1_issue_id
  ,i1.subject                   as l1_issue_subject
  ,i1.description               as l1_issue_description
  ,i1.start_date                as l1_issue_start_date
  ,i1.due_date                  as l1_issue_due_date
  ,i1.done_ratio                as l1_issue_done_ratio
  ,i1.estimated_hours           as l1_issue_estimated_hours
  ,i1.created_on                as l1_issue_created_on
  ,i1.closed_on                 as l1_issue_closed_on
  ,i1.priority_id               as l1_issue_priority_id
  ,e1.name                      as l1_issue_priority_name
  ,cvi1.value                   as l1_issue_itid
  ,i1.tracker_id                as l1_issue_tracker_id
  ,t1.name                      as l1_issue_tracker_name
  ,cvi2.value                   as l1_issue_type
  ,is1.id                       as l1_issue_status_id
  ,is1.name                     as l1_issue_status_name
  ,cvi3.value                  as l1_issue_technica_change_only
FROM
    "REDLINE"."PNMAC"."ISSUES" i1
    LEFT JOIN "REDLINE"."PNMAC"."CUSTOM_VALUES" cvi1 ON i1.id = cvi1.customized_id and cvi1.CUSTOM_FIELD_ID = '70' /* 70  = Issue ITID */
    LEFT JOIN "REDLINE"."PNMAC"."CUSTOM_VALUES" cvi2 ON i1.id = cvi2.customized_id and cvi2.CUSTOM_FIELD_ID = '41' /* 41  = Maint Tracker Work Type */
    LEFT JOIN "REDLINE"."PNMAC"."CUSTOM_VALUES" cvi3 ON i1.id = cvi3.customized_id and cvi3.CUSTOM_FIELD_ID = '68' /* 68 = Technical Change Only? */
    LEFT JOIN "REDLINE"."PNMAC"."ISSUE_STATUSES" is1 ON i1.status_id = is1.id 
    LEFT JOIN "REDLINE"."PNMAC"."ENUMERATIONS" e1 ON i1.priority_id = e1.id
    LEFT JOIN "REDLINE"."PNMAC"."TRACKERS" t1 on i1.tracker_id = t1.id
    LEFT JOIN "REDLINE"."PNMAC"."PROJECTS" pr1 ON i1.project_id = pr1.id 
    LEFT JOIN "REDLINE"."PNMAC"."CUSTOM_VALUES" cvp1 ON pr1.id = cvp1.customized_id and cvp1.CUSTOM_FIELD_ID = '106' /* 106 = Project ITID */
    LEFT JOIN "REDLINE"."PNMAC"."CUSTOM_VALUES" cvp2 ON pr1.id = cvp2.customized_id and cvp2.CUSTOM_FIELD_ID = '109' /* 109 = Primary Delivery Team */
    LEFT JOIN "REDLINE"."PNMAC"."CUSTOM_VALUES" cvp3 ON pr1.id = cvp3.customized_id and cvp3.CUSTOM_FIELD_ID = '104' /* 104 = Outsource Company */
WHERE
    year(i1.created_on) >= 2017;



CREATE OR REPLACE VIEW "REDLINE"."STAGE"."VW_REDLINESDLC" AS
select 
  i.*
  ,a.issue_technical_change_only
  ,a.qa_artifact_filename
  ,a.qa_artifact_contenttype
  ,a.qa_artifact_id_number
  ,a.qa_artifact_link
  ,a.qa_author_name
  ,a.qa_created_on
  ,a.uat_artifact_filename
  ,a.uat_artifact_contenttype
  ,a.uat_artifact_id_number
  ,a.uat_artifact_link
  ,a.uat_author_name
  ,a.uat_created_on
 FROM
    "REDLINE"."STAGE"."VW_REDLINEISSUESANDPROJECTS" i
    LEFT JOIN "REDLINE"."STAGE"."VW_REDLINEARTIFACTS" a ON i.l1_issue_id = a.issue_id
 WHERE
    a.qa_created_on = (select max(s1.created_on) from attachments s1 where a.issue_id = s1.container_id and left(s1.filename,13) = 'QA Artifact -')
    and a.uat_created_on = (select max(s2.created_on) from attachments s2 where a.issue_id = s2.container_id and left(s2.filename,14) = 'UAT Artifact -');



CREATE OR REPLACE VIEW "REDLINE"."STAGE"."VW_REDLINESDLCALL" AS
select 
  i.*
  ,a.issue_technical_change_only
  ,a.qa_artifact_filename
  ,a.qa_artifact_contenttype
  ,a.qa_artifact_id_number
  ,a.qa_artifact_link
  ,a.qa_author_name
  ,a.qa_created_on
  ,a.uat_artifact_filename
  ,a.uat_artifact_contenttype
  ,a.uat_artifact_id_number
  ,a.uat_artifact_link
  ,a.uat_author_name
  ,a.uat_created_on
 FROM
    "REDLINE"."STAGE"."VW_REDLINEISSUESANDPROJECTS" i
    LEFT JOIN "REDLINE"."STAGE"."VW_REDLINEARTIFACTS" a ON i.l1_issue_id = a.issue_id;



CREATE OR REPLACE VIEW "REDLINE"."STAGE"."VW_STATUSLIFECYCLE" AS
SELECT
    to_char(jd0.prop_key) as prop_key
    ,j0.journalized_id as issue
    ,to_char(is0.name) as status_name
    ,j0.created_on as status_begin
    ,ifnull(j1.created_on,current_timestamp) as status_end
    /* ,timestampdiff('day',j0.created_on,j1.created_on) as days_in_status */
    ,DATEDIFF('day',j0.created_on,ifnull(j1.created_on,current_timestamp)) 
      - DATEDIFF('week',j0.created_on,ifnull(j1.created_on,current_timestamp)) * 2
      as days_in_status
FROM "REDLINE"."STAGE"."VW_NEXTSTATUSCHANGE" nsc
JOIN "REDLINE"."PNMAC"."JOURNAL_DETAILS" jd0 ON nsc.first_entry = jd0.id
JOIN "REDLINE"."PNMAC"."JOURNALS" j0 ON jd0.journal_id = j0.id
JOIN "REDLINE"."PNMAC"."ISSUE_STATUSES" is0 ON to_char(jd0.value) = to_char(is0.id)
LEFT JOIN "REDLINE"."PNMAC"."JOURNAL_DETAILS" jd1 ON nsc.second_entry = jd1.id
LEFT JOIN "REDLINE"."PNMAC"."JOURNALS" j1 ON jd1.journal_id = j1.id;



CREATE OR REPLACE VIEW "REDLINE"."STAGE"."VW_STATUSLIFECYCLESUMMARY" AS
SELECT 
    issue
    ,status_name
    ,sum(days_in_status) as days_in_status
    ,min(status_begin) as first_day_in_status
from "REDLINE"."STAGE"."VW_STATUSLIFECYCLE"
    group by issue
    ,status_name
UNION
SELECT 
    issue
    ,status_name
    ,sum(days_in_status) as days_in_status
    ,min(status_begin) as first_day_in_status
from "REDLINE"."STAGE"."VW_HOLDCLARIFYLIFECYCLE"
    group by issue
    ,status_name;


DROP TABLE IF EXISTS REDLINE.STAGE.MVW_STATUSLIFECYCLESUMMARY;
CREATE TABLE REDLINE.STAGE.MVW_STATUSLIFECYCLESUMMARY AS SELECT * FROM REDLINE.STAGE.VW_STATUSLIFECYCLESUMMARY;


create or replace view "REDLINE"."STAGE"."VW_REDLINEWORKSTUDY" as
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
 LEFT JOIN "REDLINE"."STAGE"."MVW_STATUSLIFECYCLESUMMARY" lcss_in_analysis ON i.id = lcss_in_analysis.issue and lcss_in_analysis.status_name = 'In Analysis'
 LEFT JOIN "REDLINE"."STAGE"."MVW_STATUSLIFECYCLESUMMARY" lcss_rdy_for_dev ON i.id = lcss_rdy_for_dev.issue and lcss_rdy_for_dev.status_name = 'Ready for Development'
 LEFT JOIN "REDLINE"."STAGE"."MVW_STATUSLIFECYCLESUMMARY" lcss_in_dev ON i.id = lcss_in_dev.issue and lcss_in_dev.status_name = 'In Development'
 LEFT JOIN "REDLINE"."STAGE"."MVW_STATUSLIFECYCLESUMMARY" lcss_rdy_for_qa ON i.id = lcss_rdy_for_qa.issue and lcss_rdy_for_qa.status_name = 'Ready for QA'
 LEFT JOIN "REDLINE"."STAGE"."MVW_STATUSLIFECYCLESUMMARY" lcss_in_qa ON i.id = lcss_in_qa.issue and lcss_in_qa.status_name = 'In QA'
 LEFT JOIN "REDLINE"."STAGE"."MVW_STATUSLIFECYCLESUMMARY" lcss_rdy_for_uat ON i.id = lcss_rdy_for_uat.issue and lcss_rdy_for_uat.status_name = 'Ready for UAT'
 LEFT JOIN "REDLINE"."STAGE"."MVW_STATUSLIFECYCLESUMMARY" lcss_wait_for_uat ON i.id = lcss_wait_for_uat.issue and lcss_wait_for_uat.status_name = 'Waiting for UAT Approval'
 LEFT JOIN "REDLINE"."STAGE"."MVW_STATUSLIFECYCLESUMMARY" lcss_uat_approved ON i.id = lcss_uat_approved.issue and lcss_uat_approved.status_name = 'UAT Approved'
 LEFT JOIN "REDLINE"."STAGE"."MVW_STATUSLIFECYCLESUMMARY" lcss_rdy_for_release ON i.id = lcss_rdy_for_release.issue and lcss_rdy_for_release.status_name = 'Ready for Release'
 LEFT JOIN "REDLINE"."STAGE"."MVW_STATUSLIFECYCLESUMMARY" lcss_wait_for_clar ON i.id = lcss_wait_for_clar.issue and lcss_wait_for_clar.status_name = 'Waiting for Clarification'
 LEFT JOIN "REDLINE"."STAGE"."MVW_STATUSLIFECYCLESUMMARY" lcss_on_hold ON i.id = lcss_on_hold.issue and lcss_on_hold.status_name = 'Hold'
 LEFT JOIN "REDLINE"."STAGE"."MVW_STATUSLIFECYCLESUMMARY" lcss_prod_verification ON i.id = lcss_prod_verification.issue and lcss_prod_verification.status_name = 'Production Verification' 
 LEFT JOIN "REDLINE"."STAGE"."MVW_STATUSLIFECYCLESUMMARY" lcss_in_progress ON i.id = lcss_in_progress.issue and lcss_in_progress.status_name = 'In Progress' /* For ticket statuses */
 LEFT JOIN "REDLINE"."STAGE"."MVW_STATUSLIFECYCLESUMMARY" lcss_guesstimate ON i.id = lcss_guesstimate.issue and lcss_guesstimate.status_name = 'Guesstimate' /* For ticket statuses */
 /* How long since status has changed? */
 LEFT JOIN "REDLINE"."STAGE"."VW_LASTSTATUSCHANGEJOURNALENTRY" lscje ON i.id = lscje.journalized_id
 LEFT JOIN "REDLINE"."PNMAC"."JOURNALS" last_status ON lscje.lastest_journal_id = last_status.id
;



create or replace view "REDLINE"."STAGE"."VW_REDLINEWORKSTUDYMONTHLY" as 
select 
    months.date_start as month_start
    ,months.date_end as month_end
    ,i.*
    ,(CASE WHEN i.created_on between months.date_start and months.date_end  /* Created sometime during this month */
                THEN 1 else 0 END) as created_count
    ,(CASE WHEN i.created_on < months.date_end and ifnull(i.closed_on,'2099-01-01') > months.date_start /* Existed as an open ticket sometime during this month */
                and i.issue_status <> 'Cancelled'                                                       /* Not Cancelled */
                and ifnull(i.closed_on,'2099-01-01') between months.date_start and months.date_end      /* Closed this month */
                THEN 1 else 0 END) as closed_count
    ,(CASE WHEN i.created_on < months.date_end and ifnull(i.closed_on,'2099-01-01') > months.date_start /* Existed as an open ticket sometime during this month */
                and i.issue_status = 'Cancelled'                                                        /* Cancelled */
                and ifnull(i.closed_on,'2099-01-01') between months.date_start and months.date_end      /* Closed this month */
                THEN 1 else 0 END) as cancelled_count
    ,(CASE WHEN i.created_on < months.date_end and ifnull(i.closed_on,'2099-01-01') > months.date_start /* Existed as an open ticket sometime during this month */
                and i.issue_status not in ('New','Guestimmate')                                         /* Not in New or Guestimate */
                and ifnull(i.closed_on,'2099-01-01') not between months.date_start and months.date_end  /* NOT closed this month */              
                THEN 1 else 0 END) as in_progress_count
    ,(CASE WHEN (i.issue_status in ('New','Guesstimate') 
                 or 
                i.created_on < months.date_end and ifnull(i.closed_on,'2099-01-01') > months.date_start /* Existed as an open ticket sometime during this month */
                and ifnull(i.first_day_in_progress,ifnull(i.first_day_in_analysis,ifnull(i.first_under_development_date,'2099-01-01'))) > months.date_end               /* Didn't hit development during this month */ 
                ) 
                THEN 1 else 0 END) as backlog_count
from "REDLINE"."STAGE"."VW_MONTHTABLE" months
JOIN "REDLINE"."STAGE"."VW_REDLINEWORKSTUDY" i
/* where i.tracker_name in ('Story','Request') */
;



create or replace view "REDLINE"."STAGE"."VW_REDLINEWORKSTUDYWITHHOURS" as
select 
    rlws.*
    ,to_numeric(rl.entry_hours,38,6) as hours
    ,dwo.email as email 
    ,dwo.preferredname as preferredname
    ,date_from_parts(rl.entry_year,rl.entry_month,1) as entry_month
    ,rl.entry_date as entry_date
FROM "REDLINE"."STAGE"."VW_REDLINEWORKSTUDY" rlws
LEFT JOIN "REDLINE"."STAGE"."VW_TIMESHEETENTRIES" rl ON rlws.id = rl.issue_id
LEFT JOIN  "DW_ORG"."STAGE"."VW_ONE_ROW_PER_EMPLOYEE" dwo ON trim(lower(rl.USER_LOGIN)) = trim(lower(dwo.networklogin)) and dwo.rowcurrentflag = 'Y'
;



CREATE OR REPLACE VIEW "REDLINE"."STAGE"."VW_USERPROJECTACCESSREVIEW" AS 
select 
    usr.firstname
    ,usr.lastname
    ,usr.firstname||' '||usr.lastname as employee
    /* ,usr.mail */
    ,usr.last_login_on
    ,prj.name as project_name
    ,prj.description as project_description
    ,(CASE WHEN prj.status = 1 then 'Active'
        WHEN prj.status = 5 then 'Closed'
        WHEN prj.status = 9 Then 'Archived'
        ELSE to_varchar(prj.status) end
     ) as project_status
    ,rol.name as role_name
    ,cvp4.value as project_impacted_application
    /*,rol.permissions as role_permissions*/
from "REDLINE"."PNMAC"."USERS" usr
LEFT JOIN "REDLINE"."PNMAC"."MEMBERS" mem ON usr.id = mem.user_id
LEFT JOIN "REDLINE"."PNMAC"."MEMBER_ROLES" memrol ON mem.id = memrol.member_id
LEFT JOIN "REDLINE"."PNMAC"."ROLES" rol ON memrol.role_id = rol.id
LEFT JOIN "REDLINE"."PNMAC"."PROJECTS" prj ON mem.project_id = prj.id
LEFT JOIN "REDLINE"."PNMAC"."CUSTOM_VALUES" cvp4 ON prj.id = cvp4.customized_id and cvp4.CUSTOM_FIELD_ID = '242' /* 242 = Impacted Application */
WHERE year(usr.last_login_on) >= 2018 and year(prj.updated_on)
and role_name not in ('Read Only','Read-Only and Log Time');


DROP TABLE IF EXISTS REDLINE.STAGE.MVW_REDLINEWORKSTUDY;
CREATE TABLE REDLINE.STAGE.MVW_REDLINEWORKSTUDY AS SELECT * FROM REDLINE.STAGE.VW_REDLINEWORKSTUDY;

DROP TABLE IF EXISTS REDLINE.STAGE.MVW_REDLINEWORKSTUDYMONTHLY;
CREATE TABLE REDLINE.STAGE.MVW_REDLINEWORKSTUDYMONTHLY AS SELECT * FROM REDLINE.STAGE.VW_REDLINEWORKSTUDYMONTHLY;

DROP TABLE IF EXISTS REDLINE.STAGE.MVW_REDLINEWORKSTUDYWITHHOURS;
CREATE TABLE REDLINE.STAGE.MVW_REDLINEWORKSTUDYWITHHOURS AS SELECT * FROM REDLINE.STAGE.VW_REDLINEWORKSTUDYWITHHOURS;

