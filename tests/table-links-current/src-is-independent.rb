#!/usr/bin/ruby -w
system 'clear' unless ENV['clear_done']
require_relative '../testing-lib.rb'

# enable taint mode
$SAFE = 1

# purpose: test src_is_independent
#	not null
#	0 or 1

# reset directory
UtilibaseTesting.reset_db_dir()

# create, initialize, instantiate database
db = UtilibaseTesting.new_db()
dbh = db.dbh

# table name
table_name = 'links_current'


#------------------------------------------------------------------------------
# structure
#
if true
	TestMin.hr 'structure'
	
	# field structure
	UtilibaseTesting.field_structure(
		dbh,                   # dbh
		table_name,            # table name
		'src_is_independent',  # field name
		0,                     # pk
		'boolean',             # type
		1,                     # 1 if not null, 0 if nullable
		nil)                   # default
end
#
# structure
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# not null
#
if true
	TestMin.hr 'not null'
	
	# generate some uuids
	valid_uuids = [SecureRandom.uuid(), SecureRandom.uuid()]
	
	# create records in current
	sql = "insert into current(record_uuid, jhash, links) values(:valid0, '{}', '')"
	dbh.execute(sql, {'valid0'=>valid_uuids[0]})
	sql = "insert into current(record_uuid, jhash, links) values(:valid1, '{}', '')"
	dbh.execute(sql, {'valid1'=>valid_uuids[1]})
	
	# create link record with null src_is_independent
	begin
		sql = "insert into links_current(src_uuid, src_is_independent, tgt_uuid) values(:valid0, null, :valid1)"
		qty = dbh.execute(sql, {'valid0'=>valid_uuids[0], 'valid1'=>valid_uuids[1]})
		raise 'should have gotten exception'
	rescue Exception => e
		# puts e.message
		UtilibaseTesting.exception_message('not null', e, 'NOT NULL constraint failed: links_current.src_is_independent')
	end
end
#
# not null
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# 0 or 1
#
if true
	TestMin.hr '0 or 1'
	
	# generate some uuids
	valid_uuids = [SecureRandom.uuid(), SecureRandom.uuid()]
	
	# create records in current
	sql = "insert into current(record_uuid, jhash, links) values(:valid0, '{}', '')"
	dbh.execute(sql, {'valid0'=>valid_uuids[0]})
	sql = "insert into current(record_uuid, jhash, links) values(:valid1, '{}', '')"
	dbh.execute(sql, {'valid1'=>valid_uuids[1]})
	
	# create link record with 2 as src_is_independent
	begin
		sql = "insert into links_current(src_uuid, src_is_independent, tgt_uuid) values(:valid0, 2, :valid1)"
		qty = dbh.execute(sql, {'valid0'=>valid_uuids[0], 'valid1'=>valid_uuids[1]})
		raise 'should have gotten exception'
	rescue Exception => e
		# puts e.message
		UtilibaseTesting.exception_message('not null', e, 'CHECK constraint failed: links_current')
	end
end
#
# 0 or 1
#------------------------------------------------------------------------------


# done
# puts '[done]'
TestMin.done()
