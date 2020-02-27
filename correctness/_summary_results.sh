#!/bin/bash

LOG=$PWD/log

echo -e "\e[32m"
grep -e '^ok' $LOG
echo -e "\e[33m"
grep -e '^not ok' $LOG
failed=$?

if [ $failed -eq 0 ]
then
	echo
	echo -e "\e[91mFAIL\e[39m"
else
	echo -e "\e[92mPASS\e[39m"
fi
