#!/bin/bash
# SPDX-License-Identifier: GPL-2.0

bindir=$(dirname "$0")

average=$("$bindir/_average_nth_field.sh" 2 "$1/inactive_mem")
echo "inactive_mem.avg: $average" > "$2/inactive_mem.avg"
