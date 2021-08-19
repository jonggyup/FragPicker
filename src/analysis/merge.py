import sys 
import subprocess
import os

filelist_f = open("./filelist.txt", "r+")

lines = filelist_f.readlines()

for line in lines:
    filename = line.split()[0]
    trace_file = open("./" + filename + ".txt", "r+")
    trace_lines = trace_file.readlines()
    mergeWindowStart = -1
    mergeWindowEnd = -1
    mergeNums = 0
    begin = False
 
    result_file = open("./tmp.txt", "w+")

    for trace_line in trace_lines:
        splitdata = trace_line.split();
        start = int(splitdata[0]) #The start address of this request
        end = int(splitdata[1]) #The end address of this request
        nums = int(splitdata[2]) #The number of counts
        
        #Not in the current merge window, new start
        if mergeWindowEnd < start:
            if begin == True:
                result_file.write(str(mergeWindowStart) +" " + str(mergeWindowEnd) + " " + str(mergeWindowNums) + "\n") 

            mergeWindowStart = start #New mergeWindow is created
            mergeWindowEnd = end
            mergeNums = nums
            begin = True
            continue
        
        
        if mergeWindowEnd >= end:
            mergeNums += 1 #within the window, increase the count
            continue

        if mergeWindowEnd <= end:
            mergeNums += 1 #overlapped with the window, increase the count
            mergeWindowEnd = end #and extend the window
        
    result_file.write(str(mergeWindowStart) +" " + str(mergeWindowEnd) + " " + str(mergeNums) + "\n") #Store the merged I/O info.
    result_file.close()
    subprocess.call(["mv", "./tmp.txt", "./"+str(filename)+".merged"])
