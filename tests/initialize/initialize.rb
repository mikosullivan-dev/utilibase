#!/usr/bin/ruby -w
system 'clear' unless ENV['clear_done']
require_relative '../testing-lib.rb'

# enable taint mode
$SAFE = 1

# purpose: test initializing a database with the necessary objects
# d current table

# reset directory
UtilibaseTesting.reset_db_dir()

# create file name and path
db_file = Utilibase::Utils.randword() + '.utilibase'

# create databse file
dbh = Utilibase::DBH.create_db_file($ut_testing['test_dir'], db_file)

# initialize
Utilibase.initialize_db(dbh)

# TESTING
# system '/bin/ls', '/tmp/utilibase/'

# get hash of tables
sql = "select name from sqlite_master where type='table'"
rows = dbh.select_hash(sql, 'name')

# check for tables
UtilibaseTesting.isa 'current', rows['current'], Hash

# done
# puts '[done]'
TestMin.done()
