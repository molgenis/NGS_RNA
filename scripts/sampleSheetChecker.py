import sys
import csv
import os

reader = csv.DictReader(open(sys.argv[1], "rb"), delimiter=",")
project=open("project.txt.tmp","w")
build=open("build.txt.tmp","w")
species=open("species.txt.tmp","w")
sampleType=open("sampleType.txt.tmp","w")
externalSampleID=open("externalSampleIDs.txt.tmp","w")

count=0
for row in reader:
	for (k,v) in row.items():		
		if "project" in row:
			if k == "project":
				project.write(v+'\n')
		if "build" in row:
			if k == "build":
				build.write(v+'\n')
		if "species" in row:
			if k == "species":
				vals = v.split('|')
				species.write(vals[0]+'\n')
				build.write(vals[1]+'\n')
		if "sampleType" in row:
			if k == "sampleType":
				sampleType.write(v+'\n')
		if "externalSampleID" in row:
			if k == "externalSampleID":
				externalSampleID.write(v+'\n')
	if count == 0:		
		if not "species" in row:
                        out=open(sys.argv[1]+'.temp',"w")
                        print("no species found")
			os.remove("species.txt.tmp")
                        out.write(','.join(row.keys())+",species"+'\n')
                        out.write(','.join(row.values())+","+'\n')
                        count+=1
                        species="no"
	elif species == "no":
                print("no species found.")
                out.write(','.join(row.values())+","+'\n')
