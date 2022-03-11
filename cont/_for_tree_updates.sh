#!/bin/bash
# This will be called from hci.py for each update to the kernel trees.
# (Refer to run.sh for the detail)

bindir=$(dirname "$0")
"$bindir/_remote_setup_run_corr.sh" "$HUMBLE_CI_REPO" "$HUMBLE_CI_REMOTE" \
	"$HUMBLE_CI_URL" "$HUMBLE_CI_BRANCH"
