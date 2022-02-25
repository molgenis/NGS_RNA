#MOLGENIS walltime=23:59:00 mem=4gb ppn=4

#Parameter mapping
#list sampleMergedBam
#string sampleMergedBamExt
#string tempDir
#string tmpDataDir
#string project
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
tmpSampleMergedDedupBam="${MC_tmpFile}"

module load PythonPlus/2.7.16-foss-2018b-v20.12.1
module load NGS_RNA/beta
module list

#tmp
EBROOTNGS_RNA='/home/umcg-gvdvries/git/NGS_RNA'

ZSCORE=3
DELTAPSY=0.2

FORMATTMPFILE="${rMATsOutputDir}/${externalSampleID}/${externalSampleID}.rMATS.format.tsv"
FILTERTMPFILE="${rMATsOutputDir}/${externalSampleID}/${externalSampleID}.rMATS.filtered.tsv"
OUTPUTFILE="${rMATsOutputDir}/${externalSampleID}/${externalSampleID}.rMATs.final.bed"

"${EBROOTNGS_RNA}/scripts/format_rMATS.py" \
-i "${rMATsOutputDir}/${externalSampleID}/" \
-o $FORMATTMPFILE

# filter output
"${EBROOTNGS_RNA}/scripts/filter_rMATS.py" \
-i $FORMATTMPFILE \
-o $FILTERTMPFILE \
-d $DELTAPSY \
-z $ZSCORE

# convert to bed
"${EBROOTNGS_RNA}/scripts/convert_rMATS_to_bed.py" \
-i $FILTERTMPFILE \
-o $OUTPUTFILE

