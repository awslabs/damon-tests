#!/bin/bash

rm -fr ./results
sudo ~/lazybox/scripts/zram_swap.sh 4G
time CFG=full_once_config.sh ./run.sh
