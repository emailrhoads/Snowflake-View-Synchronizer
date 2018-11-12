
CREATE OR REPLACE VIEW "REDLINE"."PNMAC"."VW_USERPROJECTACCESSREVIEW" AS 
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
