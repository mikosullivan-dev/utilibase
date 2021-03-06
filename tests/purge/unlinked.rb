#!/usr/bin/ruby -w
require_relative '../testing.lib.rb'

# enable taint mode
$SAFE = 1

# purpose: test setting unlinked fields

# reset directory
UtilibaseTesting.reset_db_dir()

# create, initialize, instantiate database
db = UtilibaseTesting.new_db()
dbh = db.dbh

# load xyz into database
xyz = XYZ.new(dbh)

# remove records from Mary's phones
mary = db.record(xyz.id('mary'))
mary.update({'phones':[]})

# get mary row
mary_row = mary.row()
UtilibaseTesting.comp('update_stat', mary_row['update_stat'], 'u')

# set unlinked
db.set_unlinked()

# shoulds
shoulds = [
	"mary-home-phone",
	"mary-home-phone-properties",
	"mary-home-phone-make",
	"mary-cell-phone"
]

# get ids of unlinked records
sql = <<~SQL
select   notes
from     current
where    unlinked is not null
SQL

# get list unlinked records
got = dbh.select_column(sql)

# sql for finding record in links_current
sql = 'select * from links_current where tgt_id=:id'

# check that the unlinked records are no longer in links_current
shoulds.each { |id|
	row = dbh.get_first_row(sql, 'id'=>xyz.id(id))
	UtilibaseTesting.is_nil('links_current: ' + id, row)
}

# done
# puts '[done]'
Testmin.done()
