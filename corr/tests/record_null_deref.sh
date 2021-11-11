#!/bin/bash

ksft_skip=4

cd /sys/kernel/debug/damon

echo "4096 /foo/bar/baz" > record
echo $$ > target_ids
echo on > monitor_on
sleep 2
echo off > monitor_on

dmesg -C

echo "0 $HOME/damon.data" > record
echo $$ > target_ids
echo on > monitor_on
sleep 2
echo off > monitor_on

# BUG: kernel NULL pointer dereference, address: 0000000000000000
if dmesg | grep BUG
then
	dmesg
	exit 1
fi

exit 0
