#!/usr/bin/env python
import os
import pandas as pd
import re
import numpy as np
import sys
import getopt
import json
import matplotlib.pyplot as plt
from matplotlib import rcParams
rcParams.update({'figure.autolayout': True})

### Set defaults if commandline params are not used
inputDir = './'
outputDir = './'
plotConfig = './plot_statistics.json'

argv = sys.argv[1:]

try:
    opts, args = getopt.getopt(argv, "i:o:p:",
                            ["input_dir=",
                            "output_dir=",
                            "plot_config="])
except:
    print(help())
    sys.exit(1)

for opt, arg in opts:
    if opt in ['-i', '--input_dir']:
        inputDir = arg
    elif opt in ['-o', '--output_dir']:
        outputDir = arg
    elif opt in ['-p', '--plot_config']:
        plotConfig = arg

def listdir_fullpath(d):
    return [os.path.join(d, f) for f in os.listdir(d)]

def help():
    '''
    prints commandline params.
    '''

    print("python(3) plot_statistics.py \n\
        -i|--input_dir  <dir> \n\
        -o|--output_dir <dir> \n\
        -p|--plot_config config.json \
        ")

# Opening JSON file
with open(plotConfig) as jsonFile:
    config_json = json.load(jsonFile)

#for key, value in config_json.items():
#    print(json.dumps(config_json, indent = 4, sort_keys=True))

### Fetch all files in path
fileNames = listdir_fullpath(inputDir)

### Filter file name list for files ending with .metrics.tsv
fileNames = [file for file in fileNames if '.metrics.tsv' in file]

df_list =[]
for file in fileNames:
    df = pd.read_csv(file, sep='\t', header=None).T     # Read csv, and transpose
    df.columns = df.iloc[0]                             # Set new column names
    df.drop(0, inplace=True)
    df_list.append(df)

#concat all metics files together
df_comb = pd.concat(df_list)
#strip extention from fileaname
df_comb['Sample'] = df_comb['Sample'].apply(lambda x: re.findall(r'^(.+).sorted.merged.dedup.bam', x)[0])

#set collumns to float, except string collumns
ignore = ['Sample']
df_comb = (df_comb.set_index(ignore, append=True).astype(float).reset_index(ignore))
#print(df_comb.dtypes)

#loops over all plots to be made from plot_statistics.json, and sets ax-labels, title, axes etc...
for plot in config_json["plots"]:
    print('plot: ' + plot["name"])

    fig, ax = plt.subplots()
    ax.scatter(df_comb[plot["xas"]], df_comb[plot["yas"]])

    # Add a vertical line, on the mean.
    ax.axhline(df_comb[plot["yas"]].mean(), ls='--', color='r')
    ax.set_xlim(left=-1, right=1)
    ax.autoscale()
    ax.set_title(plot["name"])

    y_pos = np.arange(len(df_comb['Sample']))
    plt.xticks(y_pos, rotation=45, fontweight='bold', fontsize='10', horizontalalignment='right')
    plt.xlabel(plot['xAsTitle'])
    plt.ylabel(plot['yAsTitle'])
    plt.subplots_adjust(left=0.15)
    plt.autoscale()
    plt.savefig(outputDir+plot["imageName"]+'.png')
    plt.show()
