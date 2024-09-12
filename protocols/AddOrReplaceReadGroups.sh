set -o pipefail
#MOLGENIS nodes=1 ppn=8 mem=8gb walltime=05:00:00

#string project
#string stage
#string checkStage
#string intermediateDir
#string sortedBam
#string sortedBai
#string addOrReplaceGroupsBam
#string addOrReplaceGroupsBai
#string externalSampleID
#string picardVersion
#string picardJar
#string tempTmpDir
#string groupname
#string	tmpName
#string logsDir

makeTmpDir "${addOrReplaceGroupsBam}"
tmpAddOrReplaceGroupsBam="${MC_tmpFile}"

makeTmpDir "${addOrReplaceGroupsBai}"
tmpAddOrReplaceGroupsBai="${MC_tmpFile}"

#Load modules
module load "${picardVersion}"

#check modules
module list


java -Xmx6g -XX:ParallelGCThreads=8 -jar "${EBROOTPICARD}/${picardJar}" AddOrReplaceReadGroups \
I="${sortedBam}" \
O="${tmpAddOrReplaceGroupsBam}" \
SORT_ORDER=coordinate \
RGID="${externalSampleID}" \
RGLB="${externalSampleID}" \
RGPL=ILLUMINA \
RGPU="${externalSampleID}" \
RGSM="${externalSampleID}" \
CREATE_INDEX=true \
MAX_RECORDS_IN_RAM=4000000 \
TMP_DIR="${tempTmpDir}"

echo "returncode: $?";

rm "${sortedBam}"
mv "${tmpAddOrReplaceGroupsBam}" "${addOrReplaceGroupsBam}"
mv "${tmpAddOrReplaceGroupsBai}" "${addOrReplaceGroupsBai}"
echo "succes moving files";
