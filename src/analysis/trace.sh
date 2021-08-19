#!/bin/bash
#$1 is process name
#We utilize bcc tool to extract necessary information of each system call.
#inode number, request size, request position, if O_DIRECT.
/usr/share/bcc/tools/trace -n $1 'vfs_read(struct file *file, char __user *buf, size_t count, loff_t *pos) "ino = %llu | size = %llu | pos = %u | direct = %d", file->f_inode->i_ino, count, *pos, file->f_flags & O_DIRECT' > ./trace.result
#-n $1

#Condition is added i_no < 100000
#/usr/share/bcc/tools/trace -n Thread-2 'vfs_read(struct file *file, char __user *buf, size_t count, loff_t *pos) "ino = %llu | size = %llu | pos = %u | direct = %d", file->f_inode->i_ino, count, *pos, file->f_flags & O_DIRECT' > ./trace.result
