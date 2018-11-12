
CREATE OR REPLACE VIEW "REDLINE"."PNMAC"."VW_REDLINESDLCALL" AS
select 
  i.*
  ,a.issue_technical_change_only
  ,a.qa_artifact_filename
  ,a.qa_artifact_contenttype
  ,a.qa_artifact_id_number
  ,a.qa_artifact_link
  ,a.qa_author_name
  ,a.qa_created_on
  ,a.uat_artifact_filename
  ,a.uat_artifact_contenttype
  ,a.uat_artifact_id_number
  ,a.uat_artifact_link
  ,a.uat_author_name
  ,a.uat_created_on
 FROM
    "REDLINE"."PNMAC"."VW_REDLINEISSUESANDPROJECTS" i
    LEFT JOIN "REDLINE"."PNMAC"."VW_REDLINEARTIFACTS" a ON i.l1_issue_id = a.issue_id;
