
CREATE OR REPLACE VIEW "RESOURCE_CAPACITY"."PNMAC"."VW_EFFORTLISTING" AS
select distinct
          effort_id 
          ,effort_name
          ,project_id
          ,project_name
          ,milestone_id
          ,milestone_name
          ,phase_id
          ,phase_name
          ,release_id
          ,release_name
          ,item_id
          ,item_name
          ,year
          ,capitalized
          ,application_id
          ,billable_to_sub_division_id
          from "RESOURCE_CAPACITY"."PNMAC"."VW_RELEASEITEMINFO"

         UNION 

          select distinct
            effort_id
          ,effort_name
          ,project_id
          ,project_name
          ,milestone_id
          ,milestone_name
          ,phase_id
          ,phase_name
          ,release_id
          ,release_name
          ,item_id
          ,item_name
          ,year
          ,capitalized
          ,application_id
          ,billable_to_sub_division_id
          from
            "RESOURCE_CAPACITY"."PNMAC"."VW_PROJECTMILESTONEINFO"

          UNION 

          select distinct
            project_id as effort_id
            ,project_name as effort_name
            ,project_id
            ,project_name
            ,project_id as milestone_id
            ,project_name as milestone_name
            ,project_id as phase_id
            ,project_name as phase_name
            ,project_id as release_id
            ,project_name as release_name
            ,project_id as item_id
            ,project_name as item_name
            ,year as year
            ,'No' as capitalized
            ,application_id as application_id
            ,billable_to_sub_division_id
          from "RESOURCE_CAPACITY"."PNMAC"."PROJECTS"
          where year >= 2015

          UNION 

          select distinct
            work_item_id as effort_id
            ,work_item_name as effort_name
            ,work_item_id as project_id
            ,work_item_name as project_name
            ,work_item_id as milestone_id
            ,work_item_name as milestone_name
            ,work_item_id as phase_id
            ,work_item_name as phase_name
            ,work_item_id as release_id
            ,work_item_name as release_name
            ,work_item_id as item_id
            ,work_item_name as item_name
            ,year as year
            ,'No' as capitalized
            ,application_id as application_id
            ,billable_to_sub_division_id
          from "RESOURCE_CAPACITY"."PNMAC"."WORK_ITEMS"
          where year >= 2015
          
          UNION
            select distinct
               'OOO' as effort_id
              ,'Out of Office' as effort_name
              ,'OOO' as project_id
              ,'Out of Office' as project_name
              ,'OOO' as milestone_id
              ,'Out of Office' as milestone_name
              ,'OOO' as phase_id
             ,'Out of Office' as phase_name
             ,'OOO' as release_id
             ,'Out of Office' as release_name
             ,'OOO' as item_id
             ,'Out of Office' as item_name
             ,y.year as year
              ,'No' as capitalized
              ,'NOAPP' as application_id
              , null as billable_to_sub_division_id
              from (select distinct year from "RESOURCE_CAPACITY"."PNMAC"."WEEKS_INFO") y;
