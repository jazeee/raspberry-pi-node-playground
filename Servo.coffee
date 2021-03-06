gpio = require "pi-gpio"
Promise = require "bluebird"
now = require "performance-now"

Promise.promisifyAll gpio

class Servo
	constructor: (port) ->
		@position = 0
		@port = port

	setPosition: (position) ->
		@position = position
		delay = 0.5 + (@position / 180) * 2.0
		start = now()
		gpio.writeAsync @port, 1
		.then =>
			while 1
				if (now() - start) >= delay
					break
			gpio.writeAsync @port, 0

module.exports = Servo
