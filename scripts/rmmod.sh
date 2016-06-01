#! /bin/bash

interface="rtl8723be"
if [[ `lsmod | grep -E "^rtl8723be" -o` = "$interface" ]]
then
	echo "It is loaded."
	echo "Removing it."
	sudo rmmod $interface
	echo "Modprobe again."
	sudo modprobe $interface
	echo "Done."
else
	echo "Not loaded."
	echo "Doing Modprobe"
	sudo modprobe $interface
fi
