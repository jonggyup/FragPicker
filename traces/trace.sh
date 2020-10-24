#!/bin/bash
#$1 is process name
/usr/share/bcc/tools/trace 'vfs_read(struct file *file, char __user *buf, size_t count, loff_t *pos) (file->f_inode->i_ino < 3000) "ino = %llu | size = %llu | pos = %u | direct = %d", file->f_inode->i_ino, count, *pos, file->f_flags & O_DIRECT' -n Thread-2 > ./trace.result
#-n $1
