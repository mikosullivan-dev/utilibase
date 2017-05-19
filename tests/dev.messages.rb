#!/usr/bin/ruby -w
system 'clear' unless ENV['clear_done']
require_relative './testmin.rb'

# submit results
puts TestMin.message('submit-results', TestMin.settings['submit-site'])
