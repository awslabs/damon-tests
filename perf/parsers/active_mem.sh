#!/bin/bash
# SPDX-License-Identifier: GPL-2.0

bindir=$(dirname "$0")

active_average=$("$bindir/_average_nth_field.sh" 2 "$1/active_mem")
echo "active_mem.avg: $average" > "$2/active_mem.avg"

inactive_average=$("$bindir/_average_nth_field.sh" 2 "$1/inactive_mem")
echo "inactive_mem.avg: $inactive_average" > "$2/inactive_mem.avg"

echo "active_mem_rate_bp: $((active_average * 10000 / (active_average + inactive_average)))" > "$2/active_mem_rate_bp"
