#!/usr/bin/ruby -w

# load some modules
require 'sqlite3'
require 'securerandom'


#-------------------------------------------------------------------------------
# configuration
#

# minimum SQLite version
# NOTE: Make sure the following command is on a single line by itself.
SQLITE_MIN_VERSION = '3.05.0'
SQLITE_GEM_MIN_VERSION = '1.3.1'

#
# configuration
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
# check prerequisites
#

# check that we are using the minimum SQLite3 gem version
if Gem::Version.new(SQLite3::VERSION) < Gem::Version.new(SQLITE_GEM_MIN_VERSION)
	raise
		'SQLite gem version is ' + SQLite3::VERSION +
		'but must be at least ' + SQLITE_GEM_MIN_VERSION
end

# check that we are using the minimum SQLite version
if Gem::Version.new(SQLite3::SQLITE_VERSION) < Gem::Version.new(SQLITE_MIN_VERSION)
	raise
		'SQLite version is ' + SQLite3::SQLITE_VERSION +
		'but must be at least ' + SQLITE_MIN_VERSION
end

#
# check prerequisites
#-------------------------------------------------------------------------------



################################################################################
# Utilibase
#
class Utilibase
	
	#---------------------------------------------------------------------------
	# attributes
	#
	
	# version
	VERSION = '0.0.1'
	
	# KLUDGE: I assigned nil to @dbh so that the warning "possibly useless use
	# of a variable in void context" would go away. This seems like a
	# ham-handed way to do it.
	@dbh = nil
	
	# hash of statement handles
	@sths = nil
	
	# path to SQLite database file
	attr_reader :db_path
	
	#
	# attributes
	#---------------------------------------------------------------------------
	
	
	#---------------------------------------------------------------------------
	# initialize
	#
	# KLUDGE: The db_path object is checked twice: when a Utilibase object is
	# created and again when a connection is made to a file. Both checks are
	# done by Utilibase::Utils.check_db_path(), so there's no code redundancy.
	# For now we'll just let the situation be, but at some point we'll need to
	# tidy it up.
	#
	def initialize(db_path_input)
		# puts 'Utilibase.initialize()'
		
		# check path
		Utilibase::Utils.check_db_path(db_path_input)
		
		# initialize some properties
		@dbh = nil
		@sths = {}
		
		# store path
		@db_path = db_path_input
	end
	#
	# initialize
	#---------------------------------------------------------------------------
	
	
	#---------------------------------------------------------------------------
	# dbh
	# Creates the database handle if it doesn't already exist. Returns the
	# statement handle.
	#
	def dbh()
		# Testmin.hr(__method__.to_s)
		
		# initialize @dbh if we haven't already
		if @dbh.nil?
			@dbh = Utilibase::DBH.new(@db_path)
		end
		
		# return
		return @dbh
	end
	#
	# dbh
	#---------------------------------------------------------------------------
	
	
	
	#---------------------------------------------------------------------------
	# Utilibase.initialize_db
	## Static method. Initializes the database with the necessary tables,
	## indexes etc.
	##
	## This method includes the entire SQL to initialize the SQLite database as
	## a Utilibase database.
	#
	def Utilibase.initialize_db(dbh)
		# Testmin.hr(__method__.to_s)
		
		# sql
		sql_create = <<~SQL
		-- current
		-- This table holds the current records.
		create table current (
			-- record_id
			record_id
			text
			primary key
			not null,
			
			-- jhash
			-- jhash holds the canonical information about the record. All other
			-- fields derive from this field.
			jhash
			text
			not null
			check( (jhash like '{%') and (jhash like '%}') ),
			
			-- links
			-- A list of the links in jhash
			links
			text
			not null,
			
			-- update_stat
			-- This field is used in the trace and purge process.
			update_stat
			text
			check( (update_stat is null) or (update_stat = 'n') or (update_stat = 'u') ),
			
			-- dependency
			-- Indicates if this is a dependent, independent, or multilink
			-- field.
			dependency
			text
			default 'd'
			not null
			check( (dependency = 'd') or (dependency = 'i') or (dependency = 'm') ),
			
			-- unlinked
			-- i: the record has been marked as unlinked, but has not had its ancestors traced
			-- r: the record has had its ancestors traced
			-- TODO: "i" doesn't really make sense to mark as unlinked, change
			-- to "u"
			unlinked
			text
			check( unlinked in ('i', 'r') ),
			
			-- ts_start
			-- Beginning time range for when this record is active.
			ts_start
			text,
			
			-- ts_end
			-- Ending time range for when this record is active.
			-- KLUDGE: To make it easier to union ts_end with the history
			-- table, the current table has the field ts_end which is always
			-- null. It seems silly to have a field that's always null, but
			-- for now we'll go with the simple solution.
			ts_end
			text
			check( ts_end is null ),
			
			-- notes
			-- This field is for development and debugging. It has no use
			-- in production.
			notes
			text,
			
			-- check: if dependency is 'm' then links should be an empty string
			constraint dependency_and_links check (
				case
					when dependency='m' then
						links = ''
					else
						1
				end
			),
			
			-- check: if dependency is not 'd' then unlinked must be null
			constraint dependency_and_unlinked check (
				case
					when dependency != 'd' then
						unlinked is null
					else
						1
				end
			)
		);
		
		-- indexes
		create index current_record_id_update_stat on current (record_id, update_stat);
		create index current_ts_start on current (ts_start);
		create index current_dependency on current (dependency);
		create index current_update_stat on current (update_stat);
		create index current_unlinked on current (unlinked);
		
		-- history
		-- This table holds the historical records.
		create table history (
			-- version_id
			version_id
			text
			primary key
			not null,
			
			-- record_id
			record_id
			text
			not null,
			
			-- jhash
			jhash
			text
			not null
			check( (jhash like '{%') and (jhash like '%}') ),
			
			-- links
			links
			text
			not null,
			
			-- update_stat
			update_stat
			text
			default 'n'
			check( (update_stat is null) or (update_stat = 'n') ),
			
			-- ts_start
			ts_start
			text,
			
			-- ts_end
			-- KLUDGE: To make it easier to union ts_end with the history
			-- table, the current table has the field ts_end which is always
			-- null. It seems silly to have a field that's always nbull, but
			-- for now we'll go with the simple solution.
			ts_end
			text,
			
			-- notes
			-- This field is just for debugging and has no use in production
			notes
			text
		);
		
		-- indexes
		create index history_record_id on history (record_id);
		create index history_update_stat on history (update_stat);
		create index history_ts_start on history (ts_start);
		create index history_ts_end on history (ts_end);
		
		-- current links
		-- Table of links in the "current" table. This denormalized data is used
		-- as part of the trace and purge process.
		create table links_current (
			-- src_id
			src_id
			text
			not null
			references current(record_id)
			on delete cascade,
			
			-- tgt_id
			tgt_id
			text
			not null
			references current(record_id)
			on delete cascade,
			
			-- src_is_independent
			src_is_independent
			boolean
			not null
			check( src_is_independent in (0, 1) ),
			
			-- set primary key
			primary key(src_id, tgt_id)
		);
		
		-- traces
		-- This table is used as part of the trace process. A new record in this
		-- table is create for each time a record is traced. After the trace,
		-- the record is deleted.
		create table traces (
			-- trace_id
			trace_id
			text
			primary key
			not null,
			
			-- time of trace
			init_time
			timestamp
			default current_timestamp
			not null,
			
			-- independent_found
			independent_found
			boolean
			not null
			check( independent_found in (0, 1) )
			default 0
		);
		
		-- format init_time
		create trigger traces_format_ts after insert on traces begin
			update traces
				set
					init_time = strftime('%Y-%m-%dT%H:%M:%S+%fZ', new.init_time)
				where
					trace_id = new.trace_id;
		end;
		
		-- trace_records
		create table trace_records (
			-- trace_id
			trace_id
			text
			not null
			references traces(trace_id)
			on delete cascade,
			
			-- record_id
			record_id
			text
			not null
			references current(record_id)
			on delete cascade,
			
			-- src_is_independent
			independent
			boolean
			not null
			check( independent in (0, 1) ),
			
			-- primary key
			primary key(trace_id, record_id)
		);
		
		-- after insert trigger for trace_records
		create trigger trace_records_ai after insert on trace_records
		when new.independent
		begin
			update   traces
			set      independent_found = 1
			where    trace_id = new.trace_id;
		end;
		SQL
		
		# run sql
		# Note that I don't catch any exception here. See "Programming notes /
		# Error handling" for an explanation why.
		dbh.execute_batch(sql_create)
		
		# commit and start a new transaction
		dbh.commit
		dbh.transaction
	end
	#
	# Utilibase.initialize_db
	#---------------------------------------------------------------------------

	
	#---------------------------------------------------------------------------
	# trace_record
	# Given a record_id, traces if that record is descended from an
	# independent record. If it is, the record is marked as traced. If it isn't
	# then the record and all ancestor records are deleted.
	#
	def trace_record(record_id)
		# Testmin.hr(__method__.to_s + ': ' + record_id)
		
		# get database handle
		dbh = self.dbh
		
		# trace id
		trace_id = SecureRandom.uuid()
		
		# get the record that is being traced
		sql = 'select dependency from current where record_id=:record_id'
		dependency = dbh.select_field(sql, 'record_id'=>record_id)
		
		# if org record doesn't exist, we're done
		if dependency.nil?
			return
		end
		
		# if dependency is not d, we're done
		if dependency != 'd'
			return
		end
		
		# create trace record
		# sql = 'insert into traces (trace_id) values (:trace_id)'
		# dbh.execute(sql, 'trace_id'=>trace_id)
		self.insert_trace_record_sth().execute('trace_id'=>trace_id)
		
		# insert initial record
		self.initial_trace_record_sth.execute('trace_id'=>trace_id,'record_id'=>record_id)
		
		# instantiate statement handle
		insert_sth = self.insert_trace_records_sth()
		
		# get independent_found
		independent_sth = self.independent_found_sth()
		
		# loop until we've traced the record or have stopped finding records to trace
		begin
			# add records
			insert_sth.execute(sql, 'trace_id'=>trace_id)
			
			# get result count
			result_count = dbh.changes
			
			# get trace's independent_found
			independent_found = independent_sth.execute!('trace_id'=>trace_id)
			independent_found = independent_found[0][0]
		end while (result_count > 0) and (independent_found == 0)
		
		# if we did not find an independent record, delete all of the records
		# in trace_records
		if independent_found == 0
			self.delete_untraced_sth().execute('trace_id'=>trace_id)
		
		# else mark just the original record as not unlinked
		else
			self.update_traced_sth().execute('record_id'=>record_id)
		end
	end
	#
	# trace_record
	#---------------------------------------------------------------------------
	
	
	#---------------------------------------------------------------------------
	# record
	# Returns a new utilibase record object.
	#
	def record(record_id)
		# Testmin.hr(__method__.to_s)
		return Utilibase::Record.new(self, record_id)
	end
	#
	# record
	#---------------------------------------------------------------------------
	
	
	#---------------------------------------------------------------------------
	# row
	## Returns the entire record from the "current" table. "jhash" and "links"
	## are parsed. Nil is returned if no such record exists. Unlike
	## <a href="#record">record()</a>, this method returns a hash that contains
	## all the fields in the "current" table. It does <em>not</em> return a
	## record object.
	#
	def row(record_id)
		# Testmin.hr(__method__.to_s)
		
		# get record
		sql = 'select * from current where record_id=:record_id'
		row = dbh.get_first_row(sql, 'record_id'=>record_id)
		
		# if we got a record
		if not row.nil?
			row['jhash'] = JSON.parse(row['jhash'])
			row['links'] = row['links'].split(' ')
		end
		
		# return
		return row
	end
	#
	# row
	#---------------------------------------------------------------------------
	
	
	#---------------------------------------------------------------------------
	# set_unlinked
	## Sets as unlinked all records that have been unlinked from modified or
	## deleted records. Then sets records those records link to, then the
	## records <em>those<em> linked to, etc.
	#
	def set_unlinked()
		# Testmin.hr(__method__.to_s)
		
		# convenience
		dbh = self.dbh
		
		# first, set as unlinked records that were unlinked from updated sources
		self.set_unlinked_updated()
		
		# statement handle to update records as unlinked
		update_initials = self.set_unlinked_sth()
		
		# statement handle to update records as unlinked
		update_recursed = self.set_as_recursed_sth()
		
		# create statement handle
		delete_lc_sth = self.delete_from_links_current_sth()
		
		# sql to find initially unlinked records
		sql = <<~SQL
		select record_id, links
		from   current
		where  unlinked = 'i'
		SQL
		
		# loop through records, setting linked records as unlinked
		begin
			# initialize updated_count
			updated_count = 0
			
			# loop through next batch of rows to be recursed
			dbh.execute(sql) do |row|
				row['links'].split(' ').each { |link|
					# update records that have been unlinked
					update_initials.execute('id'=>link)
					updated_count += dbh.changes
					
					# delete links from links_current
					delete_lc_sth.execute('src'=>row['record_id'], 'tgt'=>link)
				}
			end
			
			# update all initialized records to recursed
			update_recursed.execute()
		end while updated_count > 0
	end
	#
	# set_unlinked
	#---------------------------------------------------------------------------
	
	
	#---------------------------------------------------------------------------
	# set_unlinked_updated
	## Set as unlinked records that were unlinked from updated sources.
	#
	def set_unlinked_updated()
		# Testmin.hr(__method__.to_s)
		
		# convenience
		dbh = self.dbh
		
		# create statement handle
		delete_lc_sth = self.delete_from_links_current_sth()
		
		# sql to update current.unlinked
		update_sth = self.update_current_unlinked_sth()
		
		# sql to loop through updated records
		sql = <<~SQL
		select   record_id, links, jhash, update_stat
		from     current
		where    (update_stat='u') and
		         (dependency in ('i', 'd'))
		SQL
		
		# loop through updated records
		dbh.execute(sql) do |row|
			# get unlinked ids
			unlinks = Utilibase::Utils.get_unlinks(row['jhash'], row['links'])
			
			# loop through unlinks
			unlinks.each do |id|
				update_sth.execute(id)
				delete_lc_sth.execute('src'=>row['record_id'], 'tgt'=>id)
			end
		end
	end
	#
	# set_unlinked_updated
	#---------------------------------------------------------------------------
	
	
	#---------------------------------------------------------------------------
	# purge
	## Purge removes all the records that were unlinked during the current
	## transaction.
	#
	def purge()
		# Testmin.hr(__method__.to_s)
		
		# convenience
		dbh = self.dbh
		
		# set unlinked
		self.set_unlinked()
		
		# sql to get unlinked records
		sql = <<~SQL
		select   record_id, unlinked
		from     current
		where    unlinked is not null
		limit    1
		SQL
		
		# loop while we get a record
		while true
			# get next row
			row = dbh.get_first_row(sql)
			
			# if we didn't get a row, we're done
			if row.nil?
				break
			end
			
			# trace record
			self.trace_record(row['record_id'])
		end
	end
	#
	# purge
	#---------------------------------------------------------------------------
	
	
	#---------------------------------------------------------------------------
	# insert_trace_record_sth
	## Creates (if necessary) and returns the statement handle for inserting
	## a record into traces.
	#
	def insert_trace_record_sth()
		# Testmin.hr(__method__.to_s)
		
		# create sth if necessary
		if not @sths.key?('insert_trace_record')
			sql = 'insert into traces (trace_id) values (:trace_id)'
			@sths['insert_trace_record'] = self.dbh.prepare(sql)
		end
		
		# return
		return @sths['insert_trace_record']
	end
	#
	# trace_record_sth
	#---------------------------------------------------------------------------
	
	
	#---------------------------------------------------------------------------
	# set_unlinked_sth
	## Creates (if necessary) and returns the statement handle for marking
	## records as unlinked.
	#
	def set_unlinked_sth()
		# Testmin.hr(__method__.to_s)
		
		# create sth if necessary
		if not @sths.key?('set_unlinked')
			# sql to update records as unlinked
			sql = <<~SQL
			update   current
			set      unlinked = 'i'
			where    record_id = :id and
					 unlinked is null and
					 dependency = 'd'
			SQL
			
			# create and store statement handle
			@sths['set_unlinked'] = self.dbh.prepare(sql)
		end
		
		# return
		return @sths['set_unlinked']
	end
	#
	# set_unlinked_sth
	#---------------------------------------------------------------------------


	#---------------------------------------------------------------------------
	# delete_from_links_current_sth
	## Creates (if necessary) and returns the statement handle for deleting
	## records from links_current as part of the trace process.
	#
	def delete_from_links_current_sth()
		# Testmin.hr(__method__.to_s)
		
		# create sth if necessary
		if not @sths.key?('delete_from_links_current')
			# sql to update records as unlinked
			sql = <<~SQL
			delete from links_current
			where       src_id=:src and
			            tgt_id=:tgt
			SQL
			
			# create and store statement handle
			@sths['delete_from_links_current'] = self.dbh.prepare(sql)
		end
		
		# return
		return @sths['delete_from_links_current']
	end
	#
	# delete_from_links_current_sth
	#---------------------------------------------------------------------------

	
	#---------------------------------------------------------------------------
	# update_current_unlinked_sth
	## Creates (if necessary) and returns the statement handle for deleting
	## records from links_current as part of the trace process.
	#
	def update_current_unlinked_sth()
		# Testmin.hr(__method__.to_s)
		
		# create sth if necessary
		if not @sths.key?('update_current_unlinked')
			# sql
			sql = <<~SQL
			update   current
			set      unlinked = 'i'
			where    dependency = 'd' and
					 record_id = :id
			SQL
			
			# create and store statement handle
			@sths['update_current_unlinked'] = self.dbh.prepare(sql)
		end
		
		# return
		return @sths['update_current_unlinked']
	end
	#
	# update_current_unlinked_sth
	#---------------------------------------------------------------------------

	
	#---------------------------------------------------------------------------
	# set_as_recursed_sth
	## Creates (if necessary) and returns the statement handle for marking
	## records as having been recursed as part of the trace process.
	#
	def set_as_recursed_sth()
		# Testmin.hr(__method__.to_s)
		
		# create sth if necessary
		if not @sths.key?('set_as_recursed')
			# sql to update records as recursed
			sql = <<~SQL
			update   current
			set      unlinked = 'r'
			where    unlinked = 'i'
			SQL
			
			# create and store statement handle
			@sths['set_as_recursed'] = self.dbh.prepare(sql)
		end
		
		# return
		return @sths['set_as_recursed']
	end
	#
	# set_as_recursed_sth
	#---------------------------------------------------------------------------
	
	
	#---------------------------------------------------------------------------
	# initial_trace_record_sth
	## Creates (if necessary) and returns the statement handle for inserting
	## the first record of a trace into trace_records.
	#
	def initial_trace_record_sth()
		# Testmin.hr(__method__.to_s)
		
		# create sth if necessary
		if not @sths.key?('initial_trace_record')
			# sql to insert initial trace record
			sql = <<~SQL
			insert into
				trace_records  ( trace_id,   record_id,   independent  )
				values         ( :trace_id,  :record_id,  0            );
			SQL
			
			# prepare
			@sths['initial_trace_record'] = self.dbh.prepare(sql)
		end
		
		# return
		return @sths['initial_trace_record']
	end
	#
	# initial_trace_record_sth
	#---------------------------------------------------------------------------
	
	
	#---------------------------------------------------------------------------
	# insert_trace_records_sth
	#
	def insert_trace_records_sth()
		# Testmin.hr(__method__.to_s)
		
		# create sth if necessary
		if not @sths.key?('insert_trace_records')
			# SQL to add records to trace_records
			sql = <<~SQL
			insert into
				trace_records (
					trace_id,
					record_id,
					independent
				)
				
				select
					:trace_id as trace_id,
					src_id,
					src_is_independent
				from
					links_current
				where
					tgt_id in (
						select record_id
						from   trace_records
						where  trace_id = :trace_id
					)
					
					and
					
					src_id not in (
						select record_id
						from   trace_records
						where  trace_id = :trace_id
					);
			SQL
			
			# prepare
			@sths['insert_trace_records'] = self.dbh.prepare(sql)
		end
		
		# return
		return @sths['insert_trace_records']
	end
	#
	# insert_trace_records_sth
	#---------------------------------------------------------------------------

	
	#---------------------------------------------------------------------------
	# independent_found_sth
	#
	def independent_found_sth()
		# Testmin.hr(__method__.to_s)
		
		# create sth if necessary
		if not @sths.key?('independent_found')
			# sql to check if an independent record was found
			sql = <<~SQL
			select  independent_found
			from    traces
			where   trace_id = :trace_id
			SQL
			
			# prepare
			@sths['independent_found'] = self.dbh.prepare(sql)
		end
		
		# return
		return @sths['independent_found']
	end
	#
	# independent_found_sth
	#---------------------------------------------------------------------------


	#---------------------------------------------------------------------------
	# update_traced_sth
	#
	def update_traced_sth()
		# Testmin.hr(__method__.to_s)
		
		# create sth if necessary
		if not @sths.key?('update_traced')
			# sql to update records that have been traced
			sql = <<~SQL
			update   current
			set      unlinked = null
			where    record_id=:record_id
			SQL
			
			# prepare
			@sths['update_traced'] = self.dbh.prepare(sql)
		end
		
		# return
		return @sths['update_traced']
	end
	#
	# update_traced_sth
	#---------------------------------------------------------------------------
	
	
	#---------------------------------------------------------------------------
	# delete_untraced_sth
	#
	def delete_untraced_sth()
		# Testmin.hr(__method__.to_s)
		
		# create sth if necessary
		if not @sths.key?('delete_untraced')
			# sql to delete records
			sql = <<~SQL
			delete from
				current
			where
				record_id in (
					select  record_id
					from    trace_records
					where   trace_id = :trace_id
				)
			SQL
			
			# prepare
			@sths['delete_untraced'] = self.dbh.prepare(sql)
		end
		
		# return
		return @sths['delete_untraced']
	end
	#
	# delete_untraced_sth
	#---------------------------------------------------------------------------


end
#
# Utilibase
################################################################################



################################################################################
# Utilibase::DBH
#
class Utilibase::DBH < SQLite3::Database

	# initialize
	# Do not accept non-existent path.
	# Do not accept tainted path.
	# Call super method.
	def initialize(db_path)
		# check path
		Utilibase::Utils.check_db_path(db_path)
		
		# run super method
		super(db_path)
		
		# return results as hash
		self.results_as_hash = true
		
		# enforce foreign key constraints
		self.execute('pragma foreign_keys = on')
		
		# begin transaction
		self.transaction
	end
	
	# execute
	# Do not accept tainted sql.
	# Call super method.
	def execute(sql, bind_vars=[])
		# Testmin.hr(__method__.to_s)
		
		# refuse to run tainted sql
		if sql.tainted?
			raise ExceptionPlus::Internal.new('tainted-sql', 'bmVCL', 'will not run tainted sql')
		end
		
		# run super method
		return super(sql, bind_vars)
	end
	
	# create_db_file
	# dir must exist
	# neither directory nor file name can be tainted
	# file must not exist
	def self.create_db_file(db_dir, db_name)
		# dir must not be tainted
		if db_dir.tainted?
			raise ExceptionPlus::Internal.new('tainted-dir', 'f6G9P', 'directory for new database file is tainted')
		end
		
		# file name must not be tainted
		if db_name.tainted?
			raise ExceptionPlus::Internal.new('tainted-file-name', 'LFZMf', 'file name for new database file is tainted')
		end
		
		# dir must exist
		if not File.directory?(db_dir)
			raise ExceptionPlus::Internal.new('non-existent-dir', 'qkPBp', 'do not have a directory: ' + db_dir)
		end
		
		# full path
		db_dir = db_dir.gsub(/\/$/, '')
		db_path = db_dir + '/' + db_name
		
		# if file already exists, throw exception
		if File.exist?(db_path)
			raise ExceptionPlus::Internal.new('db-file-already-exists', 'QJBqK', 'there is already a database file as ' + db_path)
		end
		
		# touch file
		FileUtils.touch(db_path)
		
		# create database file
		dbh = Utilibase::DBH.new(db_path)
		
		# return
		return dbh
	end
	
	# select_hash
	def select_hash(sql, key_name, bind_vars=[])
		# Testmin.hr(__method__.to_s)
		
		# hold on to current setting for results_as_hash
		results_as_hash_hold = self.results_as_hash
		self.results_as_hash = true
		
		# get query
		rows = self.query(sql, bind_vars);
		
		# initialize return value
		rv = {}
		
		# build hash of results
		while ( row = rows.next )
			rv[row[key_name]] = row
		end
		
		# reset results_as_hash setting
		self.results_as_hash = results_as_hash_hold
		
		# return
		return rv
	end
	
	# select_column
	# returns an array of all the values in the given column
	def select_column(sql, bind_vars=[])
		# Testmin.hr(__method__.to_s)
		
		# initilize return value
		rv = []
		
		# loop through results
		self.execute(sql, bind_vars) do |row|
			rv.push(row[0])
		end
		
		# return
		return rv
	end
	
	# select_field
	# returns a scalar of all the value in the first row in given column
	def select_field(sql, bind_vars=[])
		# Testmin.hr(__method__.to_s)
		
		# initilize return value
		rv = self.select_column(sql, bind_vars)
		rv = rv[0]
		
		# return
		return rv
	end
end
#
# Utilibase::DBH
################################################################################



################################################################################
# ExceptionPlus
#
class ExceptionPlus < StandardError
	# attributes
	attr_reader :error_id
	attr_reader :id

	# initialize
	def initialize(msg_id, msg, opts={})
		# hold on to error id
		@error_id = msg_id

		# generate id for just this instance
		@id = SecureRandom.uuid()

		# call super method
		super(msg_id + ':' + msg)
	end
end
#
# ExceptionPlus
################################################################################


################################################################################
# ExceptionPlus::Internal
#
class ExceptionPlus::Internal < ExceptionPlus
	# attributes
	attr_reader :internal_id

	# initialize
	def initialize(msg_id, internal_id, msg, opts={})
		# hold on to internal id
		@internal_id = internal_id

		# call super method
		super(msg_id, msg, opts)
	end
end
#
# ExceptionPlus
################################################################################



################################################################################
# Utilibase::Utils
#
module Utilibase::Utils
	require 'json'
	
	# randword
	def self.randword(len=8)
		# generate random string
		rv = ('a'..'z').to_a.shuffle[0,len].join
		
		# return
		return rv
	end
	
	# unravel
	def self.unravel(org)
		# Testmin.hr(__method__.to_s)
		
		# initialize carry
		ids = {}
		objects = {}
		
		# call hash unraveler
		# unravel_hash(org, ids, objects)
		if org.is_a?(Hash)
			unravel_hash(org, ids, objects)
		
		# unravel array
		elsif org.is_a?(Array)
			unravel_array(org, ids, objects)
		
		# else error
		else
			raise ExceptionPlus::Internal.new('unravel-not-hash-or-array', 'k1cgC', 'attempt to unravel a structure that is neither a hash nor an array')
		end
		
		# return
		return ids
	end
	
	# unravel_hash
	def self.unravel_hash(org, ids, objects)
		# Testmin.hr(__method__.to_s)
		
		# if we've already processed this object, don't do so again
		if objects[org.object_id]
			return
		end
		
		# note as done
		objects[org.object_id] = true
		
		# if no id, give it one
		if org['$id'].nil?()
			org['$id'] = SecureRandom.uuid()
		end
		
		# store pclone in ids hash
		if ids[org['$id']].nil?
			pclone = {}
			ids[org['$id']] = pclone
		else
			pclone = ids[org['$id']]
			# raise 'not yet implemented redundant hashes'
		end
		
		# loop through keys and values
		org.keys.each do |my_key|
			my_val = org[my_key]
			
			# unravel hash
			if my_val.is_a?(Hash)
				unravel_hash(my_val, ids, objects)
				pclone[my_key] = {'$id' => my_val['$id']}
			
			# unravel array
			elsif my_val.is_a?(Array)
				pclone[my_key] = unravel_array(my_val, ids, objects)
			
			# store scalar value
			else
				pclone[my_key] = my_val
			end
		end
	end
	
	# unravel_array
	def self.unravel_array(org, ids, objects)
		# Testmin.hr(__method__.to_s)
		
		# initialize return value
		rv = []
		
		# loop through elements
		org.each do |my_val|
			# unravel hash
			if my_val.is_a?(Hash)
				unravel_hash(my_val, ids, objects)
				rv.push({'$id' => my_val['$id']})
			
			# unravel array
			elsif my_val.is_a?(Array)
				# initialize new array
				rv.push(unravel_array(my_val, ids, objects))
			
			# store scalar value
			else
				rv.push(my_val)
			end
		end
		
		# return
		return rv
	end
	
	# links array
	def self.links_array(org)
		# Testmin.hr(__method__.to_s)
		
		# initialize ids
		ids = {}
		
		# links_from_hash
		links_from_array(org.values, ids)
		
		# return array of ids
		return ids.keys
	end
	
	# links_from_array
	def self.links_from_array(org, ids)
		# loop through elements
		org.each do |el|
			# hash
			if el.is_a?(Hash)
				ids[el['$id']] = true
				
			# array
			elsif el.is_a?(Array)
				links_from_array(el, ids)
			end
		end
	end
	
	# collapse
	def self.collapse(str)
		# Testmin.hr(__method__.to_s)
		
		# only process defined strings
		if str.is_a?(String) and (not str.nil?())
			str = str.gsub(/\A[ \t\r\n]+/, '')
			str = str.gsub(/[ \t\r\n]+\z/, '')
			str = str.gsub(/[ \t\r\n]+/, ' ')
		end
		
		# return
		return str
	end
	
	# check_db_path
	def self.check_db_path(db_path)
		# Testmin.hr(__method__.to_s)
		
		# path required
		if db_path.nil?
			raise ExceptionPlus::Internal.new('missing-db-path', 'gKpHv', 'missing path')
		end
		
		# path may not be tainted
		if db_path.tainted?
			raise ExceptionPlus::Internal.new('tainted-db-path', 'z7gwj', 'tainted path' + db_path)
		end
		
		# path must exist and not be a directory
		if not FileTest.exist?(db_path)
			raise ExceptionPlus::Internal.new('non-existent-db-file', '6g1Sp', 'do not have file ' + db_path)
		end
	end
	
	# merge_array
	# TO-DO: For now, only merging top-level arrays. Need to carefully work
	# through the logic of arrays nested in arrays.
	def self.merge_arrays(org, input)
		# Testmin.hr(__method__.to_s)
		
		# clone
		input = input.clone
		
		# early exit: input is empty
		if input.length > 0
			# get first element
			first = input[0]
			
			# if first is a hash, it might be an array command
			if first.is_a?(Hash)
				# if the first element is an array command
				if first['$array']
					# remove first element from input
					input.shift()
					
					# add-beginning
					if first['add-to-beginning'] or first['unshift']
						# if org is an array
						if org.is_a?(Array)
							return input + org
						else
							return input + [org]
						end
						
					# add-to-ending
					elsif first['add-to-ending'] or first['push']
						# if org is an array
						if org.is_a?(Array)
							return org + input
						else
							return [org] + input
						end
					end
				end
			end
		end
		
		# return input
		return input
	end

	# merge_jhashes
	# NOTE: This function assumes that these hashes have identical values
	# $id.
	def self.merge_jhashes(jhash_old, jhash_new)
		# Testmin.hr(__method__.to_s)

		# clone old
		jhash_merged = jhash_old.clone
		
		# loop through new keys
		jhash_new.keys.each do |my_key|
			# skip $id and hash commands
			if (my_key == '$id') or (my_key == '$hash')
				next
			end
			
			# convenience variable
			new_val = jhash_new[my_key]
			
			# if new is an array
			if new_val.is_a?(Array)
				jhash_merged[my_key] = Utilibase::Utils.merge_arrays(jhash_old[my_key], new_val)
				
			# else just replace
			else
				jhash_merged[my_key] = jhash_new[my_key]
			end
		end
		
		# hash commands
		if jhash_new.has_key?('$hash')
			hash_command(jhash_merged, jhash_new['$hash'])
		end
		
		# return
		return jhash_merged
	end
	
	# hash_command
	def self.hash_command(rv, command)
		# Testmin.hr(__method__.to_s)
		
		# if command is not a hash, nothing to do
		# TO-DO: Probably should throw an error if the command
		# is defined but not a hash.
		if not command.is_a?(Hash)
			return
		end
		
		# loop through keys
		command.keys.each do |my_key|
			# delete
			if my_key == 'delete'
				my_val = command[my_key]
				
				# defined
				if not my_val.nil?()
					# if not array, make it an array
					if not my_val.is_a?(Array)
						my_val = [my_val]
					end
					
					# loop through fields to be deleted
					my_val.each do |my_field_name|
						if my_field_name.is_a?(String)
							rv.delete(my_field_name)
						end
					end
				end
			end
		end
	end
	
	# unlinks
	def self.get_unlinks(jhash, old_links)
		# Testmin.hr(__method__.to_s)
		
		# ensure jhash is a hash
		if not jhash.is_a?(Hash)
			jhash = JSON.parse(jhash)
		end
		
		# ensure links is an array
		if not old_links.is_a?(Array)
			old_links = old_links.split(' ')
		end
		
		# get list of links from jhash
		new_links = links_array(jhash)
		
		# return
		old_links - new_links
	end
end
#
# Utilibase::Utils
################################################################################


################################################################################
# Utilibase::Record
#
class Utilibase::Record
	# attributes
	attr_reader :db
	attr_reader :id

	# initialize
	def initialize(db, rcrd_id)
		# Testmin.hr(__method__.to_s)

		# check that db is a Utilibase object
		if not db.is_a?(Utilibase)
			raise ExceptionPlus::Internal.new('non-utilibase-db-object', 'DKtkx', 'db param is not a Utilibase object')
		end

		# set attributes
		@db = db
		@id = rcrd_id
	end
	
	# dbh
	def dbh
		return self.db.dbh
	end
	
	# in_db
	def in_db()
		# Testmin.hr(__method__.to_s)
		
		# get record count
		sql = 'select count(*) as rcount from current where record_id=:id'
		record_count = self.dbh.get_first_row(sql, 'id'=>@id)
		
		# return
		return record_count['rcount'] > 0
	end

	# save
	def save(struct={})
		# Testmin.hr(__method__.to_s)

		# add or update
		if self.in_db
			self.update(struct)
		else
			self.save_new(struct)
		end
	end
	
	# save_new
	# NOTE: This method assumes that it is already known that this record does
	# not yet in the database. This method saves a completely new record
	# consisting of just the $id field.
	def save_new(struct={})
		# Testmin.hr(__method__.to_s)
		
		# clone structure because we're going to muck around with it
		struct = struct.clone
		
		# ensure that structure has id
		struct['$id'] = @id
		
		# create json string
		json = JSON.generate(struct)
		
		# sql
		sql = "insert into current(record_id, jhash, links, update_stat) values(:id, :jhash, '', 'n')"
		self.dbh.execute(sql, 'id'=>@id, 'jhash'=>json)
	end
	
	# update
	# NOTE: This method assumes that it is already known that this record
	# - is already in the database
	# - the structure has been unraveled
	def update(struct)
		# Testmin.hr(__method__.to_s)
		
		# clone structure because we're going to muck around with it
		struct = struct.clone
		
		# sql to add old record to history if it hasn't already been added
		sql = <<~SQL
		insert into
			history(
				version_id,
				record_id,
				jhash,
				links
			)
			
			select
				:version_id,
				record_id,
				jhash,
				links
			from
				current
			where
				record_id = :record_id and
				update_stat is null;
		SQL
		
		# add old record to history if this is the first update to is
		self.dbh.execute(sql, 'version_id'=>SecureRandom.uuid(), 'record_id'=>self.id)
		
		# get existing values
		sql = "select jhash from current where record_id=:id";
		existing = self.dbh.get_first_row(sql, 'id'=>self.id)
		existing = existing[0]
		
		# should have gotten existing
		if existing.nil?
			raise ExceptionPlus::Internal.new('no-existing-record', 'tVkzR', 'did not get record that is supposed to exist')
		end
		
		# parse json
		existing = JSON.parse(existing)
		
		# merge
		struct = Utilibase::Utils.merge_jhashes(existing, struct)
		
		# ensure that structure has $id
		struct['$id'] = self.id
		
		# get links
		links = Utilibase::Utils.links_array(struct)
		links = links.join(' ')
		
		# sql to update
		sql = <<~SQL
		update  current
		set     jhash=:jhash,
		        links=:links,
		        update_stat = case when update_stat is null then 'u' else update_stat end
		where
		        record_id = :id
		SQL
		
		# update
		self.dbh.execute(
			sql,
			'links'=>links,
			'jhash'=>JSON.generate(struct),
			'id'=>self.id,
		)
	end
	
	# get_jhash
	def get_jhash()
		# Testmin.hr(__method__.to_s)
		
		# if already in db
		if self.in_db()
			sql = 'select jhash from current where record_id=:id'
			jhash = self.dbh.get_first_row(sql, 'id'=>self.id)
			jhash = jhash[0]
			jhash = JSON.parse(jhash)
			return jhash
		else
			return {}
		end
	end
	
	# get_fields
	def get_field(field_names)
		# Testmin.hr(__method__.to_s)
		
		# ensure field_names is an array
		if not field_names.is_a?(Array)
			field_names = [field_names]
		end
		
		# build sql
		sql = 'select jhash from current where record_id=:id'
		jhash = self.dbh.get_first_row(sql, 'id'=>self.id)
		jhash = jhash[0]
		
		# should have gotten a jhash
		if jhash.nil?
			raise ExceptionPlus::Internal.new('get-fields~no-record', 'VxCd8', 'get_fields did not find the record in the database')
		end
		
		# parse jhash
		jhash = JSON.parse(jhash)
		
		# should be a hash
		if not jhash.is_a?(Hash)
			raise ExceptionPlus::Internal.new('get-fields~jhash-not-hash', 'D32bQ', 'get_fields did not get a hash for jhash')
		end
		
		# initialize return hash
		rv = {}
		
		# loop through field names
		field_names.each do |my_key|
			if jhash.key?(my_key)
				rv[my_key] = jhash[my_key]
			end
		end
		
		# return
		return rv
	end
	
	# alias get_fields to get_field
	alias_method :get_fields, :get_field
	
	# delete
	def delete()
		# Testmin.hr(__method__.to_s)
		
		# sql
		sql = <<~SQL
		insert into
			history(
				version_id,
				record_id,
				jhash,
				links
			)
			
			select
				:version_id,
				record_id,
				jhash,
				links
			from
				current
			where
				record_id = :record_id and
				update_stat is null;
		SQL
		
		# run insert state
		self.dbh.execute(sql, 'version_id'=>SecureRandom.uuid(), 'record_id'=>self.id)
		
		# delete record from current
		sql = 'delete from current where record_id=:id'
		self.dbh.execute(sql, 'id'=>self.id)
	end
	
	# row
	def row()
		# Testmin.hr(__method__.to_s)
		return self.db.row(self.id)
	end
end
#
# Utilibase::Record
################################################################################



#-------------------------------------------------------------------------------
# run server
# run the server if this file was executed directly instead of being required
#
if caller().length <= 0
	puts 'running server'
end
#
# run server
#-------------------------------------------------------------------------------
