#!/usr/bin/ruby -w
system 'clear' unless ENV['clear_done']
require_relative '../testing-lib.rb'

# enable taint mode
$SAFE = 1

# purpose: check for a specific problem with tracing
# mary-home-phone when mary's phones have been unlinked

# reset directory
UtilibaseTesting.reset_db_dir()

# create, initialize, instantiate database
db = UtilibaseTesting.new_db()
dbh = db.dbh

# load xyz into database
xyz = XYZ.new(dbh)

# remove records from Mary's phones
mary = db.record(xyz.uuid('mary'))
mary.update({'phones':[]})

# set_unlinked
db.set_unlinked()

# row should be marked as unlinked
mhp = xyz.current('mary-home-phone')
UtilibaseTesting.comp 'mary-home-phone - unlinked', mhp['unlinked'], 'r'

# trace record
db.trace_record mhp['record_uuid']

# mary-home-phone should not be in current anymore
UtilibaseTesting.bool 'should not be in current anymore', xyz.in_current('mary-home-phone'), false

# done
# puts '[done]'
TestMin.done()
