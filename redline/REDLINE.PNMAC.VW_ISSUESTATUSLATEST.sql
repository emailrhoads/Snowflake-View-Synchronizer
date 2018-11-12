
create or replace view "REDLINE"."PNMAC"."VW_ISSUESTATUSLATEST" as 
select 
    max(j.created_on) as last_on
    ,j.journalized_id
    ,jd.property
    ,jd.prop_key
    ,jd.value as new_value
from "REDLINE"."PNMAC"."JOURNALS" j
    LEFT JOIN "REDLINE"."PNMAC"."JOURNAL_DETAILS" jd ON jd.journal_id = j.id and jd.prop_key = 'status_id'
    group by 
     j.journalized_id
    ,jd.property
    ,jd.prop_key
    ,jd.value;
