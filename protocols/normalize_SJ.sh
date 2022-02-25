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

INPUTFILE=${intermediateDir}/${externalSampleID}.SJ.out.tab
OUTPUTFILE=${intermediateDir}/${externalSampleID}.SJ.out.norm.tab

"${EBROOTNGS_RNA}/scripts/normalize_SJ.py" \
-i $INPUTFILE \
-o $OUTPUTFILE

echo "created: ${OUTPUTFILE}"
