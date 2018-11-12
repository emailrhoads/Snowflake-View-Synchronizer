
CREATE OR REPLACE VIEW "RESOURCE_CAPACITY"."PNMAC"."VW_RELEASEITEMINFO" AS 
select
          ri.item_id as effort_id
          ,ri.item_name as effort_name
          ,ri.project_id as project_id
          ,p.project_name as project_name
          ,ri.milestone_id as milestone_id
          ,pm.milestone_item_name as milestone_name
          ,ri.phase_id as phase_id
          ,pp.phases_name as phase_name
          ,ri.release_id as release_id
          ,pr.release_name as release_name
          ,ri.item_id as item_id
          ,ri.item_name as item_name
          ,ri.year as year
          ,CASE
              WHEN ri.capitalized ='Y' THEN 'Yes'
              WHEN ri.capitalized ='N' THEN 'No'
              WHEN ri.capitalized = null THEN 'No'
              END as capitalized
           ,pm.application_id as application_id
           ,ri.billable_to_sub_division_id as billable_to_sub_division_id
          from "RESOURCE_CAPACITY"."PNMAC"."RELEASE_ITEMS" ri
          LEFT JOIN "RESOURCE_CAPACITY"."PNMAC"."PROJECTS" p ON ri.year = p.year and lower(trim(ri.project_id)) =lower(trim( p.project_id))
          LEFT JOIN "RESOURCE_CAPACITY"."PNMAC"."PROJECT_MILESTONES" pm ON ri.year = pm.year and lower(trim(ri.milestone_id)) = lower(trim(pm.project_milestone_id))
          LEFT JOIN "RESOURCE_CAPACITY"."PNMAC"."PROJECT_MILESTONE_PHASES" pp ON ri.year = pp.year and lower(trim(ri.phase_id)) = lower(trim(pp.phase_id)) 
          LEFT JOIN "RESOURCE_CAPACITY"."PNMAC"."PROJECT_MILESTONE_RELEASES" pr ON ri.year = pr.year and lower(trim(ri.release_id)) = lower(trim(pr.release_id))
          where ri.year >= 2015;
