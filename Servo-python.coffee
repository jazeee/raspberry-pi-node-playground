{execFile} = require('child_process')

module.exports = (port, degrees)->
	duration = 800 + (degrees / 180) * 2000
	console.log "Sending Servo Command", port, duration
	execFile('sudo', ['python', 'servo.py', port, duration], (error, stdout, stderr) ->
		if error?
			console.log "Error", error, stderr
		else
			console.log "Servo Finished"
	)
