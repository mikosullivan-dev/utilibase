#!/usr/bin/ruby -w
system 'clear' unless ENV['clear_done']
require_relative '../testing.lib.rb'


# enable taint mode
$SAFE = 1

# purpose: test the record_uuid field
# record_uuid
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

# table name
table_name = 'history'


#------------------------------------------------------------------------------
# structure
#
if true
	puts 'structure'
	
	# field structure
	UtilibaseTesting.field_structure(
		dbh,             # dbh
		table_name,      # table name
		'version_uuid',  # field name
		1,               # pk
		'text',          # type
		1,               # 1 if not null, 0 if nullable
		nil)             # default
end
#
# structure
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# valid uuid
#
if true
	puts 'valid uuid'
	
	# check
	begin
		# sql
		sql = <<~SQL
		insert into
			history( version_uuid,  record_uuid,  jhash, links, ts_start,  ts_end  )
			values ( :version_uuid, :record_uuid, '{}',  '',    :ts_start, :ts_end )
		SQL
		
		# run
		# NOTE: The supposed uuid in this statement isn't valid. Note the + in it.
		dbh.execute_batch(
			sql,
			'version_uuid'=>'7a00ffe9-70cb-4d73-8a83+d2394f493a1f',
			'record_uuid'=>SecureRandom.uuid(),
			'ts_start'=>'2017-03-23T04:04:18+18.098Z',
			'ts_end'=>'2017-03-24T04:04:18+18.098Z',
		)
		
		# should not get to this point
		raise 'should have gotten exception'
	rescue Exception => e
		# puts '----------------------------------'
		# puts e.message
		# puts '----------------------------------'
		
		UtilibaseTesting.exception_message('valid uuid', e, 'CHECK constraint failed: history')
	end
end
#
# valid uuid
#------------------------------------------------------------------------------



# done
# puts '[done]'
TestMin.done()
