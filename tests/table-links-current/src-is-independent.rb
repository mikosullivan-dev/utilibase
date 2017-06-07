#!/usr/bin/ruby -w
system 'clear' unless ENV['clear_done']
require_relative '../testing.lib.rb'

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
	Testmin.hr 'structure'
	
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
	Testmin.hr 'not null'
	
	# generate some ids
	valid_ids = [SecureRandom.uuid(), SecureRandom.uuid()]
	
	# create records in current
	sql = "insert into current(record_id, jhash, links) values(:valid0, '{}', '')"
	dbh.execute(sql, {'valid0'=>valid_ids[0]})
	sql = "insert into current(record_id, jhash, links) values(:valid1, '{}', '')"
	dbh.execute(sql, {'valid1'=>valid_ids[1]})
	
	# create link record with null src_is_independent
	begin
		sql = "insert into links_current(src_id, src_is_independent, tgt_id) values(:valid0, null, :valid1)"
		qty = dbh.execute(sql, {'valid0'=>valid_ids[0], 'valid1'=>valid_ids[1]})
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
	Testmin.hr '0 or 1'
	
	# generate some ids
	valid_ids = [SecureRandom.uuid(), SecureRandom.uuid()]
	
	# create records in current
	sql = "insert into current(record_id, jhash, links) values(:valid0, '{}', '')"
	dbh.execute(sql, {'valid0'=>valid_ids[0]})
	sql = "insert into current(record_id, jhash, links) values(:valid1, '{}', '')"
	dbh.execute(sql, {'valid1'=>valid_ids[1]})
	
	# create link record with 2 as src_is_independent
	begin
		sql = "insert into links_current(src_id, src_is_independent, tgt_id) values(:valid0, 2, :valid1)"
		qty = dbh.execute(sql, {'valid0'=>valid_ids[0], 'valid1'=>valid_ids[1]})
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
Testmin.done()
