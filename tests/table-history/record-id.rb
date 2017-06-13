#!/usr/bin/ruby -w
require_relative '../testing.lib.rb'


# enable taint mode
$SAFE = 1

# purpose: test the record_id field
# record_id
#	d required
#	d primary key
#	d not null

# reset directory
# UtilibaseTesting.reset_db_dir()

# create and initialize databse file
db_file = Utilibase::Utils.randword() + '.utilibase'
dbh = Utilibase::DBH.create_db_file($ut_testing['test_dir'], db_file)
Utilibase.initialize_db(dbh)

# verbosify
puts UtilibaseTesting.db_path(db_file)


# config
table_name = 'history'
field_name = 'record_id'


#------------------------------------------------------------------------------
# structure
#
if true
	Testmin.hr 'structure'
	
	# field structure
	UtilibaseTesting.field_structure(
		dbh,            # dbh
		table_name,     # table name
		'record_id',  # field name
		0,              # pk
		'text',         # type
		1,              # 1 if not null, 0 if nullable
		nil)            # default
end
#
# structure
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# index: history_record_id
#
if true
	Testmin.hr 'index: history_record_id'
	index_name = 'history_record_id'
	column_count = 1

	# check
	UtilibaseTesting.check_index(
		dbh,                    # dbh
		table_name,             # table_name
		'history_record_id',    # index name
		0,                      # 1 for unique, 0 for non-unique
		0,                      # partial
		['record_id'],          # columns in index
	)
end
#
# index: history_record_id
#------------------------------------------------------------------------------


# done
# puts '[done]'
Testmin.done()
