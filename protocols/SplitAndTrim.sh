set -o pipefail
#MOLGENIS nodes=1 ppn=2 mem=15gb walltime=23:59:00

#string project
#string stage
#string checkStage
#string sampleMergedDedupBam
#string sampleMergedDedupBai
#string splitAndTrimShortBam
#string splitAndTrimShortBai
#string samtoolsVersion
#string gatkVersion
#string intermediateDir
#string	externalSampleID
#string splitAndTrimBam
#string splitAndTrimBai
#string gatkJar
#string tmpDataDir
#string indexFile
#string tempDir
#string project
#string groupname
#string tmpName
#string logsDir

makeTmpDir "${splitAndTrimBam}"
tmpsplitAndTrimBam="${MC_tmpFile}"

makeTmpDir "${splitAndTrimBai}"
tmpsplitAndTrimBai="${MC_tmpFile}"

#Load Modules
module load "${gatkVersion}"
module load "${samtoolsVersion}"

#check modules
module list

java -Xmx14g -XX:ParallelGCThreads=2 \
-Djava.io.tmpdir="${tempDir}" \
-jar "${EBROOTGATK}/${gatkJar}" SplitNCigarReads \
--tmp-dir "${tempDir}" \
-R "${indexFile}" \
-I "${sampleMergedDedupBam}" \
-O "${tmpsplitAndTrimBam}"

mv "${tmpsplitAndTrimBam}" "${splitAndTrimBam}"
mv "${tmpsplitAndTrimBai}" "${splitAndTrimBai}"

# Create md5sum for zip file

cd "${intermediateDir}" || exit
md5sum "${splitAndTrimShortBam}" > "${splitAndTrimShortBam}.md5"
md5sum "${splitAndTrimShortBai}" > "${splitAndTrimShortBai}.md5"
cd - || exit

