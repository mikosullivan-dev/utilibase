#!/usr/bin/ruby -w
require_relative '../testing.lib.rb'


# enable taint mode
$SAFE = 1

# purpose: test instantiating a record object

# reset directory
# UtilibaseTesting.reset_db_dir()

# create, initialize, instantiate database
db_file = Utilibase::Utils.randword() + '.utilibase'
dbh = Utilibase::DBH.create_db_file($ut_testing['test_dir'], db_file)
Utilibase.initialize_db(dbh)
db_path = UtilibaseTesting.db_path(db_file)
db = Utilibase.new(db_path)

# instantiate record object
rcrd_id = SecureRandom.uuid()
rcrd = Utilibase::Record.new(db, rcrd_id)
UtilibaseTesting.isa('is a', rcrd, Utilibase::Record)
UtilibaseTesting.comp('is a', rcrd.id, rcrd_id)

# done
# puts '[done]'
Testmin.done()
