#!/usr/bin/ruby -w
system 'clear' unless ENV['clear_done']
require_relative '../testing.lib.rb'

# enable taint mode
$SAFE = 1

# purpose: test the table traces
#	trace_id
#		check id format
#	init_time
#		check default value
#		check date format

# reset directory
# UtilibaseTesting.reset_db_dir()

# create and initialize database file
db_file = Utilibase::Utils.randword() + '.utilibase'
dbh = Utilibase::DBH.create_db_file($ut_testing['test_dir'], db_file)
Utilibase.initialize_db(dbh)

# verbosify
puts UtilibaseTesting.db_path(db_file)


# config
table_name = 'traces'


#------------------------------------------------------------------------------
# structure: trace_id
#
if true
	Testmin.hr 'structure: trace_id'
	field_name = 'trace_id'
	
	UtilibaseTesting.field_structure(
		dbh,           # dbh
		table_name,    # table name
		field_name,    # field name
		1,             # pk
		'text',        # type
		1,             # 1 if not null, 0 if nullable
		nil)           # default
end
#
# structure: trace_id
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# init_time: trace_id
#
if true
	Testmin.hr 'structure: init_time'
	
	UtilibaseTesting.field_structure(
		dbh,                  # dbh
		table_name,           # table name
		'init_time',          # field name
		0,                    # pk
		'timestamp',          # type
		1,                    # 1 if not null, 0 if nullable
		'current_timestamp')  # default
end
#
# init_time: trace_id
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# init_time: default
#
if true
	Testmin.hr 'init_time: default'
	
	# generate trace_id
	trace_id = SecureRandom.uuid()
	
	# create record
	sql = 'insert into traces(trace_id) values (:id)'
	dbh.execute_batch(sql, 'id'=>trace_id)
	
	# get record
	sql = 'select * from traces where trace_id=:id'
	row = dbh.get_first_row(sql, 'id'=>trace_id)
	
	# check pattern of init_time
	if not row['init_time'].match(/\A\d{4}\-\d{2}\-\d{2}T\d{2}:\d{2}:\d{2}\+\d{2}\.\d{3}Z\z/)
		raise 'init time did not match standard time pattern'
	end
end
#
# init_time: init_time: default
#------------------------------------------------------------------------------


# done
# puts '[done]'
Testmin.done()
