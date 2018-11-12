
CREATE OR REPLACE VIEW "REDLINE"."PNMAC"."VW_RECENTJOURNALDETAILS" AS
select min(jd.id) as min_id from "REDLINE"."PNMAC"."JOURNAL_DETAILS" jd
JOIN "REDLINE"."PNMAC"."JOURNALS" j ON j.id = jd.journal_id
AND j.created_on >= add_months(current_timestamp,-18);
