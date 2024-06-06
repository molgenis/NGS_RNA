#!/usr/bin/env python3

### GAD PIPELINE ###
## filter_SJ.py
## Description : filter a SJ file based on annotations
## Usage : python filter_SJ.py -i <input file> -o <output file>
## Output : a filtered tabulated SJ file
## Requirements : python 2.7

## Author : Emilie.Tisserant u-bourgogne fr, yannis.duffourd u-bourgogne fr
## Creation Date : 20170331
## last revision date : 20201016
## Known bugs : None

import getopt
import os
import sys


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

print("#sjdb"+"\t"+"#Reads"+"\t"+"Norm"+"\t"+"Annotation"+"\t"+"Genes"+"\t"+"#Batch"+"\t"+"Zscore"+"\t"+"#GTEx")
# Uniquely mapped reads
instream = open(infile, 'r')
for line in instream:
    line = line.strip()
    tabs = line.split('\t')
    if int(tabs[6]) >= 5 and float(tabs[9]) >= 0.05 and tabs[10] != "Annotated" and tabs[11] != "." and int(tabs[12]) <= 5 and int(tabs[14]) <= 5:
        print(tabs[0]+":"+tabs[1]+"-"+tabs[2]+"\t"+tabs[6]+"\t"+"\t".join(tabs[9:]))
instream.close()


# tabs[6] >= 5,10
# tabs[9] != "Annotated"
# tabs[10] != "."
# tabs[11] <= 2
# tabs[12] <= 5
