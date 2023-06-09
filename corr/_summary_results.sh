#!/bin/bash
# SPDX-License-Identifier: GPL-2.0

if [ $# -ne 1 ]
then
	echo "Usage: $0 <log>"
	exit 1
fi

LOG=$1

echo -e "\e[32m"
grep -e '^ok' $LOG
echo -e "\e[33m"

nr_failures=$(grep -e '^not ok' "$LOG" | wc -l)
nr_skip=$(grep -e '^not ok' "$LOG" | grep -e '# SKIP$' | wc -l)
nr_failures=$((nr_failures - nr_skip))

if [ "$nr_failures" -gt 0 ]
then
	echo
	echo -e "\e[91mFAIL\e[39m"
	exit 1
else
	echo -e "\e[92mPASS\e[39m"
fi
