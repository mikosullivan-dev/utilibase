#!/usr/bin/ruby -w
system 'clear' unless ENV['clear_done']
require_relative '../testing.lib.rb'


# enable taint mode
$SAFE = 1

# purpose: getting a database handle
# NOTE: A new object requires a valid path to a database file, just like
# instantiating a Utilibase::DBH object does. In fact, they use the same
# function for the checks. For that reason I don't test here those
# requirements because those tests are done in the tests for Utilibase::DBH.

# reset directory
# UtilibaseTesting.reset_db_dir()

# create and initialize database file
db_file = Utilibase::Utils.randword() + '.utilibase'
dbh = Utilibase::DBH.create_db_file($ut_testing['test_dir'], db_file)
Utilibase.initialize_db(dbh)
db_path = UtilibaseTesting.db_path(db_file)

# instantiate utilibase object
db = Utilibase.new(db_path)

# get dbh
dbh1 = db.dbh()
UtilibaseTesting.isa('isa', dbh1, Utilibase::DBH)

# get again
dbh2 = db.dbh()
UtilibaseTesting.comp('compare', dbh1.object_id, dbh2.object_id)

# foreign_keys should be on
sql = 'pragma foreign_keys'
row = dbh.get_first_row(sql)
UtilibaseTesting.comp('foreign_keys', row['foreign_keys'], 1)

# autocommit should be off
UtilibaseTesting.bool('autocommit', dbh.transaction_active?(), true)

# done
# puts '[done]'
TestMin.done()
