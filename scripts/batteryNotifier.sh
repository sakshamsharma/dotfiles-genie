#!/bin/bash

result=$(upower -i $(upower -e | grep 'BAT') | grep -E "state|to\ full|percentage")
percent=$(echo $result | grep -E -o '[0-9]*')
state=$(echo $result | grep -E -o 'd?i?s?charging')
if [[ $percent -lt 20 && $state == "discharging" ]]
then
	notify-send "Low Battery!" "$result" --icon=dialog-information
fi
