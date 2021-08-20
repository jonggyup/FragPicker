import sys
import subprocess
import os
import fallocate

targetFile_f = open(sys.argv[1],"rb+",0)

size = 4096
seq_size = size * 32
data = targetFile_f.read(size)
start = targetFile_f.tell() - size
count=1

fileSize = targetFile_f.seek(0,2)

subprocess.check_call(["fallocate", "-o", str(0), "-l", str(fileSize), str(targetFile_f.name)]) 
while data:
    fallocate.fallocate(targetFile_f, start, size, mode=fallocate.FALLOC_FL_PUNCH_HOLE|fallocate.FALLOC_FL_KEEP_SIZE)
    fallocate.fallocate(targetFile_f, start, size, mode=0)
#    subprocess.check_call(["fallocate", "-p", "-o", str(start), "-l", str(size), str(targetFile_f.name)]) 
#    subprocess.check_call(["fallocate", "-o", str(start), "-l", str(size), str(targetFile_f.name)]) 
    targetFile_f.seek(start,0)
    targetFile_f.write(data)
#    os.fsync(targetFile_f.fileno())
    
    targetFile_f.seek(size, 1)
    data = targetFile_f.read(size)
    start = targetFile_f.tell() - size

#new start
targetFile_f.seek(seq_size, 0)
size = seq_size
data = targetFile_f.read(size)
start = targetFile_f.tell() - size

while data:
    fallocate.fallocate(targetFile_f, start, size, mode=fallocate.FALLOC_FL_PUNCH_HOLE|fallocate.FALLOC_FL_KEEP_SIZE)
    fallocate.fallocate(targetFile_f, start, size, mode=0)

#    subprocess.check_call(["fallocate", "-p", "-o", str(start), "-l", str(size), str(targetFile_f.name)]) 
 #   subprocess.check_call(["fallocate", "-o", str(start), "-l", str(size), str(targetFile_f.name)]) 
    targetFile_f.seek(start,0)
    targetFile_f.write(data)
    
    targetFile_f.seek(size, 1)
    data = targetFile_f.read(size)
    start = targetFile_f.tell() - size


os.fsync(targetFile_f.fileno())



targetFile_f.close()
