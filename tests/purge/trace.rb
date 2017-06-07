#!/usr/bin/ruby -w
system 'clear' unless ENV['clear_done']
require_relative '../testing.lib.rb'

# enable taint mode
$SAFE = 1

# purpose: test tracing records
#	finds independent parent
#	does not find independent parent

# reset directory
UtilibaseTesting.reset_db_dir()

# create, initialize, instantiate database
db = UtilibaseTesting.new_db()
dbh = db.dbh

# load xyz into database
xyz = XYZ.new(dbh)

# delete existing traces
sql = 'delete from traces'
dbh.execute(sql)


#-------------------------------------------------------------------------------
# trace mary-home-phone-properties
#
if true
	Testmin.hr('title'=>'trace mary-home-phone-properties', 'dash'=>'=')
	
	# set some records as unlinked
	sql = "update current set unlinked='r' where notes=:id"
	dbh.execute(sql, 'id'=>'mary-home-phone')
	dbh.execute(sql, 'id'=>'mary-home-phone-properties')
	
	# run trace
	db.trace_record(xyz.id('mary-home-phone-properties'))
	
	# following records should still be in the database
	in_current = {
		'mary' => nil,
		'mary-home-phone' => 'r',
		'mary-home-phone-properties' => nil,
	}
	
	# loop through in_current
	in_current.keys.each do |id|
		puts id
		
		# record should be in database
		UtilibaseTesting.bool('in current: ' + id, xyz.in_current(id), true)
		
		# get row
		row = xyz.current(id)
		
		# unlinked should be nil
		UtilibaseTesting.is_nil('unlinked: ' + id, row['unlinked'], 'should'=>in_current[id].nil?)
	end
end
#
# trace mary-home-phone-properties
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
# trace nobodys-cell-phone-properties
#
if true
	Testmin.hr('title'=>'trace nobodys-cell-phone-properties', 'dash'=>'=')
	
	# run trace
	db.trace_record(xyz.id('nobodys-cell-phone-properties'))
	
	# following records should still be in the database
	in_current = [
		'nobodys-cell-phone',
		'nobodys-cell-phone-properties',
	]
	
	# records should not be in database
	in_current.each do |id|
		puts id
		UtilibaseTesting.bool('in current: ' + id, xyz.in_current(id), false)
	end
end
#
# nobodys-cell-phone-properties
#-------------------------------------------------------------------------------


# done
# puts '[done]'
Testmin.done()
