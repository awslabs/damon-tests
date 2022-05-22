#!/bin/bash
# SPDX-License-Identifier: GPL-2.0

sync
echo 3 > /proc/sys/vm/drop_caches
