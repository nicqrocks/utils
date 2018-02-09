#!/bin/bash

#Rotate the screen and touchscreen

#Make some default variables.
curr=0
file="/tmp/rotation-"`whoami`
lock="$file.lock"
angle="normal"
touch="enable"
matrix="1 0 0 0 1 0 0 0 1"


#Check if the lock file exits.
if [[ -e $lock ]]; then
    echo "Lock file exits" 1>&2
    exit 1
fi

#Make the lock file
touch $lock

#Make function to remove lock on exit
function finish() { rm $lock; }
trap finish EXIT


#Use a file to keep track of the rotation angle.
if [[ -e "$file" ]]; then
	#The config file exists, so grab the current rotation.
	curr=`cat "$file"`

	#Add one to the value given, or reset to zero if it has been
	#incremented too many times.
	if [[ $curr -ge 2 ]]; then
		curr=0
	else
        curr=$((curr + 1))
	fi

	echo $curr > "$file"
else
	#The file does not exist, make it.
	echo "0" > "$file"
fi

case "$curr" in
	1 )
		angle="right"
		matrix="0 1 0 -1 0 1 0 0 1"
		touch="disable"
		;;
	2 )
		angle="inverted"
		matrix="-1 0 1 0 -1 1 0 0 1"
		touch="disable"
		;;
	* )
		angle="normal"
		matrix="1 0 0 0 1 0 0 0 1"
		touch="enable"
		;;
esac

#Rotate the screen given the perameters above.
echo $angle
xrandr -o $angle
xinput set-prop 'Wacom ISDv4 E6 Finger touch' \
    'Coordinate Transformation Matrix' $matrix
xinput $touch 'SynPS/2 Synaptics TouchPad'

#Sleep for a bit to make sure the screen catches up.
sleep 1

