#!/usr/bin/ruby -w
require_relative '../testing.lib.rb'

# enable taint mode
$SAFE = 1

# purpose: test the table trace_records
#	trace_id references record in traces
#	record_id references record in current
#	trace_id and record_id are primary key

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
# structure: trace_id
#
if true
	Testmin.hr 'structure: trace_id'
	
	# field structure
	UtilibaseTesting.field_structure(
		dbh,             # dbh
		table_name,      # table name
		'trace_id',    # field name
		1,               # pk
		'text',          # type
		1,               # 1 if not null, 0 if nullable
		nil,             # default
	)
end
#
# structure: trace_id
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# structure: record_id
#
if true
	Testmin.hr 'structure: record_id'
	
	# field_structure(dbh, table_name, field_name, pk, type, notnull, default)
	UtilibaseTesting.field_structure(
		dbh,             # dbh
		table_name,      # table name
		'record_id',   # field name
		2,               # pk
		'text',          # type
		1,               # 1 if not null, 0 if nullable
		nil)             # default
	
	# foreign key: record_id
	UtilibaseTesting.check_foreign_key(
		dbh,            # dbh
		table_name,     # source table
		'current',      # target table
		'record_id',  # source field
		'record_id',  # target field
		'CASCADE'       # on delete
	)
	
	# foreign key: trace_id
	UtilibaseTesting.check_foreign_key(
		dbh,           # dbh
		table_name,    # source table
		'traces',      # target table
		'trace_id',  # source field
		'trace_id',  # target field
		'CASCADE'      # on delete
	)
end
#
# structure: record_id
#------------------------------------------------------------------------------


# done
# puts '[done]'
Testmin.done()
