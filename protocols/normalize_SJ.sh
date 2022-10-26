#MOLGENIS walltime=23:59:00 mem=4gb ppn=1

#Parameter mapping
#list sampleMergedBam
#string sampleMergedBamExt
#string tempDir
#string tmpDataDir
#string project
#string externalSampleID
#string intermediateDir
#string strandedness
#string ngsVersion
#string python2PlusVersion
#string annotationGtf
#string projectJobsDir
#string project
#string groupname
#string tmpName
#string logsDir


makeTmpDir "${intermediateDir}"
tmpIntermediateDir="${MC_tmpFile}"

module load "${ngsVersion}"
module load "${python2PlusVersion}"
module list

"${EBROOTNGS_RNA}/scripts/normalize_SJ.py" \
-i "${intermediateDir}${externalSampleID}.SJ.out.tab" \
-o "${tmpIntermediateDir}${externalSampleID}.SJ.out.norm.tab"

mv "${tmpIntermediateDir}${externalSampleID}.SJ.out.norm.tab" "${intermediateDir}/${externalSampleID}.SJ.out.norm.tab"
echo "created: ${intermediateDir}${externalSampleID}.SJ.out.norm.tab"
