#!/usr/bin/ruby -w
system 'clear' unless ENV['clear_done']
require_relative '../testing.lib.rb'


# enable taint mode
$SAFE = 1

# purpose: test the record_id field
# record_id
#	d required
#	d primary key
#	d not null
#	d 36 characters long

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
		'history_record_id',  # index name
		0,                      # 1 for unique, 0 for non-unique
		0,                      # partial
		['record_id'],        # columns in index
	)
end
#
# index: history_record_id
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# valid id
#
if true
	Testmin.hr 'valid id'
	
	# check
	begin
		# sql
		sql = <<~SQL
		insert into
			history( version_id,  record_id,  jhash, links, ts_start,  ts_end  )
			values ( :version_id, :record_id, '{}',  '',    :ts_start, :ts_end )
		SQL
		
		# run
		# NOTE: The supposed id in this statement isn't valid. Note the + in it.
		dbh.execute_batch(
			sql,
			'version_id'=>SecureRandom.uuid(),
			'record_id'=>'7a00ffe9-70cb-4d73-8a83+d2394f493a1f',
			'ts_start'=>'2017-03-23T04:04:18+18.098Z',
			'ts_end'=>'2017-03-24T04:04:18+18.098Z',
		)
		
		# should not get to this point
		raise 'should have gotten exception'
	rescue Exception => e
		# puts '----------------------------------'
		# puts e.message
		# puts '----------------------------------'
		
		UtilibaseTesting.exception_message('valid id', e, 'CHECK constraint failed: history')
	end
end
#
# valid id
#------------------------------------------------------------------------------


# done
# puts '[done]'
Testmin.done()
