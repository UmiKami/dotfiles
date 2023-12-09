#!/bin/bash

iwctl station wlan0 connect "Lopez Wifi 6" 

sudo ip addr add 192.168.68.50/24 dev wlan0
 
sudo ip route add default via 192.168.68.1
