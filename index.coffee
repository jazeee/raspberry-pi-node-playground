gpio = require "pi-gpio"
Promise = require "bluebird"

Promise.promisifyAll gpio

isReverseDirection = true
isReverseDirection = false
isDebug = false

#7,12,16,18
ports = [18, 16, 7, 12]
if isReverseDirection
	ports = [12, 16, 7, 18]
outputs = [1, 1, 0, 0]

Promise.all do ->
	portsToOpen = []
	for port in ports
		portsToOpen.push(gpio.openAsync port, "output")
	portsToOpen
.then (error) ->
	console.log "Starting"
	i = 0
	interval = setInterval( ->
		for port, index in ports
			output = outputs[index]
			if isDebug
				console.log port, "->", output
			gpio.writeAsync port, output
		outputs= [outputs.splice(1)..., outputs...]
		i++
		if i > 10000
			closePorts()
			clearInterval interval
	1)
.catch ->
	setTimeout closePorts, 2000

closePorts = ->
	console.log "********** Closing **********"
	for port in ports
		gpio.close port
