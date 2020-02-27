#!/bin/bash

if [ -z "$record_files" ]
then
	record_files=`find $HOME -name damon.data`
fi

ksft_skip=4
chk_record=../damon/_chk_record.py
if [ ! -f $chk_record ]
then
	echo "$chk_record not found"
	exit $ksft_skip
fi

nr_checks=0
for f in $record_files
do
	echo "check $f"
	python3 ../damon/_chk_record.py $f
	if [ $? -ne 0 ]
	then
		exit 1
	fi
	nr_checks=$(($nr_checks + 1))
done
echo "$nr_checks records checked"
