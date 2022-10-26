#!/usr/bin/python

import os
import sys
import getopt
import logging


try:
    opts, args = getopt.getopt(sys.argv[1:], 'i:o:e:')
    for opt, arg in opts:
        if opt in ("-i"):
            inputfile = arg
        elif opt in ("-o"):
            sys.stdout = open(arg, 'w')
        elif opt in ("-e"):
            logfile = arg
except getopt.GetoptError:
    print ("Usage : python create_counts_matrix.py -i <fileslist/file> -o <output/matrix/file> -e <log/file>")
    sys.exit(1)

# Create list for files
files_list = []
liststream = open(inputfile, 'r')
for line in liststream:
    line = line.strip()
    tabs = line.split("\t")
    files_list.append(tabs[0])
liststream.close()

# Read count files
samplelist = []
genelist = []
matrixdict = {}
i = 0
for f in files_list:
    samplelist.append(f.split("/")[-1].split(".")[0])
    stream = open(f, 'r')
    for line in stream:
        line = line.strip()
        tabs = line.split("\t")
        if not line.startswith('N_'):
            if i == 0:
                genelist.append(tabs[0])
            matrixdict.setdefault(tabs[0], []).append(tabs[1])
    stream.close()
    i += 1

# Print matrix
print ("Genes"+"\t"+"\t".join(samplelist))
for gene in genelist:
    print (gene+"\t"+"\t".join(matrixdict[gene]))

logging.info('end')
