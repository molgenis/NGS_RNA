#!/usr/bin/env python

### GAD PIPELINE ###
## format_rMATS.py
## Description : This script regroup and format the rMATs output
## Usage : python format_rMATS -i <input directory> -o <output file>
## Output : tabulated output file with events detected for each gene
## Requirements : python 2.7, numpy

## Author : Emilie.Tisserant u-bourgogne fr
## Creation Date : 20170331
## last revision date : 20201007
## Known bugs : None


import os
import sys
import getopt
from numpy import mean, std



# Options
try:
    opts, args = getopt.getopt(sys.argv[1:], 'i:o:')
    for opt, arg in opts:
        if opt in ("-i"):
            prefix = arg
        elif opt in ("-o"):
            sys.stdout = open(arg, 'w')
except getopt.GetoptError:
    print('usage : ')
    sys.exit(1)

print("Type\tID\tGeneID\tchr\tstrand\tcoordinates\texons\tIJC_SAMPLE_1\tSJC_SAMPLE_1\tIJC_SAMPLE_2\tSJC_SAMPLE_2\tPValue\tFDR\tIncLevel1\tIncLevel2\tIncLevelDifference\tZscore")

event_type = ["A3SS","A5SS","RI","SE","MXE"]
for event in event_type:
    instream = open(prefix+"/"+event+".MATS.JCEC.txt", 'r')
    for line in instream:
        line = line.strip()
        tabs = line.split('\t')
        if not line.startswith('ID'):
            if event == "SE" and (float(tabs[19]) <= 0.05):
                IncLevel_list = list(map(float,tabs[21].split(',')))
                IncLevel_list.append(float(tabs[20]))
                zscore = (float(tabs[20])-mean(IncLevel_list))/std(IncLevel_list)
                coordinates = tabs[3]+":"+str(min(list(map(int,tabs[5:11]))))+"-"+str(max(list(map(int,tabs[5:11]))))
                exons = "SE_exon:"+tabs[3]+":"+tabs[5]+"-"+tabs[6]+";upstream_exon:"+tabs[3]+":"+tabs[7]+"-"+tabs[8]+";downstream_exon:"+tabs[3]+":"+tabs[9]+"-"+tabs[10]
                print(event+"\t"+"\t".join(tabs[0:2])+"\t"+"\t".join(tabs[3:5])+"\t"+coordinates+"\t"+exons+"\t"+"\t".join(tabs[12:16])+"\t"+"\t".join(tabs[18:])+"\t"+str(zscore))
            if event == "RI" and (float(tabs[19]) <= 0.05):
                IncLevel_list = list(map(float,tabs[21].split(',')))
                IncLevel_list.append(float(tabs[20]))
                zscore = (float(tabs[20])-mean(IncLevel_list))/std(IncLevel_list)
                coordinates = tabs[3]+":"+str(min(list(map(int,tabs[5:11]))))+"-"+str(max(list(map(int,tabs[5:11]))))
                exons = "RI_exon:"+tabs[3]+":"+tabs[5]+"-"+tabs[6]+";upstream_exon:"+tabs[3]+":"+tabs[7]+"-"+tabs[8]+";downstream_exon:"+tabs[3]+":"+tabs[9]+"-"+tabs[10]
                print(event+"\t"+"\t".join(tabs[0:2])+"\t"+"\t".join(tabs[3:5])+"\t"+coordinates+"\t"+exons+"\t"+"\t".join(tabs[12:16])+"\t"+"\t".join(tabs[18:])+"\t"+str(zscore))
            if event == "A3SS" and (float(tabs[19]) <= 0.05):
                IncLevel_list = list(map(float,tabs[21].split(',')))
                IncLevel_list.append(float(tabs[20]))
                zscore = (float(tabs[20])-mean(IncLevel_list))/std(IncLevel_list)
                coordinates = tabs[3]+":"+str(min(list(map(int,tabs[5:11]))))+"-"+str(max(list(map(int,tabs[5:11]))))
                exons = "long_exon:"+tabs[3]+":"+tabs[5]+"-"+tabs[6]+";short_exon:"+tabs[3]+":"+tabs[7]+"-"+tabs[8]+";flanking_exon:"+tabs[3]+":"+tabs[9]+"-"+tabs[10]
                print(event+"\t"+"\t".join(tabs[0:2])+"\t"+"\t".join(tabs[3:5])+"\t"+coordinates+"\t"+exons+"\t"+"\t".join(tabs[12:16])+"\t"+"\t".join(tabs[18:])+"\t"+str(zscore))
            if event == "A5SS" and (float(tabs[19]) <= 0.05):
                IncLevel_list = list(map(float,tabs[21].split(',')))
                IncLevel_list.append(float(tabs[20]))
                zscore = (float(tabs[20])-mean(IncLevel_list))/std(IncLevel_list)
                coordinates = tabs[3]+":"+str(min(list(map(int,tabs[5:11]))))+"-"+str(max(list(map(int,tabs[5:11]))))
                exons = "long_exon:"+tabs[3]+":"+tabs[5]+"-"+tabs[6]+";short_exon:"+tabs[3]+":"+tabs[7]+"-"+tabs[8]+";flanking_exon:"+tabs[3]+":"+tabs[9]+"-"+tabs[10]
                print(event+"\t"+"\t".join(tabs[0:2])+"\t"+"\t".join(tabs[3:5])+"\t"+coordinates+"\t"+exons+"\t"+"\t".join(tabs[12:16])+"\t"+"\t".join(tabs[18:])+"\t"+str(zscore))
            if event == "MXE" and (float(tabs[21]) <= 0.05):
                IncLevel_list = list(map(float,tabs[23].split(',')))
                IncLevel_list.append(float(tabs[22]))
                zscore = (float(tabs[22])-mean(IncLevel_list))/std(IncLevel_list)
                coordinates = tabs[3]+":"+str(min(list(map(int,tabs[5:13]))))+"-"+str(max(list(map(int,tabs[5:13]))))
                exons = "1st_exon:"+tabs[3]+":"+tabs[5]+"-"+tabs[6]+";2nd_exon:"+tabs[3]+":"+tabs[7]+"-"+tabs[8]+";upstream_exon:"+tabs[3]+":"+tabs[9]+"-"+tabs[10]+";downstream_exon:"+tabs[3]+":"+tabs[11]+"-"+tabs[12]
                print(event+"\t"+"\t".join(tabs[0:2])+"\t"+"\t".join(tabs[3:5])+"\t"+coordinates+"\t"+exons+"\t"+"\t".join(tabs[14:18])+"\t"+"\t".join(tabs[20:])+"\t"+str(zscore))

instream.close()
