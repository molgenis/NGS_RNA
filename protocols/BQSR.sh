#MOLGENIS nodes=1 ppn=8 mem=15gb walltime=23:59:00

#string project
#string stage
#string checkStage
#string gatkVersion
#string intermediateDir
#string	externalSampleID
#string bqsrBam
#string bqsrBai
#string IndelRealignedBam
#string	IndelRealignedBai
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


java -Xmx14g -XX:ParallelGCThreads=8 -Djava.io.tmpdir=${tmpTmpDataDir} -jar $EBROOTGATK/GenomeAnalysisTK.jar \
 -T BaseRecalibrator\
 -R ${indexFile} \
 -I ${IndelRealignedBam} \
 -o ${bqsrBeforeGrp} \
 -knownSites ${dbsnpVcf} \
 -knownSites ${goldStandardVcf} \
 -knownSites ${oneKgPhase1IndelsVcf} \
 -nct 2

java -Xmx14g -XX:ParallelGCThreads=8 -Djava.io.tmpdir=${tmpTmpDataDir} -jar $EBROOTGATK/GenomeAnalysisTK.jar \
 -T PrintReads \
 -R ${indexFile} \
 -I ${IndelRealignedBam} \
 -o ${tmpBqsrBam} \
 -BQSR ${bqsrBeforeGrp} \
 -nct 2


  mv ${tmpBqsrBam} ${bqsrBam}
  mv ${tmpBqsrBai} ${bqsrBai}

cd ${intermediateDir}
 md5sum $(basename ${bqsrBam})> $(basename ${bqsrBam}).md5sum
 md5sum $(basename ${bqsrBai})> $(basename ${bqsrBai}).md5sum
cd -

  echo "returncode: $?";
  echo "succes moving files";
  echo "## "$(date)" ##  $0 Done "

