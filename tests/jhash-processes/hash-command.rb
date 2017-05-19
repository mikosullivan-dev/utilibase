#!/usr/bin/ruby -w
system 'clear' unless ENV['clear_done']
require_relative '../testmin.rb'
require_relative '../testing-lib.rb'

# enable taint mode
$SAFE = 1

# purpose: test merging hashes
#	d addition of element
#	deletion of element
#	replacement of element
#	merge array


# uuids
fruit = SecureRandom.uuid()


#------------------------------------------------------------------------------
# deletion of single element
#
if true
	puts 'deletion of element'
	
	# original structure
	rv = {'$uuid'=>fruit, 'a'=>1, 'b'=>2, 'c'=>3}
	command = {'delete'=>'a'}
	
	# delete
	Utilibase::Utils.hash_command(rv, command)
	
	# should
	should = {'$uuid'=>fruit, 'b'=>2, 'c'=>3}
	
	# check
	UtilibaseTesting.comp_hash('deletion of single element', rv, should)
end
#
# deletion of single element
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# deletion of array of elements
#
if true
	puts 'deletion of array of elements'
	
	# original structure
	rv = {'$uuid'=>fruit, 'a'=>1, 'b'=>2, 'c'=>3, 'd'=>4}
	command = {'delete'=>['a', 'd']}
	
	# delete
	Utilibase::Utils.hash_command(rv, command)
	
	# should
	should = {'$uuid'=>fruit, 'b'=>2, 'c'=>3}
	
	# check
	UtilibaseTesting.comp_hash('deletion of arrays of elements', rv, should)
end
#
# deletion of array of elements
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# nil as key
#
if true
	puts 'nil as key'
	
	# original structure
	rv = {'$uuid'=>fruit, 'a'=>1, 'b'=>2, 'c'=>3, 'd'=>4}
	command = {'delete'=>['a', nil]}
	
	# delete
	Utilibase::Utils.hash_command(rv, command)
	
	# should
	should = {'$uuid'=>fruit, 'b'=>2, 'c'=>3, 'd'=>4}
	
	# check
	UtilibaseTesting.comp_hash('nil as key', rv, should)
end
#
# nil as key
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# no hash command
#
if true
	puts 'no hash command'
	
	# original structure
	rv = {'$uuid'=>fruit, 'a'=>1, 'b'=>2, 'c'=>3, 'd'=>4}
	command = nil
	
	# delete
	Utilibase::Utils.hash_command(rv, command)
	
	# should
	should = {'$uuid'=>fruit, 'a'=>1, 'b'=>2, 'c'=>3, 'd'=>4}
	
	# check
	UtilibaseTesting.comp_hash('no hash command', rv, should)
end
#
# no hash command
#------------------------------------------------------------------------------


# done
# puts '[done]'
TestMin.done()
