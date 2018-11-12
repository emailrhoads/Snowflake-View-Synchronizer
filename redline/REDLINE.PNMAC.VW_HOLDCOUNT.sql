
create or replace view "REDLINE"."PNMAC"."VW_HOLDCOUNT" as 
select 
    count(*) as hold_count
    ,j.journalized_id
from journals j
    JOIN journal_details jd ON jd.journal_id = j.id 
        and jd.property = 'cf'
        and jd.prop_key = '44'
        and value in ('1','Yes')
    group by 
     j.journalized_id;
