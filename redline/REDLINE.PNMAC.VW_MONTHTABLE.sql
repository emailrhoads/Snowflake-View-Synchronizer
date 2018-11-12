
CREATE OR REPLACE VIEW "REDLINE"."PNMAC"."VW_MONTHTABLE" AS 
SELECT 
    date_start
    ,dateadd('day',-1, add_months(date_start,1)) as date_end
 FROM
(SELECT /* Table of all months from 2014 to 2023 */
 dateadd(month,row_number() over (ORDER BY seq4())-1,add_months(date_from_parts(year(current_timestamp()), month(current_timestamp()), 1),-12)) as date_start
FROM table(generator(rowCount => 14))) generator;
