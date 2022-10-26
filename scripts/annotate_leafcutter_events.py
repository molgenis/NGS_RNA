#!/usr/bin/python

### GAD PIPELINE ###
## annotate_leafcutter_events.py
## Description : annotate a SJ file with omim entries
## Usage : python annotate_leafcutter_events -i <leafcutter report> -o <output file> -d <omim file>
## Output : a tabulated leafcutter file including omim annotation
## Requirements : python 2.7, leafcutter output files

## Author : Emilie.Tisserant u-bourgogne fr, yannis.duffourd u-bourgogne fr
## Creation Date : 20170331
## last revision date : 20201021
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
    print 'usage : '
    sys.exit(1)


omim_dict = {}
stream = open(omim, 'r')
for line in stream:
    line = line.strip()
    tabs = line.split('\t')
    omim_dict[tabs[0]] = tabs[1]
stream.close()


#Annotate variants
stream = open(filein, 'r')
for line in stream:
    line = line.strip()
    tabs = line.split('\t')
    if not line.startswith('cluster'):
        genelist = []
        gl = tabs[6].split(",")
        tag = 0
        for g in gl:
            if g in omim_dict:
                genelist.append(omim_dict[g])
                tag += 1
            else:
                genelist.append(".")
        if tag > 0:
            print line+"\t"+",".join(genelist)
        else:
            print line+"\t."
    else:
        print line+"\tOMIM"
stream.close()
