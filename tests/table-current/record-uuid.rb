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
table_name = 'current'

#------------------------------------------------------------------------------
# structure
#
if true
	TestMin.hr 'structure'
	
	# field_structure(dbh, table_name, field_name, pk, type, notnull, default)
	UtilibaseTesting.field_structure(
		dbh,             # dbh
		table_name,      # table name
		'record_uuid',    # field name
		1,               # pk
		'text',          # type
		1,               # 1 if not null, 0 if nullable
		nil)             # default
end
#
# structure
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# uuid format
#
if true
	TestMin.hr 'uuid format'
	
	# check
	begin
		sql = "insert into current(record_uuid, jhash, links) values(:uuid, '{}', '')"
		
		# NOTE: The supposed uuid in this statement isn't valid. Note the + in it.
		dbh.execute_batch(sql, 'uuid'=>'7a00ffe9-70cb-4d73-8a83+d2394f493a1f')
		raise 'should have gotten exception'
	rescue Exception => e
		# puts e.message
		UtilibaseTesting.exception_message('valid uuid', e, 'CHECK constraint failed: current')
	end
end
#
# uuid format
#------------------------------------------------------------------------------


# done
# puts '[done]'
TestMin.done()
