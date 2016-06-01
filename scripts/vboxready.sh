#! /bin/bash

sudo modprobe vboxdrv
sudo modprobe vboxnetadp
sudo modprobe vboxnetflt
sudo modprobe vboxpci
sudo modprobe vboxvideo
VBoxClient-all
sudo systemctl start vboxservice

# Added to allow host-only networks
#VBoxManage hostonlyif create
