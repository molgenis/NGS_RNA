#!/usr/bin/env python3

### GAD PIPELINE ###
## normalize_SJ.py
## Description : This script normalize SJ data
## Usage : python normalize_SJ -i <input directory> -o <output file>
## Output : tabulated output file with normalized data
## Requirements : python 2.7

## Author : Emilie Tisserant u-bourgogne fr, yannis duffourd u-bourgogne fr
## Creation Date : 20170331
## last revision date : 20201009
## Known bugs : None


import os
import sys
import getopt

# Options
try:
    opts, args = getopt.getopt(sys.argv[1:], 'i:o:')
    for opt, arg in opts:
        if opt in ("-i"):
            infile = arg
        elif opt in ("-o"):
            sys.stdout = open(arg, 'w')
except getopt.GetoptError:
    print('usage : ')
    sys.exit(1)


junclist, juncdict, startdict, enddict = [], {}, {}, {}
instream = open(infile, 'r')
for line in instream:
    line = line.strip()
    tabs = line.split('\t')
    junc = tabs[0]+":"+tabs[1]+"-"+tabs[2]
    junclist.append(junc)
    juncdict[junc] = line
    startdict.setdefault(tabs[0]+":"+tabs[1], [])
    startdict[tabs[0]+":"+tabs[1]].append(int(tabs[6]))
    enddict.setdefault(tabs[0]+":"+tabs[2], [])
    enddict[tabs[0]+":"+tabs[2]].append(int(tabs[6]))
instream.close()

for j in junclist:
    start=j.split(":")[0]+":"+j.split(":")[1].split("-")[0]
    end=j.split(":")[0]+":"+j.split(":")[1].split("-")[1]
    reads, total = int(juncdict[j].split('\t')[6]), 0
    if start in startdict:
        total=total+sum(startdict[start])
    if end in enddict:
        total=total+sum(enddict[end])
    if total > 0:
        norm = reads/float(total-reads)
        #print juncdict[j]+"\t"+str(norm)+"\t"+str(len(startdict[start]))+"\t"+str(len(enddict[end]))
        print(juncdict[j]+"\t"+str(norm))
    else:
        #print juncdict[j]+"\t0\t.\t."
        print(juncdict[j]+"\t0")
