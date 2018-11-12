
create or replace view "REDLINE"."PNMAC"."VW_LASTSTATUSCHANGEJOURNALENTRY" as 
select 
    max(j.id) as lastest_journal_id
    ,j.journalized_id
from "REDLINE"."PNMAC"."JOURNALS" j
    JOIN "REDLINE"."PNMAC"."JOURNAL_DETAILS" jd 
    ON jd.journal_id = j.id
    where jd.prop_key = 'status_id'
group by
    j.journalized_id;
