#!/bin/bash
# SPDX-License-Identifier: GPL-2.0

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

patterns_to_test="stairs_30secs zigzag_30secs"
nr_hugetlbpages_file="/sys/kernel/mm/hugepages/hugepages-2048kB/nr_hugepages"
if [ -e "$nr_hugetlbpages_file" ]
then
	nr_hugetlbpages=$(cat "$nr_hugetlbpages_file")
	if [ "$nr_hugetlbpages" -lt 1 ]
	then
		echo "allocate 10 hugepages"
		echo 10 > "$nr_hugetlbpages_file"
		nr_hugetlbpages=$(cat "$nr_hugetlbpages_file")
		if [ $nr_hugetlbpages -ne 10 ]
		then
			echo "hugetlb alloc failed, skip it"
		else
			patterns_to_test+=" 2mb"
		fi
	else
		patterns_to_test+=" 2mb"
	fi
fi

for pattern in $patterns_to_test
do
	if [ "$pattern" == "2mb" ]
	then
		$DAMO record "./masim/masim -h masim/configs/$pattern.cfg"
	else
		$DAMO record "./masim/masim masim/configs/$pattern.cfg"
	fi
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
	elif [ "$pattern" == "2mb" ]
	then
		min_wss=4000000
		max_wss=7000000
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
