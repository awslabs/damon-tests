#!/bin/bash
# Run DAMON correctness tests on a remote test machine

if [ $# -ne 4 ]
then
	echo "Usage: $0 <test user> <test machine> <ssh port> <log file>"
	exit 1
fi

test_user=$1
test_machine=$2
ssh_port=$3
log_file=$4

if ssh "$test_user@$test_machine" -p "$ssh_port" \
	sudo "/home/$test_user/damon-tests/corr/run.sh" | tee "$log_file"
then
	echo "$(basename "$0") SUCCESS" | tee --append "$log_file"
fi
