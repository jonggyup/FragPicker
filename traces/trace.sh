#!/bin/bash
#$1 is process name
/usr/share/bcc/tools/trace 'vfs_read(struct file *file, char __user *buf, size_t count, loff_t *pos) "ino = %llu | size = %llu | pos = %u", file->f_inode->i_ino, count, *pos' -n $1 &> trace.result

cat trace.result | awk '{print $7, $11, $15}' > ./trace.result


