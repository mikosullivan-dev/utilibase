#!/usr/bin/ruby -w
system 'clear' unless ENV['clear_done']
require_relative '../testing.lib.rb'

# enable taint mode
$SAFE = 1

# purpose: test the table traces
#	trace_uuid
#		check uuid format
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
# structure: trace_uuid
#
if true
	TestMin.hr 'structure: trace_uuid'
	field_name = 'trace_uuid'
	
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
# structure: trace_uuid
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# trace_uuid: uuid format
#
if true
	TestMin.hr 'trace_uuid: uuid format'
	
	# check
	begin
		# sql
		sql = <<~SQL
		insert into
			traces( trace_uuid  )
			values ( :uuid )
		SQL
		
		# run
		dbh.execute_batch(
			sql,
			'uuid'=>'xxx'
		)
		
		# should not get to this point
		raise 'should have gotten exception'
	rescue Exception => e
		# puts '------------------------------'
		# puts e.message
		# puts '------------------------------'
		
		UtilibaseTesting.exception_message('valid uuid', e, 'CHECK constraint failed: traces')
	end
end
#
# trace_uuid: uuid format
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# init_time: trace_uuid
#
if true
	TestMin.hr 'structure: init_time'
	
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
# init_time: trace_uuid
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# init_time: default
#
if true
	TestMin.hr 'init_time: default'
	
	# generate trace_uuid
	trace_uuid = SecureRandom.uuid()
	
	# create record
	sql = 'insert into traces(trace_uuid) values (:uuid)'
	dbh.execute_batch(sql, 'uuid'=>trace_uuid)
	
	# get record
	sql = 'select * from traces where trace_uuid=:uuid'
	row = dbh.get_first_row(sql, 'uuid'=>trace_uuid)
	
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
TestMin.done()
