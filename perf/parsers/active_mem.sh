#!/bin/bash
# SPDX-License-Identifier: GPL-2.0

bindir=$(dirname "$0")

average=$("$bindir/_average_nth_field.sh" 2 "$1/active_mem")
echo "active_mem.avg: $average" > "$2/active_mem.avg"
