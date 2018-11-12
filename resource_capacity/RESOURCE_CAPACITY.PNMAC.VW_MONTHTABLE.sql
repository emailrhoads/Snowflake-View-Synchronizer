CREATE OR REPLACE VIEW "RESOURCE_CAPACITY"."PNMAC"."VW_MONTHTABLE" AS 
SELECT 
 dateadd(month,row_number() over (ORDER BY seq4())-1,date_from_parts(year(current_timestamp)-2,'01','28')) as date
 FROM table(generator(rowCount => 48));