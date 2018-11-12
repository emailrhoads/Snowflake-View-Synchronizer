
create or replace view "REDLINE"."PNMAC"."VW_REDLINEWORKSTUDYMONTHLY" as 
select 
    months.date_start as month_start
    ,months.date_end as month_end
    ,i.*
    ,(CASE WHEN i.created_on between months.date_start and months.date_end  /* Created sometime during this month */
                THEN 1 else 0 END) as created_count
    ,(CASE WHEN i.created_on < months.date_end and ifnull(i.closed_on,'2099-01-01') > months.date_start /* Existed as an open ticket sometime during this month */
                and i.issue_status <> 'Cancelled'                                                       /* Not Cancelled */
                and ifnull(i.closed_on,'2099-01-01') between months.date_start and months.date_end      /* Closed this month */
                THEN 1 else 0 END) as closed_count
    ,(CASE WHEN i.created_on < months.date_end and ifnull(i.closed_on,'2099-01-01') > months.date_start /* Existed as an open ticket sometime during this month */
                and i.issue_status = 'Cancelled'                                                        /* Cancelled */
                and ifnull(i.closed_on,'2099-01-01') between months.date_start and months.date_end      /* Closed this month */
                THEN 1 else 0 END) as cancelled_count
    ,(CASE WHEN i.created_on < months.date_end and ifnull(i.closed_on,'2099-01-01') > months.date_start /* Existed as an open ticket sometime during this month */
                and i.issue_status not in ('New','Guestimmate')                                         /* Not in New or Guestimate */
                and ifnull(i.closed_on,'2099-01-01') not between months.date_start and months.date_end  /* NOT closed this month */              
                THEN 1 else 0 END) as in_progress_count
    ,(CASE WHEN (i.issue_status in ('New','Guesstimate') 
                 or 
                i.created_on < months.date_end and ifnull(i.closed_on,'2099-01-01') > months.date_start /* Existed as an open ticket sometime during this month */
                and ifnull(i.first_day_in_progress,ifnull(i.first_day_in_analysis,ifnull(i.first_under_development_date,'2099-01-01'))) > months.date_end               /* Didn't hit development during this month */ 
                ) 
                THEN 1 else 0 END) as backlog_count
from "REDLINE"."PNMAC"."VW_MONTHTABLE" months
JOIN "REDLINE"."PNMAC"."VW_REDLINEWORKSTUDY" i
/* where i.tracker_name in ('Story','Request') */
;
