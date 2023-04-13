#!/bin/bash
# Run DAMON correctness tests on a remote test machine

set -o pipefail

if [ $# -ne 5 ]
then
	echo "Usage: $0 <test user> <test machine> <ssh port> <log file> \\"
	echo "		<work dir>"
	exit 1
fi

test_user=$1
test_machine=$2
ssh_port=$3
log_file=$4
work_dir=$5

timeout_interval=3600
for i in {1..5};
do
	if ssh "$test_user@$test_machine" -p "$ssh_port" \
		-o ServerAliveInterval=60 \ nohup \
		sudo timeout "$timeout_interval" \
			"$work_dir/damon-tests/corr/run.sh" 2>&1 | \
				tee "$log_file"
	then
		echo "$(basename "$0") SUCCESS" | tee --append "$log_file"
		break
	fi
	echo "$(basename "$0") time out ($i times)" | tee --append "$log_file"
	ssh -p "$ssh_port" "$test_user@$test_machine" \
		sudo shutdown -r now 2>&1 | tee --append "$log_file"
	sleep 60
	echo "shutdown and waitied one minute.  retry..."
done
