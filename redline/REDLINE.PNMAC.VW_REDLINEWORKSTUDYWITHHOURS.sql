
create or replace view "REDLINE"."PNMAC"."VW_REDLINEWORKSTUDYWITHHOURS" as
select 
    rlws.*
    ,to_numeric(rl.entry_hours,38,6) as hours
    ,dwo.email as email 
    ,dwo.preferredname as preferredname
    ,date_from_parts(rl.entry_year,rl.entry_month,1) as entry_month
    ,rl.entry_date as entry_date
FROM "REDLINE"."PNMAC"."VW_REDLINEWORKSTUDY" rlws
LEFT JOIN "REDLINE"."PNMAC"."VW_TIMESHEETENTRIES" rl ON rlws.id = rl.issue_id
LEFT JOIN  "DW_ORG"."PNMAC"."VW_ONE_ROW_PER_EMPLOYEE" dwo ON trim(lower(rl.USER_LOGIN)) = trim(lower(dwo.networklogin)) and dwo.rowcurrentflag = 'Y'
;
