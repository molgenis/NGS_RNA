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
#string ngsVersion
#string python2PlusVersion


makeTmpDir "${intermediateDir}"
tmpintermediateDir="${MC_tmpFile}"

module load "${ngsVersion}"
module load "${python2PlusVersion}"
module list

rm -f "${intermediateDir}/${project}.SJ.samples.list"

for sample in "${externalSampleID[@]}"
do
  echo "${intermediateDir}/${sample}.SJ.out.norm.tab" >> "${intermediateDir}/${project}.SJ.samples.list"
done

"${EBROOTNGS_RNA}/scripts/create_batch_sjdb.py" \
-l "${intermediateDir}/${project}.SJ.samples.list" \
-o "${tmpintermediateDir}/${project}.SJ.batch.list"

mv "${tmpintermediateDir}/${project}.SJ.batch.list" "${intermediateDir}/${project}.SJ.batch.list"
echo "Created: ${intermediateDir}/${project}.SJ.batch.list"
