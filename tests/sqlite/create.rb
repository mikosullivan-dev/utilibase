#!/usr/bin/ruby -w
require_relative '../testing.lib.rb'

# enable taint mode
$SAFE = 1

# purpose: test creating and successfully connecting to a database
# d directory name cannot be tainted
# d file name cannot be tainted
# d directory must exist
# d file must not already exist
# d successful creation



#------------------------------------------------------------------------------
# directory name cannot be tainted
#
if true
	Testmin.hr 'directory name cannot be tainted'
	
	# create and taint directory name
	db_dir = Utilibase::Utils.randword()
	db_dir.taint
	
	# call function
	begin
		Utilibase::DBH.create_db_file(db_dir, 'xxx')
		raise 'previous operation should have thrown exception'
	rescue ExceptionPlus::Internal => e
		UtilibaseTesting.error_id 'error id', e, 'tainted-dir'
		UtilibaseTesting.is_internal 'is internal', e
		UtilibaseTesting.internal_id 'internal id', e, 'f6G9P'
	rescue ExceptionPlus => e
		raise 'should not have gotten ExceptionPlus'
	rescue StandardError => e
		raise 'should not have gotten plain exception'
	end
end
#
# directory name cannot be tainted
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# file name cannot be tainted
#
if true
	Testmin.hr 'file name cannot be tainted'
	
	# create file name and path
	db_file = Utilibase::Utils.randword()
	db_path = UtilibaseTesting.db_path(db_file)
	
	# ensure file is deleted
	FileUtils.rm_rf(db_path) or die $!
	
	# taint file name
	db_file.taint
	
	# call function
	begin
		Utilibase::DBH.create_db_file($ut_testing['test_dir'], db_file)
		raise 'previous operation should have thrown exception'
	rescue ExceptionPlus::Internal => e
		UtilibaseTesting.error_id 'error id', e, 'tainted-file-name'
		UtilibaseTesting.is_internal 'is internal', e
		UtilibaseTesting.internal_id 'internal id', e, 'LFZMf'
	rescue ExceptionPlus => e
		raise 'should not have gotten ExceptionPlus'
	rescue StandardError => e
		puts e
		raise 'should not have gotten plain exception'
	end
	
	# TESTING
	# Testmin.devexit
end
#
# file name may not be tainted
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# directory must exist
#
if true
	Testmin.hr 'directory must exist'
	
	# create directory path
	db_dir = Utilibase::Utils.randword()
	
	# call function
	begin
		Utilibase::DBH.create_db_file(db_dir, 'xxx')
		raise 'previous operation should have thrown exception'
	rescue ExceptionPlus::Internal => e
		UtilibaseTesting.error_id 'error id', e, 'non-existent-dir'
		UtilibaseTesting.is_internal 'is internal', e
		UtilibaseTesting.internal_id 'internal id', e, 'qkPBp'
	rescue ExceptionPlus => e
		raise 'should not have gotten ExceptionPlus'
	rescue StandardError => e
		raise 'should not have gotten plain exception'
	end
end
#
# directory must exist
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# file must not already exist
#
if true
	Testmin.hr 'file must not already exist'
	
	# create file name and path
	db_file = Utilibase::Utils.randword()
	db_path = UtilibaseTesting.db_path(db_file)
	
	# touch file
	FileUtils.touch(db_path) or die $!
	
	# call function
	begin
		Utilibase::DBH.create_db_file($ut_testing['test_dir'], db_file)
		raise 'previous operation should have thrown exception'
	rescue ExceptionPlus::Internal => e
		UtilibaseTesting.error_id 'error id', e, 'db-file-already-exists'
		UtilibaseTesting.is_internal 'is internal', e
		UtilibaseTesting.internal_id 'internal id', e, 'QJBqK'
	rescue ExceptionPlus => e
		raise 'should not have gotten ExceptionPlus'
	rescue StandardError => e
		raise 'should not have gotten plain exception'
	end
end
#
# file must not already exist
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# successful database file creation
#
if true
	Testmin.hr 'successful database file creation'
	
	# create file name and path
	db_file = Utilibase::Utils.randword()
	db_path = UtilibaseTesting.db_path(db_file)
	
	# create database file
	dbh = Utilibase::DBH.create_db_file($ut_testing['test_dir'], db_file)
	
	# file should exist
	if not File.exist?(db_path)
		raise 'db-file-not-exist: database should exist but does not'
	end
	
	# test that dbh is an sqlite database handle
	UtilibaseTesting.isa('isa', dbh, SQLite3::Database)
end
#
# successful database file creation
#------------------------------------------------------------------------------



# done
# puts '[done]'
Testmin.done()
