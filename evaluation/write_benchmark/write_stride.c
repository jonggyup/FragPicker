#define _GNU_SOURCE     /* Obtain O_DIRECT definition from <fcntl.h> */
#include <fcntl.h>
#include <malloc.h>
#include <sys/time.h>
#include <time.h>
#include <sys/types.h>
#include <unistd.h>
#include <string.h>
#include <stdlib.h>

int
main(int argc, char *argv[])
{
	int fd;
	ssize_t numWrite = 0;
	ssize_t fileSize = 0;
	size_t size;
	off_t offset;
	unsigned char *buf;
	int bufSize=0;
	clock_t t;
	struct timeval start, end;
	long secs_used, micros_used;

	size = 1024*atoi(argv[2]);
	offset = 0;
	bufSize = posix_memalign((void **)&buf, 4096, size);
	memset(buf, 0, bufSize);

	fd = open(argv[1], O_RDWR | O_DIRECT);
	if (fd == -1)
		printf("open error\n");

	/* memalign() allocates a block of memory aligned on an address that
	 * is a multiple of its first argument. By specifying this argument as
	 * 2 * 'alignment' and then adding 'alignment' to the returned pointer,
	 * we ensure that 'buf' is aligned on a non-power-of-two multiple of
	 * 'alignment'. We do this to ensure that if, for example, we ask
	 * for a 256-byte aligned buffer, we don't accidentally get
	 * a buffer that is also aligned on a 512-byte boundary. */
	fileSize = lseek(fd, 0, SEEK_END);
	lseek(fd, 0, SEEK_SET);

	gettimeofday(&start, NULL);
	while (offset + size < fileSize ) {
		numWrite += write(fd, buf, size);

		if (numWrite == -1) {
			printf("Write Error\n");
			return 0;
		}

		offset = lseek(fd, 1024*288, SEEK_CUR);
	}
	gettimeofday(&end, NULL);
	double elapsed_time = ((double)t)/CLOCKS_PER_SEC;

	secs_used=(end.tv_sec - start.tv_sec);
	micros_used = secs_used*1000000 + end.tv_usec - start.tv_usec;

	printf("Throughput = %f\n", (double)numWrite/micros_used);

}
