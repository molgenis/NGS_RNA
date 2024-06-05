#!/usr/bin/env python

### GAD PIPELINE ###
## convert_rMATS_to_bed.py
## Description : This script convert the rMATs output to a bed file for further integration to snv
## Usage : python convert_rMATS_to_bed -i <inuput directory> -o <output file>
## Output : tabulated output file with events detected for each gene
## Requirements : python 2.7, numpy

## Author : Emilie.Tisserant u-bourgogne fr
## Creation Date : 20170331
## last revision date : 20201007
## Known bugs : None

import os
import sys
import getopt




# Options
try:
    opts, args = getopt.getopt(sys.argv[1:], 'i:o:')
    for opt, arg in opts:
        if opt in ("-i"):
            inputfile = arg
        elif opt in ("-o"):
            sys.stdout = open(arg, 'w')
except getopt.GetoptError:
    print('usage : ')
    sys.exit(1)


instream = open(inputfile, 'r')
for line in instream:
    line = line.strip()
    tabs = line.split('\t')
    if not line.startswith('Type'):
        for i in tabs[6].split(";"):
            print(i.split(":")[1]+"\t"+i.split(":")[2].split("-")[0]+"\t"+i.split(":")[2].split("-")[1]+"\t"+tabs[1]+"_"+tabs[0]+"_"+i.split(":")[0])
instream.close()
