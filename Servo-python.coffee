{execFile} = require('child_process')

module.exports = (port, degrees)->
	duration = 800 + (degrees / 180) * 2000
	execFile('sudo', ['python', 'servo.py', port, degrees], (error, stdout, stderr) ->
		if error?
			console.log "Error", error, stderr
	)
