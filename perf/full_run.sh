#!/bin/bash

rm -fr ./results
sudo ~/lazybox/scripts/zram_swap.sh 4G
from_date=$(date)
time CFG=full_once_config.sh ./run.sh
echo "tests ran from $from_date to $(date)"
