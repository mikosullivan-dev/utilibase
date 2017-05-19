#!/usr/bin/ruby -w
system 'clear' unless ENV['clear_done']
require_relative '../testmin.rb'
require_relative '../testing-lib.rb'

# enable taint mode
$SAFE = 1

# purpose: test merging arrays
#	simple replacement in top level array
#	nested array
#	add-to-beginning
#	add-to-ending
#	merge with existing scalar
#		add-to-beginning
#		add-to-ending


# uuids
fruit = SecureRandom.uuid()
apple = SecureRandom.uuid()



#------------------------------------------------------------------------------
# input is empty array
#
if true
	puts 'input is empty array'
	
	# original structure
	org = ['a', 'b', 'c', {'$uuid'=>fruit}]
	input = []
	
	# merge
	merged = Utilibase::Utils.merge_arrays(org, input)
	
	# check
	UtilibaseTesting.comp('input is empty array', merged.length, 0)
end
#
# input is empty array
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# simple replacement in top level array
#
if true
	puts 'simple replacement in top level array'
	
	# original structure
	org = ['a', 'b', 'c', {'$uuid'=>fruit}]
	input = [{'$uuid'=>apple}, 'd', 'e', 'f', 'g', 'h']
	
	# merge
	merged = Utilibase::Utils.merge_arrays(org, input)
	
	# check
	UtilibaseTesting.comp('simple replacement in top level array', merged.length, 6)
end
#
# simple replacement in top level array
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# add-to-beginning
#
if true
	puts 'add-to-beginning'
	
	# original structure
	org = ['a', 'b', 'c', 'd']
	input = [{'$array'=>true, 'add-to-beginning'=>true}, 1, 2, 3, 4, 5, 6]
	
	# merge
	merged = Utilibase::Utils.merge_arrays(org, input)
	
	# remove first element of input
	input.shift
	
	# check
	UtilibaseTesting.comp('add-to-beginning', merged.length, 10)
	UtilibaseTesting.comp_arrays('add-to-beginning- compare', merged, input + org)
end
#
# add-to-beginning
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# add-to-ending
#
if true
	puts 'add-to-ending'
	
	# original structure
	org = ['first org', '2', '3', 'last org']
	input = [{'$array'=>true, 'add-to-ending'=>true}, 5, 6, 7, 8, 9, 'last input']
	
	# merge
	merged = Utilibase::Utils.merge_arrays(org, input)
	
	# remove first element of input
	input.shift
	
	# check
	UtilibaseTesting.comp('add-to-ending - count', merged.length, 10)
	UtilibaseTesting.comp_arrays('add-to-ending - compare', merged, org + input)
end
#
# add-to-ending
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# merge with existing scalar: add-to-beginning
#
if true
	puts 'merge with existing scalar: add-to-beginning'
	
	# original structure
	org = 'first org'
	input = [{'$array'=>true, 'add-to-beginning'=>true}, 2, 3, 4, 5, 6, 'last input']
	
	# merge
	merged = Utilibase::Utils.merge_arrays(org, input)
	
	# remove first element of input
	input.shift
	
	# check
	UtilibaseTesting.comp('add-to-ending - count', merged.length, 7)
	UtilibaseTesting.comp_arrays('add-to-ending - compare', merged, input + [org])
end
#
# merge with existing scalar: add-to-beginning
#------------------------------------------------------------------------------



#------------------------------------------------------------------------------
# merge with existing scalar: add-to-ending
#
if true
	puts 'merge with existing scalar: add-to-ending'
	
	# original structure
	org = 'first org'
	input = [{'$array'=>true, 'add-to-ending'=>true}, 2, 3, 4, 5, 6, 'last input']
	
	# merge
	merged = Utilibase::Utils.merge_arrays(org, input)
	
	# remove first element of input
	input.shift
	
	# check
	UtilibaseTesting.comp('add-to-ending - count', merged.length, 7)
	UtilibaseTesting.comp_arrays('add-to-ending - compare', merged, [org] + input)
end
#
# merge with existing scalar: add-to-ending
#------------------------------------------------------------------------------



# done
# puts '[done]'
TestMin.done()
