
CREATE OR REPLACE VIEW "DW_ORG"."PNMAC"."VW_EMPLOYEE_HIERARCHY" AS 
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
