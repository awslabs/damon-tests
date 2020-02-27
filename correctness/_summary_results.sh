#!/bin/bash

LOG=$PWD/log

echo -e "\e[32m"
grep -e '^ok' $LOG
echo -e "\e[33m"
grep -e '^not ok' $LOG
failed=$?

echo

if [ $failed ]
then
	echo -e "\e[91mFAIL"
else
	echo -e "\e[92mPASS"
fi
echo -e "\e[39m"
