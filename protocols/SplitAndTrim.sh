#MOLGENIS nodes=1 ppn=8 mem=10gb walltime=23:59:00

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

java -Dsamjdk.use_async_io_read_samtools=false \
-Dsamjdk.use_async_io_write_samtools=true \
-Dsamjdk.use_async_io_write_tribble=false \
-Dsamjdk.compression_level=2 \
-jar "${EBROOTGATK}/gatk-package-4.1.4.1-local.jar" SplitNCigarReads \
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

