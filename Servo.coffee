gpio = require "pi-gpio"
Promise = require "bluebird"
now = require "performance-now"

class Servo
	constructor: (port) ->
		@position = 0
		@port = port

	start: =>
		delay = 0.5 + (@position / 180) * 2.0
		start = now()
		gpio.writeAsync @port, 1
		.then =>
			while 1
				if (now() - start) >= delay
					break
			gpio.writeAsync @port, 0
		.delay 20
		.then @start

	setPosition: (position) ->
		@position = position

module.exports = {Servo}
