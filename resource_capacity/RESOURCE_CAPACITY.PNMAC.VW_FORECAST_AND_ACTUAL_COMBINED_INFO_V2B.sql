
CREATE OR REPLACE VIEW "RESOURCE_CAPACITY"."PNMAC"."VW_FORECAST_AND_ACTUAL_COMBINED_INFO_V2B" AS
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
from "RESOURCE_CAPACITY"."PNMAC"."VW_FORECAST_AND_ACTUAL_COMBINED_INFO_V2A" faac
LEFT JOIN "RESOURCE_CAPACITY"."PNMAC"."SUB_DIVISIONS" billed_sub_division ON faac.BILLED_SUB_DIVISION_ID = billed_sub_division.sub_division_id
LEFT JOIN "RESOURCE_CAPACITY"."PNMAC"."SUB_DIVISIONS" team_sub_division ON faac.EMPLOYEE_WORKING_TEAM_ID = team_sub_division.sub_division_id
LEFT JOIN "DW_ORG"."PNMAC"."DEPARTMENT" billed_department ON faac.BILLED_DEPARTMENT_ID = billed_department.departmentid
LEFT JOIN "RESOURCE_CAPACITY"."PNMAC"."VW_WEEKLYTOTALSBYEMP" weekly_totals 
    ON faac.employee_id = weekly_totals.employee_id and faac.year = weekly_totals.year and faac.week = weekly_totals.week and faac.employee_id <> 'Forecast'
LEFT JOIN "REDLINE"."PNMAC"."CUSTOM_VALUES" rl_sbc ON faac.REDLINE_ISSUE = rl_sbc.customized_id and rl_sbc.custom_field_id = '35' /* Sponsoring Business Channel */
LEFT JOIN "REDLINE"."PNMAC"."ISSUES" rl_issue ON faac.REDLINE_ISSUE = rl_issue.id
LEFT JOIN "REDLINE"."PNMAC"."VERSIONS" v ON rl_issue.fixed_version_id = v.id
LEFT JOIN "REDLINE"."PNMAC"."PROJECTS" vp ON v.project_id = vp.id
/* LEFT JOIN "REDLINE"."PNMAC"."CUSTOM_VALUES" rl_pdt ON rl_issue.project_id = rl_pdt.customized_id and rl_pdt.custom_field_id = '109' /* Primary Delivery Team */
LEFT JOIN "DW_ORG"."PNMAC"."DIVISION" billed_division ON (faac.billed_division_id = billed_division.divisionid OR (faac.billed_division_id is null and billed_sub_division.division_id = billed_division.divisionid) ) and billed_division.companyid <> 2009
;
