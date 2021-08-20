#Adviosry lock version
import sys
import subprocess
import os
import fallocate
import fcntl

#Block alloccation
def reallocation_func(targetFile_f, start, size):
    fallocate.fallocate(targetFile_f, start, size, mode= fallocate.FALLOC_FL_PUNCH_HOLE | fallocate.FALLOC_FL_KEEP_SIZE)
    fallocate.fallocate(targetFile_f, start, size, mode = 0)

#Migration by re-writing
def defrag_func(targetFile_f, start, end):
    size = end-start+1
    fcntl.lockf(targetFile_f, fcntl.LOCK_EX, size, start, 0) #file locking. Here you can use mandatory, record lock, etc. depending on the purpose.
    targetFile_f.seek(start, 0)
    data = targetFile_f.read(size)
    reallocation_func(targetFile_f, start, size) #Block Allocation
    targetFile_f.seek(start, 0)
#   os.fsync(targetFile_f.fileno()) #fsync is optional.
    targetFile_f.write(data) #Data migration
    fcntl.lockf(targetFile_f, fcntl.LOCK_UN, size, start, 0) #Unlock file
   
         
#open the file list to defrag
filelist_f=open("../analysis/filelist.txt", "r+")
filename_lines = filelist_f.readlines()
#total=0 #for debugging (how many blocks migrated)

for filename_line in filename_lines:

    if str(filename_line.split()[0]) == '':
        continue

    #Traslate inode number to the file path
    filename = subprocess.check_output(["find", "/mnt", "-inum", filename_line.split()[0]]).decode('ascii').strip()

    filefrag_f=open("../analysis/frag_degree.txt", "w+")
    subprocess.check_call(["filefrag", "-v", filename], stdout=filefrag_f) #obtain the fragmentation state of the file
    subprocess.check_call(["sed","-i","1,3d", "../analysis/frag_degree.txt"])
    subprocess.check_call(["sed","-i","$d", "../analysis/frag_degree.txt"])
    os.fsync(filefrag_f.fileno())

    filefrag_f.close()

    filefrag_f=open("../analysis/frag_degree.txt", "r+")
    filefrag_f.seek(0)
    filefrag_lines = filefrag_f.readlines()

    targetFile_f = open(filename, "rb+")
    targetRange_f = open("../analysis/"+filename_line.split()[0]+".sorted", "r")
    targetRange = targetRange_f.readline()
    startRange = int(targetRange.split()[0])
    endRange = int(targetRange.split()[1])
    currentStart = 0
    currentEnd = -1
    
    #Performs fragmentation checking
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
                #If defragmtation is needed, FragPicker performs block allocation and data migration
                defrag_func(targetFile_f, startRange, endRange) 
                #total = total + endRange - startRange
                targetRange = targetRange_f.readline()
                if targetRange == '':
                    break
    
                startRange = int(targetRange.split()[0])
                endRange = int(targetRange.split()[1])

    targetFile_f.flush()
    os.fsync(targetFile_f.fileno()) #For durability
    targetFile_f.close()
    filefrag_f.close()
    #print(total)


