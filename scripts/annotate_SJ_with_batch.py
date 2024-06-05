#!/usr/bin/python
### GAD PIPELINE ###
## annotate_SJ_with_batch.py
## Description : annotate a SJ file with batch coubts
## Usage : python annotate_SJ_with_batch.py -i <input file> -o <output file> -b <sjdb batch file>
## Output : a tabulated SJ file containing batch counts annotation
## Requirements : python 2.7, numpy

## Author : Emilie.Tisserant u-bourgognefr, yannis.duffourd u-bourgognefr
## Creation Date : 20170331
## last revision date : 20201009
## Known bugs : None

import getopt
import os
import sys


from numpy import mean, std

# Options
try:
    opts, args = getopt.getopt(sys.argv[1:], 'i:b:o:')
    for opt, arg in opts:
        if opt in ("-i"):
            infile = arg
        elif opt in ("-b"):
            batch = arg
        elif opt in ("-o"):
            sys.stdout = open(arg, 'w')
except getopt.GetoptError:
    print('usage : ')
    sys.exit(1)


juncdict = {}
instream = open(infile, 'r')
for line in instream:
    line = line.strip()
    tabs = line.split('\t')
    junc = tabs[0]+":"+tabs[1]+"-"+tabs[2]
    juncdict[junc] = line
instream.close()

juncbatchdict, nbsamples = {}, []
stream = open(batch, 'r')
for line in stream:
    line = line.strip()
    tabs = line.split('\t')
    if not line.startswith('sjdb'):
        if tabs[1] not in nbsamples:
            nbsamples.append(tabs[1])
        if tabs[0] in juncdict and int(tabs[2]) > 3:
            if tabs[0] not in juncbatchdict:
                juncbatchdict[tabs[0]]=[[tabs[1]],[tabs[2]],[tabs[3]]]
            else:
                juncbatchdict[tabs[0]][0].append(tabs[1])
                juncbatchdict[tabs[0]][1].append(tabs[2])
                juncbatchdict[tabs[0]][2].append(tabs[3])
stream.close()

# TODO zscore
instream = open(infile, 'r')
for line in instream:
    line = line.strip()
    tabs = line.split('\t')
    junc = tabs[0]+":"+tabs[1]+"-"+tabs[2]
    if junc in  juncbatchdict:
        #print line+"\t"+",".join(juncbatchdict[junc][0])+"\t"+",".join(juncbatchdict[junc][1])+"\t"+str(len(juncbatchdict[junc][1])-1)
        norm_list = list(map(float,juncbatchdict[junc][2]))
        norm_list = norm_list + [0. for i in range((len(nbsamples)-len(norm_list)))]
        zscore = (float(tabs[9])-mean(norm_list))/std(norm_list)
        print(line+"\t"+str(len(juncbatchdict[junc][1])-1)+"\t"+str(zscore))
instream.close()
