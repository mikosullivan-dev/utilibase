#!/usr/bin/ruby -w
system 'clear' unless ENV['clear_done']
require_relative '../testing-lib.rb'


# enable taint mode
$SAFE = 1

# purpose: test the links field
# record_uuid
#	d required
#	d not primary key
#	d not null
#	may be empty string -> handled in valid-entry.rb

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
		'links',       # field name
		0,             # pk
		'text',        # type
		1,             # 1 if not null, 0 if nullable
		nil)           # default
end
#
# structure
#------------------------------------------------------------------------------



# done
# puts '[done]'
TestMin.done()
