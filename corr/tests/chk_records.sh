#!/bin/bash

if [ -z "$record_files" ]
then
	record_files=$(find . -name damon.data)
fi

ksft_skip=4
damo=./damo/damo
if [ ! -f $damo ]
then
	echo "$damo not found"
	exit $ksft_skip
fi

nr_checks=0
for f in $record_files
do
	echo "check $f"
	python3 "$damo" validate "$f"  --aggr 90000 110000 \
		--nr_regions 5 1100 --nr_accesses 0 23
	if [ $? -ne 0 ]
	then
		exit 1
	fi
	nr_checks=$(($nr_checks + 1))
done
echo "$nr_checks records checked"
