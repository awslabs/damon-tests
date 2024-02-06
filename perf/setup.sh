#!/bin/bash

set -e

if [ $# -ne 3 ]
then
	echo "Usage: $0 <kernel commit> <remote name> <remote url>"
	echo
	echo "Setup machine for running the performance test agains the"
	echo "linux kernel of <kernel commit>, which can be fetched from"
	echo "<remote name> remote repo of url <remote url>"
	echo
	echo "e.g., $0 985236144211 gh.damon https://github.com/damonitor/linux.git"
	exit 1
fi

commit=$1
remote=$2
url=$3

bindir=$(dirname "$0")
repos_dir=$(realpath "$bindir/../../")

# rsync is required for remote results fetching
sudo apt install -y rsync
# pstree is required by lazybox
sudo apt install -y psmisc

# Setup test machine for corr test run
cont_local_setup_sh=$(realpath "$bindir/../cont/_local_setup.sh")
"$cont_local_setup_sh" "$repos_dir" upstream/next upstream/next \
	"$commit" "$remote" "$url"

# Install PARSEC3/SPLASH-2X
cd "$repos_dir"
if [ ! -d parsec-benchmark ]
then
	git clone https://github.com/damonitor/parsec-benchmark
else
	git -C parsec-benchmark fetch origin
	git -C parsec-benchmark checkout origin/master
fi
cd parsec-benchmark
./configure
./get-inputs -n
bash -c "source env.sh && parsecmgmt -a build"
