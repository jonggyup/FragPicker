import sys
import subprocess
import os

def reallocation_func(target_file, start, size):
    subprocess.check_call(["fallocate", "-p", "-o", str(start), "-l", str(size), str(target_file.name)])
    subprocess.check_call(["fallocate", "-o", str(start), "-l", str(size), str(target_file.name)])

defragsize=int(sys.argv[2])

frag_degree = open("frag_degree", "w+")
target_file = open(sys.argv[1],"rb+",0)


subprocess.check_call(["filefrag", "-v", sys.argv[1]], stdout=frag_degree)
frag_degree.seek(0)
frag_degree.readline()
line = frag_degree.readline()
filesize = line.split(' ')[5]
frag_degree.readline()


lines = frag_degree.readlines()

offset = 0
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
            offset = target_file.seek(-1*size,1)
            reallocation_func(target_file, offset, size)
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

