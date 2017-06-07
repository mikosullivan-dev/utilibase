#!/usr/bin/ruby -w
system 'clear' unless ENV['clear_done']
require_relative '../testing.lib.rb'


# enable taint mode
$SAFE = 1

# purpose: test the update_stat field
# must be 'n' or null
# must be indexed by history_update_stat

# reset directory
# UtilibaseTesting.reset_db_dir()

# create and initialize database file
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
	Testmin.hr('structure')
	
	# field structure
	UtilibaseTesting.field_structure(
		dbh,            # dbh
		table_name,     # table name
		'update_stat',  # field name
		0,              # pk
		'text',         # type
		0,              # 1 if not null, 0 if nullable
		"'n'")          # default
end
#
# structure
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# index: history_update_stat
#
if true
	Testmin.hr('history_update_stat')
	
	# check
	UtilibaseTesting.check_index(
		dbh,                    # dbh
		table_name,             # table_name
		'history_update_stat',  # index name
		0,                      # 1 for unique, 0 for non-unique
		0,                      # partial
		['update_stat'],        # columns in index
	)
end
#
# index: history_update_stat
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# null is ok
#
if true
	puts '--- null is ok -----------------------------------------------------'
	
	# sql
	sql = <<~SQL
	insert into
		history(  version_id,   record_id,   jhash,  links,  ts_start,   ts_end,   update_stat   )
		values (  :version_id,  :record_id,  '{}',   '',     :ts_start,  :ts_end,  :update_stat  )
	SQL
	
	# run
	dbh.execute_batch(
		sql,
		'version_id'=>SecureRandom.uuid(),
		'record_id'=>SecureRandom.uuid(),
		'ts_start'=>'2017-03-23T04:04:18+18.098Z',
		'ts_end'=>'2017-03-24T04:04:18+18.098Z',
		'update_stat' => nil,
	)
end
#
# null is ok
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# n is ok
#
if true
	puts '--- n is ok --------------------------------------------------------'
	
	# sql
	sql = <<~SQL
	insert into
		history(  version_id,   record_id,   jhash,  links,  ts_start,   ts_end,   update_stat   )
		values (  :version_id,  :record_id,  '{}',   '',     :ts_start,  :ts_end,  :update_stat  )
	SQL
	
	# run
	dbh.execute_batch(
		sql,
		'version_id'=>SecureRandom.uuid(),
		'record_id'=>SecureRandom.uuid(),
		'ts_start'=>'2017-03-23T04:04:18+18.098Z',
		'ts_end'=>'2017-03-24T04:04:18+18.098Z',
		'update_stat' => 'n',
	)
end
#
# n is ok
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# default is ok
#
if true
	puts '--- default is ok --------------------------------------------------'
	
	# sql
	sql = <<~SQL
	insert into
		history(  version_id,   record_id,   jhash,  links,  ts_start,   ts_end   )
		values (  :version_id,  :record_id,  '{}',   '',     :ts_start,  :ts_end  )
	SQL
	
	# run
	dbh.execute_batch(
		sql,
		'version_id'=>SecureRandom.uuid(),
		'record_id'=>SecureRandom.uuid(),
		'ts_start'=>'2017-03-23T04:04:18+18.098Z',
		'ts_end'=>'2017-03-24T04:04:18+18.098Z',
	)
end
#
# default is ok
#------------------------------------------------------------------------------



#------------------------------------------------------------------------------
# anything else is error
#
if true
	puts '--- anything else is error ------------------------------------------'
	
	# check
	begin
		# sql
		sql = <<~SQL
		insert into
			history(  version_id,   record_id,   jhash,  links,  ts_start,   ts_end,   update_stat   )
			values (  :version_id,  :record_id,  '{}',   '',     :ts_start,  :ts_end,  :update_stat  )
		SQL
		
		# run
		dbh.execute_batch(
			sql,
			'version_id'=>SecureRandom.uuid(),
			'record_id'=>SecureRandom.uuid(),
			'ts_start'=>'2017-03-23T04:04:18+18.098Z',
			'ts_end'=>'2017-03-24T04:04:18+18.098Z',
			'update_stat' => 'u',
		)
		
		# should not get this far
		raise 'should have gotten exception'
	rescue Exception => e
		UtilibaseTesting.exception_message('anything else is error', e, 'CHECK constraint failed: history')
	end
end
#
# anything else is error
#------------------------------------------------------------------------------


# done
# puts '[done]'
Testmin.done()
