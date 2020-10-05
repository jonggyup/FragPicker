import sys
import subprocess
import os
import re

thislist = list()

try:
    with open("./traces/iozone_rand.trace") as f:
        for line in f:
            thislist=re.split("\(|,|=|\)", line)
            thislist = [x for x in thislist if "\\" not in x]
         #   if thislist[0] == "read"
            thislist.pop()
            print(thislist)

except IOError:
    print("Cannot open file")
    sys.exit(1)
