#!/usr/bin/ruby -w
system 'clear' unless ENV['clear_done']
require_relative '../testing.lib.rb'


# enable taint mode
$SAFE = 1

# purpose: test the timestamp fields
#	ts_start: check date format
#	ts_end: must be nil

# reset directory
# UtilibaseTesting.reset_db_dir()

# create and initialize database file
db_file = Utilibase::Utils.randword() + '.utilibase'
dbh = Utilibase::DBH.create_db_file($ut_testing['test_dir'], db_file)
Utilibase.initialize_db(dbh)

# verbosify
puts UtilibaseTesting.db_path(db_file)

# table name
table_name = 'current'

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
# index: current_ts_start
#
if true
	Testmin.hr 'index: current_ts_start'
	
	# check
	UtilibaseTesting.check_index(
		dbh,                  # dbh
		table_name,           # table_name
		'current_ts_start',   # index name
		0,                    # 1 for unique, 0 for non-unique
		0,                    # partial
		['ts_start'],         # columns in index
	)
end
#
# index: current_ts_start
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# structure: ts_end
#
if true
	Testmin.hr 'structure: ts_end'
	
	# field structure
	UtilibaseTesting.field_structure(
		dbh,           # dbh
		table_name,    # table name
		'ts_end',    # field name
		0,             # pk
		'text',        # type
		0,             # 1 if not null, 0 if nullable
		nil)           # default
end
#
# structure: ts_end
#------------------------------------------------------------------------------



#------------------------------------------------------------------------------
# ts_start: format
#
if true
	Testmin.hr 'ts_start: format'
	
	# check
	begin
		sql = "insert into current(record_uuid, jhash, links, ts_start) values(:uuid, '{}', '', 'xxx')"
		dbh.execute_batch(sql, 'uuid'=>SecureRandom.uuid())
		raise 'should have gotten exception'
	rescue Exception => e
		# puts e.message
		UtilibaseTesting.exception_message('ts_start format', e, 'CHECK constraint failed: current')
	end
end
#
# ts_start: format
#------------------------------------------------------------------------------



#------------------------------------------------------------------------------
# ts_end: must be null
#
if true
	Testmin.hr 'ts_end: must be null'
	
	# check
	begin
		sql = "insert into current(record_uuid, jhash, links, ts_end) values(:uuid, '{}', '', '2017-03-24T04:04:18+18.098Z')"
		dbh.execute_batch(sql, 'uuid'=>SecureRandom.uuid())
		raise 'should have gotten exception'
	rescue Exception => e
		# puts e.message
		UtilibaseTesting.exception_message('valid uuid', e, 'CHECK constraint failed: current')
	end
end
#
# ts_end: must be null
#------------------------------------------------------------------------------


# done
# puts '[done]'
Testmin.done()
