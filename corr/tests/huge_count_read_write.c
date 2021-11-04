#include <fcntl.h>
#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>

void test(char *file)
{
	int filedesc = open(file, O_RDWR);
	char buf[25];
	int ret;

	printf("test %s\n", file);
	if (filedesc < 0) {
		fprintf(stderr, "failed opening %s\n", file);
		exit(1);
	}

	write(filedesc, "", 0xffffff65ul);
	perror("after write: ");
	ret = read(filedesc, buf, 0xffffff65ul);
	perror("after read: ");
	close(filedesc);
}

int main(void)
{
	test("/sys/kernel/debug/damon/attrs");
	test("/sys/kernel/debug/damon/init_regions");
	test("/sys/kernel/debug/damon/kdamond_pid");
	test("/sys/kernel/debug/damon/mk_contexts");
	test("/sys/kernel/debug/damon/monitor_on");
	test("/sys/kernel/debug/damon/record");
	test("/sys/kernel/debug/damon/rm_contexts");
	test("/sys/kernel/debug/damon/schemes");
	test("/sys/kernel/debug/damon/target_ids");

	return 0;
}
