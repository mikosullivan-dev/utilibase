#!/usr/bin/ruby -w
system 'clear' unless ENV['clear_done']
require_relative '../testing-lib.rb'

# enable taint mode
$SAFE = 1

# collapse
str = " x \n y	z "
puts str
str = Utilibase::Utils.collapse(str)
puts str
