#!/usr/bin/ruby -w
system 'clear' unless ENV['clear_done']
require_relative '../testing.lib.rb'

require 'sqlite3'

# enable taint mode
$SAFE = 1

# create file name and path
db_file = Utilibase::Utils.randword()
db_path = UtilibaseTesting.db_path(db_file)

# get database handle
dbh = SQLite3::Database.new(db_path)

# show database handle
puts dbh

# does file exist?
puts File.exist?(db_path)

# nil database handle
dbh = nil
puts dbh

# does file exist?
puts File.exist?(db_path)

# done
# UtilibaseTesting.done()
puts '[done]'
