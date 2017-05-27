#!/usr/bin/ruby -w
system 'clear' unless ENV['clear_done']
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
sql = 'update current set update_stat=null where record_uuid=:uuid'
db.dbh.execute(sql, 'uuid'=>rcrd.uuid)

# get record object again
rcrd = Utilibase::Record.new(db, rcrd.uuid)

# delete record
rcrd.delete()

# record should not be in current
UtilibaseTesting.record_in_current('record should not be in current', db, rcrd.uuid, {'should'=>false})

# record should be in history
UtilibaseTesting.record_in_history('record should be in history once', db, rcrd.uuid, 1)

# done
# puts '[done]'
TestMin.done()
