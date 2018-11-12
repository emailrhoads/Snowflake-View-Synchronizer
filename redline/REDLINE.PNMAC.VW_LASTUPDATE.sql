
CREATE OR REPLACE VIEW "REDLINE"."PNMAC"."VW_LASTUPDATE" AS 
select max(updated_on) last_issue_update_on from "REDLINE"."PNMAC"."ISSUES";
