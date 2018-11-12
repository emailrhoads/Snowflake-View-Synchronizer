
CREATE OR REPLACE VIEW "RESOURCE_CAPACITY"."PNMAC"."VW_FORECAST_V2" AS 
SELECT
  f.effort_id as effort_id
  ,f.billable_to_sub_division_id as billed_sub_division_id
  ,s.department_id as billed_department_id
  ,s.division_id as billed_division_id
  ,null as application_id
  ,null as application_name

  ,CASE WHEN (select count(week) from PNMAC.weeks_info wi where wi.year = f.year and 'Q'||wi.quarter = f.quarter) = 0 then 0 
  ELSE forecast/(select count(week) from PNMAC.weeks_info wi where wi.year = f.year and 'Q'||wi.quarter = f.quarter) END forecast
  ,(CASE WHEN pm.capitalized ='Y' THEN 'Yes' ELSE 'No' END) as capitalized

  ,f.year
  ,f.quarter
  ,w.month as month
  ,w.week as week
  ,dateadd(day, 7*(w.week - 1) - 
     (CASE WHEN date_part('dow', date_from_parts(w.year, 1, 1)) = 0 THEN -1
      ELSE date_part('dow', date_from_parts(w.year, 1, 1))-1 END), date_from_parts(w.year, 1, 1) ) as entry_date

  ,'Forecast' as employee_id
  ,'Forecast' as network_login
  ,f.sub_division_id as working_team_sub_division_id

  ,'Forecast' as redline_project
  ,'0' as redline_issue
  ,'Forecast' as redline_issue_subject
  ,(CASE 
        WHEN f.effort_id = 'OOO' THEN 'OOO'
        
        WHEN f.effort_id in ('WK068','WK075','WK096','WK118','WK122','WK128','WK131','WK154',
                'WK165','WK174','WK175','WK176','WK177','WK178','WK179','WK180',
                'WK181','WK182','WK183','WK184','WK185','WK186','WK187','WK188',
                'WK190','WK181','WK194','WK197','WK198','WK201','WK202','WK209','WK228','WK237',
                'WK232','WK234','WK247','WK318','WK911','WK913') THEN 'ADMIN'
        WHEN left(f.effort_id,2) = 'WK' THEN 'MAINT'
        ELSE 'PROJ' END) as WORK_CATEGORY

  FROM "RESOURCE_CAPACITY"."PNMAC"."FTE_FORECAST" f
  LEFT JOIN "RESOURCE_CAPACITY"."PNMAC"."SUB_DIVISIONS" s ON f.billable_to_sub_division_id = s.sub_division_id
  LEFT JOIN "RESOURCE_CAPACITY"."PNMAC"."PROJECT_MILESTONES" pm ON f.effort_id = pm.project_milestone_id and f.year = pm.year
  ,"RESOURCE_CAPACITY"."PNMAC"."WEEKS_INFO" w
  WHERE
    f.year >= 2015
    and w.year = f.year
    and f.quarter = 'Q'||w.quarter;
