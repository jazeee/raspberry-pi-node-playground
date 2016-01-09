gpio = require "pi-gpio"
Promise = require "bluebird"
http = require "http"
dispatcher = require "httpdispatcher"
fs = require "fs"

Promise.promisifyAll gpio

isDebug = false

leftPorts = [16, 18]
rightPorts = [3, 5]
ports = [leftPorts..., rightPorts...]

class Motor
	constructor: (ports) ->
		@speed = 0
		@ports = ports

	updateMotorPort: (portIndex) =>
		speed = Math.abs @speed
		timeDelay = 99 / speed
		console.log new Date(), timeDelay
		otherPortIndex = 1 - portIndex
		gpio.writeAsync @ports[otherPortIndex], 0
		.then => gpio.writeAsync @ports[portIndex], 1
		.delay 100 - timeDelay
		.then => gpio.writeAsync @ports[portIndex], 0
		.delay timeDelay

	startMotor: =>
		if @speed > 0
			@updateMotorPort 0
			.then @startMotor
		else if @speed < 0
			@updateMotorPort 1
			.then @startMotor
		else
			gpio.writeAsync @ports[0], 0
			.then => gpio.writeAsync @ports[1], 0
			.delay 50
			.then @startMotor

	goFaster: =>
		@speed++
		@speed = Math.min 99, @speed

	goSlower: =>
		@speed--
		@speed = Math.max -99, @speed

	goMaxSpeed: =>
		@speed = 99

	stop: =>
		@speed = 0

leftMotor = new Motor leftPorts
rightMotor = new Motor rightPorts

dispatcher.setStatic "resources"
dispatcher.onGet "/left/faster", (request, response) ->
	response.writeHead 200, {'Content-type': "text/plain"}
	response.end "Moving Left Faster"
	leftMotor.goFaster()
dispatcher.onGet "/left/slower", (request, response) ->
	response.writeHead 200, {'Content-type': "text/plain"}
	response.end "Moving Left Slower"
	leftMotor.goSlower()
dispatcher.onGet "/right/faster", (request, response) ->
	response.writeHead 200, {'Content-type': "text/plain"}
	response.end "Moving Right Faster"
	rightMotor.goFaster()
dispatcher.onGet "/right/slower", (request, response) ->
	response.writeHead 200, {'Content-type': "text/plain"}
	response.end "Moving Right Slower"
	rightMotor.goSlower()
dispatcher.onGet "/left/max", (request, response) ->
	response.writeHead 200, {'Content-type': "text/plain"}
	response.end "Moving Left Max"
	leftMotor.goMaxSpeed()
dispatcher.onGet "/right/max", (request, response) ->
	response.writeHead 200, {'Content-type': "text/plain"}
	response.end "Moving Right Max"
	rightMotor.goMaxSpeed()
dispatcher.onGet "/full-speed", (request, response) ->
	response.writeHead 200, {'Content-type': "text/plain"}
	response.end "Moving Full Speed"
	leftMotor.goMaxSpeed()
	rightMotor.goMaxSpeed()
dispatcher.onGet "/stop", (request, response) ->
	response.writeHead 200, {'Content-type': "text/plain"}
	response.end "Stopping"
	leftMotor.stop()
	rightMotor.stop()


dispatcher.onGet "/", (request, response) ->
	index = fs.createReadStream "mad-jaz-fury-robot.html"
	index.pipe response

server = http.createServer (request, response) ->
	try
		console.log request.url
		dispatcher.dispatch request, response
	catch error
		console.error error

Promise.all do ->
	portsToOpen = []
	for port in ports
		portsToOpen.push(gpio.openAsync port, "output")
	portsToOpen
.then (error) ->
	console.log "Started GPIO"
	leftMotor.startMotor()
	rightMotor.startMotor()
	return
.catch (error) ->
	console.error error
	setTimeout closePorts, 2000

closePorts = ->
	console.log "********** Closing GPIO ports**********"
	for port in ports
		gpio.close port

server.listen 8000, ->
	console.log "Listenting on port 8000"
