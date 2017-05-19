#!/usr/bin/ruby -w
system 'clear' unless ENV['clear_done']
require_relative '../testing-lib.rb'

# enable taint mode
$SAFE = 1

# purpose: test the unlinked field
# must be or or 1

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
field_name = 'unlinked'

#------------------------------------------------------------------------------
# structure
#
if true
	TestMin.hr 'structure'
	
	# field structure
	UtilibaseTesting.field_structure(
		dbh,         # dbh
		table_name,  # table name
		field_name,  # field name
		0,           # pk
		'text',      # type
		0,           # 1 if not null, 0 if nullable
		nil,         # default
	)
end
#
# structure
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# index: current_unlinked
#
if true
	TestMin.hr('current_unlinked')
	
	# check
	UtilibaseTesting.check_index(
		dbh,                 # dbh
		table_name,          # table_name
		'current_unlinked',  # index name
		0,                   # 1 for unique, 0 for non-unique
		0,                   # partial
		['unlinked']         # columns in index
	)
end
#
# index: current_update_stat
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# must be i or r
#
if true
	TestMin.hr('must be i or r')
	
	# check
	begin
		sql = "insert into current(record_uuid, jhash, links, unlinked) values(:uuid, '{}', '', 'x')"
		dbh.execute_batch(sql, 'uuid'=>SecureRandom.uuid())
		raise 'should have gotten exception'
	rescue Exception => e
		UtilibaseTesting.exception_message('must be i or r', e, 'CHECK constraint failed: current')
	end
end
#
# must be i or r
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# unlinked cannot be defined if dependency is i
#
if true
	TestMin.hr('unlinked cannot be defined if dependency is i')
	
	# check
	begin
		sql = "insert into current(record_uuid, jhash, links, dependency, unlinked) values(:uuid, '{}', '', 'i', 'i')"
		dbh.execute_batch(sql, 'uuid'=>SecureRandom.uuid())
		raise 'should have gotten exception'
	rescue Exception => e
		UtilibaseTesting.exception_message('must be i or r', e, 'CHECK constraint failed: dependency_and_unlinked')
	end
end
#
# unlinked cannot be defined if dependency is i
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# unlinked cannot be defined if dependency is m
#
if true
	TestMin.hr('unlinked cannot be defined if dependency is m')
	
	# check
	begin
		sql = "insert into current(record_uuid, jhash, links, dependency, unlinked) values(:uuid, '{}', '', 'm', 'i')"
		dbh.execute_batch(sql, 'uuid'=>SecureRandom.uuid())
		raise 'should have gotten exception'
	rescue Exception => e
		UtilibaseTesting.exception_message('must be i or r', e, 'CHECK constraint failed: dependency_and_unlinked')
	end
end
#
# unlinked cannot be defined if dependency is m
#------------------------------------------------------------------------------


# done
# puts '[done]'
TestMin.done()
