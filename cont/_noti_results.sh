#!/bin/bash

if [ $# -ne 6 ]
then
	echo "Usage: $0 \\"
	echo "	<linux repo> <linux remote> <linux url> <linux branch> \\"
	echo "	<logs dir> <receipients>"
	exit 1
fi

repo=$1
remote=$2
url=$3
branch=$4
logs_dir=$5
recipients=$6

repo_name=$(basename "$repo")

commit_intro=$(git -C "$repo" show --pretty="%h (\"%s\")" --quiet \
	"$remote/$branch")

mail_file=$(mktemp damon-tests-noti-XXXX)
subject="[damon-tests-noti] $repo_name: $remote/$branch ($commit_intro)"
echo "Subject: $subject" > "$mail_file"
echo >> "$mail_file"
for log_file in "$logs_dir"/*
do
	if basename "$log_file" | grep "^remote_run_corr_*"
	then
		if tail -n 2 "$log_file" | head -n 1 | grep "PASS"
		then
			echo "PASS" >> "$mail_file"
		else
			echo "FAIL" >> "$mail_file"
		fi
		echo >> "$mail_file"
	fi

	echo "log file: $log_file" >> "$mail_file"
	echo >> "$mail_file"
	head -n 10 "$log_file" >> "$mail_file"
	echo "[...]" >> "$mail_file"
	tail -n 30 "$log_file" >> "$mail_file"
	echo >> "$mail_file"
	echo "---" >> "$mail_file"
	echo >> "$mail_file"
done

git send-email --compose-encoding UTF-8 --to "$recipients" "$mail_file"
rm "$mail_file"
