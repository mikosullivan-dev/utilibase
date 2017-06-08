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
		'version_id',  # field name
		1,               # pk
		'text',          # type
		1,               # 1 if not null, 0 if nullable
		nil)             # default
end
#
# structure
#------------------------------------------------------------------------------





# done
# puts '[done]'
Testmin.done()
