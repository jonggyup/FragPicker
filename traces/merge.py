import sys 
import subprocess
import os

filelist_f = open("./filelist.txt", "r+")
result_file = open("./tmp.txt", "w+")

lines = filelist_f.readlines()

for line in lines:
    filename = line.split()[0]
    trace_file = open("./" + filename + ".txt", "r+")
    trace_lines = trace_file.readlines()
    currentStart = -1
    currentEnd = -1
    currentNums = 0
    begin = False
    
    for trace_line in trace_lines:
        print(trace_line)
        splitdata = trace_line.split();
        start = int(splitdata[0])
        end = int(splitdata[1])
        nums = int(splitdata[2])
        
        #Not in the current range, new start
        if currentEnd < start:
            if begin == True:
                result_file.write(str(currentStart) +" " + str(currentEnd) + " " + str(currentNums) + "\n") 

            currentStart = start
            currentEnd = end
            currentNums = nums
            begin = True
            continue

        if currentEnd >= end:
            currentNums += 1
            continue

        if currentEnd <= end:
            currentNums += 1
            currentEnd = end

result_file.write(str(currentStart) +" " + str(currentEnd) + " " + str(currentNums) + "\n") 
