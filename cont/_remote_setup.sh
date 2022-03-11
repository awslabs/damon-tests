#!/bin/bash
# Sets up the remote test machine.

set -o pipefail

if [ $# -ne 9 ]
then
	echo "Usage: $0 <test user> <test machine> <ssh port> <log file> \\"
	echo "		<damon-tests version> <damo version> <linux ver> \\"
	echo "		<linux remote name> <linux remote url>"
	exit 1
fi

bindir=$(dirname "$0")
test_user=$1
test_machine=$2
ssh_port=$3
log_file=$4
damon_tests_version=$5
damo_version=$6
linux_ver=$7
linux_remote_name=$8
linux_remote_url=$9

local_setup_sh="_local_setup.sh"
remote_work_dir="/home/$test_user/damon-tests-cont"
ssh -p "$ssh_port" "$test_user@$test_machine" mkdir -p "$remote_work_dir" \
	2>&1 | tee "$log_file"
rsync -e "ssh -p $ssh_port" "$bindir/$local_setup_sh" \
	"$test_user@$test_machine:$remote_work_dir/" 2>&1 | \
	tee --append "$log_file"
if ! ssh -p "$ssh_port" -o ServerAliveInterval=60 "$test_user@$test_machine" \
	nohup "$remote_work_dir/$local_setup_sh" "$remote_work_dir" \
	"$damon_tests_version" "$damo_version" \
	"$linux_ver" "$linux_remote_name" "$linux_remote_url" 2>&1 | \
	tee --append "$log_file"
then
	echo "$local_setup_sh failed" | tee --append "$log_file"
	exit 1
fi
echo "reboot" | tee --append "$log_file"
ssh -p "$ssh_port" "$test_user@$test_machine" sudo shutdown -r now 2>&1 | \
	tee --append "$log_file"
echo "$(basename "$0") SUCCESS" | tee --append "$log_file"
