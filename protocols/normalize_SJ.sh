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
#string annotationGtf
#string projectJobsDir
#string project
#string groupname
#string tmpName
#string logsDir


makeTmpDir "${intermediateDir}"
tmpIntermediateDir="${MC_tmpFile}"

module load "${ngsversion}"
module load "${Python2PlusVersion}"
module list

INPUTFILE=${tmpIntermediateDir}/${externalSampleID}.SJ.out.tab
OUTPUTFILE=${tmpIntermediateDir}/${externalSampleID}.SJ.out.norm.tab

"${EBROOTNGS_RNA}/scripts/normalize_SJ.py" \
-i "${tmpIntermediateDir}"/"${externalSampleID}.SJ.out.tab" \
-o "${tmpIntermediateDir}"/"${externalSampleID}.SJ.out.norm.tab"

mv "${tmpIntermediateDir}"/"${externalSampleID}.SJ.out.norm.tab" "${intermediateDir}/${externalSampleID}.SJ.out.norm.tab"
echo "created: ${intermediateDir}/${externalSampleID}.SJ.out.norm.tab"
