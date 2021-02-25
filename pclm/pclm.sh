#!/bin/bash

# vm image file should have a user 'damon' and 'parsec3_on_ubuntu' is installed
# in the accout's home directory.

if [ $# -lt 2 ]
then
	echo "Usage: $0 <qemu_tools> <vm image file> [<workload> <wait time>]"
	exit 1
fi

qemu_tools=$1
image_file=$2
workload=$3
wait_time=$4

startvm="$qemu_tools/startvm.sh"
qemucmd="$qemu_tools/cmd.sh"

if [ -z "$TMUX" ]
then
	echo "$0 should be executed in tmux"
	exit 1
fi

# Start VMs in separate tmux window
tmux split-window "sudo $startvm --mon mona \"$image_file\""
tmux split-window "sudo $startvm --mon monb --sshport 2252 --incoming mig \"$image_file\""

sleep 3

# Start post-copy live migration
bindir=$(dirname $0)
"$bindir/__pclm.sh" "$qemu_tools" mona monb mig "$workload" "$wait_time"

# Quit VMs
sudo "$qemucmd" mona quit
sudo "$qemucmd" monb quit
