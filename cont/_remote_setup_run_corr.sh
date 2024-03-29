#!/bin/bash

set -e

if [ $# -ne 4 ]
then
	echo "Usage: $0 <linux repo> <linux remote> <linux url> <linux branch>"
	exit 1
fi

# get humble ci environment variables
linux_repo=$1
linux_remote=$2
linux_url=$3
linux_branch=$4

linux_commit=$(git -C "$linux_repo" rev-parse "$linux_remote/$linux_branch")

bindir=$(dirname "$0")
logs_dir="logs/$(date +%Y-%m-%d)/$linux_remote-$linux_branch/$(date +%Y-%m-%d-%H-%M)"
mkdir -p "$logs_dir"

# config.sh should define test_machines, test_users, and test_ssh_ports vars
config_sh=config.sh
if [ ! -f "$config_sh" ]
then
	echo "Cannot find $config_sh"
	exit 1
fi
source "$config_sh"

if [ -z ${test_machines+x} ] || [ -z ${test_users+x} ] || \
	[ -z ${test_ssh_ports+x} ]
then
	echo "config is insuffient"
	exit 1
fi

echo "setup machines"
for ((i = 0 ; i < ${#test_machines[@]} ; i++))
do
	test_user=${test_users[$i]}
	remote_work_dir="/home/$test_user/damon-tests-cont"
	logfile=remote_setup_"$i"_${test_machines[$i]}
	"$bindir/_remote_setup.sh" "${test_users[$i]}" "${test_machines[$i]}" \
		"${test_ssh_ports[$i]}" "$logs_dir/$logfile" \
		"$remote_work_dir" "downstream/next" "downstream/next" \
		"$linux_commit" "$linux_remote" "$linux_url" &
	# limit number of parallel setups to 5, to not stress remote repos
	if [ $i -ne 0 ] && [ $((i % 5)) -eq 0 ]
	then
		echo "wait until previous 5 remote setup complete..."
		wait
	fi
done
wait

echo "check if remote setup all success"
for ((i = 0 ; i < ${#test_machines[@]} ; i++))
do
	logfile=remote_setup_"$i"_${test_machines[$i]}
	last_log=$(tail -n 1 "$logs_dir/$logfile")
	if [ ! "$last_log" = "_remote_setup.sh SUCCESS" ]
	then
		echo "$i-th test machine (${test_machines[$i]}) setup failed"
		exit 1
	fi
done

echo "wait for reboot"
sleep 60

echo "run tests"
for ((i = 0 ; i < ${#test_machines[@]} ; i++))
do
	test_user=${test_users[$i]}
	remote_work_dir="/home/$test_user/damon-tests-cont"
	logfile=remote_run_corr_"$i"_${test_machines[$i]}
	"$bindir/_remote_run_corr.sh" "${test_users[$i]}" \
		"${test_machines[$i]}" "${test_ssh_ports[$i]}" \
		"$logs_dir/$logfile" "$remote_work_dir" &
done
wait

if [ "$result_noti_recipients" = "" ]
then
	echo "result_noti_recipients are unset, skip sending the noti"
	exit 0
fi
echo "send results notification"
"$bindir/_noti_results.sh" \
	"$linux_repo" "$linux_remote" "$linux_url" "$linux_branch" \
	"$logs_dir" "$result_noti_recipients"
