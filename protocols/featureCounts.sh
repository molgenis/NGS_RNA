set -o pipefail
#MOLGENIS walltime=24:00:00 nodes=1 cores=1 mem=6gb

#Parameter mapping
#string sampleMergedBam
#string annotationGtf
#string strandedness
#string project
#string groupname
#string tmpName
#string logsDir
#string externalSampleID
#string annotationGtf
#string seqType
#string RbundleBioconductor
#string ngsVersion
#string intermediateDir

module load "${RbundleBioconductor}"
module load "${ngsVersion}"
module list

mkdir -p "${intermediateDir}/featureCounts/"

featureCountsDir="${intermediateDir}/featureCounts/"

if [[ "${seqType}" == 'SR' ]]
then
	echo "seqType = ${seqType}"
else
	echo "seqType = ${seqType}"
fi

## 1 = forward strand == 1++,1--,2+-,2-+ 
## 2 = reversed strand == 1+-,1-+,2++,2--

strandFraction=$(grep 1+-,1-+,2++,2-- "${strandedness}/${externalSampleID}.strandedness.txt" | sed 's/^[^:]*: //')

if [[ "${strandFraction}" =~ ^0.9 ]]
then
	echo "${strandFraction}=~ 0.9 strandedness is 2"
	strand_specific=2
elif [[ "${strandFraction}" =~ ^0.8 ]]
then
	echo "${strandFraction}=~ 0.8 strandedness is 2"
	strand_specific=2
elif [[ "${strandFraction}" =~ ^0.0 ]]
then
	echo "${strandFraction}=~ 0.0 stradedness is 1"
	strand_specific=1
else
	echo "${strandFraction} unstranded so strandedness is 0"
	strand_specific=0
fi

Rscript "${EBROOTNGS_RNA}/scripts/featureCounts.R" "${externalSampleID}" "${sampleMergedBam}" "${annotationGtf}" "${seqType}" "${strand_specific}" "${featureCountsDir}" > "${featureCountsDir}/${externalSampleID}_featureCounts.log"