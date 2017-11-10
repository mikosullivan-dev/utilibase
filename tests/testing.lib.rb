# I like to clear the screen before each test
if (ENV['AUTOCLEAR']) and (not ENV['TESTMIN'])
	system('/usr/bin/clear')
	ENV['CLEAR_DONE'] = '1'
end

# load Testmin
require_relative './testmin.rb'

# load configuration
require_relative './testing.config.rb'

# load Utilibase
require_relative $ut_testing['utilibase_path']

# load FileUtils
require 'fileutils'


###############################################################################
# UtilibaseTesting
#
module UtilibaseTesting
	# set global
	# $ut = UtilibaseTesting
	
	# new database handle
	$new_dbh = nil
	
	# path to database directory
	# DB_DIR = $ut_testing['test_dir']
	
	# reset_db_dir
	def UtilibaseTesting.reset_db_dir()
		# delete directory if it exists
		if File.exist?($ut_testing['test_dir'])
			FileUtils.remove_dir($ut_testing['test_dir'])
		end
		
		# create directory
		FileUtils::mkdir_p $ut_testing['test_dir']
	end
	# error id
	def UtilibaseTesting.error_id(test_name, e, msgid)
		raise TypeError, 'not-StandardErrorPlus' unless e.is_a?(StandardErrorPlus)
		
		# check error id
		unless e.error_id == msgid
			raise 'incorrect-message-id: ' + test_name
		end
	end
	
	# is_internal
	def UtilibaseTesting.is_internal(test_name, e, opts={})
		opts = {'should'=>true}.merge(opts)
		
		# check internal state
		if opts['should']
			if not e.is_a?(StandardErrorPlus::Internal)
				raise 'internal-not-true: ' + test_name
			end
		else
			if e.is_a?(StandardErrorPlus::Internal)
				raise 'internal-true: ' + test_name
			end
		end
	end
	
	# internal_id
	def UtilibaseTesting.internal_id(test_name, e, internal_id)
		raise TypeError, 'not-StandardErrorPlus' unless e.is_a?(StandardErrorPlus::Internal)
		
		# check error id
		unless e.internal_id == internal_id
			raise 'incorrect-internal-id: ' + test_name
		end
	end
	
	# returns the full path to a file in the database dir
	def UtilibaseTesting.db_path(filename)
		# ensure directory exists
		if not FileTest.exist?($ut_testing['test_dir'])
			FileUtils.mkdir($ut_testing['test_dir'])
		end
		
		# build and return full path
		return $ut_testing['test_dir'] + '/' + filename
	end
	
	# isa
	def UtilibaseTesting.isa(test_name, my_object, class_should, opts={})
		# puts 'isa'
		# puts my_object.class
		
		# default options
		opts = {'should'=>true}.merge(opts)
		
		if opts['should']
			if not my_object.is_a?(class_should)
				raise test_name + ' - isa: should be class ' + class_should + 'but instead is class ' + my_object.class
			end
		else
			if my_object.is_a?(class_should)
				raise test_name + 'isa-should-not: should not be class ' + class_should + 'but instead is '
			end
		end
	end
	
	# comp
	def UtilibaseTesting.comp(test_name, is, should, opts={})
		# UtilibaseTesting.hr('comp()')
		
		# default options
		opts = {'should'=>true}.merge(opts)
		
		# test
		if opts['should']
			if is != should
				# raise test_name + ': not equal [is: ' + is.to_s() + ']|[should: ' + should.to_s() + ']'
				UtilibaseTesting.fail(test_name, "not equal\nis: " + is.to_s() + "\nshould: " + should.to_s())
			end
		else
			if is == should
				# UtilibaseTesting.fail(test_name, 'equal [is: ' + is.to_s() + ']|[should: ' + should.to_s() + ']')
				UtilibaseTesting.fail(test_name, "equal\nis: " + is.to_s() + "\nshould: " + should.to_s())
			end
		end
		
		# return
		return true
	end
	
	# comp_hash
	def UtilibaseTesting.comp_hash(test_name, is, should, opts={})
		opts = {'should'=>true}.merge(opts)
		
		if opts['should']
			if is != should
				UtilibaseTesting.fail test_name, 'hashes not equal'
			end
		else
			if is == should
				UtilibaseTesting.fail test_name, 'hashes equal'
			end
		end
	end
	
	# comp_arrays
	def UtilibaseTesting.comp_arrays(test_name, is, should, opts={})
		# UtilibaseTesting.hr(__method__.to_s)
		
		# default options
		opts = {'should'=>true}.merge(opts)
		
		# if arrays should be sorted
		if opts['sort']
			is = is.sort
			should = should.sort
		end
		
		# if they should be equal
		if opts['should']
			if is != should
				UtilibaseTesting.fail(
					test_name,
					"arrays not equal\n" +
					"--- is --------------------------------\n" +
					is.join("\n") + "\n" +
					"--- should ----------------------------\n" +
					should.join("\n") + "\n" +
					"---------------------------------------\n"
				)
			end
		
		# else they should not be equal
		else
			if is == should
				if is == should
					UtilibaseTesting.fail(
						test_name,
						"arrays equal but should not be\n" +
						"--- is --------------------------------\n" +
						is.join("\n") + "\n" +
						"--- should ----------------------------\n" +
						should.join("\n") + "\n" +
						"---------------------------------------\n"
					)
				end


			end
		end
	end
	
	# field_structure
	def UtilibaseTesting.field_structure(dbh, table_name, field_name, pk, type, notnull, default)
		# UtilibaseTesting.hr(table_name + '.' + field_name)
		
		# test name
		tn = 'structure: ' + table_name + '.' + field_name + ' - '
		
		# get column info
		sql = "pragma table_info(" + table_name + ")"
		table = dbh.select_hash(sql, 'name')
		field = table[field_name]
		
		# check properties
		UtilibaseTesting.comp( tn + 'primary key',     field['pk'],              pk           )
		UtilibaseTesting.comp( tn + 'type',            field['type'],            type         )
		UtilibaseTesting.comp( tn + 'not null',        field['notnull'],         notnull      )
		UtilibaseTesting.comp( tn + 'default value',   field['dflt_value'].to_s, default.to_s )
	end
	
	# exception message
	def UtilibaseTesting.exception_message(test_name, e, should, opts={})
		# UtilibaseTesting.hr('UtilibaseTesting.exception_message')
		
		# e must be an exception
		raise TypeError, 'not-Exception' unless e.is_a?(Exception)
		opts = {'should'=>true}.merge(opts)
		
		# collapse should
		should = Utilibase::Utils.collapse(should)
		
		# check
		if opts['should']
			if Utilibase::Utils.collapse(e.message) != should
				UtilibaseTesting.fail(
					test_name,
					"incorrect exception message\n" +
					"is: " + e.message + "\n" +
					"should: " + should
				)
			end
		else
			if Utilibase::Utils.collapse(e.message) == should
				raise (
					test_name + " - incorrect exception message\n" +
					"is but should not be: " + e.message
				)
			end
		end
	end
	
	# check_index
	def UtilibaseTesting.check_index(dbh, table_name, index_name, unique, partial, columns)
		# puts 'check_index: ' + index_name
		
		# test name
		tn = 'check_index: ' + index_name
		
		# get index info from index_list
		sql = 'pragma index_list(' + table_name + ')'
		indexes = dbh.select_hash(sql, 'name')
		index = indexes[index_name]
		
		# check info from index_list
		UtilibaseTesting.comp( tn + 'unique',   index['unique'],   unique  )
		UtilibaseTesting.comp( tn + 'partial',  index['partial'],  partial )
		
		# get info from index_info
		sql = 'pragma index_info(' + index_name + ')'
		index_columns = dbh.select_hash(sql, 'name')
		
		# check column count
		UtilibaseTesting.comp( tn + 'column count', index_columns.length, columns.length )
		
		# loop through columns
		columns.each { |col|
			if not index_columns.key?(col)
				raise 'do not have column ' + col + ' for index ' + index_name
			end
		}
	end
	
	# new_db
	def UtilibaseTesting.new_db()
		# generate file path
		db_file = Utilibase::Utils.randword() + '.utilibase'
		
		# get database handle
		dbh = Utilibase::DBH.create_db_file($ut_testing['test_dir'], db_file)
		
		# initialize database
		Utilibase.initialize_db(dbh)
		
		# get full database path
		db_path = UtilibaseTesting.db_path(db_file)
		
		# create utilibase object
		db = Utilibase.new(db_path)
		
		# note name of database in /tmp/utilibase/latest_new_db.txt
		open($ut_testing['test_dir'] + '/latest_new_db.txt', 'w') { |f|
			f.puts db_path
		}
		
		# hold on to new dbh
		$new_dbh = db.dbh
		
		# verbosify
		puts 'new database: ' + db.db_path
		
		# return
		return db
	end
	
	# check_foreign_key
	def UtilibaseTesting.check_foreign_key(dbh, src_table, tgt_table, src_field, tgt_field, on_delete)
		# puts 'check_foreign_key: ' + src_table + '.' + src_field
		
		# test name
		tn = 'foreign key: ' + src_table + '.' + src_field
		
		# get column info
		sql = "pragma foreign_key_list(" + src_table + ")"
		
		# loop through rows looking for the field being checked
		dbh.execute( sql ) do |row|
			if row['from'] == src_field
				# TESTING
				# puts row
				
				# compare
				UtilibaseTesting.comp( tn + 'target table: ', row['table'], tgt_table )
				UtilibaseTesting.comp( tn + 'target field: ', row['to'], tgt_field )
				UtilibaseTesting.comp( tn + 'on_delete: ', row['on_delete'], on_delete )
				
				# success
				return true
			end
		end
		
		# if we get this far, the foreign key was not found
		raise test_name + ': equal [is: ' + is.to_s() + ']|[should: ' + should.to_s() + ']'
	end
	
	# record_in_current
	def UtilibaseTesting.record_in_current(test_name, db, record_id, opts={})
		# puts 'record_in_current'
		opts = {'should'=>true}.merge(opts)
		
		# get count of record
		sql = 'select count(*) as rcount from current where record_id=:id'
		row = db.dbh.get_first_row(sql, 'id'=>record_id)
		
		# if should
		if opts['should']
			if row['rcount'] != 1
				raise (test_name + ': record is not in current but should be')
			end
		else
			if row['rcount'] != 0
				raise (test_name + ': record is in current but should not be')
			end
		end
	end
	
	# record_in_history
	def UtilibaseTesting.record_in_history(test_name, db, record_id, should_count)
		puts 'record_in_history'
		
		# get count of record
		sql = 'select count(*) as rcount from history where record_id=:id'
		row = db.dbh.get_first_row(sql, 'id'=>record_id)
		
		# check count
		if row['rcount'] != should_count
			raise (
				test_name + ': record is not in history ' + should_count.to_s +
				' time(s) but is actually in it ' + row['rcount'].to_s + ' time(s)'
			)
		end
	end
	
	# is_nil
	def UtilibaseTesting.is_nil(test_name, val, opts={})
		opts = {'should'=>true}.merge(opts)
		
		if opts['should']
			if not val.nil?()
				# raise test_name + ' - value should be nil but is not'
				UtilibaseTesting.fail test_name, 'value should be nil but is not'
			end
		else
			if val.nil?()
				# raise test_name + ' - value should not be nil but is'
				UtilibaseTesting.fail test_name, 'value should not be nil but is'
			end
		end
	end
end
#
# UtilibaseTesting
###############################################################################


###############################################################################
# XYZ
#
class XYZ
	# properties
	attr_reader :dbh
	attr_reader :records
	attr_reader :ids
	
	# initialize
	def initialize(dbh)
		@dbh = dbh
		
		# get structure
		struct = self.load()
	
		# hold on to array and hash of records
		@records = struct['all']
		@ids = struct['ids']
	end
	
	# struct
	# returns the structure of xyzcorp.json as a two element hash:
	#	unraveled: an unraveled array of all the records
	#	byname: a hash of the records keyed by their "name" property
	def struct()
		# puts 'UtilibaseTesting.xyz()'
		
		# get raw structure
		struct = parse()
		
		# unravel
		unraveled = Utilibase::Utils::unravel(struct)
		
		# inititialize return hash
		all = []
		ids = {}
		rv = { 'all'=>all, 'ids'=>ids }
		
		# loop through unraveled building hash based on "id"
		unraveled.keys.each do |my_key|
			el = unraveled[my_key]
			
			# add to hash of elements that have an id
			if not el['id'].nil?
				ids[el['id']] = el
			end
			
			# add to array of all elements
			all.push(el)
		end
		
		# return
		return rv
	end
	
	# parse
	# slurps in the content of xyzcorp.json and returns it as a parsed
	# structure
	def parse()
		# slurp in source
		src = File.read('../xyzcorp.json')
		
		# parse json
		rv = JSON.parse(src)
		
		# return
		return rv
	end
	
	# load
	# loads the xyz corp data to the given database
	def load()
		# UtilibaseTesting.hr('load')
		
		# get xyz data
		struct = struct()
		all = struct['all']
		
		# sql
		sql = <<~SQL
		insert into
			current(record_id, jhash, links, dependency, notes)
			values(:record_id, :jhash, :links, :dependency, :notes)
		SQL
		
		# statement handle
		current_ins_sth = dbh.prepare(sql)
		
		# sql to add to links_current
		sql = <<~SQL
		insert into
			links_current (
				src_id,
				tgt_id,
				src_is_independent
			)
			values (
				:src,
				:tgt,
				:src_is_independent
			)
		SQL
		
		# statement handle to add to
		links_current_ins_sth = dbh.prepare(sql)
		
		# add records to current
		all.each do |el|
			# record id
			record_id = el['$id']
			
			# get dependency
			dependency = el['$class']
			
			# default rclass to d
			if dependency.nil?
				dependency = 'd'
			end
			
			# create json string for jhash
			jhash = JSON.generate(el)
			
			# links string
			links = Utilibase::Utils.links_array(el)
			
			# notes is just the id
			notes = el['id']
			
			# execute statement handle
			# check
			begin
				current_ins_sth.execute(
					'record_id'=>record_id,
					'jhash'=>jhash,
					'links' => links.join(' '),
					'dependency' => dependency,
					'notes' => notes
				)
			rescue StandardError => e
				puts e.message
				exit
			end
		end
		
		# add records to links_current
		all.each do |el|
			# record id
			record_id = el['$id']
			
			# get dependency
			dependency = el['$class']
			
			# default rclass to d
			if dependency.nil?
				dependency = 'd'
			end
			
			# links string
			links = Utilibase::Utils.links_array(el)
			
			# insert records into links_current
			links.each {
				|link_tgt|
				
				# determine src_is_independent
				src_is_independent = (dependency == 'i' ? 1 : 0)
				
				# TESTING
				# puts 'link_tgt: ' + link_tgt + ' | link_src: ' + record_id
				
				# add record
				begin
					links_current_ins_sth.execute(
						'src'=>record_id,
						'tgt'=>link_tgt,
						'src_is_independent' => src_is_independent,
					)
				rescue StandardError => e
					puts e.message
					exit
				end
			}
		end
		
		# sql to delete records
		sql = <<~SQL
		delete
			from   current
			where  record_id=:id
		SQL
		
		# delete records marked for deletion
		all.each do |el|
			if el['delete']
				dbh.execute(sql, 'id'=>el['$id'])
			end
		end
		
		# return structure
		return struct
	end
	
	# record
	def record(id)
		# UtilibaseTesting.hr('record: ' + id)
		
		# get record
		record = ids[id]
		
		# if no record, raise exception
		if record.nil?
			raise StandardErrorPlus::Internal.new('xyz~record~no-such-id', 'WkTFp', 'no such id: ' + id)
		end
		
		# return
		return record
	end
	
	# id
	def id(id)
		return self.record(id)['$id']
	end
	
	# id_in_current
	# returns true if a row with the given id (in notes field) exists in current
	def in_current(id)
		# UtilibaseTesting.hr('in_current: ' + id)
		
		# get record
		record = self.record(id)
		
		# get row
		sql = 'select count(*) as count from current where record_id=:id'
		row = dbh.get_first_row(sql, 'id'=>record['$id'])
		
		# return
		return row['count'] > 0 ? true : false
	end
	
	# current
	# returns the row in current indicated by the id
	# NOTE: This function returns the row, not a record object
	# jhash will be parsed, and links will be an array
	def current(id)
		# UtilibaseTesting.hr('xyz.current: ' + id)
		
		# get record
		record = ids[id]
		
		# if no record, raise exception
		if record.nil?
			# raise 'in-current-no-such-id: no such record in xyz struct: ' + id
			raise StandardErrorPlus::Internal.new('xyz~row~no-such-id', 'LJLZ7', 'no such id: ' + id)
		end
		
		# get row
		sql = 'select * from current where record_id=:id'
		row = dbh.get_first_row(sql, 'id'=>record['$id'])
		
		# if row is defined, parse some of the fields
		if not row.nil?
			# parse jhash
			row['jhash'] = JSON.parse(row['jhash'])
			
			# parse links
			row['links'] = row['links'].split(' ')
		end
		
		# return
		return row
	end
	
	# check that a record is in links_current
	def in_links_current(src, tgt, opts={})
		# UtilibaseTesting.hr('in_links_current: ' + src + ' -> ' + tgt)
		
		# sql
		sql = 'select * from links_current where src_id=:src and tgt_id=:tgt'
		
		# get row
		row = dbh.get_first_row(
			sql,
			'src'=>ids[src]['$id'],
			'tgt'=>ids[tgt]['$id'],
		)
		
		# false if we didn't get the record
		if row.nil?
			return false
		end
		
		# if src_is_independent was sent as an option, check that it matches
		# the option
		if not opts['src_is_independent'].nil?
			row_sii = (row['src_is_independent'] == 1) ? true : false
			
			if not UtilibaseTesting.bool_comp(opts['src_is_independent'], row_sii)
				return false
			end
		end
		
		# return true
		return true
	end
end
#
# XYZ
###############################################################################


__END__
	
	
	# exit_commit
	def UtilibaseTesting.exit_commit()
		# UtilibaseTesting.hr(__method__.to_s)
		$new_dbh.commit()
		puts "\n", '[devexit]'
		exit
	end
	
	# show_sql
	def UtilibaseTesting.show_sql(dbh, sql, binds={})
		# UtilibaseTesting.hr(__method__.to_s)
		
		# initialize first_done
		first_done = false
		
		# opening hr
		UtilibaseTesting.hr()
		
		# loop through query
		dbh.execute( sql, binds ) do |row|
			# output either newline or set first_done=true
			if first_done
				puts
			else
				first_done = true
			end
			
			# output row
			show_row(row)
		end
		
		# closing hr
		UtilibaseTesting.hr()
	end
	
	# show_row
	def UtilibaseTesting.show_row(row)
		# UtilibaseTesting.hr(__method__.to_s)
		
		# clone row
		row = row.clone
		
		# remove numeric keys
		row.keys.each { |key|
			if key.is_a?(Fixnum)
				row.delete(key)
			end
		}
			
			# output row
			puts row
	end
	
	# fail
	def UtilibaseTesting.fail(test_name, message)
		# UtilibaseTesting.hr('fail()')
		
		# title
		puts
		UtilibaseTesting.hr('dash'=>'#')
		puts '# fail: ' + test_name
		puts '#'
		
		# output message
		puts message
		
		# bottom
		puts '#'
		puts '# fail: ' + test_name
		UtilibaseTesting.hr('dash'=>'#')
		puts
		
		# we're done
		exit
	end
end
#
# UtilibaseTesting
###############################################################################
