events = {}

readline = require('readline').createInterface {
	input: process.stdin,
	output: process.stdout
}

readline.on 'line', (input)->
	inputs = input.split ' '
	cmd = inputs[0]
	param = inputs[1]
	if events[cmd]
		events[cmd](param)

io = {
	bind: (event, fn)->
		events[event] = fn
	print: (str) ->
		console.log str	
}

io.bind 'clear', -> `console.log('\033[2J')`
io.bind 'dump', ->
	module.exports.sparkle.dump()
io.bind 'exec', (cmd)->
	try
		io.print eval cmd
	catch error
		io.print error

module.exports = {
	sparkle: null
}