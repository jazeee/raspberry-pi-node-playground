#!/bin/bash

TIME=$1

echo "Running for $TIME"

for i in 2 3 23 24; do gpio-admin export $i; done

for i in 2 3 23 24; do echo out > /sys/class/gpio/gpio$i/direction ; done

i=1; echo $i > /sys/class/gpio/gpio24/value && echo $i > /sys/class/gpio/gpio2/value

sleep $TIME

i=0; echo $i > /sys/class/gpio/gpio24/value && echo $i > /sys/class/gpio/gpio2/value

i=1; echo $i > /sys/class/gpio/gpio23/value && echo $i > /sys/class/gpio/gpio3/value

sleep $TIME

i=0; echo $i > /sys/class/gpio/gpio23/value && echo $i > /sys/class/gpio/gpio3/value

for i in 2 3 23 24; do gpio-admin unexport $i; done
