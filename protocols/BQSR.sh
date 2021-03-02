#MOLGENIS nodes=1 ppn=8 mem=15gb walltime=23:59:00

#string project
#string stage
#string checkStage
#string gatkVersion
#string intermediateDir
#string	externalSampleID
#string bqsrBam
#string bqsrBai
#string splitAndTrimBam
#string	splitAndTrimBai
#string indelRealignmentTargets
#string oneKgPhase1IndelsVcf
#string goldStandardVcf
#string bqsrBeforeGrp
#string dbsnpVcf
#string tmpDataDir
#string indexFile
#string tmpTmpDataDir
#string project
#string groupname
#string tmpName
#string logsDir

makeTmpDir ${bqsrBam} 
tmpBqsrBam=${MC_tmpFile}

makeTmpDir ${bqsrBai}
tmpBqsrBai=${MC_tmpFile}

#Load Modules
${stage} ${gatkVersion}

#check modules
${checkStage}

echo "## "$(date)" Start $0"

echo
echo
echo "Running GATK BQSR:"


java -Dsamjdk.use_async_io_read_samtools=false \
-Dsamjdk.use_async_io_write_samtools=true \
-Dsamjdk.use_async_io_write_tribble=false \
-Dsamjdk.compression_level=2 \
-jar -Xmx7g -XX:ParallelGCThreads=2 -Djava.io.tmpdir="${tmpTmpDataDir}" \
"${EBROOTGATK}/gatk-package-4.1.4.1-local.jar" BaseRecalibrator \
 -R "${indexFile}" \
 -I "${splitAndTrimBam}" \
 -O "${bqsrBeforeGrp}" \
 --known-sites "${dbsnpVcf}"

java -jar -Xmx7g -XX:ParallelGCThreads=2 -Djava.io.tmpdir="${tmpTmpDataDir}" \
"${EBROOTGATK}/gatk-package-4.1.4.1-local.jar" ApplyBQSR \
-R "${indexFile}" \
-I "${splitAndTrimBam}" \
-O "${tmpBqsrBam}" \
--bqsr-recal-file "${bqsrBeforeGrp}"

  mv "${tmpBqsrBam}" "${bqsrBam}"
  mv "${tmpBqsrBai}" "${bqsrBai}"

cd "${intermediateDir}"
 md5sum $(basename "${bqsrBam}")> $(basename "${bqsrBam}").md5sum
 md5sum $(basename "${bqsrBai}")> $(basename "${bqsrBai}").md5sum
cd -

  echo "returncode: $?";
  echo "succes moving files";
  echo "## "$(date)" ##  $0 Done "

