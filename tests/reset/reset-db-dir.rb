#!/usr/bin/ruby -w
system 'clear' unless ENV['clear_done']
require_relative '../testmin.rb'
require_relative '../testing.lib.rb'

# enable taint mode
$SAFE = 1

# purpose: test deleting all the files in /tmp/utilibase

# reset directory
UtilibaseTesting.reset_db_dir()

# directory should exist
if not File.exist?($ut_testing['test_dir'])
	raise 'db-dir-does-not-exist: the database directory does not exist'
end

# create a file in the dir
FileUtils.touch($ut_testing['test_dir'] + '/' + Utilibase::Utils.randword)

# reset directory
UtilibaseTesting.reset_db_dir()

# count files in db directory
if Dir.glob($ut_testing['test_dir'] + '/*').length > 0
	raise 'db-dir-not-reset: the database directory was not emptied by UtilibaseTesting.reset_db_dir()'
end

# done
# puts '[done]'
TestMin.done()
