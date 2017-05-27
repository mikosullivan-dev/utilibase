#!/usr/bin/ruby -w
system 'clear' unless ENV['clear_done']
require_relative '../testmin.rb'
require_relative '../testing.lib.rb'

# enable taint mode
$SAFE = 1

# purpose: test unraveling an input hash structure


#------------------------------------------------------------------------------
# org
#
org = {
	'name' => 'org',
	'fruit' => {
		'name' => 'fruit',
		'apple' => {
			'name' => 'apple',
			'color' => 'red',
			'taste' => 'tart',
			'distributor' => {'$uuid' => '1bf14725-554b-448c-9f04-62b51a7808a1'},
		},
		
		'grape' => {
			'name' => 'grape',
			'stores' => ['Kroger', 'Food Lion', {'store'=>'Dart', 'name'=>'dart'}],
			'color' => 'purple',
			'taste' => 'sweet',
			'distributor' => {'$uuid' => '1bf14725-554b-448c-9f04-62b51a7808a1'},
		},
		
		'stages' => ['early', 'timely', 'late'],
	},
	
	'distributor' => {
		'$uuid' => '1bf14725-554b-448c-9f04-62b51a7808a1',
		'name' => 'distributor',
	},
}
#
# org
#------------------------------------------------------------------------------

# call unravel
unraveled = Utilibase::Utils.unravel(org)

# initialize by_name
by_name = {}

# build hash of rexcords by name
unraveled.values.each do |my_val|
	by_name[my_val['name']] = my_val
end


#------------------------------------------------------------------------------
# comp_uuids
#
def comp_uuids(test_name, is, should)
	return UtilibaseTesting.comp(test_name, is['$uuid'], should['$uuid'])
end
#
# comp_uuids
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# org
#
if true
	TestMin.hr 'org'
	el = by_name['org']
	
	# tests
	comp_uuids('org => fruit', el['fruit'], by_name['fruit'])
	
	# should hash
	should_hash = {
		'$uuid'       => el['$uuid'],
		'name'        => 'org',
		'fruit'       => {'$uuid'=>by_name['fruit']['$uuid']},
		'distributor' => {'$uuid'=>by_name['distributor']['$uuid']},
	}
	
	# compare
	UtilibaseTesting.comp_hash('org hash', el, should_hash)
end
#
# org
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# fruit
#
if true
	TestMin.hr 'fruit'
	el = by_name['fruit']
	
	# check uuids
	comp_uuids('fruit => apple', el['apple'], by_name['apple'])
	comp_uuids('fruit => grape', el['grape'], by_name['grape'])
	
	# build hash for should
	should_hash = {
		'$uuid'=>el['$uuid'],
		'name'=>'fruit',
		'apple'=>{'$uuid'=>by_name['apple']['$uuid']},
		'grape'=>{'$uuid'=>by_name['grape']['$uuid']},
		'stages' => ['early', 'timely', 'late'],
	}
	
	# compare
	UtilibaseTesting.comp_hash('fruit hash', el, should_hash)
end
#
# fruit
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# apple
#
if true
	TestMin.hr 'apple'
	el = by_name['apple']
	
	# build hash for should
	should_hash = {
		'$uuid'=>el['$uuid'],
		'name' => 'apple',
		'color' => 'red',
		'taste' => 'tart',
		'distributor' => {'$uuid'=>by_name['distributor']['$uuid']},
	}
	
	# compare
	UtilibaseTesting.comp_hash('apple hash', el, should_hash)
end
#
# apple
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# grape
#
if true
	TestMin.hr 'grape'
	el = by_name['grape']
	
	# build hash for should
	should_hash = {
		'$uuid'=>el['$uuid'],
		'name' => 'grape',
		'stores' => ['Kroger', 'Food Lion', {'$uuid'=>by_name['dart']['$uuid']}],
		'color' => 'purple',
		'taste' => 'sweet',
		'distributor' => {'$uuid'=>by_name['distributor']['$uuid']},
	}
	
	# compare
	UtilibaseTesting.comp_hash('grape hash', el, should_hash)
end
#
# grape
#------------------------------------------------------------------------------



# done
# puts '[done]'
TestMin.done()
