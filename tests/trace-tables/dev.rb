#!/usr/bin/ruby -w
system 'clear' unless ENV['clear_done']
require_relative '../testing-lib.rb'

# enable taint mode
$SAFE = 1

# purpose: test the table trace_records
#	trace_uuid references record in traces
#	record_uuid references record in current
#	trace_uuid and record_uuid are unique

# reset directory
UtilibaseTesting.reset_db_dir()

# create and initialize database file
db_file = Utilibase::Utils.randword() + '.utilibase'
dbh = Utilibase::DBH.create_db_file(UtilibaseTesting.db_dir(), db_file)
Utilibase.initialize_db(dbh)

# verbosify
puts UtilibaseTesting.db_path(db_file)

# config
table_name = 'trace_records'

# foreign keys
UtilibaseTesting.check_foreign_key(
	dbh,            # dbh
	table_name,     # source table
	'current',      # target table
	'record_uuid',  # source field
	'record_uuid',  # target field
	'CASCADE'       # on delete
)

# done
puts '[done]'
