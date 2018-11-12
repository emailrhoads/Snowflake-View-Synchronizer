
create or replace view "REDLINE"."PNMAC"."VW_EMPLOYEE_LISTING" as

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
