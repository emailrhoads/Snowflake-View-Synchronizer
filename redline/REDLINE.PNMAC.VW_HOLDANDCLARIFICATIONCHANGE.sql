
CREATE OR REPLACE VIEW "REDLINE"."PNMAC"."VW_HOLDANDCLARIFICATIONCHANGE" AS
select 
    min(jd1.id) as second_entry
    ,jd0.id as first_entry
from "REDLINE"."PNMAC"."JOURNALS" j0
JOIN "REDLINE"."PNMAC"."VW_RECENTJOURNALDETAILS" rjd
JOIN "REDLINE"."PNMAC"."JOURNAL_DETAILS" jd0 ON j0.id = jd0.journal_id and jd0.property = 'cf' and to_char(jd0.prop_key) in ('44','45') and rjd.min_id <= jd0.id and jd0.value in ('1','Yes')
JOIN "REDLINE"."PNMAC"."JOURNALS" j1 ON j0.journalized_id = j1.journalized_id and j0.id < j1.id
JOIN "REDLINE"."PNMAC"."JOURNAL_DETAILS" jd1 ON rjd.min_id <= jd1.id and jd1.property = 'cf' and j1.id = jd1.journal_id and to_char(jd1.prop_key) = to_char(jd0.prop_key) and to_char(jd1.old_value) in ('1','Yes')
group by 
    jd0.id;
