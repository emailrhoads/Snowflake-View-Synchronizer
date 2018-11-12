import snowflake.connector
import json
import os

class SnowflakeConnection:
	'''
	This is used to instantiate and manage
		as snowflake connection throughout
		the duration of the session
	'''

	def __init__(self, _environment = 'dev'):

		if 'PROD' in _environment.upper():
			self.account = os.environ['PROD_ACCOUNT']
			self.username = os.environ['PROD_USERNAME']
			self.password = os.environ['PROD_PASSWORD']
			self.authenticator = os.environ['PROD_AUTHENTICATOR']
		else:
			self.account = os.environ['DEV_ACCOUNT']
			self.username = os.environ['DEV_USERNAME']
			self.password = os.environ['DEV_PASSWORD']
			self.authenticator = os.environ['DEV_AUTHENTICATOR']

		self.connection = snowflake.connector.connect(
		  user=self.username,
		  account=self.account,
		  authenticator=self.authenticator,
		  password=self.password
		)

	def run(self, _statement):
		return self.connection.cursor().execute(_statement)

	def set_warehouse(self, _warehouse):
		statement = "USE warehouse "+_warehouse+";"
		return self.run(statement)

	def set_database(self, _database):
		statement = "USE "+_database+";"
		return self.run(statement)

	def listify(self, _cursorObject):
		rows = []
		for cursor in _cursorObject:
			rows.append(cursor)
		return rows 

	def fetch(self, _statement):
		cursor = self.run(_statement)
		return self.listify(cursor)