#define _GNU_SOURCE     /* Obtain O_DIRECT definition from <fcntl.h> */
#include <fcntl.h>
#include <malloc.h>
#include <sys/time.h>
#include <time.h>
int
main(int argc, char *argv[])
{
	int fd;
	ssize_t numRead=100;
	ssize_t totalnumRead=0;
	size_t length, alignment;
	off_t offset;
	char *buf;
	clock_t t;
	int size = 128;
	struct timeval start, end;
	long secs_used, micros_used;

	length = 1024*atoi(argv[2]);
	offset = 0;
	alignment = 4096;

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

	buf = memalign(alignment * 2, length + alignment);
	if (buf == NULL)
		printf("memalign\n");

	buf += alignment;
	
	gettimeofday(&start, NULL);
	while (numRead != 0) {
		numRead = read(fd, buf, length);
		totalnumRead += numRead;
		if (numRead == -1)
			printf("read\n");
	}
	gettimeofday(&end, NULL);
	double elapsed_time = ((double)t)/CLOCKS_PER_SEC;

	secs_used=(end.tv_sec - start.tv_sec);
	micros_used = secs_used*1000000 + end.tv_usec - start.tv_usec;

	printf("Throughput = %f\n", (double)totalnumRead/micros_used);

}
