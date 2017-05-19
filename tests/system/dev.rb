#!/usr/bin/ruby -w
# system 'clear' unless ENV['clear_done']

# enable taint mode
$SAFE = 1

# output results
puts '{"testmin-success":false, "whatever":1}'
