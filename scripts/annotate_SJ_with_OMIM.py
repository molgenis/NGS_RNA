#!/usr/bin/python

### GAD PIPELINE ###
## annotate_SJ_with_OMIM.py
## Description : annotate a SJ file with data from OMIM database
## Usage : python annotate_SJ_with_OMIM.py -i <input file> -o <output file>
## Output : a tabulated SJ file including OMIM annotation
## Requirements : python 2.7, OMIM2 list

## Author : Emilie.Tisserant u-bourgogne fr, yannis.duffourd u-bourgogne fr
## Creation Date : 20170331
## last revision date : 20201016
## Known bugs : None

import getopt
import os
import sys

# Options
try:
    opts, args = getopt.getopt(sys.argv[1:], 'd:i:o:')
    for opt, arg in opts:
        if opt in ("-d"):
            omim = arg
        elif opt in ("-i"):
            filein = arg
        elif opt in ("-o"):
            sys.stdout = open(arg, 'w')
except getopt.GetoptError:
    print('usage : ')
    sys.exit(1)

omim_dict = {}
stream = open(omim, 'r')
for line in stream:
    line = line.strip()
    tabs = line.split('\t')
    omim_dict[tabs[0]] = tabs[1]
stream.close()

#Annotate variants
streamin = open(filein, 'r')
for line in streamin:
    line = line.strip()
    tabs = line.split('\t')
    if not line.startswith('#'):
        genelist = []
        gl = tabs[4].split(",")
        tag = 0
        for g in gl:
            if g in omim_dict:
                genelist.append(omim_dict[g])
                tag += 1
            else:
                genelist.append(".")
        if tag > 0:
            print(line+"\t"+",".join(genelist))
        else:
            print(line+"\t"+".")
    else:
        print(line+"\tOMIM")
streamin.close()
