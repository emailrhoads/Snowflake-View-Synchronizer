
CREATE OR REPLACE VIEW "DW_ORG"."PNMAC"."VW_MONTHLY_EMPLOYEES_WITH_BUDGET" AS 
SELECT 
    me.*
    ,bd.headcountbudgeted
    from "DW_ORG"."PNMAC"."VW_MONTHLY_EMPLOYEES" me
    LEFT JOIN "DW_ORG"."PNMAC"."DEPARTMENT_BUDGET" bd ON me.app_dev_budget_category = bd.category and me.outsourced = bd.outsourced and me.monthstart = bd.month;
