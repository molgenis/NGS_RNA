#!/bin/bash
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
#string sequencer
#string flowcell
#string run
#string tempDir
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

echo "## $(date) Start $0"

java -Xmx6g -XX:ParallelGCThreads=8 -jar "${EBROOTPICARD}/${picardJar}" AddOrReplaceReadGroups \
I="${sortedBam}" \
O="${tmpAddOrReplaceGroupsBam}" \
SORT_ORDER=coordinate \
RGID="${externalSampleID}" \
RGLB="${externalSampleID}" \
RGPL=ILLUMINA \
RGPU="${sequencer}_${flowcell}_${run}" \
RGSM="${externalSampleID}" \
RGDT=$(date --rfc-3339=date) \
CREATE_INDEX=true \
MAX_RECORDS_IN_RAM=4000000 \
TMP_DIR="${tempDir}"

echo "returncode: $?";
mv "${tmpAddOrReplaceGroupsBam}" "${addOrReplaceGroupsBam}"
mv "${tmpAddOrReplaceGroupsBai}" "${addOrReplaceGroupsBai}"
echo "succes moving files";
echo "## $(date) ##  $0 Done "
