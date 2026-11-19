set -o pipefail
#MOLGENIS walltime=24:00:00 nodes=1 cores=1 mem=6gb

#Parameter mapping
#string sampleMergedBam
#string project
#string groupname
#string tmpName
#string logsDir
#string externalSampleID
#string annotationGtf
#string seqType
#string RbundleBioconductor
#string intermediateDir

module load "${RbundleBioconductor}"
module list



fraserCountsDir="${intermediateDir}/fraserCounts/"


Rscript "${EBROOTNGS_RNA}/scripts/frasercounts.R" "${sampleMergedBam}" "${fraserCountsDir}"