
create or replace view "DW_ORG"."PNMAC"."VW_ONE_ROW_PER_EMPLOYEE" as
select * from  "DW_ORG"."PNMAC"."EMPLOYEE" 
where employeekey in (select employeekey from "DW_ORG"."PNMAC"."VW_LASTESTEMPRECORDS");
