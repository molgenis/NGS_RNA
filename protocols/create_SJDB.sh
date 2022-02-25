#MOLGENIS walltime=23:59:00 mem=4gb ppn=4

#Parameter mapping
#list sampleMergedBam
#string sampleMergedBamExt
#string tempDir
#string tmpDataDir
#string project
#list externalSampleID
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

rm -f "${intermediateDir}/${project}.SJ.samples.list"

for sample in "${externalSampleID[@]}"
do
  echo "${intermediateDir}/$sample.SJ.out.norm.tab" >> "${intermediateDir}/${project}.SJ.samples.list"
done

INPUTFILE=/groups/umcg-solve-rd/tmp01/umcg-gvdvries/NGS_RNA_test_large//SJ.samples.list
OUTPUTFILE=/groups/umcg-solve-rd/tmp01/umcg-gvdvries/NGS_RNA_test_large//SJ.batch.list

"${EBROOTNGS_RNA}/scripts/create_batch_sjdb.py" \
-l "${intermediateDir}/${project}.SJ.samples.list" \
-o "${intermediateDir}/${project}.SJ.batch.list"

echo "Created: ${intermediateDir}/${project}.SJ.batch.list"
