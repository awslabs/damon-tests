#!/bin/bash

ksft_skip=4

TEST_DIR=$PWD

if [ $EUID -ne 0 ]
then
	echo "Run as root"
	exit $ksft_skip
fi

if [ ! -d ./masim ]
then
	echo "masim not installed?"
	exit "$ksft_skip"
fi

DAMO=./damo/damo

if [ ! -f $DAMO ]
then
	echo "damo not installed?"
	exit "$ksft_skip"
fi

thp_file="/sys/kernel/mm/transparent_hugepage/enabled"
if [ -f "$thp_file" ]
then
	thps="always madvise"
else
	thps=""
fi

for thp in $thps
do
	if [ ! "$thp" = "" ]
	then
		echo "set thp $thp"
		echo "$thp" > "$thp_file"
	fi

for pattern in stairs_30secs zigzag_30secs
do
	$DAMO record "./masim/masim masim/configs/$pattern.cfg"
	if [ ! -f damon.data ]
	then
		echo "damon.data for $pattern not found"
		exit 1
	fi
	if ! "$DAMO" validate
	then
		echo "$pattern: record file validation failed"
		exit 1
	else
		echo "$pattern: record file validated"
	fi

	if [ "$pattern" == "stairs_30secs" ]
	then
		if [ "$thp" = "always" ]
		then
			min_wss=7000000
			max_wss=13000000
		else
			min_wss=9000000
			max_wss=11000000
		fi
	elif [ "$pattern" == "zigzag_30secs" ]
	then
		min_wss=90000000
		max_wss=110000000
	fi
	wss=$($DAMO report wss --raw_number --range 50 51 1 | \
		grep -e "^ 50" | awk '{print $2}')
	if [ "$wss" -lt "$min_wss" ] || [ "$wss" -gt "$max_wss" ]
	then
		echo "$pattern: expected wss in [$min_wss, $max_wss] but $wss"
		exit 1
	else
		echo "$pattern: expected wss ($min_wss <= $wss <= $max_wss)"
	fi
done

done	# thps
