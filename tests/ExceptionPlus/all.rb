#!/usr/bin/ruby -w
system 'clear' unless ENV['clear_done']
require_relative '../testmin.rb'
require_relative '../testing-lib.rb'

# enable taint mode
$SAFE = 1

# tests
# basic
# internal


#------------------------------------------------------------------------------
# ExceptionPlus
#
if true
	puts 'ExceptionPlus'
	mye = ExceptionPlus.new('my-id', 'my message')
	UtilibaseTesting.error_id('basic error id', mye, 'my-id')
	UtilibaseTesting.is_internal('internal - is internal', mye, {'should'=>false})
	
	# raise exception
	begin
		raise mye
	rescue ExceptionPlus::Internal => epi
		raise 'should not have gotten to ExceptionPlus::Internal'
	rescue ExceptionPlus => ep
	rescue Exception => e
		raise 'should not have gotten to Exception'
	end
end
#
# ExceptionPlus
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# ExceptionPlus::Internal
#
if true
	puts 'ExceptionPlus::Internal'
	
	# create and test exception
	my_internal_id = Utilibase::Utils.randword()
	mye = ExceptionPlus::Internal.new('my-public-id', my_internal_id, 'my message')
	UtilibaseTesting.error_id('internal - error id', mye, 'my-public-id')
	UtilibaseTesting.is_internal('internal - is internal', mye)
	UtilibaseTesting.internal_id('internal - internal_id', mye, my_internal_id)
	
	# raise exception
	begin
		raise mye
	rescue ExceptionPlus::Internal => epi
	rescue ExceptionPlus => ep
		raise 'should not have gotten to ExceptionPlus'
	rescue Exception => e
		raise 'should not have gotten to Exception'
	end
end
#
# ExceptionPlus::Internal
#------------------------------------------------------------------------------


# done
# puts '[done]'
TestMin.done()
