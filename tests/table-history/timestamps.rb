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


#------------------------------------------------------------------------------
# ts_start: format
#
if true
	Testmin.hr 'ts_start: format'
	
	# check
	begin
		# sql
		sql = <<~SQL
		insert into
			history( version_uuid,  record_uuid,  jhash, links, ts_start,  ts_end  )
			values ( :version_uuid, :record_uuid, '{}',  '',    :ts_start, :ts_end )
		SQL
		
		# run
		dbh.execute_batch(
			sql,
			'version_uuid'=>SecureRandom.uuid(),
			'record_uuid'=>SecureRandom.uuid(),
			'ts_start'=>'xxx',
			'ts_end'=>'2017-03-24T04:04:18+18.098Z'
		)
		
		# should not get to this point
		raise 'should have gotten exception'
	rescue Exception => e
		# puts '------------------------------'
		# puts e.message
		# puts '------------------------------'
		
		UtilibaseTesting.exception_message('valid uuid', e, 'CHECK constraint failed: history')
	end
end
#
# ts_start: format
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# ts_end: format
#
if true
	Testmin.hr 'ts_end: format'
	
	# check
	begin
		# sql
		sql = <<~SQL
		insert into
			history( version_uuid,  record_uuid,  jhash, links, ts_start,  ts_end  )
			values ( :version_uuid, :record_uuid, '{}',  '',    :ts_start, :ts_end )
		SQL
		
		# run
		dbh.execute_batch(
			sql,
			'version_uuid'=>SecureRandom.uuid(),
			'record_uuid'=>SecureRandom.uuid(),
			'ts_start'=>'2017-03-24T04:04:18+18.098Z',
			'ts_end'=>'xxx'
		)
		
		# should not get to this point
		raise 'should have gotten exception'
	rescue Exception => e
		# puts '------------------------------'
		# puts e.message
		# puts '------------------------------'
		
		UtilibaseTesting.exception_message('valid uuid', e, 'CHECK constraint failed: history')
	end
end
#
# ts_end: format
#------------------------------------------------------------------------------

# done
# puts '[done]'
Testmin.done()
