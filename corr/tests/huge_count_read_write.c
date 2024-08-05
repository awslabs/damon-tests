#include <fcntl.h>
#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>

void test(char *file)
{
	int filedesc = open(file, O_RDWR);
	char buf[512];
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

int main(int argc, char *argv[])
{
	if (argc != 2) {
		fprintf(stderr, "Usage: %s <file>\n", argv[0]);
		exit(1);
	}
	test(argv[1]);

	return 0;
}
