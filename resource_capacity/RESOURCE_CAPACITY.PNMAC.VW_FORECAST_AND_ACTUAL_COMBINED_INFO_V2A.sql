
CREATE OR REPLACE VIEW "RESOURCE_CAPACITY"."PNMAC"."VW_FORECAST_AND_ACTUAL_COMBINED_INFO_V2A" AS
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
 FROM  "RESOURCE_CAPACITY"."PNMAC"."VW_FORECAST_AND_ACTUAL_COMBINED_V2" faac
 LEFT JOIN "DW_ORG"."PNMAC"."VW_ONE_ROW_PER_EMPLOYEE" employee ON faac.employee_id = employee.employeeid and faac.employee_id <> 'Forecast'
 LEFT JOIN "DW_ORG"."PNMAC"."VW_ONE_ROW_PER_EMPLOYEE" manager ON employee.manageremployeeid = manager.employeeid
 LEFT JOIN "RESOURCE_CAPACITY"."PNMAC"."EMPLOYEES" rc_employee ON faac.employee_id = rc_employee.employee_id
 LEFT JOIN "RESOURCE_CAPACITY"."PNMAC"."SUB_DIVISIONS" s_effort_get_dept ON ifnull(faac.BILLED_SUB_DIVISION_ID,rc_employee.sub_division_id) = s_effort_get_dept.sub_division_id /* if rc, get info here */
 LEFT JOIN "RESOURCE_CAPACITY"."PNMAC"."SUB_DIVISIONS" s_working_team ON faac.WORKING_TEAM_SUB_DIVISION_ID = s_working_team.sub_division_id
 LEFT JOIN "RESOURCE_CAPACITY"."PNMAC"."VW_EFFORTLISTING" effort_listing ON lower(trim(faac.EFFORT_ID)) = lower(trim(effort_listing.effort_id)) and faac.YEAR = effort_listing.year
 LEFT JOIN "RESOURCE_CAPACITY"."PNMAC"."APPLICATIONS" applications ON effort_listing.application_id = applications.application_id
 LEFT JOIN "DW_ORG"."PNMAC"."DEPARTMENT" employee_dept ON employee.departmentid = employee_dept.departmentid
 LEFT JOIN "DW_ORG"."PNMAC"."DEPARTMENT" manager_dept  ON manager.departmentid = manager_dept.departmentid
 LEFT JOIN "DW_ORG"."PNMAC"."VW_EMPLOYEE_HIERARCHY" emp_hierarchy ON faac.employee_id = emp_hierarchy.employee_id;
