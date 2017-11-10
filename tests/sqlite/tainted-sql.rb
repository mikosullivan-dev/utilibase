#!/usr/bin/ruby -w
require_relative '../testing.lib.rb'

# enable taint mode
$SAFE = 1

# set file name
db_path = 'whatever'
db_path = UtilibaseTesting.db_path(db_path)

# get database handle
dbh = Utilibase::DBH.new(db_path)

# sql
sql = 'select sqlite_version()'
sql.taint

# begin
begin
	dbh.get_first_value(sql)
	raise 'previous operation should have thrown exception'
rescue StandardErrorPlus::Internal => e
	UtilibaseTesting.error_id 'error id', e, 'tainted-sql'
	UtilibaseTesting.is_internal 'is internal', e
	UtilibaseTesting.internal_id 'internal id', e, 'bmVCL'
rescue StandardErrorPlus => e
	raise 'should not have gotten StandardErrorPlus'
rescue StandardError => e
	raise 'should not have gotten plain exception'
end


# done
# puts '[done]'
Testmin.done()
