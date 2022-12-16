#MOLGENIS walltime=5:59:00 mem=4gb ppn=1

#Parameter mapping
#string sampleMergedDedupBam
#string sampleMergedDedupBai
#string project
#string rnaseqcVersion
#string rnaSeQCGTF
#string rnaSeQCDir
#string groupname
#string tmpName
#string logsDir

mkdir -p "${rnaSeQCDir}"

singularity exec --bind "/groups:/groups,/apps:/apps" "${rnaseqcVersion}" \
rnaseqc -v \
--coverage \
"${rnaSeQCGTF}" \
"${sampleMergedDedupBam}" \
"${rnaSeQCDir}"
