import sys
import subprocess
import os

#Data Migration without block allocation
def defrag_func(targetFile_f, start, end):
    targetFile_f.seek(start, 0)
    size = end-start+1
    data = targetFile_f.read(size)
    targetFile_f.seek(start, 0)
    targetFile_f.write(data)
         
#Open the file list to defrag
filelist_f=open("../analysis/filelist.txt", "r+")
filename_lines = filelist_f.readlines()

for filename_line in filename_lines:

    if str(filename_line.split()[0]) == '':
        continue
    
    #translate inode number to the file path
    filename = subprocess.check_output(["find", "/mnt", "-inum", filename_line.split()[0]]).decode('ascii').strip()


    filefrag_f=open("../analysis/frag_degree.txt", "w+")
    subprocess.check_call(["filefrag", "-v", filename], stdout=filefrag_f)
    #obtain the fragmentation state of the file
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
                #If defragmentation is needed, FragPicker performs data migration
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



