#!/usr/bin/ruby -w
system 'clear' unless ENV['clear_done']
require_relative '../testing.lib.rb'


# enable taint mode
$SAFE = 1

# purpose: test the jhash field
# record_uuid
#	d required
#	d not primary key
#	d not null
#	d starts with {
#	d ends with }

# reset directory
# UtilibaseTesting.reset_db_dir()

# create and initialize databse file
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
	puts 'structure'
	
	# field structure
	UtilibaseTesting.field_structure(
		dbh,           # dbh
		table_name,    # table name
		'jhash',       # field name
		0,             # pk
		'text',        # type
		1,             # 1 if not null, 0 if nullable
		nil)           # default
end
#
# structure
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# not null
#
if true
	puts 'not null'
	
	# check
	begin
		sql = "insert into current(record_uuid, jhash, links) values(:uuid, null, '')"
		dbh.execute_batch(sql, 'uuid'=>SecureRandom.uuid())
		raise 'should have gotten exception'
	rescue Exception => e
		UtilibaseTesting.exception_message('starts with {', e, 'NOT NULL constraint failed: current.jhash')
	end
end
#
# not null
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# starts with {
#
if true
	puts 'starts with {'
	
	# check
	begin
		sql = "insert into current(record_uuid, jhash, links) values(:uuid, '}', '')"
		dbh.execute_batch(sql, 'uuid'=>SecureRandom.uuid())
		raise 'should have gotten exception'
	rescue Exception => e
		UtilibaseTesting.exception_message('starts with {', e, 'CHECK constraint failed: current')
	end
end
#
# starts with {
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# ends with }
#
if true
	puts 'ends with }'
	
	# check
	begin
		sql = "insert into current(record_uuid, jhash, links) values(:uuid, '{', '')"
		dbh.execute_batch(sql, 'uuid'=>SecureRandom.uuid())
		raise 'should have gotten exception'
	rescue Exception => e
		UtilibaseTesting.exception_message('ends with }', e, 'CHECK constraint failed: current')
	end
end
#
# ends with }
#------------------------------------------------------------------------------



# done
# puts '[done]'
TestMin.done()
