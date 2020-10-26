import sys
import subprocess
import os

dummyFile_f = os.open("/mnt/dummy", os.O_CREAT|os.O_DIRECT|os.O_RDWR)
targetFile_f = os.open(sys.argv[1], os.O_DIRECT|os.O_RDWR)

fragUnit=4096
times=1

while len(data) > 0:
    mmap.mmap(dummyFile_f, fragUnit,-1, 1024 * fragUnit)
    
    os.read(

    m.write(data)
    os.seek(dummyFile_f, -1 * fragUnit)
    os.write(dummyFile_f, m)

    data = so.read(targetFile_F, fragUnit)
    os.write(targetFile_f, fragUnit)

frag_degree.seek(0)
frag_degree.readline()
line = frag_degree.readline()
filesize = line.split(' ')[5]
frag_degree.readline()


lines = frag_degree.readlines()


bufsize = 0
need = 0
for line in lines[:-1]:
    fragsize = int(line.split(':')[3])
    bufsize += fragsize * 4
    if bufsize < defragsize:
        need = 1
        continue

    while bufsize >= defragsize:
        if need == 1:
            '''print(need)'''
            data = target_file.read(defragsize*1024)
            size = len(data)
            target_file.seek(-1*size,1)
            target_file.write(data)

            '''os.fsync(target_file.fileno())'''
            need = 0
            target_file.seek(-1*defragsize*1024,1)

        
        target_file.seek(defragsize*1024,1)
        bufsize -= defragsize

    if bufsize > 0:
        need=1

'''print(target_file.tell())'''
if need == 1:
    data = target_file.read(bufsize*1024)
    size = len(data)
    target_file.seek(-1*size,1) 
    target_file.write(data)
    
target_file.flush()
os.fsync(target_file.fileno())

target_file.close()
frag_degree.close()

