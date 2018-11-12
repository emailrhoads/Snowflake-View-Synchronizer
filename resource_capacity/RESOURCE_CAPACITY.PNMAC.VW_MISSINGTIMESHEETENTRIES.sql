
CREATE OR REPLACE VIEW "RESOURCE_CAPACITY"."PNMAC"."VW_MISSINGTIMESHEETENTRIES" AS 
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
    (select distinct lower(trim(vwfaci.employee_network_login)) as employee_network_login from "RESOURCE_CAPACITY"."PNMAC"."MVW_FORECASTANDACTUALCOMBINEDINFO" vwfaci 
     where vwfaci.employee_id <> 'Forecast'
        AND lower(trim(vwfaci.employee_employment_type)) <> 'fixed bid' and lower(trim(vwfaci.employee_title)) not like '%fixed bid%') as vw
LEFT JOIN
    (select distinct year, week, week_start_date  from "RESOURCE_CAPACITY"."PNMAC"."MVW_FORECASTANDACTUALCOMBINEDINFO" where week_start_date <= current_timestamp) date
LEFT JOIN 
    "RESOURCE_CAPACITY"."PNMAC"."MVW_FORECASTANDACTUALCOMBINEDINFO" hours 
        ON lower(trim(vw.employee_network_login)) = lower(trim(hours.employee_network_login)) and date.week = hours.week and date.year = hours.year
group by 
    vw.employee_network_login
    ,hours.employee_department_name
    ,date.week
    ,date.year
    ,date.week_start_date
    ) year_week_count_by_id  
    LEFT JOIN "DW_ORG"."PNMAC"."VW_LASTESTEMPRECORDS" employee_detail ON lower(trim(year_week_count_by_id.employee_network_login)) = lower(trim(employee_detail.networklogin)) AND employee_detail.ROWCURRENTFLAG = 'Y' and employee_detail.employmentstatus = 'Active'
    LEFT JOIN "DW_ORG"."PNMAC"."DEPARTMENT" department ON employee_detail.DEPARTMENTID = department.departmentid
    LEFT JOIN "DW_ORG"."PNMAC"."EMPLOYEE" manager ON employee_detail.manageremployeeid = manager.employeeid AND manager.ROWCURRENTFLAG = 'Y'
    WHERE year_week_count_by_id.week_start_date between ifnull(employee_detail.hiredate,'1900-01-01') and ifnull(employee_detail.terminationdate,current_timestamp);
