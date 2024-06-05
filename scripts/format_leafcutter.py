#!/usr/bin/python

### GAD PIPELINE ###
## format_leafcutter.py
## Description : annotate a SJ file with batch coubts
## Usage : python format_leafcutter -i <leafcutter outlier_cluster_significance file> -o <output file> -e <leafcutter outlier_effect_sizes file>
## Output : a tabulated leafcutter file containing coordinates of effect
## Requirements : python 2.7, leafcutter output files

## Author : Emilie Tisserant u-bourgogne fr, yannis duffourd u-bourgogne fr
## Creation Date : 20170331
## last revision date : 20201021
## Known bugs : None


import os
import sys
import getopt

# Options
try:
    opts, args = getopt.getopt(sys.argv[1:], 'i:e:o:')
    for opt, arg in opts:
        if opt in ("-i"):
            filein = arg
        elif opt in ("-e"):
            effect = arg
        elif opt in ("-o"):
            sys.stdout = open(arg, 'w')
except getopt.GetoptError:
    print('usage : ')
    sys.exit(1)


clu_dict = {}
stream = open(filein, 'r')
for line in stream:
    if line.startswith("status") or line.startswith("cluster"):
        continue
    line = line.strip()
    tabs = line.split('\t')
    clu = tabs[0].split(":")[1]
    if tabs[1] == "Not enough valid samples" or  tabs[1] == "<=1 sample with coverage>min_coverage" or tabs[1] == "<=1 sample with coverage>0":
        continue
    clu_dict[clu] = line
stream.close()

effect_dict = {}
stream = open(effect, 'r')
for line in stream:
    line = line.strip()
    tabs = line.split('\t')
    if not line.startswith('intron'):
        clu = tabs[0].split(":")[3]
        if clu in clu_dict:
            if clu not in effect_dict:
                effect_dict[clu] = []
            effect_dict[clu].append(int(tabs[0].split(":")[1]))
            effect_dict[clu].append(int(tabs[0].split(":")[2]))
stream.close()

print "cluster\tstatus\tloglr\tdf\tp\tp.adjust\tgenes\tcoordinates"
for i in clu_dict:
    print(clu_dict[i]+"\t"+clu_dict[i].split(":")[0]+":"+str(min(effect_dict[i]))+"-"+str(max(effect_dict[i])))
