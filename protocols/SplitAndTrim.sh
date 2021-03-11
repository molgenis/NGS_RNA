#MOLGENIS nodes=1 ppn=1 mem=10gb walltime=23:59:00

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
#string tmpTmpDataDir
#string project
#string groupname
#string tmpName
#string logsDir

makeTmpDir "${splitAndTrimBam}"
tmpsplitAndTrimBam="${MC_tmpFile}"

makeTmpDir "${splitAndTrimBai}"
tmpsplitAndTrimBai="${MC_tmpFile}"

#Load Modules
${stage} ${gatkVersion}
${stage} ${samtoolsVersion}

#check modules
module list

echo "## "$(date)" Start $0"

echo
echo
echo "Running split and trim:"

gatk --java-options "-XX:ParallelGCThreads=1 -Djava.io.tmpdir=${tmpTmpDataDir} -Xmx10g" SplitNCigarReads \
-R "${indexFile}" \
-I "${sampleMergedDedupBam}" \
-O "${tmpsplitAndTrimBam}"

  mv "${tmpsplitAndTrimBam}" "${splitAndTrimBam}"
  mv "${tmpsplitAndTrimBai}" "${splitAndTrimBai}"

  # Create md5sum for zip file
	
  cd "${intermediateDir}"
  md5sum "${splitAndTrimShortBam}" > "${splitAndTrimShortBam}.md5"
  md5sum "${splitAndTrimShortBai}" > "${splitAndTrimShortBai}.md5"
  echo "returncode: $?";
  echo "succes moving files";
  cd -

  echo "## "$(date)" ##  $0 Done "

