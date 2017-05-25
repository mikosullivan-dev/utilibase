#!/usr/bin/ruby -w
system 'clear' unless ENV['clear_done']
require_relative '../testing.lib.rb'

# enable taint mode
$SAFE = 1

# purpose: test the record object
#	instantiate object
#	save new record
#	update existing record

# reset directory
UtilibaseTesting.reset_db_dir()

# create, initialize, instantiate database
db = UtilibaseTesting.new_db()
dbh = db.dbh

# create record object
rcrd = Utilibase::Record.new(db, SecureRandom.uuid())

# uuids
uuids = [SecureRandom.uuid(), SecureRandom.uuid()]

# call in_db
in_db = rcrd.in_db()
UtilibaseTesting.bool('in_db', in_db, false)

# build org
struct = {
	'$uuid'=>rcrd.uuid,
	'x'=>1,
	'z'=>'original z value',
	'y'=>[ {'$uuid'=>uuids[0]}, {'$uuid'=>uuids[1]} ],
}

# save new record
rcrd.save(struct)

# TESTING
puts 'after save'

# get new record
sql = 'select * from current where record_uuid=:uuid'
updated = dbh.get_first_row(sql, 'uuid'=>rcrd.uuid)
jhash = updated['jhash']
jhash = JSON.parse(jhash)

# update_stat should be n
UtilibaseTesting.comp('uuid', updated['update_stat'], 'n')

# set a field or fields
rcrd.update(struct)

# get updated record
sql = 'select * from current where record_uuid=:uuid'
updated = dbh.get_first_row(sql, 'uuid'=>rcrd.uuid)
jhash = updated['jhash']
jhash = JSON.parse(jhash)

# update_stat should still be n
UtilibaseTesting.comp('uuid', updated['update_stat'], 'n')

# check
UtilibaseTesting.comp('uuid', jhash['$uuid'], rcrd.uuid)
UtilibaseTesting.comp('y uuid 0', struct['y'][0]['$uuid'], uuids[0])
UtilibaseTesting.comp('y uuid 1', struct['y'][1]['$uuid'], uuids[1])

# update again
# uuid should not change
struct = { 'x'=>2, '$uuid'=>SecureRandom.uuid() }
rcrd.update(struct)

# get updated record
sql = 'select * from current where record_uuid=:uuid'
updated = dbh.get_first_row(sql, 'uuid'=>rcrd.uuid)
jhash = updated['jhash']
jhash = JSON.parse(jhash)

# update_stat should still be n
UtilibaseTesting.comp('uuid', updated['update_stat'], 'n')

# check
UtilibaseTesting.comp('uuid', jhash['$uuid'], rcrd.uuid)
UtilibaseTesting.comp('x', jhash['x'], 2)

# get single value
struct = rcrd.get_fields('x')
UtilibaseTesting.comp_hash('get single value', struct, {'x'=>2})

# get multiple values
struct = rcrd.get_fields(['x', 'z'])
UtilibaseTesting.comp_hash('get single value', struct, {'x'=>2, 'z'=>'original z value'})

# append to array
struct = { 'y'=>[{'$array'=>true, 'add-to-ending'=>true}, 'add to ending'] }
rcrd.update(struct)

# get updated record
sql = 'select * from current where record_uuid=:uuid'
updated = dbh.get_first_row(sql, 'uuid'=>rcrd.uuid)
jhash = updated['jhash']
jhash = JSON.parse(jhash)

# check
UtilibaseTesting.comp('add to ending', jhash['y'][2], 'add to ending')
UtilibaseTesting.comp('uuid', updated['update_stat'], 'n')

# manually change record
sql = "update current set update_stat=null where record_uuid=:uuid"
db.dbh.execute(sql, 'uuid'=>rcrd.uuid)

# update record using record object
TestMin.hr('update record using record object')
struct = {'z'=>'z value'}
rcrd.update(struct)

# get updated record
sql = 'select * from current where record_uuid=:uuid'
updated = dbh.get_first_row(sql, 'uuid'=>rcrd.uuid)
UtilibaseTesting.comp('update', updated['update_stat'], 'u')

# check jhash
TestMin.hr('check jhash')
jhash = rcrd.get_jhash()
UtilibaseTesting.comp('add to ending', jhash['y'][2], 'add to ending')
UtilibaseTesting.comp('add to ending', jhash['z'], 'z value')

# set record to not updated
TestMin.hr('set record to not updated')
sql = 'update current set update_stat=null where record_uuid=:uuid'
db.dbh.execute(sql, 'uuid'=>rcrd.uuid)

# get record object again
rcrd = Utilibase::Record.new(db, rcrd.uuid)

# update record
struct = {'z'=>'new z value'}
rcrd.update(struct)

# get updated record
sql = 'select * from current where record_uuid=:uuid'
updated = dbh.get_first_row(sql, 'uuid'=>rcrd.uuid)
jhash = updated['jhash']
jhash = JSON.parse(jhash)
UtilibaseTesting.comp('update new record', jhash['z'], 'new z value')
UtilibaseTesting.comp('update', updated['update_stat'], 'u')

# history table should have old copy of record
TestMin.hr('history table should have old copy of record')
sql = 'select jhash from history where record_uuid=:uuid'
historical = dbh.get_first_row(sql, 'uuid'=>rcrd.uuid)
historical_jhash = historical['jhash']
historical_jhash = JSON.parse(historical_jhash)
UtilibaseTesting.comp('historical record', historical_jhash['z'], 'original z value')

# done
# puts '[done]'
TestMin.done()
