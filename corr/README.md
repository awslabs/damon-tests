THIS REPO IS DEPRECATED
=======================

This repo (https://github.com/awslabs/damon-tests) was one of the official
GitHub repos for damo.  However, after 2024-09-05, this has been[1] no longer
the official GitHub repo.  Please use the new official GitHub repo
(https://github.com/damonitor/damon-tests) instead.

[1] https://lore.kernel.org/20240813232158.83903-1-sj@kernel.org

---

This directory contains scripts for DAMON correctness tests.

Pre-requisites
==============

The kernel containing the version of the DAMON you want to test should be
running and the DAMON debugfs interface should be enabled.  Environment
variable named `LINUX_DIR` should point to your kernel source code directory.
If the variable is not set, it defaults to `$HOME/linux`.

Getting Started
===============

Just `./run.sh`.  It will run the tests and show the summarized results at the
end, as below:

    [...]

    ok 1 selftests: damon: debugfs_attrs.sh
    ok 2 selftests: damon: debugfs_record.sh
    ok 1 selftests: damon-tests: kunit.sh
    ok 2 selftests: damon-tests: masim.sh
    ok 3 selftests: damon-tests: chk_records.sh
    ok 4 selftests: damon-tests: build_i386.sh
    ok 5 selftests: damon-tests: build_m68k.sh
    
    PASS
