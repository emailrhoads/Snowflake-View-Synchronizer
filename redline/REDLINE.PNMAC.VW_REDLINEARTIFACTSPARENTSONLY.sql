
CREATE OR REPLACE VIEW "REDLINE"."PNMAC"."VW_REDLINEARTIFACTSPARENTSONLY" AS 
SELECT 
  ifnull(cvi1.value,cvp1.value)                                         as itid
  ,pr1.id                                                               as project_id
  ,pr1.name                                                             as project_name
  ,pr1.description                                                      as project_description
  ,pr1.IDENTIFIER                                                       as project_identifier
  ,pr1.impacted_application                                             as project_impacted_application
  ,cvp1.value                                                           as project_itid
  ,cvp2.value                                                           as project_primary_delivery_team
  ,cvp3.value                                                           as project_outsource_company
  ,i1.id                                                                as issue_id
  ,i1.subject                                                           as issue_subject
  ,i1.description                                                       as issue_description
  ,i1.start_date                                                        as issue_start_date
  ,i1.due_date                                                          as issue_due_date
  ,i1.done_ratio                                                        as issue_done_ratio
  ,i1.estimated_hours                                                   as issue_estimated_hours
  ,i1.created_on                                                        as issue_created_on
  ,i1.closed_on                                                         as issue_closed_on
  ,i1.updated_on                                                        as issue_last_updated_on
  ,i1.priority_id                                                       as issue_priority_id
  ,e1.name                                                              as issue_priority_name
  ,cvi1.value                                                           as issue_itid
  ,cvi3.value                                                           as issue_technical_change_only
  ,i1.tracker_id                                                        as issue_tracker_id
  ,t1.name                                                              as issue_tracker_name
  ,cvi2.value                                                           as issue_type
  ,is1.id                                                               as issue_status_id
  ,is1.name                                                             as issue_status_name
  ,a1qa.filename                                                        as qa_artifact_filename
  ,a1qa.content_type                                                    as qa_artifact_contenttype
  ,a1qa.container_id                                                    as qa_artifact_id_number
  ,'https://redline2.pnmac.com/download_from_s3/'||a1qa.id              as qa_artifact_link
  ,uqa.firstname||' '||uqa.lastname                                     as qa_author_name
  ,a1qa.created_on                                                      as qa_created_on
  ,a1uat.filename                                                       as uat_artifact_filename
  ,a1uat.content_type                                                   as uat_artifact_contenttype
  ,a1uat.container_id                                                   as uat_artifact_id_number
  ,'https://redline2.pnmac.com/download_from_s3/'||a1uat.id             as uat_artifact_link
  ,uuat.firstname||' '||uuat.lastname                                   as uat_author_name
  ,a1uat.created_on                                                     as uat_created_on
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
    LEFT JOIN "REDLINE"."PNMAC"."ATTACHMENTS" a1qa  ON i1.id = a1qa.container_id and LEFT(a1qa.filename ,13) = 'QA Artifact -' 
    LEFT JOIN "REDLINE"."PNMAC"."USERS" uqa on a1qa.author_id = uqa.id
    LEFT JOIN "REDLINE"."PNMAC"."ATTACHMENTS" a1uat ON i1.id = a1uat.container_id and LEFT(a1uat.filename ,14) = 'UAT Artifact -'
    LEFT JOIN "REDLINE"."PNMAC"."USERS" uuat on a1uat.author_id = uuat.id
WHERE
    i1.parent_id is null;
