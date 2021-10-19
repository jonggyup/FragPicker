/*-----------------------------------------------------------------------------
 * log2phys.c - this Mac OS X program attempts to provide a physical disk
 * map for the specified file(s).
 *
 * This is an EXPERIMENT! I think the code does what it says,
 * but I have not verified the results.
 *-----------------------------------------------------------------------------
 * Bob Harris 14-Apr-2010 o initial coding
 *-----------------------------------------------------------------------------
 */
#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <unistd.h>
#include <errno.h>
#define STRIDE (4096) /* ASSUMES the allocation unit is 4K */
void log2phys(char *file);
	int
main(int ac, char **av)
{
	int n;
	if ( ac < 2 ) {
		fprintf(stderr, "Usage: log2phys file [file ...] ");
		exit(EXIT_FAILURE);
	}
	for(n=1; n < ac; n++) {
		log2phys(av[n]);
	}
	exit(EXIT_SUCCESS);
}
	void
log2phys(char *file)
{
	int fd;
	int sts;
	off_t offset;
	off_t previous;
	off_t length;
	struct log2phys phys;
	printf(" filename = %s \n", file); /* display the file name */
	fd = open(file, O_RDONLY); /* open the file */
	if ( fd < 0 ) {
		fprintf(stderr,"open(%s,O_RDONLY)", file);
		perror(" ");
		exit(EXIT_FAILURE);
	}
	/*
	 * Seek through the file 4K at a time, and obtain the disk offset
	 */
	sts = 0;
	previous = (off_t)-1;
	length = 0;
	for(offset=0; sts >= 0; offset += STRIDE) {
		/* position to next offset in the file */
		sts = lseek(fd, offset, SEEK_SET);
		if ( sts < 0 ) {
			fprintf(stderr,"lseek(%d, %lld, SEEK_SET)", fd, offset);
			perror(" ");
			exit(EXIT_FAILURE);
		}
		/* fetch the current physical location for file offset */
		sts = fcntl(fd, F_LOG2PHYS, &phys);
		if ( sts < 0 && errno == ERANGE ) {
			/* we have gone past the end of the file */
			break;
		}
		else if ( sts < 0 ) {
			fprintf(stderr,"fcntl(%d, F_LOG2PHYS, &phys)", fd);
			perror(" ");
			exit(EXIT_FAILURE);
		}
		/*
		 * Figure out if this is a non-contiguous allocation unit
		 */
		if ( previous + length != phys.l2p_devoffset ) {
			if ( length != 0 ) {
				/*
				 * We have accumulated some length from the previous run of
				 * allocation units, so display the length of the previous
				 * starting offset
				 */
				printf(" length= %11lld \n", length);
				length = 0;
			}
			/* Display the offset of this new run of allocation units */
			printf(" file_offset= %10lld volume_offset= %17lld", 
					offset, phys.l2p_devoffset);
			/* save the new previous starting physical offset */
			previous = phys.l2p_devoffset;
		}
		/* Count this allocation unit as part of the length */
		length += STRIDE;
	}
	/*
	 * Print the final length.
	 */
	if ( length ) {
		printf(" length= %11lld \n", length);
	}
	close(fd);
}
