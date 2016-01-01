gpio = require "pi-gpio"
Promise = require "bluebird"
http = require "http"
dispatcher = require "httpdispatcher"
fs = require "fs"

Promise.promisifyAll gpio

isReverseDirection = true
isReverseDirection = false
isDebug = false

#7,12,16,18
ports = [18, 16, 7, 12]
if isReverseDirection
	ports = [12, 16, 7, 18]
outputs = [1, 1, 0, 0]

dispatcher.onGet "/up", (request, response) ->
	response.writeHead 200, {'Content-type': "text/plain"}
	response.end "Moving Up"
	moveMotor true
dispatcher.onGet "/down", (request, response) ->
	response.writeHead 200, {'Content-type': "text/plain"}
	response.end "Moving Down"
	moveMotor false
dispatcher.onGet "/stop", (request, response) ->
	response.writeHead 200, {'Content-type': "text/plain"}
	response.end "Stopping"
	clearInterval motorInterval

dispatcher.onGet "/", (request, response) ->
	index = fs.createReadStream "index.html"
	index.pipe response

server = http.createServer (request, response) ->
	try
		console.log request.url
		dispatcher.dispatch request, response
	catch error
		console.error error

motorInterval = undefined

moveMotor = (isReverseDirection) ->
	ports = [18, 16, 7, 12]
	if isReverseDirection
		ports = [12, 16, 7, 18]
	clearInterval motorInterval
	motorInterval = setInterval( ->
		for port, index in ports
			output = outputs[index]
			if isDebug
				console.log port, "->", output
			gpio.writeAsync port, output
		outputs= [outputs.splice(1)..., outputs...]
	1)

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
		if i > 10
			clearInterval interval
	1)
.catch ->
	setTimeout closePorts, 2000

closePorts = ->
	console.log "********** Closing **********"
	for port in ports
		gpio.close port

server.listen 8000, ->
	console.log "Listenting on port 8000"
