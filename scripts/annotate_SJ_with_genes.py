#!/usr/bin/python

### GAD PIPELINE ###
## annotate_SJ_with_genes.py
## Description : annotate a SJ file with data from refseq genes
## Usage : python annotate_SJ_with_genes.py -i <input file> -o <output file> -g <refseq gtf file>
## Output : a tabulated SJ file containing genes annotation
## Requirements : python 2.7

## Author : Emilie.Tisserant u-bourgogne fr, yannis.duffourd u-bourgogne fr
## Creation Date : 20170331
## last revision date : 20201009
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
            gtf = arg
        elif opt in ("-o"):
            sys.stdout = open(arg, 'w')
except getopt.GetoptError:
    print 'usage : '
    sys.exit(1)

genes_dict = {}
stream = open(gtf, 'r')
for line in stream:
    if line.startswith('#'):
        continue
    line = line.strip()
    tabs = line.split('\t')
    gene = line.split('"')[1]
    chrm, start, end = tabs[0], int(tabs[3]), int(tabs[4])
    gene = line.split('"')[1]
    if gene not in genes_dict:
        genes_dict[gene] = [chrm, start, end]
    elif chrm == genes_dict[gene][0]:
        if start < genes_dict[gene][1]:
            genes_dict[gene][1] = start
        if end > genes_dict[gene][2]:
            genes_dict[gene][2] = end
stream.close()



#TODO strand???

instream = open(infile, 'r')
for line in instream:
    line = line.strip()
    tabs = line.split('\t')
    chrm = tabs[0]
    start = int(tabs[1])
    end = int(tabs[2])
    genes_list = []
    for g in genes_dict:
        if genes_dict[g][0] == chrm and int(genes_dict[g][1]) <= start and int(genes_dict[g][2]) >= start:
            genes_list.append(g)
        if genes_dict[g][0] == chrm and int(genes_dict[g][1]) <= end and int(genes_dict[g][2]) >= end:
            genes_list.append(g)
    if len(genes_list) > 0:
        print line+"\t"+",".join(list(set(genes_list)))
    else:
        print line+"\t"+"."
instream.close()
