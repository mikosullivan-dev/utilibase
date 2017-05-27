#!/usr/bin/ruby -w
system 'clear' unless ENV['clear_done']
require_relative '../testmin.rb'
require_relative '../testing-lib.rb'

# enable taint mode
$SAFE = 1

# purpose: test unraveling an input hash structure


#------------------------------------------------------------------------------
# org
#
by_name = {
	'apple' => SecureRandom.uuid(),
	'grape' => SecureRandom.uuid(),
	'dart' => SecureRandom.uuid(),
	'wheel' => SecureRandom.uuid(),
}

org = {
	'$uuid' => by_name['org'],
	'name' => 'org',
	
	'fruit' => [
		{'$uuid' => by_name['apple']},
		{'$uuid' => by_name['grape']},
		[ 1, {'$uuid' => by_name['dart']}, [[{'$uuid' => by_name['grape']}]], 'send me on my way'],
	],
	
	'idea' => {'$uuid'=>by_name['wheel']},
}
#
# org
#------------------------------------------------------------------------------


# get array, sort
got = Utilibase::Utils.links_array(org)
got = got.sort

# build should
should = [
	by_name['apple'],
	by_name['grape'],
	by_name['dart'],
	by_name['wheel'],
]

# sort should
should = should.sort

# compare
if got != should
	raise 'links-array-fail'
end

# done
# puts '[done]'
TestMin.done()
