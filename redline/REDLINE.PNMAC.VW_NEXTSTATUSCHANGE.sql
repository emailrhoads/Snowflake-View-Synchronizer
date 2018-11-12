
CREATE OR REPLACE VIEW "REDLINE"."PNMAC"."VW_NEXTSTATUSCHANGE" AS
select 
    jd0.id as first_entry
    ,min(jd1.id) as second_entry
from "REDLINE"."PNMAC"."JOURNALS" j0
JOIN "REDLINE"."PNMAC"."VW_RECENTJOURNALDETAILS" rjd
JOIN "REDLINE"."PNMAC"."JOURNAL_DETAILS" jd0 ON j0.id = jd0.journal_id and to_char(jd0.prop_key) = 'status_id' and rjd.min_id <= jd0.id
LEFT JOIN "REDLINE"."PNMAC"."JOURNALS" j1 ON j0.journalized_id = j1.journalized_id and j0.id < j1.id
LEFT JOIN "REDLINE"."PNMAC"."JOURNAL_DETAILS" jd1 ON rjd.min_id <= jd1.id and j1.id = jd1.journal_id and to_char(jd1.prop_key) = 'status_id' and to_char(jd1.old_value) = to_char(jd0.value)
group by 
    jd0.id;
