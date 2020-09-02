This directory contains scripts for DAMON correctness tests.

TL; DR
======

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


Pre-requisites
==============

The kernel containing the version of the DAMON you want to test should be
running and the DAMON debugfs interface should be enabled.  Envrionment
variable named `LINUX_DIR` should point to your kernel source code directory.
If the variable is not set, it defaults to `$HOME/linux`.


Tests
=====

This directory currently supports below 8 tests.


kselftest
---------

Test DAMON original selftests.


kunit
-----

Test units of DAMON using the kunit tests of DAMON source code.


masim-record
------------

Test DAMON's record feature using a memory access simulator program (masim).


masim-damos
-----------

Test the data access monitoring-based operation schemes (DAMOS) feature of
DAMON using a memory access simulator program (masim).


chk_records
-----------

Test whether the DAMON record feature made files are made as expected.  In
addition to that made with `masim-record` test, it tests every `damon.data`
file under your home directory.


build_i386
----------

Test i386 cross build for a previous build failure, which reported by kbuild
robot[1].


build_m68k
----------

Test m68k cross build for a previous build failure, which reported by kbuild
robot[2].

[1] https://lore.kernel.org/linux-mm/202002051834.cKoViGVl%25lkp@intel.com/
[2] https://lore.kernel.org/linux-mm/202002130710.3P1Y98f7%25lkp@intel.com/
