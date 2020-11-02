import sys
import subprocess
import os


targetFile_f = open(sys.argv[1],"rb+",0)

size = 4096
data = targetFile_f.read(size)
start = targetFile_f.tell() - size


fileSize = targetFile_f.seek(0,2)

while data:
    subprocess.check_call(["fallocate", "-p", "-o", str(start), "-l", str(size), str(targetFile_f.name)]) 
    subprocess.check_call(["fallocate", "-o", str(start), "-l", str(size), str(targetFile_f.name)]) 
    targetFile_f.seek(start,0)
    targetFile_f.write(data)
    os.fsync(targetFile_f.fileno())
    
    targetFile_f.seek(size, 1)
    data = targetFile_f.read(size)
    start = targetFile_f.tell() - size

targetFile_f.close()
