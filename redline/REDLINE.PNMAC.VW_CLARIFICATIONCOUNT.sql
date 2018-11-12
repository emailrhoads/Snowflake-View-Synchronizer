
create or replace view "REDLINE"."PNMAC"."VW_CLARIFICATIONCOUNT" as 
select 
    count(*) as clarification_count
    ,j.journalized_id
from journals j
    JOIN journal_details jd ON jd.journal_id = j.id 
        and jd.property = 'cf'
        and jd.prop_key = '45'
        and value in ('1','Yes')
    group by 
     j.journalized_id;
