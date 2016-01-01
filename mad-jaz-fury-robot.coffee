gpio = require "pi-gpio"
Promise = require "bluebird"
http = require "http"
dispatcher = require "httpdispatcher"
fs = require "fs"

Promise.promisifyAll gpio

isDebug = false

leftPort = 16
rightPort = 18
ports = [leftPort, rightPort]

class Motor
	constructor: (port) ->
		@speed = 0
		@port = port

	goFaster: =>
		@speed++
		@speed = Math.min 199, @speed
		@updateTimer()

	goSlower: =>
		@speed--
		@speed = Math.max 0, @speed
		@updateTimer()

	updateTimer: =>
		clearInterval @motorInterval
		@motorInterval = undefined
		if @speed > 0
			timeDelay = 199 / @speed
			@motorInterval = setInterval( =>
				gpio.writeAsync @port, 1
				.delay 200 - timeDelay
				.then => gpio.writeAsync @port, 0
			200)
		else
			gpio.writeAsync @port, 0

	stop: =>
		@speed = 0
		@updateTimer()

leftMotor = new Motor leftPort
rightMotor = new Motor rightPort

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
.catch ->
	setTimeout closePorts, 2000

closePorts = ->
	console.log "********** Closing GPIO ports**********"
	for port in ports
		gpio.close port

server.listen 8000, ->
	console.log "Listenting on port 8000"
