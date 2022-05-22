#!/bin/bash
# SPDX-License-Identifier: GPL-2.0

thpstat=$1/thpstat

keywords="
thp_fault_alloc
thp_fault_fallback
thp_fault_fallback_charge
thp_collapse_alloc
thp_collapse_alloc_failed
thp_file_alloc
thp_file_fallback
thp_file_fallback_charge
thp_file_mapped
thp_split_page
thp_split_page_failed
thp_deferred_split_page
thp_split_pmd
thp_split_pud
thp_zero_page_alloc
thp_zero_page_alloc_failed
thp_swpout
thp_swpout_fallback"

echo > $2/thpstat.total

for keyword in $keywords
do
	before=$(grep "\<$keyword\>" $thpstat | head -n 1 | awk '{print $2}')
	after=$(grep "\<$keyword\>" $thpstat | tail -n 1 | awk '{print $2}')
	echo $keyword $((after - before)) >> $2/thpstat.total
done
