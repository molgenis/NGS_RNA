set -o pipefail
#MOLGENIS walltime=23:59:00 mem=12gb ppn=8 nodes=1

#string gatkVersion
#string tmpTmpDataDir
#string tmpDataDir
#string indexFile
#string bqsrBam
#string intermediateDir
#string externalSampleID
#string dbsnpVcf
#string dbSNPFileID
#string gatkHaplotypeCallerGvcf
#string gatkHaplotypeCallerGvcftbi
#string project
#string groupname
#string tmpName
#string logsDir

makeTmpDir "${gatkHaplotypeCallerGvcf}"
tmpGatkHaplotypeCallerGvcf=${MC_tmpFile}

makeTmpDir "${gatkHaplotypeCallerGvcftbi}"
tmpGatkHaplotypeCallerGvcftbi=${MC_tmpFile}

#Load modules
module load "${gatkVersion}"

#Check modules
module list

gatk --java-options "-XX:ParallelGCThreads=1 -Djava.io.tmpdir=${tmpTmpDataDir} -Xmx12g" HaplotypeCaller \
-R "${indexFile}" \
-I "${bqsrBam}" \
--dbsnp "${dbsnpVcf}" \
-ERC GVCF \
-O "${tmpGatkHaplotypeCallerGvcf}"

mv "${tmpGatkHaplotypeCallerGvcf}" "${gatkHaplotypeCallerGvcf}"
mv "${tmpGatkHaplotypeCallerGvcftbi}" "${gatkHaplotypeCallerGvcftbi}"
