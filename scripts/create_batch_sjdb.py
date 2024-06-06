#!/usr/bin/env python3

### GAD PIPELINE ###
## create_batch_sjdb.py
## Description : This script create a SJDB file from a list of normalized SJ files
## Usage : python create_batch_sjdb -i <input file> -o <output file>
## Output : tabulated output file with SJ associated to samples
## Requirements : python 2.7

## Author : Emilie.Tisserant u-bourgogne fr, yannis duffourd u-bourgogne fr
## Creation Date : 20170331
## last revision date : 20201009
## Known bugs : None




import os
import sys
import getopt

# Options
try:
    opts, args = getopt.getopt(sys.argv[1:], 'l:o:')
    for opt, arg in opts:
        if opt in ("-l"):
            fileslist = arg
        elif opt in ("-o"):
            sys.stdout = open(arg, 'w')
except getopt.GetoptError:
    print('usage : ')
    sys.exit(1)

# Create list for files
files_list = []
liststream = open(fileslist, 'r')
for line in liststream:
    line = line.strip()
    tabs = line.split("\t")
    files_list.append(tabs[0])
liststream.close()

for f in files_list:
    sample = f.split("/")[-1].split(".")[0]
    stream = open(f, 'r')
    for line in stream:
        line = line.strip()
        tabs = line.split("\t")
        print(tabs[0]+":"+tabs[1]+"-"+tabs[2]+"\t"+sample+"\t"+tabs[6]+"\t"+tabs[9])
    stream.close()
