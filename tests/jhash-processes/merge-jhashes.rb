#!/usr/bin/ruby -w
require_relative '../testing.lib.rb'

# enable taint mode
$SAFE = 1

# purpose: test merging hashes
#	d addition of element
#	deletion of element
#	replacement of element
#	merge array


# ids
fruit = SecureRandom.uuid()


#------------------------------------------------------------------------------
# addition of element
#
if true
	puts 'addition of element'
	
	# original structure
	org = {'$id'=>fruit, 'a'=>1}
	input = {'$id'=>fruit, 'b'=>2}
	
	# merge
	merged = Utilibase::Utils.merge_jhashes(org, input)
	
	# should
	should = {'$id'=>fruit, 'a'=>1, 'b'=>2}
	
	# check
	UtilibaseTesting.comp_hash('addition of element', merged, should)
end
#
# addition of element
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# deletion of single element
#
if true
	puts 'deletion of single element'
	
	# original structure
	org = {'$id'=>fruit, 'a'=>1, 'b'=>2, 'c'=>3, 'd'=>4}
	input = {'$id'=>fruit, '$hash'=>{'delete'=>'a'}}
	
	# merge
	merged = Utilibase::Utils.merge_jhashes(org, input)
	
	# should
	should = {'$id'=>fruit, 'b'=>2, 'c'=>3, 'd'=>4}
	
	# check
	UtilibaseTesting.comp_hash('deletion of single element', merged, should)
end
#
# deletion of single element
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# deletion of multiple elements
#
if true
	puts 'deletion of multiple elements'
	
	# original structure
	org = {'$id'=>fruit, 'a'=>1, 'b'=>2, 'c'=>3, 'd'=>4}
	input = {'$id'=>fruit, '$hash'=>{'delete'=>['a', 'b']}}
	
	# merge
	merged = Utilibase::Utils.merge_jhashes(org, input)
	
	# should
	should = {'$id'=>fruit, 'c'=>3, 'd'=>4}
	
	# check
	UtilibaseTesting.comp_hash('deletion of multiple elements', merged, should)
end
#
# deletion of single element
#------------------------------------------------------------------------------


# done
# puts '[done]'
Testmin.done()
