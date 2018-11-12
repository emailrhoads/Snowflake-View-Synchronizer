
create or replace view "REDLINE"."PNMAC"."VW_JOURNALANDDETAILS" as 
select 
    j.id
    ,j.journalized_id
    ,j.created_on
    ,jd.property
    ,jd.prop_key
    ,jd.old_value
    ,jd.value as new_value
from "REDLINE"."PNMAC"."JOURNALS" j
    LEFT JOIN "REDLINE"."PNMAC"."JOURNAL_DETAILS" jd ON jd.journal_id = j.id;
