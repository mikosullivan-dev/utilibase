#!/usr/bin/ruby -w
system 'clear' unless ENV['clear_done']
require_relative '../testing-lib.rb'


# enable taint mode
$SAFE = 1

# purpose: test successfully adding a record

# reset directory
# UtilibaseTesting.reset_db_dir()

# create and initialize databse file
db_file = Utilibase::Utils.randword() + '.utilibase'
dbh = Utilibase::DBH.create_db_file($ut_testing['test_dir'], db_file)
Utilibase.initialize_db(dbh)

# verbosify
puts UtilibaseTesting.db_path(db_file)


# check
sql = "insert into current(record_uuid, jhash, links) values(:uuid, '{}', '')"
dbh.execute_batch(sql, {'uuid'=>SecureRandom.uuid()})


# done
# puts '[done]'
TestMin.done()
