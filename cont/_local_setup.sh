#!/bin/bash
# Sets up the local test machine.  Specifically, ensure specified version of
# damon-tests, damo, lazybox, and linux are checked out under work directory
# and the linux is built and installed.

set -e

if [ $# -ne 6 ]
then
	echo "Usage: $0 <workdir> <damon-tests commit> <damo commit> \\"
	echo "		<linux commit> <linux remote name> <linux remote url>"
	exit 1
fi

work_dir=$1
damon_tests_commit=$2
damo_commit=$3
linux_commit=$4
linux_remote_name=$5
linux_remote_url=$6

sudo apt install -y git build-essential

fetch_git()
{
	if [ $# -ne 3 ]
	then
		echo "Usage: fetch_git <repo> <remote name> <remote url>"
		exit 1
	fi
	repo=$1
	remote_name=$2
	remote_url=$3
	echo "$(basename "$0")/fetch_git() called with $@"
	if [ ! -d "$repo" ]
	then
		mkdir -p "$repo"
		git -C "$repo" init
	fi
	if ! git -C "$repo" remote | grep --quiet --line-regexp "$remote_name"
	then
		git -C "$repo" remote add "$remote_name" "$remote_url"
	fi
	git -C "$repo" fetch "$remote_name"
}

checkout_git()
{
	if [ $# -ne 4 ]
	then
		echo "Usage: checkout_git <repo> <remote name> <remote url> <ref>"
		exit 1
	fi
	repo=$1
	remote_name=$2
	remote_url=$3
	ref=$4
	echo "$(basename "$0")/checkout_git() called with $@"
	if ! git -C "$repo" cat-file commit "$ref" &> /dev/null
	then
		fetch_git "$repo" "$remote_name" "$remote_url"
	fi
	git -C "$repo" checkout "$ref"
}

gh_upstream="https://github.com/damonitor"
gh_downstream="https://github.com/awslabs"

if [ ! -d "$work_dir" ]
then
	echo "make work dir $work_dir"
	mkdir -p "$work_dir"
fi

echo "setup masim"
masim_path=$work_dir/masim
masim_gh_repo=https://github.com/sjp38/masim
checkout_git "$masim_path" "origin" "$masim_gh_repo" "origin/master"
make -C "$masim_path"

echo "setup lazybox"
lazybox_path=$work_dir/lazybox
lazybox_gh_repo=https://github.com/sjp38/lazybox
checkout_git "$lazybox_path" "origin" "$lazybox_gh_repo" "origin/master"

echo "setup damon-tests"
damon_tests_path=$work_dir/damon-tests
fetch_git "$damon_tests_path" "upstream" "$gh_upstream/damon-tests"
fetch_git "$damon_tests_path" "downstream" "$gh_downstream/damon-tests"
git -C "$damon_tests_path" checkout "$damon_tests_commit"

echo "setup damo"
damo_path=$work_dir/damo
fetch_git "$damo_path" "upstream" "$gh_upstream/damo"
fetch_git "$damo_path" "downstream" "$gh_downstream/damo"
git -C "$damo_path" checkout "$damo_commit"

echo "setup linux"
linux_path=$work_dir/linux
checkout_git "$linux_path" "$linux_remote_name" "$linux_remote_url" \
	"$linux_commit"

# build/install linux
build_linux=$lazybox_path/scripts/kernel_dev/build.sh
damon_config=$damon_tests_path/corr/tests/damon_config
damon_config_edited="$damon_config.cont_kernel"
cp "$damon_config" "$damon_config_edited"
# For perf tests
echo "CONFIG_PSI=y" >> "$damon_config_edited"
echo "CONFIG_ZRAM=m" >> "$damon_config_edited"
sudo bash "$build_linux" --install --config "$damon_config_edited" \
	"$linux_path" "$linux_path.out"
rm "$damon_config_edited"

# build/install perf
build_install_perf="$lazybox_path/scripts/kernel_dev/build_install_perf.sh"
perf_out="$work_dir/perf.out"
if ! sudo which perf
then
	mkdir -p "$perf_out"
	sudo "$build_install_perf" "$linux_path" "$perf_out"
fi
