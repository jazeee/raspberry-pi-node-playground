#!/bin/bash

for i in 4 18 23 24; do gpio-admin export $i; done

for i in 4 18 23 24; do echo out > /sys/class/gpio/gpio$i/direction ; done

i=1; echo $i > /sys/class/gpio/gpio24/value && echo $i > /sys/class/gpio/gpio23/value

sleep 5s

i=0; echo $i > /sys/class/gpio/gpio24/value && echo $i > /sys/class/gpio/gpio23/value

for i in 4 18 23 24; do gpio-admin unexport $i; done
