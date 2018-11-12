
CREATE OR REPLACE VIEW "REDLINE"."PNMAC"."VW_STATUSLIFECYCLE" AS
SELECT
    to_char(jd0.prop_key) as prop_key
    ,j0.journalized_id as issue
    ,to_char(is0.name) as status_name
    ,j0.created_on as status_begin
    ,ifnull(j1.created_on,current_timestamp) as status_end
    /* ,timestampdiff('day',j0.created_on,j1.created_on) as days_in_status */
    ,DATEDIFF('day',j0.created_on,ifnull(j1.created_on,current_timestamp)) 
      - DATEDIFF('week',j0.created_on,ifnull(j1.created_on,current_timestamp)) * 2
      as days_in_status
FROM "REDLINE"."PNMAC"."VW_NEXTSTATUSCHANGE" nsc
JOIN "REDLINE"."PNMAC"."JOURNAL_DETAILS" jd0 ON nsc.first_entry = jd0.id
JOIN "REDLINE"."PNMAC"."JOURNALS" j0 ON jd0.journal_id = j0.id
JOIN "REDLINE"."PNMAC"."ISSUE_STATUSES" is0 ON to_char(jd0.value) = to_char(is0.id)
LEFT JOIN "REDLINE"."PNMAC"."JOURNAL_DETAILS" jd1 ON nsc.second_entry = jd1.id
LEFT JOIN "REDLINE"."PNMAC"."JOURNALS" j1 ON jd1.journal_id = j1.id;
