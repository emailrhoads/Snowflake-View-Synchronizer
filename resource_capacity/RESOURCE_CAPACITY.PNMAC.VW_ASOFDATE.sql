
CREATE OR REPLACE VIEW "RESOURCE_CAPACITY"."PNMAC"."VW_ASOFDATE" AS 
select
max(
dateadd(day,-2-date_part(weekday, dateadd(week, 1, date_from_parts(b.year,1,1))), dateadd(week, b.week, date_from_parts(b.year,1,1)))
   
  ) as as_of_date
from "RESOURCE_CAPACITY"."PNMAC"."VW_REDLINEACTUALS_V2" b
where year between extract(year,CURRENT_DATE)-1 and extract(year,CURRENT_DATE)+1;
