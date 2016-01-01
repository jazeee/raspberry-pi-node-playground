gpio = require "pi-gpio"
Promise = require "bluebird"
http = require "http"
dispatcher = require "httpdispatcher"
fs = require "fs"

Promise.promisifyAll gpio

isDebug = false

leftPort = 16
rightPort = 18

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

dispatcher.onGet "/up", (request, response) ->
	response.writeHead 200, {'Content-type': "text/plain"}
	response.end "Moving Up"
	leftMotor.goFaster()
	moveMotor true
dispatcher.onGet "/down", (request, response) ->
	response.writeHead 200, {'Content-type': "text/plain"}
	response.end "Moving Down"
	rightMotor.goFaster()
	moveMotor false
dispatcher.onGet "/stop", (request, response) ->
	response.writeHead 200, {'Content-type': "text/plain"}
	response.end "Stopping"
	leftMotor.stop()
	rightMotor.stop()


dispatcher.onGet "/", (request, response) ->
	index = fs.createReadStream "index.html"
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
	console.log "Starting"
.catch ->
	setTimeout closePorts, 2000

closePorts = ->
	console.log "********** Closing **********"
	for port in ports
		gpio.close port

server.listen 8000, ->
	console.log "Listenting on port 8000"
