#!/bin/bash
#MOLGENIS walltime=23:59:00 mem=8gb ppn=6

#Parameter mapping
#string stage
#string checkStage
#list sampleMergedBam,sampleMergedBai
#string tempDir
#string tmpDataDir
#string project
#string intermediateDir
#string groupname
#string tmpName
#string logsDir

sleep 5

#Function to check if array contains value
array_contains () {
	local array="$1[@]"
	local seeking=$2
	local in=1
	for element in "${!array-}"; do
		if [[ "${element}" == "${seeking}" ]]; then
			in=0
			break
		fi
	done
	return $in
}

makeTmpDir "${sampleMergedBam}"
tmpSampleMergedBam="${MC_tmpFile}"

makeTmpDir "${sampleMergedBai}"
tmpSampleMergedBai="${MC_tmpFile}"

#Load MAJIQ module
module load MAJIQ/2.1-foss-2018b-Python-3.7.4
module list

#Create string with input BAM files for Picard
#This check needs to be performed because Compute generates duplicate values in array
INPUTS=()
INPUTBAMS=()
UNIQUEBAIS=()

for bamFile in "${sampleMergedBam[@]}"
do
	array_contains INPUTS "INPUT=${bamFile}" || INPUTS+=("INPUT=${bamFile}")    # If bamFile does not exist in array add it
done


mkdir -p "${intermediateDir}"/majiq/bams

# possibility 3:
cat <<EOT >> "${intermediateDir}"/majiq/config.ini

[info]
bamdirs="${intermediateDir}"/majiq/bams/
genome=hg19
readlen=150

[experiments]
validatie="${INPUTS[@]}"
EOT

majiq build /apps/data/Ensembl/GrCh37.75/pub/release-75/gff/Homo_sapiens.GRCh37.75.gff -o "${intermediateDir}"/majiq -c /groups/umcg-atd/tmp01/projects/validatie_NGS_RNA_Diagnostiek/run01_leafcutter/results/majiq/config.ini -j 4 

# werkt ook blijkbaar...
majiq psi -o "${intermediateDir}"/majiq/output/ --min-experiments 0.10 -n validatie ${intermediateDir}/majiq/*.majiq

#Voila command:
voila tsv -f ${intermediateDir}"/majiq/output//${project}_voila_output.tsv "${intermediateDir}"/majiq/output/
