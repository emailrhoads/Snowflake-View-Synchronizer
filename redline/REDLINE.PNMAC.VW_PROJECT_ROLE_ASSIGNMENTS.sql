
create or replace view "REDLINE"."PNMAC"."VW_PROJECT_ROLE_ASSIGNMENTS" as
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
