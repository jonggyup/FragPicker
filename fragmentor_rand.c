#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/file.h>
#include <sys/types.h>
#include <sys/stat.h> 
#include <string.h>
#include <time.h>

#include <fcntl.h>
#define BUF_SIZE 4096
#define DUMMY_SIZE 4096

//#define _GNU_SOURCE

int main(int argc, char *argv[])
{

	int target_fd, tmp_fd, dummy_fd;
	int ret, count, frag_ret, dummy_ret, size;
	unsigned char *frag_buf, *seq_buf, *dummy_buf;
	srand(time(0));

	dummy_ret = posix_memalign((void **)&dummy_buf, 4096, DUMMY_SIZE);
	memset(dummy_buf, 0, DUMMY_SIZE);



	if (frag_ret) {
		perror("posix_memalign failed\n");
		exit(1);
	}
	if (argv[1] == NULL) {
		printf("No file speicified\n");
		exit(1);
	}
	printf("Fragmenting %s starts\n", argv[1]);
	remove("/mnt/dummy");
	target_fd = open(argv[1], O_RDWR | O_DIRECT | O_SYNC | O_CREAT, 0755);
	tmp_fd = open("/mnt/tmp", O_RDWR | O_DIRECT | O_SYNC | O_CREAT, 0755);
	dummy_fd = open("/mnt/dummy", O_RDWR | O_DIRECT | O_SYNC | O_CREAT, 0755);
	if (target_fd < 0){
		perror("open failed");
		exit(1);
	}
	count=0;
	do {
		frag_ret = posix_memalign((void **)&frag_buf, 4096, BUF_SIZE*size);
		frag_ret = read(target_fd, frag_buf, frag_ret);
		if (frag_ret == 0)
			break;
		if (frag_ret < 0) 
			perror("read ./direct_io.data failed\n");
		frag_ret = write(tmp_fd, frag_buf, frag_ret);
		write(dummy_fd, dummy_buf, DUMMY_SIZE);
		if (ret < 0) 
			perror("write ./direct_io.data failed\n");
		count++;
	} while (frag_ret > 0);

printf("finished\n");
close(tmp_fd);
close(target_fd);
close(dummy_fd);

rename("/mnt/tmp", argv[1]);

free(frag_buf);
free(seq_buf);
free(dummy_buf);
}


