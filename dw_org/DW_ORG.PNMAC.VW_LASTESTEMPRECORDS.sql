
create or replace view "DW_ORG"."PNMAC"."VW_LASTESTEMPRECORDS" as
select * from  "DW_ORG"."PNMAC"."EMPLOYEE" 
where (CASE WHEN employmentstatus = 'Active' THEN '1' ELSE 0 END)||UPDATEDDATETIME||employeekey in (select employeekeycode from "DW_ORG"."PNMAC"."VW_LASTESTRECORD");
