
CREATE OR REPLACE VIEW "RESOURCE_CAPACITY"."PNMAC"."VW_PROJECTMILESTONEINFO" AS 
select
            pm.project_milestone_id as effort_id
            ,pm.milestone_item_name as effort_name
            ,pm.project_id
            ,p.project_name
            ,project_milestone_id as milestone_id
            ,pm.milestone_item_name as milestone_name
            ,project_milestone_id as phase_id
            ,pm.milestone_item_name as phase_name
            ,project_milestone_id as release_id
            ,pm.milestone_item_name as release_name
            ,project_milestone_id as item_id
            ,pm.milestone_item_name as item_name
            ,pm.year as year
            ,CASE
              WHEN pm.capitalized ='Y' THEN 'Yes'
              WHEN pm.capitalized ='N' THEN 'No'
              WHEN pm.capitalized = null THEN 'No'
              END as capitalized
             ,pm.application_id as application_id
            ,pm.billable_to_sub_division_id as billable_to_sub_division_id
          from
            "RESOURCE_CAPACITY"."PNMAC"."PROJECT_MILESTONES" pm, "RESOURCE_CAPACITY"."PNMAC"."PROJECTS" p
          where
            pm.year = p.year and lower(trim(pm.project_id)) = lower(trim(p.project_id))
            and pm.year >= 2015;
