#!/usr/bin/ruby -w
system 'clear' unless ENV['clear_done']
require_relative '../testing-lib.rb'

# enable taint mode
$SAFE = 1

# purpose: test the table trace_records
#	trace_uuid references record in traces
#	record_uuid references record in current
#	trace_uuid and record_uuid are primary key

# reset directory
UtilibaseTesting.reset_db_dir()

# create and initialize database file
db_file = Utilibase::Utils.randword() + '.utilibase'
dbh = Utilibase::DBH.create_db_file($ut_testing['test_dir'], db_file)
Utilibase.initialize_db(dbh)

# verbosify
puts UtilibaseTesting.db_path(db_file)

# config
table_name = 'trace_records'


#------------------------------------------------------------------------------
# structure: trace_uuid
#
if true
	TestMin.hr 'structure: trace_uuid'
	
	# field structure
	UtilibaseTesting.field_structure(
		dbh,             # dbh
		table_name,      # table name
		'trace_uuid',    # field name
		1,               # pk
		'text',          # type
		1,               # 1 if not null, 0 if nullable
		nil,             # default
	)
end
#
# structure: trace_uuid
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# structure: record_uuid
#
if true
	TestMin.hr 'structure: record_uuid'
	
	# field_structure(dbh, table_name, field_name, pk, type, notnull, default)
	UtilibaseTesting.field_structure(
		dbh,             # dbh
		table_name,      # table name
		'record_uuid',   # field name
		2,               # pk
		'text',          # type
		1,               # 1 if not null, 0 if nullable
		nil)             # default
	
	# foreign key: record_uuid
	UtilibaseTesting.check_foreign_key(
		dbh,            # dbh
		table_name,     # source table
		'current',      # target table
		'record_uuid',  # source field
		'record_uuid',  # target field
		'CASCADE'       # on delete
	)
	
	# foreign key: trace_uuid
	UtilibaseTesting.check_foreign_key(
		dbh,           # dbh
		table_name,    # source table
		'traces',      # target table
		'trace_uuid',  # source field
		'trace_uuid',  # target field
		'CASCADE'      # on delete
	)
end
#
# structure: record_uuid
#------------------------------------------------------------------------------


# done
# puts '[done]'
TestMin.done()
