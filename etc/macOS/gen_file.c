#define _GNU_SOURCE     /* Obtain O_DIRECT definition from <fcntl.h> */
#include <fcntl.h>
#include <sys/time.h>
#include <time.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>

#define FRAG_SIZE 131072 //(128KB)
int
main(int argc, char *argv[])
{
	int fd, fd2, fd3;
	int frag_size = atoi(argv[4]);
	int size = frag_size;
	unsigned char *buf, *buf2;
	buf = (unsigned char *)malloc(frag_size);
	int count = 10485760/size; //10MB


	clock_t t;
	struct timeval start, end;
	long secs_used, micros_used;

	fd = open(argv[1], O_RDWR | O_CREAT);
	fd2 = open(argv[2], O_RDWR | O_CREAT);
	fd3 = open(argv[3], O_RDWR | O_CREAT);

	if (fd == -1 || fd2 == -1 || fd3 == -1)
		printf("open error\n");

    	fcntl(fd, F_NOCACHE, 1);
    	fcntl(fd2, F_NOCACHE, 1);
//    	fcntl(fd3, F_NOCACHE, 1);

	lseek(fd, 0, SEEK_SET);
	lseek(fd2, 0, SEEK_SET);
	lseek(fd3, 0, SEEK_SET);

	while (count--)
	{
		write(fd, buf, size);
		fsync(fd);
		write(fd2, buf, size);
		fsync(fd2);
	}

	count = 10485760/size;
	while (count--)
	{
		write(fd3, buf, size);
	}
	fsync(fd3);

	printf("Evaluation finished!\n");
	return 0;
}
