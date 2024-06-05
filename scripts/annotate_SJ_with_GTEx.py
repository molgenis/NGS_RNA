#!/usr/bin/python

### GAD PIPELINE ###
## annotate_SJ_with_GTEx.py
## Description : annotate a SJ file with data from GTEx database
## Usage : python annotate_SJ_with_GTEx.py -i <input file> -o <output file>
## Output : a tabulated SJ file including GTEx annotation
## Requirements : python 2.7, GTEx database

## Author : Emilie.Tisserant u-bourgogne fr, yannis.duffourd u-bourgogne fr
## Creation Date : 20170331
## last revision date : 20201016
## Known bugs : None

import getopt
import os
import sys


# Options
try:
    opts, args = getopt.getopt(sys.argv[1:], 'i:g:o:')
    for opt, arg in opts:
        if opt in ("-i"):
            infile = arg
        elif opt in ("-g"):
            gtex = arg
        elif opt in ("-o"):
            sys.stdout = open(arg, 'w')
except getopt.GetoptError:
    print('usage : ')
    sys.exit(1)

juncdict = {}
stream = open(gtex, 'r')
for line in stream:
    line = line.strip()
    tabs = line.split('\t')
    if not line.startswith('junction_id'):
        junc = "chr"+tabs[0].split("_")[0]+":"+tabs[0].split("_")[1]+"-"+tabs[0].split("_")[2]
        juncdict[junc]=",".join(tabs[1:])
stream.close()



instream = open(infile, 'r')
for line in instream:
    line = line.strip()
    tabs = line.split('\t')
    junc = tabs[0]+":"+tabs[1]+"-"+tabs[2]
    if junc in juncdict:
        c = 0
        for j in juncdict[junc].split(","):
            if int(j) > 3:
                c = c+1
        #print line+"\t"+str(c)+"\t"+juncdict[junc]
        print(line+"\t"+str(c))
    else:
        #print line+"\t0\t."
        print(line+"\t0")
instream.close()
