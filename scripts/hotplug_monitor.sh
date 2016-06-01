#! /bin/bash

export DISPLAY=:0
export XAUTHORITY=/home/saksham/.Xauthority

function connect(){
  xrandr --output HDMI1 --left-of eDP1 --preferred --primary --output eDP1 --preferred
  echo "Connected at" >> /home/saksham/hell
  date >> /home/saksham/hell
}
  
function disconnect(){
  xrandr --output HDMI1 --off
  echo "Disconnected at " >> /home/saksham/hell
  date >> /home/saksham/hell
}
   
xrandr | grep "HDMI1 connected" &> /dev/null && connect || disconnect
