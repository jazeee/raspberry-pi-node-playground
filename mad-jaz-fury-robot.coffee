gpio = require "pi-gpio"
Promise = require "bluebird"
http = require "http"
express = require "express"
app = express()
fs = require "fs"
Motor = require "./Motor"
servoPython = require "./Servo-python"

isDebug = false

leftPorts = [16, 18]
rightPorts = [3, 5]
servoPort = 4 #GPIO port, for pin 7
ports = [leftPorts..., rightPorts...]

leftMotor = new Motor leftPorts
rightMotor = new Motor rightPorts

app.use "/resources", express.static 'resources'
app.get "/left/faster", (request, response) ->
	response.writeHead 200, {'Content-type': "text/plain"}
	response.end "Moving Left Faster"
	leftMotor.goFaster()
app.get "/left/slower", (request, response) ->
	response.writeHead 200, {'Content-type': "text/plain"}
	response.end "Moving Left Slower"
	leftMotor.goSlower()
app.get "/right/faster", (request, response) ->
	response.writeHead 200, {'Content-type': "text/plain"}
	response.end "Moving Right Faster"
	rightMotor.goFaster()
app.get "/right/slower", (request, response) ->
	response.writeHead 200, {'Content-type': "text/plain"}
	response.end "Moving Right Slower"
	rightMotor.goSlower()
app.get "/left/max", (request, response) ->
	response.writeHead 200, {'Content-type': "text/plain"}
	response.end "Moving Left Max"
	leftMotor.goMaxSpeed()
app.get "/right/max", (request, response) ->
	response.writeHead 200, {'Content-type': "text/plain"}
	response.end "Moving Right Max"
	rightMotor.goMaxSpeed()
app.get "/left/min", (request, response) ->
	response.writeHead 200, {'Content-type': "text/plain"}
	response.end "Moving Left Min"
	leftMotor.goMinSpeed()
app.get "/right/min", (request, response) ->
	response.writeHead 200, {'Content-type': "text/plain"}
	response.end "Moving Right Min"
	rightMotor.goMinSpeed()
app.get "/full-speed", (request, response) ->
	response.writeHead 200, {'Content-type': "text/plain"}
	response.end "Moving Full Speed"
	leftMotor.goMaxSpeed()
	rightMotor.goMaxSpeed()
app.get "/stop", (request, response) ->
	response.writeHead 200, {'Content-type': "text/plain"}
	response.end "Stopping"
	leftMotor.stop()
	rightMotor.stop()
app.get "/servo", (request, response) ->
	position = 30
	response.writeHead 200, {'Content-type': "text/plain"}
	response.end "Moving Servo to #{position}"
	servoPython servoPort, position

app.get "/", (request, response) ->
	response.writeHead 200, 'Content-Type': 'text/html'
	index = fs.createReadStream "mad-jaz-fury-robot.html"
	index.pipe response

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

server = http.createServer app
server.listen 8000, ->
	console.log "Listenting on port 8000"
