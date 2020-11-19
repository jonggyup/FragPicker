import sys
import subprocess
import os
import ctypes
import ctypes.util

def reallocation_func(targetFile_f, start, size):
    #fallocate(targetFile_f, start, size, mode=FALLOC_FL_PUNCH_HOLE)
    #fallocate(targetFile_f, start, size)
#    print(str(targetFile_f.name))
#    print("fallocate", "-o", str(start), "-l", str(size), str(targetFile_f.name))
    subprocess.check_call(["fallocate", "-p", "-o", str(start), "-l", str(size), str(targetFile_f.name)])
    subprocess.check_call(["fallocate", "-o", str(start), "-l", str(size), str(targetFile_f.name)])

def defrag_func(targetFile_f, start, end):
    targetFile_f.seek(start, 0)
    size = end-start+1
    data = targetFile_f.read(size)
    reallocation_func(targetFile_f, start, size)
    targetFile_f.seek(start, 0)
    targetFile_f.write(data)
   
         

filelist_f=open("./traces/filelist.txt", "r+")
filename_lines = filelist_f.readlines()

for filename_line in filename_lines:

    if str(filename_line.split()[0]) == '':
        continue
    
    filename = subprocess.check_output(["find", "/mnt", "-inum", filename_line.split()[0]]).decode('ascii').strip()


    filefrag_f=open("./traces/frag_degree.txt", "w+")
    subprocess.check_call(["filefrag", "-v", filename], stdout=filefrag_f)
    subprocess.check_call(["sed","-i","1,3d", "./traces/frag_degree.txt"])
    subprocess.check_call(["sed","-i","$d", "./traces/frag_degree.txt"])
    os.fsync(filefrag_f.fileno())

    filefrag_f.close()

    filefrag_f=open("./traces/frag_degree.txt", "r+")
    filefrag_f.seek(0)
    filefrag_lines = filefrag_f.readlines()

    targetFile_f = open(filename, "rb+", buffering=10485760)
    targetRange_f = open("./traces/"+filename_line.split()[0]+".merged", "r")
    targetRange = targetRange_f.readline()
    startRange = int(targetRange.split()[0])
    endRange = int(targetRange.split()[1])
    currentStart = 0
    currentEnd = -1

    for filefrag_line in filefrag_lines:
        currentStart = currentEnd + 1
        currentEnd= currentStart + int(filefrag_line.split(':')[3])*4096 - 1

        while targetRange != '':
            if currentStart <= startRange and currentEnd >= endRange:
                targetRange = targetRange_f.readline()
                if targetRange == '':
                    break
                startRange = int(targetRange.split()[0])
                endRange = int(targetRange.split()[1])

            elif currentEnd <= startRange:
                break


            elif currentStart <= startRange and currentEnd < endRange and currentEnd > startRange:
                defrag_func(targetFile_f, startRange, endRange)
                targetRange = targetRange_f.readline()
                if targetRange == '':
                    break
    
                startRange = int(targetRange.split()[0])
                endRange = int(targetRange.split()[1])

    targetFile_f.flush()
    os.fsync(targetFile_f.fileno())
    targetFile_f.close()
    filefrag_f.close()



