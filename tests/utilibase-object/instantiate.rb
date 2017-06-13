#!/usr/bin/ruby -w
require_relative '../testing.lib.rb'


# enable taint mode
$SAFE = 1

# purpose: test instantiating a utilibase object
# NOTE: A new object requires a valid path to a database file, just like
# instantiating a Utilibase::DBH object does. In fact, they use the same
# function for the checks. For that reason I don't test here those
# requirements because those tests are done in the tests for Utilibase::DBH.

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

# done
# puts '[done]'
Testmin.done()
