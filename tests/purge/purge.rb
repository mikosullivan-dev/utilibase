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

# rows that should have been purged
purged_should = [
	'mary-home-phone',
	'mary-home-phone-properties',
	'mary-home-phone-make',
	'mary-cell-phone',
]

# rows that should not have been purged
purged_not = [
	'redstone'
]

# remove records from Mary's phones
mary = db.record(xyz.uuid('mary'))
mary.update({'phones':[]})

# purge
db.purge()

# loop through records that should have been purged
purged_should.each { |id|
	UtilibaseTesting.bool 'purged: ' + id, xyz.in_current(id), false
}

# loop through records that should have been purged
purged_not.each { |id|
	UtilibaseTesting.bool 'not purged: ' + id, xyz.in_current(id), true
}

# done
# puts '[done]'
Testmin.done()
