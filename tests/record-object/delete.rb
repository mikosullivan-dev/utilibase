#!/usr/bin/ruby -w
require_relative '../testing.lib.rb'


# enable taint mode
$SAFE = 1

# purpose: test deleting a record object

# reset directory
# UtilibaseTesting.reset_db_dir()

# create, initialize, instantiate database
db = UtilibaseTesting.new_db()

# get record
rcrd = Utilibase::Record.new(db, SecureRandom.uuid())

# save new record
rcrd.save_new()

# set record to not updated
sql = 'update current set update_stat=null where record_id=:id'
db.dbh.execute(sql, 'id'=>rcrd.id)

# get record object again
rcrd = Utilibase::Record.new(db, rcrd.id)

# delete record
rcrd.delete()

# record should not be in current
UtilibaseTesting.record_in_current('record should not be in current', db, rcrd.id, {'should'=>false})

# record should be in history
UtilibaseTesting.record_in_history('record should be in history once', db, rcrd.id, 1)

# done
# puts '[done]'
Testmin.done()
