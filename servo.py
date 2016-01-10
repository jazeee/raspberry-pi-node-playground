#!/bin/python

from RPIO import PWM
import sys
import time

servo = PWM.Servo()

port = int(sys.argv[1])
delay = float(sys.argv[2])

print port
print delay


position = 700
while position < delay:
	servo.set_servo(port, position)
	position = position + 50
	time.sleep(0.05)

time.sleep(0.5)
servo.set_servo(port, 700)
time.sleep(1)
