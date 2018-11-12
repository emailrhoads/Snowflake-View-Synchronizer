
create or replace view "REDLINE"."PNMAC"."VW_READONLYACCESSREVIEW" as
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
