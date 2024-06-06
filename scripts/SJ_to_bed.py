#!/usr/bin/env python3

### GAD PIPELINE ###
## SJ_to_bed.py
## Description : convert a SJ file into a bed file
## Usage : python SJ_to_bed.py -i <input file> -o <output file>
## Output : a bed file
## Requirements : python 2.7

## Author : Emilie.Tisserant u-bourgogne fr, yannis.duffourd u-bourgogne fr
## Creation Date : 20170331
## last revision date : 20201016
## Known bugs : None

import getopt
import os
import sys

# python SJ_to_bed.py -i dijarn.SJ.filter.tsv -o dijarn.SJ.bed
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


instream = open(infile, 'r')
for line in instream:
    line = line.strip()
    tabs = line.split('\t')
    if not line.startswith('#'):
        print(tabs[0].split(":")[0]+"\t"+tabs[0].split(":")[1].split("-")[0]+"\t"+tabs[0].split(":")[1].split("-")[1]+"\t"+tabs[0]+":"+tabs[1])
instream.close()
