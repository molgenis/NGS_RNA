#MOLGENIS walltime=23:59:00 mem=4gb ppn=4

#Parameter mapping
#list sampleMergedBam
#string sampleMergedBamExt
#string tempDir
#string tmpDataDir
#string project
#string ngsversion
#string Python2PlusVersion
#string externalSampleID
#string intermediateDir
#string strandedness
#string rMATsOutputDir
#string annotationGtf
#string projectJobsDir
#string project
#string groupname
#string tmpName
#string logsDir

makeTmpDir "${intermediateDir}"
tmpintermediateDir=${MC_tmpFile}

module load "${ngsversion}"
module load "${Python2PlusVersion}"
module list

ZSCORE=3
DELTAPSY=0.2

echo "reformatting format_rMATS.py"
"${EBROOTNGS_RNA}/scripts/format_rMATS.py" \
-i "${rMATsOutputDir}/${externalSampleID}/" \
-o "${tmpintermediateDir}${externalSampleID}.rMATS.format.tsv"

# filter output
"${EBROOTNGS_RNA}/scripts/filter_rMATS.py" \
-i "${tmpintermediateDir}${externalSampleID}.rMATS.format.tsv" \
-o "${tmpintermediateDir}${externalSampleID}.rMATS.filtered.tsv" \
-d $DELTAPSY \
-z $ZSCORE

# convert to bed
"${EBROOTNGS_RNA}/scripts/convert_rMATS_to_bed.py" \
-i "${tmpintermediateDir}${externalSampleID}.rMATS.filtered.tsv" \
-o "${tmpintermediateDir}${externalSampleID}.rMATs.final.bed"

mv "${tmpintermediateDir}/${externalSampleID}."* "${rMATsOutputDir}/${externalSampleID}/"
echo "Created ${rMATsOutputDir}/${externalSampleID}/${externalSampleID}.rMATs.final.bed"
