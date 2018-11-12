
CREATE OR REPLACE VIEW "REDLINE"."PNMAC"."VW_HOLDCLARIFYLIFECYCLE" AS
SELECT
    j0.journalized_id as issue
    ,to_char(cf0.name) as status_name
    ,j0.created_on as status_begin
    ,j1.created_on as status_end
    ,DATEDIFF('day'
        ,j0.created_on
        ,j1.created_on
        ) + 0
      - DATEDIFF('week'
        ,j0.created_on
        ,j1.created_on
        ) * 2
      as days_in_status
    /*,timestampdiff('day',j0.created_on,j1.created_on) as days_in_status */
FROM "REDLINE"."PNMAC"."VW_HOLDANDCLARIFICATIONCHANGE" hcc
JOIN "REDLINE"."PNMAC"."JOURNAL_DETAILS" jd0 ON hcc.first_entry = jd0.id
JOIN "REDLINE"."PNMAC"."CUSTOM_FIELDS" cf0 ON to_char(jd0.prop_key) = to_char(cf0.id)
JOIN "REDLINE"."PNMAC"."JOURNALS" j0 ON jd0.journal_id = j0.id
JOIN "REDLINE"."PNMAC"."JOURNAL_DETAILS" jd1 ON hcc.second_entry = jd1.id
JOIN "REDLINE"."PNMAC"."JOURNALS" j1 ON jd1.journal_id = j1.id;
