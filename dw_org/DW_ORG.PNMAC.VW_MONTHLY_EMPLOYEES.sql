
CREATE OR REPLACE VIEW "DW_ORG"."PNMAC"."VW_MONTHLY_EMPLOYEES" AS 
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
  ,(SELECT date FROM "DW_ORG"."PNMAC"."VW_MONTHTABLE") month_table
WHERE 
    (CASE WHEN month_table.date BETWEEN org_emp.rowstartdate 
        AND ifnull(
                ifnull(org_emp.rowenddate,org_emp.terminationdate), 
                (CASE WHEN org_emp.employmentstatus = 'Terminated' 
                    THEN org_emp.UPDATEDDATETIME 
                    ELSE datefromparts(extract(year,CURRENT_DATE()),extract(month,CURRENT_DATE()),28) END)
                )
          THEN org_emp.employeeid else 'Inactive' END) <> 'Inactive';
