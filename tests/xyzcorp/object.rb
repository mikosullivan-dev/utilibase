#!/usr/bin/ruby -w
system 'clear' unless ENV['clear_done']
require_relative '../testing.lib.rb'

# enable taint mode
$SAFE = 1

# purpose: test the XYZ class, which represents a test data structure
#	instantiate object
#	xyz.uuid()
#	xyz.exists()

# reset directory
UtilibaseTesting.reset_db_dir()

# create, initialize, instantiate database
db = UtilibaseTesting.new_db()
dbh = db.dbh

# get XYZ object
xyz = XYZ.new(dbh)

# check properties
UtilibaseTesting.isa('dbh', xyz.dbh, Utilibase::DBH)
UtilibaseTesting.isa('records', xyz.records, Array)
UtilibaseTesting.isa('ids', xyz.ids, Hash)

# convenience
ids = xyz.ids

# check some values
UtilibaseTesting.isa('joe', ids['joe'], Hash)
UtilibaseTesting.comp('joe class', ids['joe']['$class'], 'i')
UtilibaseTesting.comp('mary class', ids['mary']['$class'], 'i')
UtilibaseTesting.comp('mary-cell-phone', ids['mary-cell-phone']['location'], 'cell')

# xyz.in_current: if no such id, should get exception
begin
	xyz.in_current('whatever')
	raise 'should have gotten exception'
rescue Exception => e
	UtilibaseTesting.error_id('in_current: no such id', e, 'xyz~record~no-such-id')
end

# 'deleted-cell-phone' record should not be in current
UtilibaseTesting.bool('non-existent row', xyz.in_current('deleted-cell-phone'), false)

# 'mary' record should be in current
UtilibaseTesting.bool('existent row', xyz.in_current('mary'), true)

# xyz.row: if no such id, should get exception
begin
	xyz.current('whatever')
	raise 'should have gotten exception'
rescue Exception => e
	UtilibaseTesting.error_id('row: no such id', e, 'xyz~row~no-such-id')
end

# row for existent record should return hash
UtilibaseTesting.isa('hash for existent row', xyz.current('mary'), Hash)

# row for deleted record should return nil
UtilibaseTesting.is_nil('record nobodys-cell-phone', xyz.current('deleted-cell-phone'))

# check properties of a row from current
row = xyz.current('joe')
UtilibaseTesting.isa('existent row', row, Hash)
UtilibaseTesting.isa('jhash', row['jhash'], Hash)
UtilibaseTesting.isa('links', row['links'], Array)

# mary -> mary-cell-phone
UtilibaseTesting.bool(
	'mary -> mary-cell-phone',
	xyz.in_links_current('mary', 'mary-cell-phone', 'src_is_independent'=>true),
	true
)

# mary -> mary-cell-phone
UtilibaseTesting.bool(
	'mary -> mary-home-phone',
	xyz.in_links_current('mary', 'mary-home-phone', 'src_is_independent'=>true),
	true
)

# mary-home-phone -> mary-home-phone-properties
UtilibaseTesting.bool(
	'mary-home-phone -> mary-home-phone-properties',
	xyz.in_links_current('mary-home-phone', 'mary-home-phone-properties', 'src_is_independent'=>true),
	false
)


# done
# puts '[done]'
Testmin.done()
