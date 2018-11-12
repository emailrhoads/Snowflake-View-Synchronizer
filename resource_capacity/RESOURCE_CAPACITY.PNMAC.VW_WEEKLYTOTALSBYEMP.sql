
CREATE OR REPLACE VIEW "RESOURCE_CAPACITY"."PNMAC"."VW_WEEKLYTOTALSBYEMP" AS 
        select 
        employee_id
        ,year
        ,week
        ,ceil(sum(billable_hours),1) as total_weekly_hours
        ,(CASE WHEN ceil(sum(billable_hours),1) >= 40 THEN 40 ELSE ceil(sum(billable_hours),1) END) as capped_weekly_hours
     FROM
    "RESOURCE_CAPACITY"."PNMAC"."VW_ACTUALS_V2"
    group by 
    employee_id
        ,year
        ,week;
