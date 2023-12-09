#!/bin/bash


boutput=$(bluetoothctl << EOM

devices

EOM
)


device=$(echo "$boutput" | grep AirPods)
IFS=' ' read -ra ADDR <<< "$device"

#for i in "${ADDR[@]}"; do
#	echo "$i"
#done


device_id="${ADDR[1]}"

routput=$(bluetoothctl << EOM

connect $device_id

EOM
)


