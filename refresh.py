import codecs
import os
import snowflake_utility
import subprocess
import sys
import time
from shutil import copyfile

def get_relevant_schemas():
	relevantSchemas = [
		'RESOURCE_CAPACITY.PNMAC'
		,'DW_ORG.PNMAC'
		,'REDLINE.PNMAC'
	]
	return relevantSchemas

def get_names_from_list(_list, _index):
	names = []
	for row in _list:
		names.append(row[_index])
	return names

def get_objects_for_schema(_object, _database, _schema):
	statement = 'SHOW TERSE '+_object+' IN '+_database+'.'+_schema+';'
	object_data = snowflake_utility.SnowflakeConnection().fetch(statement)
	return get_names_from_list(object_data,1)

def parse_database_and_schema(_fullstring):
	return _fullstring.split(".")

def get_view_ddl(_database, _schema, _view):
	fully_prefixed_name = dot_combine(_database, _schema, _view)
	statement = "SELECT get_ddl('view','"+ fully_prefixed_name +"');"
	return snowflake_utility.SnowflakeConnection().fetch(statement)[0][0].encode('utf-8')

def build_directory(_database):
	current_directory = sys.path[0]
	return  current_directory + '/' + _database.lower()

def make_directory_if_needed(_database):
	directory = build_directory(_database)
	if not os.path.exists(directory):
		os.makedirs(directory)
	return

def write_sql_to_file(_database, _schema, _object, _sql):
	directory = build_directory(_database)
	filename = dot_combine(_database.upper(),_schema.upper(),_object.upper(),'sql')
	fullpath = directory + '/' + filename
	f = open(fullpath,'w')
	f.write(_sql)
	f.close()
	return

def get_relevant_database_objects():
	schema_list = get_relevant_schemas()
	object_list = []
	for prefixed_schema in schema_list:
		database, schema = parse_database_and_schema(prefixed_schema) #parse database and schema from input
		print("Processing database: %s" % database)
		object_list = update_view_scripts(database, schema, object_list)
		object_list = update_materialized_view_scripts(database, schema, object_list)
	return object_list

def update_view_scripts(_database, _schema, _object_list):
	print(" processing views")
	make_directory_if_needed(_database) #create folder for this database unless it already exists
	views = get_objects_for_schema('VIEWS', _database, _schema) #get the views for the schema
	for view in views: 	#for each view in the schema...
		print(" ... %s" % view)
		_object_list.append(dot_combine(_database,_schema,view))
		sql_to_create_view = get_view_ddl(_database, _schema, view) #get the DDL for the view
		write_sql_to_file(_database, _schema, view, sql_to_create_view) #write the DDL to folder/file.sql where folder = db and file = viewname
	print ("done views!")
	return _object_list

def update_materialized_view_scripts(_database, _schema, _object_list):
	print(" processing tables")
	make_directory_if_needed(_database) #create folder for this database unless it already exists
	tables = get_objects_for_schema('TABLES', _database, _schema) #get the tables for the schema
	for table in tables: 	#for each table in the schema...
		print(" ... %s" % table)
		if "MVW_" in table:
			print("		creating sql script to materialize view")
			sql_to_create_mvw = create_materialized_view_sql(_database, _schema, table)
			write_sql_to_file(_database, _schema, table, sql_to_create_mvw)
			_object_list.append(dot_combine(_database,_schema,table))
		else:
			print("		skipped b/c not like MVW_ ") 
	print ("done materialized views!")
	return _object_list

def create_materialized_view_sql(_database, _schema, _object):
	table = dot_combine(_database, _schema, _object)
	view = table.replace('MVW_','VW_')
	sql = 'DROP TABLE IF EXISTS '+table+';\n'
	sql += 'CREATE TABLE '+table+' AS SELECT * FROM '+view+';'
	return sql

def dot_combine(*args):
    return '.'.join(i if i is not None else '' for i in args)

def parse_object_to_parts(_object):
	return _object.split('.')

def get_object_script(_item, _mode):
	database, schema, object = parse_object_to_parts(_item)
	directory = build_directory(database)
	fullpath = directory + '/' + _item + '.sql'
	with codecs.open(fullpath, _mode, encoding='utf-8') as file:
		#string = file.read().replace('\n', ' ')
		string = file.read()
	return string

def read_file(_full_path_to_file):
	with codecs.open(_full_path_to_file, 'r', encoding='utf-8') as file:
		#data = file.read().replace('\n', ' ')
		data = file.read()
	return data

'''
	This assumes that the _list list contains _item
'''
def upsort_downstream_dependencies(_list, _item, _sql, _change_count):
	for element in _list:
		#print("	... processing %s" % element)
		if _item == element: 
			continue #skip self
		if 'VW_MONTHTABLE' in _item:
			continue #skip the month tables, don't need to sort against them
		current_item_index = _list.index(_item)
		database, schema, object = parse_object_to_parts(element)
		if _sql.find(object) != -1: #the given item is contained in the SQL!
			current_element_index = _list.index(element)

			#print("		Dependency index: %s" % current_element_index)
			#print("		Item index: %s" % current_item_index)

			if current_element_index > current_item_index:
				print("		Found a dependency!")
				print("		" + element)
				print("		Resorting")
				_change_count += 1;
				_list.insert(current_item_index, _list.pop(current_element_index))
				current_item_index = _list.index(_item)
	return _list, _change_count 

def sort_to_remove_dependency_conflicts(_object_list):
	print("Sorting the objects to remove dependencies...")
	total_changes_made = 1
	iterations = 0
	while total_changes_made > 0 :
		total_changes_made = 0
		for item in _object_list:
			changes_made = 0
			print("\n")
			print("	Trying to find a home for %s" % item)
			sql_to_make = get_object_script(item, 'r')
			_object_list, changes_made = upsort_downstream_dependencies(_object_list, item, sql_to_make, changes_made)
			total_changes_made += changes_made
			#print("Iteration changes: %s, Item changes :%s" %(total_changes_made, changes_made) )
		iterations += 1
		print("Iteration: %s" % iterations)
	print("All done!")
	return _object_list

def write_object_list_to_file(_object_list):
	f = get_ordered_object_file('w')
	#f.write(_object_list)
	for item in _object_list:
		f.write(item)
		f.write("\n")
	return f.close()

def get_file(_filename,_mode):
	#cwd = sys.path[0]
	#fullpath = cwd + '/' + _filename
	return open(_filename,_mode)

def get_ordered_object_file(_mode):
	cwd = sys.path[0]
	fullpath = cwd + '/deploy_order.txt'
	return open(fullpath,_mode)

def get_deployment_script_file(_mode):
	cwd = sys.path[0]
	fullpath = cwd + '/deployment_script.sql'
	return open(fullpath,_mode)

def get_staging_script_file(_mode):
	cwd = sys.path[0]
	fullpath = cwd + '/staging_script.sql'
	return open(fullpath,_mode)

def create_deployment_script():
	input_file = get_ordered_object_file('r')
	output_file = get_deployment_script_file('w')
	object_list = [line.rstrip('\n') for line in input_file]
	write_drop_statements(object_list, output_file)
	write_create_statements(object_list, output_file)
	#write_grant_statements(ouput_file)
	input_file.close()
	output_file.close()
	return 

def write_drop_statements(_list, _output):
	_output.write('/* drop objects */\n')
	for item in _list:
		if 'MVW_' in item:
			type = 'TABLE'
		else:
			type = 'VIEW'
		statement = 'DROP '+type+' IF EXISTS '+item+';\n'
		_output.write(statement)
	_output.write("\n\n")
	print("drop statements done!")

	return

def write_create_statements(_list, _output):
	_output.write('/* create objects in order */\n')
	for item in _list:
		sql_to_create = get_object_script(item, 'r')
		#print(sql_to_create)
		_output.write(sql_to_create.encode('utf-8'))
		_output.write("\n\n")
	print("create statements done!")
	_output.write("\n\n")
	return

def commit_into_gitlab():
	the_time = time.strftime('%Y-%m-%d %T', time.gmtime())
	message = "automatic commit made at "+the_time
	comment = 'git commit -a -m "'+message+'"'
	#print(comment)
	return subprocess.check_output([comment])

def sanity_check_length_of_object_list(_list):
	length = len(_list)
	if length < 15:
		raise ValueError('Expected >=15 objects to be discovered in the refresh but only found',length)
	return

def create_staging_script():
	ordered_objects = get_ordered_object_file('r') #get replacement reject
	object_list = [line.rstrip('\n') for line in ordered_objects]
	output_file = get_file(sys.path[0]+'/staging_script.sql','w')
	deployment_script = get_file(sys.path[0]+'/deployment_script.sql','r')
	lines = [line for line in deployment_script] 
	#print(lines)

	for line in lines:
		#print(line)
		for element in object_list:
			unquoted_swapped_element = element.replace('.PNMAC.','.STAGE.')
			line = line.replace(element,unquoted_swapped_element)

			quoted_element = '"' + ('"."').join(element.split('.')) + '"'
			quoted_swap_element = quoted_element.replace('."PNMAC".','."STAGE".')
			#print(quoted_element)
			#print(quoted_swap_element)
			line = line.replace(quoted_element,quoted_swap_element)

		output_file.write(line)
	output_file.close()
	return

'''
TODO
	-log into gitlab 
	-commit into gitlab
	-Grant ownership at end of deployment for both tables and views for each schema!
		GRANT OWNERSHIP ON { objectType <object_name> | ALL schemaObjectsType IN SCHEMA <schema_name> }
   		TO ROLE TBALL_R
'''

##set current location to where script is located!
abspath = os.path.abspath(__file__)
dname = os.path.dirname(abspath)
os.chdir(dname)

##write list of objects
object_list = get_relevant_database_objects()
sanity_check_length_of_object_list(object_list)
object_list = sort_to_remove_dependency_conflicts(object_list)
write_object_list_to_file(object_list)

##create deployment scripts
create_deployment_script()
create_staging_script()





	

	



