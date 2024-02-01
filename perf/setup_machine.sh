#!/bin/bash

set -e

bindir=$(dirname "$0")
repos_dir=$(realpath "$bindir/../../")

# Setup test machine for corr test run
cont_local_setup_sh=$(realpath "$bindir/../cont/_local_setup.sh")
"$cont_local_setup_sh" "$repos_dir" upstream/next upstream/next gh.damon/next \
	gh.damon https://github.com/damonitor/linux.git

# Install PARSEC3/SPLASH-2X
