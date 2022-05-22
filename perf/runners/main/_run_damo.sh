#!/bin/bash
# SPDX-License-Identifier: GPL-2.0

if [ $# -ne 7 ]
then
	echo "Usage: $0 <damo> <subcommand> <record file> <scheme> <target> <pid_to_wait> <timeout>"
	exit 1
fi

damo=$1
subcommand=$2
record_file=$3
scheme=$4
target=$5
pid_to_wait=$6
timeout=$7

if [ "$subcommand" = "record" ]
then
	"$damo" "$subcommand" -o "$record_file"  "$target" &
	damo_pid=$!
elif [ "$subcommand" = "schemes" ]
then
	"$damo" "$subcommand" -c "$scheme" "$target" &
	damo_pid=$!
else
	echo "Unsupported subcommand '$subcommand'"
	exit 1
fi

echo "wait pid $pid_to_wait with timeout $timeout seconds"
for ((i = 0; i < "$timeout"; i++))
do
	if [ ! -z "$pid_to_wait" ] && [ ! -d "/proc/$pid_to_wait" ]
	then
		break
	fi
	sleep 1
done

kill -SIGINT "$damo_pid"

monitor_on="/sys/kernel/debug/damon/monitor_on"
for ((i = 0;  i > 0; i++))
do
	monitor_on=$(cat "$monitor_on")
	if [ "$monitor_on" = "off" ]
	then
		break
	fi
	echo "waiting for monitor off $i seconds"
	sleep 1
done

if [ "$subcommand" = "record" ] && [ ! -f "/sys/kernel/debug/damon/record" ]
then
	while [ -d "/proc/$damo_pid" ]
	do
		sleep 1
		echo "waiting for damo finishes"
	done

	"$damo" adjust -i "$record_file" -o damon.adjusted.data
	rm "$record_file" "$record_file.perf.data"
	mv damon.adjusted.data "$record_file"
fi
