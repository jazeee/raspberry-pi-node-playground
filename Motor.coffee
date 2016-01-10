gpio = require "pi-gpio"
Promise = require "bluebird"

Promise.promisifyAll gpio

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

	goMinSpeed: =>
		@speed = -99

	stop: =>
		@speed = 0

module.exports.Motor = Motor
