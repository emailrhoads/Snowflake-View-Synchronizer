
CREATE OR REPLACE VIEW "REDLINE"."PNMAC"."VW_STATUSLIFECYCLESUMMARY" AS
SELECT 
    issue
    ,status_name
    ,sum(days_in_status) as days_in_status
    ,min(status_begin) as first_day_in_status
from "REDLINE"."PNMAC"."VW_STATUSLIFECYCLE"
    group by issue
    ,status_name
UNION
SELECT 
    issue
    ,status_name
    ,sum(days_in_status) as days_in_status
    ,min(status_begin) as first_day_in_status
from "REDLINE"."PNMAC"."VW_HOLDCLARIFYLIFECYCLE"
    group by issue
    ,status_name;
