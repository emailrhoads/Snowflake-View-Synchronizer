
create or replace view "DW_ORG"."PNMAC"."VW_LASTESTRECORD" as
select max((CASE WHEN employmentstatus = 'Active' THEN '1' ELSE 0 END)||UPDATEDDATETIME||employeekey) as employeekeycode, lower(trim(networklogin)) as networklogin from "DW_ORG"."PNMAC"."EMPLOYEE" 
/* use udpatetime to do a sort  and bias towards active records */
where rowcurrentflag = 'Y'
and employeeid not in ('001025')
/* Some updates for records need to be removed! */
group by lower(trim(networklogin));
