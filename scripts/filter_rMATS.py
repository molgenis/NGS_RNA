#!/usr/bin/env python

### GAD PIPELINE ###
## filter_rMATS.py
## Description : This script filter rMATs output
## Usage : python filter_rMATS -i <input directory> -o <output file> -z <zscore> -d <deltapsy>
## Output : tabulated output file with events detected for each gene
## Requirements : python 2.7, numpy

## Author : Emilie Tisserant u-bourgogne fr
## Creation Date : 20170331
## last revision date : 20201007
## Known bugs : None
import os
import sys
import getopt




# Options
try:
    opts, args = getopt.getopt(sys.argv[1:], 'i:d:z:o:')
    for opt, arg in opts:
        if opt in ("-i"):
            inputfile = arg
        elif opt in ("-d"):
            deltapsy = arg
        elif opt in ("-z"):
            zscore = arg
        elif opt in ("-o"):
            sys.stdout = open(arg, 'w')
except getopt.GetoptError:
    print 'usage : '
    sys.exit(1)


instream = open(inputfile, 'r')
for line in instream:
    line = line.strip()
    tabs = line.split('\t')
    if not line.startswith('Type'):
        if ((float(tabs[15]) >= float(deltapsy)) or  (float(tabs[15]) <= -float(deltapsy))) and ((float(tabs[16]) >= float(zscore)) or  (float(tabs[16]) <= -float(zscore))):
            print line
    else:
        print line
instream.close()
