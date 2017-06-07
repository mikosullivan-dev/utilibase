#!/usr/bin/ruby -w
system 'clear' unless ENV['clear_done']
require_relative '../testing.lib.rb'

# enable taint mode
$SAFE = 1

# reset directory
UtilibaseTesting.reset_db_dir()

# done
# puts '[done]'
Testmin.done()
