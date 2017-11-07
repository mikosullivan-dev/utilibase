#!/usr/bin/ruby -w
require_relative '../testing.lib.rb'


# enable taint mode
$SAFE = 1

# purpose: test the jhash field
#	required
#	not primary key
#	not null
#	starts with {
#	ends with }

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
		sql = "insert into history(version_id, record_id, jhash, links) values(:version_id, :record_id, null, '')"
		dbh.execute_batch(sql, 'version_id'=>SecureRandom.uuid(), 'record_id'=>SecureRandom.uuid())
		raise 'should have gotten exception'
	rescue StandardError => e
		# puts '-------------------'
		# puts e.message
		# puts '-------------------'
		UtilibaseTesting.exception_message('starts with {', e, 'NOT NULL constraint failed: history.jhash')
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
		sql = "insert into history(version_id, record_id, jhash, links) values(:version_id, :record_id, '}', '')"
		dbh.execute_batch(sql, 'version_id'=>SecureRandom.uuid(), 'record_id'=>SecureRandom.uuid())
		raise 'should have gotten exception'
	rescue StandardError => e
		UtilibaseTesting.exception_message('starts with {', e, 'CHECK constraint failed: history')
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
		sql = "insert into history(version_id, record_id, jhash, links) values(:version_id, :record_id, '{', '')"
		dbh.execute_batch(sql, 'version_id'=>SecureRandom.uuid(), 'record_id'=>SecureRandom.uuid())
		raise 'should have gotten exception'
	rescue StandardError => e
		UtilibaseTesting.exception_message('starts with {', e, 'CHECK constraint failed: history')
	end
end
#
# ends with }
#------------------------------------------------------------------------------



# done
# puts '[done]'
Testmin.done()
