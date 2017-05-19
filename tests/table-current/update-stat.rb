#!/usr/bin/ruby -w
system 'clear' unless ENV['clear_done']
require_relative '../testing-lib.rb'


# enable taint mode
$SAFE = 1

# purpose: test the update_stat field
# must be nil, n, or u

# reset directory
# UtilibaseTesting.reset_db_dir()

# create and initialize database file
db_file = Utilibase::Utils.randword() + '.utilibase'
dbh = Utilibase::DBH.create_db_file($ut_testing['test_dir'], db_file)
Utilibase.initialize_db(dbh)

# verbosify
puts UtilibaseTesting.db_path(db_file)

# table_name
table_name = 'current'


#------------------------------------------------------------------------------
# structure
#
if true
	TestMin.hr 'structure'
	
	# field structure
	UtilibaseTesting.field_structure(
		dbh,            # dbh
		table_name,     # table name
		'update_stat',  # field name
		0,              # pk
		'text',         # type
		0,              # 1 if not null, 0 if nullable
		nil)            # default
end
#
# structure
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# index: current_update_stat
#
if true
	TestMin.hr('current_update_stat')
	
	# check
	UtilibaseTesting.check_index(
		dbh,                    # dbh
		table_name,             # table_name
		'current_update_stat',  # index name
		0,                      # 1 for unique, 0 for non-unique
		0,                      # partial
		['update_stat']         # columns in index
	)
end
#
# index: current_update_stat
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# index: current_record_uuid_update_stat
#
if true
	TestMin.hr('current_record_uuid_update_stat')
	
	# check
	UtilibaseTesting.check_index(
		dbh,                                # dbh
		table_name,                         # table_name
		'current_record_uuid_update_stat',  # index name
		0,                                  # 1 for unique, 0 for non-unique
		0,                                  # partial
		['record_uuid', 'update_stat']      # columns in index
	)
end
#
# index: current_record_uuid_update_stat
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# must be nil, n, or u
#
if true
	TestMin.hr 'must be nil, n, or u'
	
	# check
	begin
		sql = "insert into current(record_uuid, jhash, links, update_stat) values(:uuid, '{}', '', 'c')"
		dbh.execute_batch(sql, 'uuid'=>SecureRandom.uuid())
		raise 'should have gotten exception'
	rescue Exception => e
		UtilibaseTesting.exception_message('must be nil, n, or u', e, 'CHECK constraint failed: current')
	end
end
#
# must be nil, n, or u
#------------------------------------------------------------------------------


# done
# puts '[done]'
TestMin.done()
