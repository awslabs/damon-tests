TEST_GEN_FILES += huge_count_read_write
TEST_GEN_FILES += dbgfs_target_ids_read_before_terminate_race

# unit tests
TEST_PROGS = kunit.sh

# simple regression tests
TEST_PROGS += huge_count_read_write.sh buffer_overflow.sh rm_contexts.sh
TEST_PROGS += record_null_deref.sh
TEST_PROGS += dbgfs_target_ids_read_before_terminate_race.sh

# functional tests
TEST_PROGS += damo_tests.sh
TEST_PROGS += masim-record.sh masim-damos.sh

# build tests
TEST_PROGS += build_i386.sh build_m68k.sh build_arm64.sh
TEST_PROGS += build_i386_idle_flag.sh
TEST_PROGS += build_i386_highpte.sh

include ../lib.mk
