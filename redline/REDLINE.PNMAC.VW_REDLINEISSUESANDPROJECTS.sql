
CREATE OR REPLACE VIEW "REDLINE"."PNMAC"."VW_REDLINEISSUESANDPROJECTS" AS 
SELECT 
  ifnull(cvi1.value,cvp1.value) as itid
  ,pr1.id                        as project_id
  ,pr1.name                      as project_name
  ,pr1.description               as project_description
  ,pr1.IDENTIFIER                as project_identifier
  ,pr1.impacted_application      as project_impacted_application
  ,cvp1.value                    as project_itid
  ,cvp2.value                    as project_primary_delivery_team
  ,cvp3.value                    as project_outsource_company
  ,i1.id                        as l1_issue_id
  ,i1.subject                   as l1_issue_subject
  ,i1.description               as l1_issue_description
  ,i1.start_date                as l1_issue_start_date
  ,i1.due_date                  as l1_issue_due_date
  ,i1.done_ratio                as l1_issue_done_ratio
  ,i1.estimated_hours           as l1_issue_estimated_hours
  ,i1.created_on                as l1_issue_created_on
  ,i1.closed_on                 as l1_issue_closed_on
  ,i1.priority_id               as l1_issue_priority_id
  ,e1.name                      as l1_issue_priority_name
  ,cvi1.value                   as l1_issue_itid
  ,i1.tracker_id                as l1_issue_tracker_id
  ,t1.name                      as l1_issue_tracker_name
  ,cvi2.value                   as l1_issue_type
  ,is1.id                       as l1_issue_status_id
  ,is1.name                     as l1_issue_status_name
  ,cvi3.value                  as l1_issue_technica_change_only
FROM
    "REDLINE"."PNMAC"."ISSUES" i1
    LEFT JOIN "REDLINE"."PNMAC"."CUSTOM_VALUES" cvi1 ON i1.id = cvi1.customized_id and cvi1.CUSTOM_FIELD_ID = '70' /* 70  = Issue ITID */
    LEFT JOIN "REDLINE"."PNMAC"."CUSTOM_VALUES" cvi2 ON i1.id = cvi2.customized_id and cvi2.CUSTOM_FIELD_ID = '41' /* 41  = Maint Tracker Work Type */
    LEFT JOIN "REDLINE"."PNMAC"."CUSTOM_VALUES" cvi3 ON i1.id = cvi3.customized_id and cvi3.CUSTOM_FIELD_ID = '68' /* 68 = Technical Change Only? */
    LEFT JOIN "REDLINE"."PNMAC"."ISSUE_STATUSES" is1 ON i1.status_id = is1.id 
    LEFT JOIN "REDLINE"."PNMAC"."ENUMERATIONS" e1 ON i1.priority_id = e1.id
    LEFT JOIN "REDLINE"."PNMAC"."TRACKERS" t1 on i1.tracker_id = t1.id
    LEFT JOIN "REDLINE"."PNMAC"."PROJECTS" pr1 ON i1.project_id = pr1.id 
    LEFT JOIN "REDLINE"."PNMAC"."CUSTOM_VALUES" cvp1 ON pr1.id = cvp1.customized_id and cvp1.CUSTOM_FIELD_ID = '106' /* 106 = Project ITID */
    LEFT JOIN "REDLINE"."PNMAC"."CUSTOM_VALUES" cvp2 ON pr1.id = cvp2.customized_id and cvp2.CUSTOM_FIELD_ID = '109' /* 109 = Primary Delivery Team */
    LEFT JOIN "REDLINE"."PNMAC"."CUSTOM_VALUES" cvp3 ON pr1.id = cvp3.customized_id and cvp3.CUSTOM_FIELD_ID = '104' /* 104 = Outsource Company */
WHERE
    year(i1.created_on) >= 2017;
