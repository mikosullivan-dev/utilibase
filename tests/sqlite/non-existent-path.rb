#!/usr/bin/ruby -w
require_relative '../testing.lib.rb'

# enable taint mode
$SAFE = 1

# set file name
db_path = 'whatever'
db_path = UtilibaseTesting.db_path(db_path)

# delete path
FileUtils.rm_rf(db_path) or die $!


# attempt to get database handle
begin
	Utilibase::DBH.new(db_path)
	raise 'previous operation should have thrown exception'
rescue ExceptionPlus => e
	UtilibaseTesting.error_id('non-existent file', e, 'non-existent-db-file')
rescue StandardError => e
	puts e.message
	raise 'should not have gotten plain exception'
end


# done
# puts '[done]'
Testmin.done()
