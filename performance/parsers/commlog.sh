#!/bin/bash

# input is in format of: 'real    0m50.592s'
runtime=$(grep -e '^real' $1/commlog | sed 's/^real//' | \
	awk -F'[ms]' '{print $1 * 60 + $2}')
echo "runtime: $runtime" > $2/runtime
