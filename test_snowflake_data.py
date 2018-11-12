import snowflake.connector
import snowflake_utility
import os
import pytest
import boto3
import base64
from botocore.exceptions import ClientError
import datetime

#def get_secret():
#    secret_name = "dev/Snowflake/ServiceAccounts"
#    region_name = "us-west-2"
#
#    # Create a Secrets Manager client
#    session = boto3.session.Session()
#    client = session.client(
#        service_name='secretsmanager',
#        region_name=region_name
#    )
#
#    # In this sample we only handle the specific exceptions for the 'GetSecretValue' API.
#    # See https://docs.aws.amazon.com/secretsmanager/latest/apireference/API_GetSecretValue.html
#    # We rethrow the exception by default.
#    try:
#        get_secret_value_response = client.get_secret_value(
#            SecretId=secret_name
#        )
#    except ClientError as e:
#        if e.response['Error']['Code'] == 'DecryptionFailureException':
#            # Secrets Manager can't decrypt the protected secret text using the provided KMS key.
#            # Deal with the exception here, and/or rethrow at your discretion.
#            raise e
#        elif e.response['Error']['Code'] == 'InternalServiceErrorException':
#            # An error occurred on the server side.
#            # Deal with the exception here, and/or rethrow at your discretion.
#            raise e
#        elif e.response['Error']['Code'] == 'InvalidParameterException':
#            # You provided an invalid value for a parameter.
#            # Deal with the exception here, and/or rethrow at your discretion.
#            raise e
#        elif e.response['Error']['Code'] == 'InvalidRequestException':
#            # You provided a parameter value that is not valid for the current state of the resource.
#            # Deal with the exception here, and/or rethrow at your discretion.
#            raise e
#        elif e.response['Error']['Code'] == 'ResourceNotFoundException':
#            # We can't find the resource that you asked for.
#            # Deal with the exception here, and/or rethrow at your discretion.
#            raise e
#    else:
#        # Decrypts secret using the associated KMS CMK.
#        # Depending on whether the secret is a string or binary, one of these fields will be populated.
#        if 'SecretString' in get_secret_value_response:
#            secret = get_secret_value_response['SecretString']
#            secret_value = secret
#        else:
#            decoded_binary_secret = base64.b64decode(get_secret_value_response['SecretBinary'])
#            secret_value = decoded_binary_secret
#            
#    return secret_value

def test_ooo_value_for_2017_meets_expectations():
	statement = (
		"SELECT YEAR, TO_NUMERIC(SUM(BILLABLE_HOURS)) as yearly_hours " \
		"FROM RESOURCE_CAPACITY.PNMAC.MVW_FORECASTANDACTUALCOMBINEDINFO " \
		"WHERE YEAR = 2017 AND EFFORT_ID = 'OOO' GROUP BY YEAR;"	)
	ooo_value_for_2017 = snowflake_utility.SnowflakeConnection().fetch(statement)[0]
	assert ooo_value_for_2017 == (2017, 75396),"Response for 2017 OOO did not match the expected 75,396"

def test_perl_hours():
	statement = (
		"SELECT TO_NUMERIC(SUM(billable_hours)) as perl_total_hours from "\
		"RESOURCE_CAPACITY.PNMAC.MVW_FORECASTANDACTUALCOMBINEDINFO "\
		"WHERE redline_project = 'Privacy Escalation & Response Log (PERL)';")
	perl_hours_logged = snowflake_utility.SnowflakeConnection().fetch(statement)[0][0]
	assert perl_hours_logged == 5,"PERL hours should match 5"


def test_no_duplicate_employees_in_table():
	statement = (
		"SELECT TO_NUMERIC(count(distinct employee_id)) from " \
		" RESOURCE_CAPACITY.PNMAC.MVW_FORECASTANDACTUALCOMBINEDINFO " \
		"WHERE week = 40 and year = 2018 and employee_network_login = 'ahong';"
		)
	count_of_alice_hong = snowflake_utility.SnowflakeConnection().fetch(statement)[0][0]
	assert count_of_alice_hong == 1,"Alice Hong count should match 1"

def test_to_make_sure_last_month_has_hours():
	year_month = (datetime.datetime.now() + datetime.timedelta(-30)).strftime('%Y-%m')
	last_month = year_month + '-01'

	statement = (
		"select count(billable_hours) from RESOURCE_CAPACITY.PNMAC.MVW_FORECASTANDACTUALCOMBINEDINFO "\
		" where month_of_week_start_date = '" + last_month +"'; "
		)
	billable_hours_last_month = snowflake_utility.SnowflakeConnection().fetch(statement)[0][0]
	assert billable_hours_last_month > 0,"Last month must have had >0 hours!"

def test_work_study_hours_match_timesheet_entries():
    statement = (
            "select count(*) FROM " \
            " (select id, sum(hours) as hours from REDLINE.PNMAC.MVW_REDLINEWORKSTUDYWITHHOURS group by id) mvw " \
            " FULL OUTER JOIN " \
            " (select issue_id, sum(entry_hours) as hours from REDLINE.PNMAC.VW_TIMESHEETENTRIES group by issue_id) vw " \
            " ON mvw.id = vw.issue_id " \
            " WHERE round(vw.hours) <> round(mvw.hours); "\
            )
    mismatches = snowflake_utility.SnowflakeConnection().fetch(statement)[0][0]
    assert mismatches == 0,"Should be no hourly mismatch between MVW_REDLINEWORKSTUDYWITHHOURS and VW_TIMESHEETENTRIES"

def test_timesheet_entries_table_matches_view():
    statement = (
        " select count(*) " \
        " FROM (select issue_id, sum(hours) as hours from REDLINE.PNMAC.TIME_ENTRIES " \
        " where year(created_on) >= '2017' group by issue_id) tbl " \
        " FULL OUTER JOIN  " \
        " (select issue_id, sum(entry_hours) as hours from REDLINE.PNMAC.VW_TIMESHEETENTRIES group by issue_id) vw " \
        " ON tbl.issue_id = vw.issue_id " \
        " WHERE round(tbl.hours) <> round(vw.hours); " \
        )
    mismatches = snowflake_utility.SnowflakeConnection().fetch(statement)[0][0]
    assert mismatches == 0,"Should be no hourly mismatch between TIME_ENTRIES and VW_TIMESHEETENTRIES"

def test_old_billable_hours_flowing_through_correctly():
    statement = (
        " select abs(tbl.hours - vw.hours) from " \
        "    (select sum(billable_hours) as hours from " \
        "       RESOURCE_CAPACITY.PNMAC.BILLABLE_HOURS where year >= 2017) tbl" \
        "    CROSS JOIN" \
        "    (select sum(BILLABLE_HOURS) as hours from " \
        "        RESOURCE_CAPACITY.PNMAC.MVW_FORECASTANDACTUALCOMBINEDINFO " \
        "     where REDLINE_ISSUE = 0 and year >= 2017) vw; "  \

        )
    difference = snowflake_utility.SnowflakeConnection().fetch(statement)[0][0]
    assert difference <= 10,"Should be <=10  mismatch between RESOURCE_CAPACITY.PNMAC.BILLABLE_HOURS and RESOURCE_CAPACITY.PNMAC.MVW_FORECASTANDACTUALCOMBINEDINFO"

def test_no_duplicate_employee_ids():
    statement = (
            "select count(*) from (select  "\
            "  employeeid, count(*)  "\
            "  from DW_ORG.PNMAC.VW_ONE_ROW_PER_EMPLOYEE "\
            "  group by employeeid "\
            "  having count(*) > 1) ;" \
        )
    duplicates = snowflake_utility.SnowflakeConnection().fetch(statement)[0][0]
    assert duplicates == 0,'There should be no employees with duplicate ID values'

def test_no_duplicate_network_logins():
    statement = (
            " select count(*) from (select  "\
            "  networklogin, count(*)  "\
            "  from DW_ORG.PNMAC.VW_ONE_ROW_PER_EMPLOYEE "\
            "  group by networklogin "\
            "  having count(*) > 1); "\
        )
    duplicates = snowflake_utility.SnowflakeConnection().fetch(statement)[0][0]
    assert duplicates == 0,'There should be no employees with networkLoginId values'

''' 
TODO: 
	--Add a check that has last month's hours > 0 in the MVW (otherwise we are likely rebuilding incorreclty)
'''
