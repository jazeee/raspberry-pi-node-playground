gpio = require "pi-gpio"
Promise = require "bluebird"
http = require "http"
express = require "express"
app = express()
fs = require "fs"
Motor = require "./Motor"
Servo = require "./Servo"

isDebug = false

leftPorts = [16, 18]
rightPorts = [3, 5]
servoPort = 7
ports = [leftPorts..., rightPorts..., servoPort]

leftMotor = new Motor leftPorts
rightMotor = new Motor rightPorts

servo = new Servo servoPort

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
	position = 180 * Math.random()
	response.writeHead 200, {'Content-type': "text/plain"}
	response.end "Moving Servo to #{position}"
	servo.setPosition position

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
