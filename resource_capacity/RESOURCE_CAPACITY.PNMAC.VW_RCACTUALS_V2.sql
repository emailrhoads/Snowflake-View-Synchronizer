
CREATE OR REPLACE VIEW "RESOURCE_CAPACITY"."PNMAC"."VW_RCACTUALS_V2" AS
SELECT
  trim(b.effort_id) as effort_id
  ,(CASE WHEN b.effort_id = 'OOO' AND ( trim(ifnull(b.sub_division_id,'NULL')) = 'NULL' OR length(trim(b.sub_division_id)) = 0 ) THEN ifnull(trim(b.team),trim(e.sub_division_id))
    ELSE trim(b.sub_division_id) END ) as billed_sub_division_id
  ,trim(s.division_id) as billed_division_id
  ,s.department_id as billed_department_id
  ,trim(b.team) as working_team_sub_division_id
  ,b.year as year
  ,'Q'||extract(quarter from dateadd(day,-6-date_part(weekday, dateadd(week, 1, date_from_parts(b.year,1,1))), dateadd(week, b.week, date_from_parts(b.year,1,1))))
    as quarter
  ,extract(month from dateadd(day,-6-date_part(weekday, dateadd(week, 1, date_from_parts(b.year,1,1))), dateadd(week, b.week, date_from_parts(b.year,1,1))))
    as month
  ,b.week as week
  ,dateadd(day, 7*(b.week - 1) - 
             (CASE WHEN date_part('dow', date_from_parts(b.year, 1, 1)) = 0 THEN -1
              ELSE date_part('dow', date_from_parts(b.year, 1, 1))-1 END), date_from_parts(b.year, 1, 1) ) as entry_date
  ,trim(b.employee_id) as employee_id
  ,b.billable_hours as billable_hours
  ,null as capitalized /* billable_hours.capitalized is NOT trust-worthy! */
  ,(CASE 
        WHEN b.effort_id = 'OOO' THEN 'OOO'
        
        WHEN b.effort_id in ('WK068','WK075','WK096','WK118','WK122','WK128','WK131','WK154',
                'WK165','WK174','WK175','WK176','WK177','WK178','WK179','WK180',
                'WK181','WK182','WK183','WK184','WK185','WK186','WK187','WK188',
                'WK190','WK181','WK194','WK197','WK198','WK201','WK202','WK209','WK228','WK237',
                'WK232','WK234','WK247','WK318','WK911','WK913') THEN 'ADMIN'
        WHEN left(b.effort_id,2) = 'WK' THEN 'MAINT'
        ELSE 'PROJ' END) as WORK_CATEGORY
FROM "RESOURCE_CAPACITY"."PNMAC"."BILLABLE_HOURS" b
LEFT JOIN "RESOURCE_CAPACITY"."PNMAC"."SUB_DIVISIONS" s ON ifnull(trim(b.sub_division_id),trim(b.team)) = s.sub_division_id
LEFT JOIN "RESOURCE_CAPACITY"."PNMAC"."EMPLOYEES" e ON trim(b.employee_id) = trim(e.employee_id)
WHERE
 b.year >= 2015;
