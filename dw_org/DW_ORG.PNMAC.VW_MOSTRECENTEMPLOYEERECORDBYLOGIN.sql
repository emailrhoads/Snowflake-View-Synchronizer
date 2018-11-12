
create or replace view "DW_ORG"."PNMAC"."VW_MOSTRECENTEMPLOYEERECORDBYLOGIN" as
select max(employeekey) as employeekeycode, networklogin from "DW_ORG"."PNMAC"."EMPLOYEE" 
where rowcurrentflag = 'Y'
and employeeid not in ('001025')
/* Some updates for records need to be removed! */
group by networklogin;
