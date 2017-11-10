#!/usr/bin/ruby -w
require_relative '../testing.lib.rb'

# enable taint mode
$SAFE = 1

# tests
# basic
# internal


#------------------------------------------------------------------------------
# StandardErrorPlus
#
if true
	puts 'StandardErrorPlus'
	mye = StandardErrorPlus.new('my-id', 'my message')
	UtilibaseTesting.error_id('basic error id', mye, 'my-id')
	UtilibaseTesting.is_internal('internal - is internal', mye, {'should'=>false})
	
	# raise exception
	begin
		raise mye
	rescue StandardErrorPlus::Internal => epi
		raise 'should not have gotten to StandardErrorPlus::Internal'
	rescue StandardErrorPlus => ep
	rescue Exception => e
		raise 'should not have gotten to Exception'
	end
end
#
# StandardErrorPlus
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# StandardErrorPlus::Internal
#
if true
	puts 'StandardErrorPlus::Internal'
	
	# create and test exception
	my_internal_id = Utilibase::Utils.randword()
	mye = StandardErrorPlus::Internal.new('my-public-id', my_internal_id, 'my message')
	UtilibaseTesting.error_id('internal - error id', mye, 'my-public-id')
	UtilibaseTesting.is_internal('internal - is internal', mye)
	UtilibaseTesting.internal_id('internal - internal_id', mye, my_internal_id)
	
	# raise exception
	begin
		raise mye
	rescue StandardErrorPlus::Internal => epi
	rescue StandardErrorPlus => ep
		raise 'should not have gotten to StandardErrorPlus'
	rescue Exception => e
		raise 'should not have gotten to Exception'
	end
end
#
# StandardErrorPlus::Internal
#------------------------------------------------------------------------------


# done
# puts '[done]'
Testmin.done()
