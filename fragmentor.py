import sys
import subprocess
import os
import mmap

dummyFile_f = os.open("/mnt/dummy", os.O_CREAT|os.O_DIRECT|os.O_RDWR)
targetFile_f = os.open(sys.argv[1], os.O_DIRECT|os.O_RDWR)
fo = os.fdopen(targetFile_f, "rb", 0)
print(sys.argv[1])

fragUnit=1024
offset=0

data = mmap.mmap(-1, fragUnit)


numBytes = fo.readinto(data)
#print(data.read(numBytes))
while numBytes > 0:
    os.write(targetFile_f, data.read(numBytes))
    numBytes = fo.readinto(data)



