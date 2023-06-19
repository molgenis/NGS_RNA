set -o pipefail
#MOLGENIS nodes=1 ppn=8 mem=15gb walltime=23:59:00

#string project
#string stage
#string checkStage
#string gatkVersion
#string gatkJar
#string intermediateDir
#string	externalSampleID
#string bqsrBam
#string bqsrBai
#string splitAndTrimBam
#string	splitAndTrimBai
#string bqsrBeforeGrp
#string dbsnpVcf
#string tmpDataDir
#string indexFile
#string tmpTmpDataDir
#string project
#string groupname
#string tmpName
#string logsDir

makeTmpDir "${bqsrBam}"
tmpBqsrBam=${MC_tmpFile}

makeTmpDir "${bqsrBai}"
tmpBqsrBai=${MC_tmpFile}

#Load Modules
module load "${gatkVersion}"

#check modules
module list

echo "Running GATK BQSR:"


java -jar -Xmx7g -XX:ParallelGCThreads=2 -Djava.io.tmpdir="${tmpTmpDataDir}" \
"${EBROOTGATK}/${gatkJar}" BaseRecalibrator \
-R "${indexFile}" \
-I "${splitAndTrimBam}" \
-O "${bqsrBeforeGrp}" \
--known-sites "${dbsnpVcf}"

java -jar -Xmx7g -XX:ParallelGCThreads=2 -Djava.io.tmpdir="${tmpTmpDataDir}" \
"${EBROOTGATK}/${gatkJar}" ApplyBQSR \
-R "${indexFile}" \
-I "${splitAndTrimBam}" \
-O "${tmpBqsrBam}" \
--bqsr-recal-file "${bqsrBeforeGrp}"

mv "${tmpBqsrBam}" "${bqsrBam}"
mv "${tmpBqsrBai}" "${bqsrBai}"

cd "${intermediateDir}" || exit
md5sum "$(basename "${bqsrBam}")" > "$(basename "${bqsrBam}").md5"
md5sum "$(basename "${bqsrBai}")" > "$(basename "${bqsrBai}").md5"
cd - || exit

echo "returncode: $?";
echo "succes moving files";

