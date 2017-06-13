#!/usr/bin/ruby -w
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

# ids
ids = [SecureRandom.uuid(), SecureRandom.uuid()]

# call in_db
in_db = rcrd.in_db()
UtilibaseTesting.bool('in_db', in_db, false)

# build org
struct = {
	'$id'=>rcrd.id,
	'x'=>1,
	'z'=>'original z value',
	'y'=>[ {'$id'=>ids[0]}, {'$id'=>ids[1]} ],
}

# save new record
rcrd.save(struct)

# TESTING
puts 'after save'

# get new record
sql = 'select * from current where record_id=:id'
updated = dbh.get_first_row(sql, 'id'=>rcrd.id)
jhash = updated['jhash']
jhash = JSON.parse(jhash)

# update_stat should be n
UtilibaseTesting.comp('id', updated['update_stat'], 'n')

# set a field or fields
rcrd.update(struct)

# get updated record
sql = 'select * from current where record_id=:id'
updated = dbh.get_first_row(sql, 'id'=>rcrd.id)
jhash = updated['jhash']
jhash = JSON.parse(jhash)

# update_stat should still be n
UtilibaseTesting.comp('id', updated['update_stat'], 'n')

# check
UtilibaseTesting.comp('id', jhash['$id'], rcrd.id)
UtilibaseTesting.comp('y id 0', struct['y'][0]['$id'], ids[0])
UtilibaseTesting.comp('y id 1', struct['y'][1]['$id'], ids[1])

# update again
# id should not change
struct = { 'x'=>2, '$id'=>SecureRandom.uuid() }
rcrd.update(struct)

# get updated record
sql = 'select * from current where record_id=:id'
updated = dbh.get_first_row(sql, 'id'=>rcrd.id)
jhash = updated['jhash']
jhash = JSON.parse(jhash)

# update_stat should still be n
UtilibaseTesting.comp('id', updated['update_stat'], 'n')

# check
UtilibaseTesting.comp('id', jhash['$id'], rcrd.id)
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
sql = 'select * from current where record_id=:id'
updated = dbh.get_first_row(sql, 'id'=>rcrd.id)
jhash = updated['jhash']
jhash = JSON.parse(jhash)

# check
UtilibaseTesting.comp('add to ending', jhash['y'][2], 'add to ending')
UtilibaseTesting.comp('id', updated['update_stat'], 'n')

# manually change record
sql = "update current set update_stat=null where record_id=:id"
db.dbh.execute(sql, 'id'=>rcrd.id)

# update record using record object
Testmin.hr('update record using record object')
struct = {'z'=>'z value'}
rcrd.update(struct)

# get updated record
sql = 'select * from current where record_id=:id'
updated = dbh.get_first_row(sql, 'id'=>rcrd.id)
UtilibaseTesting.comp('update', updated['update_stat'], 'u')

# check jhash
Testmin.hr('check jhash')
jhash = rcrd.get_jhash()
UtilibaseTesting.comp('add to ending', jhash['y'][2], 'add to ending')
UtilibaseTesting.comp('add to ending', jhash['z'], 'z value')

# set record to not updated
Testmin.hr('set record to not updated')
sql = 'update current set update_stat=null where record_id=:id'
db.dbh.execute(sql, 'id'=>rcrd.id)

# get record object again
rcrd = Utilibase::Record.new(db, rcrd.id)

# update record
struct = {'z'=>'new z value'}
rcrd.update(struct)

# get updated record
sql = 'select * from current where record_id=:id'
updated = dbh.get_first_row(sql, 'id'=>rcrd.id)
jhash = updated['jhash']
jhash = JSON.parse(jhash)
UtilibaseTesting.comp('update new record', jhash['z'], 'new z value')
UtilibaseTesting.comp('update', updated['update_stat'], 'u')

# history table should have old copy of record
Testmin.hr('history table should have old copy of record')
sql = 'select jhash from history where record_id=:id'
historical = dbh.get_first_row(sql, 'id'=>rcrd.id)
historical_jhash = historical['jhash']
historical_jhash = JSON.parse(historical_jhash)
UtilibaseTesting.comp('historical record', historical_jhash['z'], 'original z value')

# done
# puts '[done]'
Testmin.done()
