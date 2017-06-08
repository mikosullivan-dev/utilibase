#!/usr/bin/ruby -w
system 'clear' unless ENV['clear_done']
require_relative '../testing.lib.rb'


# enable taint mode
$SAFE = 1

# purpose: test the timestamp fields
#	ts_start: check date format
#	ts_end: check date format

# reset directory
UtilibaseTesting.reset_db_dir()

# create and initialize database file
db_file = Utilibase::Utils.randword() + '.utilibase'
dbh = Utilibase::DBH.create_db_file($ut_testing['test_dir'], db_file)
Utilibase.initialize_db(dbh)

# verbosify
puts UtilibaseTesting.db_path(db_file)


# config
table_name = 'history'


#------------------------------------------------------------------------------
# structure: ts_start
#
if true
	Testmin.hr 'structure: ts_start'
	
	# field structure
	UtilibaseTesting.field_structure(
		dbh,           # dbh
		table_name,    # table name
		'ts_start',    # field name
		0,             # pk
		'text',        # type
		0,             # 1 if not null, 0 if nullable
		nil)           # default
end
#
# structure: ts_start
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# index: history_ts_start
#
if true
	Testmin.hr 'index: history_ts_start'
	
	# check
	UtilibaseTesting.check_index(
		dbh,                  # dbh
		table_name,           # table_name
		'history_ts_start',   # index name
		0,                    # 1 for unique, 0 for non-unique
		0,                    # partial
		['ts_start'],         # columns in index
	)
end
#
# index: history_ts_start
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# structure: ts_end
#
if true
	Testmin.hr 'structure: ts_end'
	
	# field structure
	UtilibaseTesting.field_structure(
		dbh,          # dbh
		table_name,   # table name
		'ts_end',     # field name
		0,            # pk
		'text',       # type
		0,            # 1 if not null, 0 if nullable
		nil)          # default
end
#
# structure: ts_end
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# index: history_ts_end
#
if true
	Testmin.hr 'index: history_ts_end'
	# check
	UtilibaseTesting.check_index(
		dbh,                 # dbh
		table_name,          # table_name
		'history_ts_end',    # index name
		0,                   # 1 for unique, 0 for non-unique
		0,                   # partial
		['ts_end'],          # columns in index
	)
end
#
# index: history_ts_end
#------------------------------------------------------------------------------



# done
# puts '[done]'
Testmin.done()
