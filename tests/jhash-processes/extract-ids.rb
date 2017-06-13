#!/usr/bin/ruby -w
require_relative '../testing.lib.rb'

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
	'$id' => by_name['org'],
	'name' => 'org',
	
	'fruit' => [
		{'$id' => by_name['apple']},
		{'$id' => by_name['grape']},
		[ 1, {'$id' => by_name['dart']}, [[{'$id' => by_name['grape']}]], 'send me on my way'],
	],
	
	'idea' => {'$id'=>by_name['wheel']},
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
Testmin.done()
