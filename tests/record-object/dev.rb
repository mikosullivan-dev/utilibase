#!/usr/bin/ruby -w
system 'clear' unless ENV['clear_done']
require_relative '../testing-lib.rb'


# enable taint mode
$SAFE = 1

old_hash = {'a'=>'old', 'b'=>'this is b'}
new_hash = {'a'=>'new'}

puts old_hash.merge(new_hash)
