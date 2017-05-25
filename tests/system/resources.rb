#!/usr/bin/ruby -w
system 'clear' unless ENV['clear_done']
require_relative '../testmin.rb'
require_relative '../testing.config.rb'
require 'fileutils'

# load built-in ruby modules
require 'sqlite3'

# enable taint mode
$SAFE = 1

# purpose: test that the system has the resources that are necessary to run
# Utilibase
#	sqlite3
#		installed
#		minimum version
#	sqlite3 gem
#		minimum version

# NOTE: This script does not load utilibase.rb or testing.lib.rb.

# initialize details hash, which will be saved to log
details = {}


#-------------------------------------------------------------------------------
# check if sqlite3 is installed
# This test simply checks if the command sqlite3 is in the command path. Maybe
# there's a more reliable way to test if SQLite3 is installed?
#

# get path to the command sqlite3
sqlite_which = `which sqlite3`

# if we don't get a path, assume that means SQLite3 isn't installed
if sqlite_which.length == 0
	puts 'SQLite3-not-installed: sqlite3 is not installed'
	exit
end

#
# check if sqlite3 is installed
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
# check sqlite and sqlite3 gem minimum versions
# NOTE: We could just require utilibase.rb, but we want to isolate just the
# tests for the sqlite3 package and gem. For that reason we manually read
# through the file to get the required minimum versions.
#

# note SQLite gem version
details['sqlite-gem-version'] = SQLite3::VERSION

# check SQLite3 gem
File.readlines('../' + $ut_testing['utilibase_path']).each do |line|
	if line.match(/\A\s*SQLITE_GEM_MIN_VERSION\b/)
		# parse out minimum version
		min = line.gsub(/\A\s*SQLITE_GEM_MIN_VERSION\s*\=\s*/, '')
		min = min.gsub(/'/, '')
		min = min.gsub(/\n.*/, '')
		
		# check againt actual version
		if Gem::Version.new(SQLite3::VERSION) < Gem::Version.new(min)
			# output error
			puts (
				'min-sqlite-gem-version: ' +
				'SQLite gem version is ' + SQLite3::VERSION + ' ' +
				'but must be at least ' + min
			)
			
			# we're done
			exit
		end
		
		break
	end
end

# note SQLite version
details['sqlite-version'] = SQLite3::SQLITE_VERSION

# check SQLite3
File.readlines('../' + $ut_testing['utilibase_path']).each do |line|
	if line.match(/\A\s*SQLITE_MIN_VERSION\b/)
		# parse out minimum version
		min = line.gsub(/\A\s*SQLITE_MIN_VERSION\s*\=\s*/, '')
		min = min.gsub(/'/, '')
		min = min.gsub(/\n.*/, '')
		
		# check again actual version
		if Gem::Version.new(SQLite3::SQLITE_VERSION) < Gem::Version.new(min)
			# output error
			puts (
				'min-sqlite-version: ' +
				'SQLite version is ' + SQLite3::SQLITE_VERSION + ' ' +
				'but must be at least ' + min
			)
			
			# we're done
			exit
		end
		
		break
	end
end

#
# check sqlite and sqlite3 gem minimum versions
#-------------------------------------------------------------------------------


# TESTING
# sleep 100000

# done
# puts '[done]'
TestMin.done(details)
