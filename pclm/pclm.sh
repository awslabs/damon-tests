#!/bin/bash

if [ $# -ne 2 ]
then
	echo "Usage: $0 <qemu_tools> <vm image file>"
	exit 1
fi

qemu_tools=$1
image_file=$2

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
"$bindir/__pclm.sh" "$qemu_tools" mona monb mig

# Quit VMs
sudo "$qemucmd" mona quit
sudo "$qemucmd" monb quit
