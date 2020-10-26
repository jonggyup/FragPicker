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
	int fd, fd2, fd3;
	int ret;
	unsigned char *buf;
	ret = posix_memalign((void **)&buf, 4096, BUF_SIZE);
	if (ret) {
		perror("posix_memalign failed");
		exit(1);
	}
	fd = open("/mnt/a.c", O_RDWR | O_DIRECT | O_SYNC | O_CREAT, 0755);
	fd2 = open("/mnt/tmp", O_RDWR | O_DIRECT | O_SYNC | O_CREAT, 0755);
	fd3 = open("/mnt/dummy", O_RDWR | O_DIRECT | O_SYNC | O_CREAT, 0755);
	if (fd < 0){
		perror("open failed");
		exit(1);
	}

	do {
		ret = read(fd, buf, BUF_SIZE);
		if (ret == 0)
			break;
		if (ret < 0) 
			perror("read ./direct_io.data failed");
		ret = write(fd2, buf, ret);
		write(fd3, buf, ret);
		printf("%d\n",ret);
		if (ret < 0) 
			perror("write ./direct_io.data failed");
	} while (ret > 0);
	
	printf("finished \n");
	close(fd);
	close(fd2);

	rename("/mnt/tmp", "/mnt/a.c");

	free(buf);
}


