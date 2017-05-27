#!/usr/bin/ruby -w
system 'clear' unless ENV['clear_done']
require_relative '../testing-lib.rb'

# load modules
$SAFE = 1

# done
TestMin.done()
