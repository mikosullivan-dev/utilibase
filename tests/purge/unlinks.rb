#!/usr/bin/ruby -w
system 'clear' unless ENV['clear_done']
require_relative '../testing.lib.rb'

# enable taint mode
$SAFE = 1

# purpose: test getting a list of unlinked records
# from an old links field and a new jhash

# config: keep links
keep_links = [ SecureRandom.uuid(), SecureRandom.uuid(), SecureRandom.uuid()]
old_links = [ SecureRandom.uuid(), SecureRandom.uuid(), SecureRandom.uuid()]
new_links = [ SecureRandom.uuid(), SecureRandom.uuid(), SecureRandom.uuid()]

# TESTING
# puts ['a', 'b', 'c'].sort == ['a', 'c', 'b'].sort
# exit

# jhash
jhash =
	'{' +
	'"$id":"6b3e967d-b736-4151-a64d-72cbaa77c047", ' +
	'"phones":[' +
		'{"$id":"' + (keep_links + new_links).join('"}, {"$id":"') + '"}' +
		']' +
	'}'

# send_links
send_links = (keep_links + old_links).join(' ')

# call unlinks function
unlinked_links = Utilibase::Utils.get_unlinks(jhash, send_links)

# old_links should be same as unlinked_links
UtilibaseTesting.bool(
	'old_links and unlinked_links',
	(old_links.sort == unlinked_links.sort),
	true
)


# done
# puts '[done]'
Testmin.done()
