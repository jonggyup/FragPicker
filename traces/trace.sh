#!/bin/bash
#$1 is process name
#/usr/share/bcc/tools/trace 'vfs_read(struct file *file, char __user *buf, size_t count, loff_t *pos) "ino = %llu | size = %llu | pos = %u | direct = %d", file->f_inode->i_ino, count, *pos, file->f_flags & O_DIRECT' > ./trace.result
#-n $1

#Condition is added i_no < 100000
/usr/share/bcc/tools/trace 'vfs_write(struct file *file, char __user *buf, size_t count, loff_t *pos) (file->f_inode->i_ino < 300) "ino = %llu | size = %llu | pos = %u | direct = %d", file->f_inode->i_ino, count, *pos, file->f_flags & O_DIRECT' > ./trace.result
