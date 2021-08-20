#define _GNU_SOURCE     /* Obtain O_DIRECT definition from <fcntl.h> */
#include <fcntl.h>
#include <malloc.h>
#include <sys/time.h>
#include <time.h>
#include <sys/types.h>
#include <unistd.h>
#include <stdlib.h>

int
main(int argc, char *argv[])
{
	int fd;
	ssize_t numRead=100;
	ssize_t totalnumRead=0;
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

	fd = open(argv[1], O_RDONLY | O_DIRECT);
	if (fd == -1)
		printf("open\n");

	/* memalign() allocates a block of memory aligned on an address that
	 * is a multiple of its first argument. By specifying this argument as
	 * 2 * 'alignment' and then adding 'alignment' to the returned pointer,
	 * we ensure that 'buf' is aligned on a non-power-of-two multiple of
	 * 'alignment'. We do this to ensure that if, for example, we ask
	 * for a 256-byte aligned buffer, we don't accidentally get
	 * a buffer that is also aligned on a 512-byte boundary. */

	gettimeofday(&start, NULL);
	while (numRead != 0) {
		numRead = read(fd, buf, size);
		totalnumRead += numRead;

		if (numRead == -1)
			printf("read\n");
		lseek(fd, 1024*288, SEEK_CUR);

	}
	gettimeofday(&end, NULL);
	double elapsed_time = ((double)t)/CLOCKS_PER_SEC;

	secs_used=(end.tv_sec - start.tv_sec);
	micros_used = secs_used*1000000 + end.tv_usec - start.tv_usec;

	printf("Throughput = %f\n", (double)totalnumRead/micros_used);

}
