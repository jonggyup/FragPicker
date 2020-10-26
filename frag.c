#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/file.h>
#include <sys/types.h>
#include <sys/stat.h> 
#include <string.h>

#include <fcntl.h>
#define BUF_SIZE 4096
//#define _GNU_SOURCE

int main()
{
	int fd;
	int ret;
	unsigned char *buf;
	ret = posix_memalign((void **)&buf, 512, BUF_SIZE);
	if (ret) {
		perror("posix_memalign failed");
		exit(1);
	}

	fd = open("/mnt/b.c", O_RDWR | O_DIRECT, 0755);
	if (fd < 0){
		perror("open failed");
		exit(1);
	}

	do {
		ret = read(fd, buf, BUF_SIZE);
		if (ret < 0) {
			perror("write ./direct_io.data failed");
		lseek(fd, -1*ret, 0);
		write(1, buf, ret);
		}
	} while (ret > 0);

	free(buf);
	close(fd);
}


