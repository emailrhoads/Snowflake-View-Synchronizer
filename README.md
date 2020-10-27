# it-pmo-snowflake-views

This project contains the DDL for views that are created in support of the Tableau reports used by the App Dev ITPMO.

## What it does

- This will look at schemas in Snowflake and pull out the views. 
- The SQL for those views will then be written to file in the format `schema/view_name.sql`.
- Then each of the views is checked iteratively to see if there are object dependencies.
- From there a deployment order is created, which is then used to create a deployment script.
- The script will reference the .sql for each view and combine it inot a single deployment.sql file
- The previous deployment.sql file will be copied into rollback.sql which can be used to revert to previous version.

