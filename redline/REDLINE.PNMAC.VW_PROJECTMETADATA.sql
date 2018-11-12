
CREATE OR REPLACE VIEW "REDLINE"."PNMAC"."VW_PROJECTMETADATA" AS 
select 
    p.*
    ,itid.value as itid
    ,spid.value as spid
    ,efforts.effort_name as effort_name
    ,parent1.name as first_parent
    ,parent2.name as second_parent
    ,parent3.name as third_parent
    ,parent4.name as fourth_parent
    ,parent5.name as fifth_parent
from projects p
left join custom_values itid ON p.id = itid.customized_id and itid.custom_field_id = 106
left join custom_values spid ON p.id = spid.customized_id and spid.custom_field_id = 107
left join projects parent1 on p.parent_id = parent1.id
left join projects parent2 on parent1.parent_id = parent2.id
left join projects parent3 on parent2.parent_id = parent3.id
left join projects parent4 on parent3.parent_id = parent4.id
left join projects parent5 on parent4.parent_id = parent5.id
left join "RESOURCE_CAPACITY"."PNMAC"."VW_EFFORTLISTING" efforts on itid.value = efforts.effort_id
where p.status = 1;
