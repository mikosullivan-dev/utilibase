#!/usr/bin/ruby -w
system 'clear' unless ENV['clear_done']
require_relative './testmin.rb'


puts TestMin.submit_ask()


__END__

# yes_no_details
TestMin.yes_no_details(
	TestMin.message('submit-request', TestMin.settings['submit-site']),
)
