#!/usr/bin/ruby -w

# enable taint mode
$SAFE = 1

# callee_path
callee_path = './dev.callee.rb'

begin
	mycode = IO.read(callee_path)
	mycode.untaint
	myclass = eval(mycode)
rescue
	myclass = Class.new
end

myobject = myclass.new
puts myobject.class
puts '[done]'
