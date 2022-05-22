#!/bin/bash
# SPDX-License-Identifier: GPL-2.0

ksft_skip=4

if [ $EUID -ne 0 ]
then
	echo "Run as root"
	exit $ksft_skip
fi

if [ ! -d ./damo ]
then
	echo "damo not installed?"
	exit "$ksft_skip"
fi

./damo/tests/run.sh
