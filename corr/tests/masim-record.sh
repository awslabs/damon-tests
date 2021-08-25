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

ETHP=$TEST_DIR/ethp.damos
echo "# format is: <min/max size> <min/max frequency (0-100)> <min/max age> <action>

2M      null    5       null    1s      null    hugepage
2M      null    null    5       1s      null    nohugepage" > $ETHP

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
		echo "$thp" > "$thp_file"
	fi

for pattern in stairs zigzag
do
	$DAMO record "./masim/masim masim/configs/$pattern.cfg"
	if [ ! -f damon.data ]
	then
		echo "damon.data for $pattern not found"
		exit 1
	fi
	if [ -f ../damon/_chk_record.py ]
	then
		python3 ../damon/_chk_record.py damon.data
		if [ $? -ne 0 ]
		then
			echo "record file for $pattern is wrong"
			exit 1
		fi
	fi

	if [ "$pattern" == "stairs" ]
	then
		if [ "$thp" = "always" ]
		then
			min_wss=7000000
			max_wss=13000000
		else
			min_wss=9000000
			max_wss=11000000
		fi
	elif [ "$pattern" == "zigzag" ]
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
