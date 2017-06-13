#!/usr/bin/ruby -w
require_relative '../testing.lib.rb'

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
	Testmin.hr 'structure'
	
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
	Testmin.hr 'index: current_dependency'
	
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
	Testmin.hr 'defaults to d'
	
	# generate id
	record_id = SecureRandom.uuid()
	
	# add record
	sql = "insert into current(record_id, jhash, links) values(:id, '{}', '')"
	dbh.execute_batch(sql, 'id'=>record_id)
	
	# get record
	sql = "select * from current where record_id=:id"
	record = dbh.get_first_row(sql, record_id);
	UtilibaseTesting.comp( 'default value', record['dependency'], 'd' )

end
#
# defaults to d
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# must be only i, d, or m
#
if true
	Testmin.hr 'must be only i, d, or m'
	
	# check
	begin
		sql = "insert into current(record_id, jhash, links, dependency) values(:id, '{}', '', 'x')"
		dbh.execute_batch(sql, 'id'=>SecureRandom.uuid())
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
	Testmin.hr "if dependency is 'm' then links must be ''"
	
	# check
	begin
		sql = "insert into current(record_id, jhash, links, dependency) values(:rid, '{}', :lids, 'm')"
		dbh.execute_batch(
			sql,
			'rid'=>SecureRandom.uuid(),
			'lids'=>SecureRandom.uuid(),
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
Testmin.done()
