#!/usr/bin/ruby -w
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
			'distributor' => {'$id' => '1bf14725-554b-448c-9f04-62b51a7808a1'},
		},
		
		'grape' => {
			'name' => 'grape',
			'stores' => ['Kroger', 'Food Lion', {'store'=>'Dart', 'name'=>'dart'}],
			'color' => 'purple',
			'taste' => 'sweet',
			'distributor' => {'$id' => '1bf14725-554b-448c-9f04-62b51a7808a1'},
		},
		
		'stages' => ['early', 'timely', 'late'],
	},
	
	'distributor' => {
		'$id' => '1bf14725-554b-448c-9f04-62b51a7808a1',
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
# comp_ids
#
def comp_ids(test_name, is, should)
	return UtilibaseTesting.comp(test_name, is['$id'], should['$id'])
end
#
# comp_ids
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# org
#
if true
	Testmin.hr 'org'
	el = by_name['org']
	
	# tests
	comp_ids('org => fruit', el['fruit'], by_name['fruit'])
	
	# should hash
	should_hash = {
		'$id'       => el['$id'],
		'name'        => 'org',
		'fruit'       => {'$id'=>by_name['fruit']['$id']},
		'distributor' => {'$id'=>by_name['distributor']['$id']},
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
	Testmin.hr 'fruit'
	el = by_name['fruit']
	
	# check ids
	comp_ids('fruit => apple', el['apple'], by_name['apple'])
	comp_ids('fruit => grape', el['grape'], by_name['grape'])
	
	# build hash for should
	should_hash = {
		'$id'=>el['$id'],
		'name'=>'fruit',
		'apple'=>{'$id'=>by_name['apple']['$id']},
		'grape'=>{'$id'=>by_name['grape']['$id']},
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
	Testmin.hr 'apple'
	el = by_name['apple']
	
	# build hash for should
	should_hash = {
		'$id'=>el['$id'],
		'name' => 'apple',
		'color' => 'red',
		'taste' => 'tart',
		'distributor' => {'$id'=>by_name['distributor']['$id']},
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
	Testmin.hr 'grape'
	el = by_name['grape']
	
	# build hash for should
	should_hash = {
		'$id'=>el['$id'],
		'name' => 'grape',
		'stores' => ['Kroger', 'Food Lion', {'$id'=>by_name['dart']['$id']}],
		'color' => 'purple',
		'taste' => 'sweet',
		'distributor' => {'$id'=>by_name['distributor']['$id']},
	}
	
	# compare
	UtilibaseTesting.comp_hash('grape hash', el, should_hash)
end
#
# grape
#------------------------------------------------------------------------------



# done
# puts '[done]'
Testmin.done()
