#!/usr/bin/ruby -w
system 'clear' unless ENV['clear_done']
require_relative '../testing-lib.rb'

# enable taint mode
$SAFE = 1

# purpose: test the dependency field
# d defaults to d
# d can not be null
# d must be only i, d, or m

# reset directory
UtilibaseTesting.reset_db_dir()

# create, initialize, instantiate database
db = UtilibaseTesting.new_db()
dbh = db.dbh

# table name
table_name = 'current'

#------------------------------------------------------------------------------
# structure
#
if true
	TestMin.hr 'structure'
	
	# field structure
	UtilibaseTesting.field_structure(
		dbh,           # dbh
		table_name,    # table name
		'dependency',  # field name
		0,             # pk
		'text',        # type
		1,             # 1 if not null, 0 if nullable
		"'d'")         # default
end
#
# structure
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# index: current_dependency
#
if true
	TestMin.hr 'index: current_dependency'
	
	# check
	UtilibaseTesting.check_index(
		dbh,                   # dbh
		table_name,            # table_name
		'current_dependency',  # index name
		0,                     # 1 for unique, 0 for non-unique
		0,                     # partial
		['dependency'],        # columns in index
	)
end
#
# index: current_dependency
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# defaults to d
#
if true
	TestMin.hr 'defaults to d'
	
	# generate uuid
	record_uuid = SecureRandom.uuid()
	
	# add record
	sql = "insert into current(record_uuid, jhash, links) values(:uuid, '{}', '')"
	dbh.execute_batch(sql, 'uuid'=>record_uuid)
	
	# get record
	sql = "select * from current where record_uuid=:uuid"
	record = dbh.get_first_row(sql, record_uuid);
	UtilibaseTesting.comp( 'default value', record['dependency'], 'd' )

end
#
# defaults to d
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# must be only i, d, or m
#
if true
	TestMin.hr 'must be only i, d, or m'
	
	# check
	begin
		sql = "insert into current(record_uuid, jhash, links, dependency) values(:uuid, '{}', '', 'x')"
		dbh.execute_batch(sql, 'uuid'=>SecureRandom.uuid())
		raise 'should have gotten exception'
	rescue Exception => e
		# puts e.message
		UtilibaseTesting.exception_message('must be only i, d, or m', e, 'CHECK constraint failed: current')
	end
end
#
# must be only i, d, or m
#------------------------------------------------------------------------------



#------------------------------------------------------------------------------
# if dependency is 'm' then links must be ''
#
if true
	TestMin.hr "if dependency is 'm' then links must be ''"
	
	# check
	begin
		sql = "insert into current(record_uuid, jhash, links, dependency) values(:ruuid, '{}', :luuids, 'm')"
		dbh.execute_batch(
			sql,
			'ruuid'=>SecureRandom.uuid(),
			'luuids'=>SecureRandom.uuid(),
		)
		
		# should not get this far
		raise 'should have gotten exception'
	rescue Exception => e
		# puts e.message
		UtilibaseTesting.exception_message(
			"if dependency is 'm' then links must be ''",
			e,
			'CHECK constraint failed: dependency_and_links',
		)
	end
end
#
# if dependency is 'm' then links must be ''
#------------------------------------------------------------------------------



# done
# puts '[done]'
TestMin.done()
