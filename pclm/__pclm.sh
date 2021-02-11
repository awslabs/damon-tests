#!/bin/bash

# Getting started:
#
#     (terminal A) sudo ./startvm.sh --monitor src damon.disk
#     (terminal B) sudo ./startvm.sh --monitor dst --sshport 2252 \
#                                    --incoming mig damon.disk
#     (terminal C) ./pcml.sh src dst mig

if [ $# -ne 4 ]
then
	echo "USage: $0 <qemu_tools> <src monitor> <dst monitor> \
		<migration socket>"
	exit 1
fi

qemu_tools="$1"
mon_src="$2"
mon_dst="$3"
mig_sock="$4"

qemu_cmd="$qemu_tools/cmd.sh"

bindir=$(dirname $0)

if ! sudo "$qemu_cmd" "$mon_src" "info status" | \
	grep -q "VM status: running"
then
	echo "Source is not running"
	exit 1
fi

if ! sudo "$qemu_cmd" "$mon_dst" "info status" | \
	grep -q "VM status: paused (inmigrate)"
then
	echo "Destination is not running"
	exit 1
fi

sudo "$qemu_cmd" "$mon_src" "migrate_set_capability postcopy-ram on"
sudo "$qemu_cmd" "$mon_dst" "migrate_set_capability postcopy-ram on"
sudo "$qemu_cmd" "$mon_dst" "migrate_set_capability postcopy-blocktime on"

sudo "$qemu_cmd" "$mon_src" "migrate -d unix:$mig_sock"
sudo "$qemu_cmd" "$mon_src" "migrate_start_postcopy"

while :;
do
	status=$(sudo "$qemu_cmd" "$mon_src" "info migrate")
	echo "source state"
	echo "$status"
	echo

	if echo $status | grep -q "Migration status: completed"
	then
		echo
		echo "destination state"
		sudo "$qemu_cmd" "$mon_dst" "info migrate"
		break
	fi

	sleep 2
done
