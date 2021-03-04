#MOLGENIS walltime=23:59:00 mem=12gb ppn=8 nodes=1

#string stage
#string gatkVersion
#string checkStage
#string tmpTmpDataDir
#string tmpDataDir
#string indexFile
#string bqsrBam
#string intermediateDir
#string externalSampleID
#string dbsnpVcf
#string dbSNPFileID
#string GatkHaplotypeCallerGvcf
#string GatkHaplotypeCallerGvcfidx
#string project
#string groupname
#string tmpName
#string logsDir

makeTmpDir ${GatkHaplotypeCallerGvcf}
tmpGatkHaplotypeCallerGvcf=${MC_tmpFile}

makeTmpDir ${GatkHaplotypeCallerGvcfidx}
tmpGatkHaplotypeCallerGvcfidx=${MC_tmpFile}

array_contains () { 
    local array="$1[@]"
    local seeking=$2
    local in=1
    for element in "${!array-}"; do
        if [[ "$element" == "$seeking" ]]; then
            in=0
            break
        fi
    done
    return $in
}

#Load modules
${stage} ${gatkVersion}

#Check modules
${checkStage}

echo "## "$(date)" Start $0"

gatk --java-options "-XX:ParallelGCThreads=1 -Djava.io.tmpdir=${tmpTmpDataDir} -Xmx12g" HaplotypeCaller \
-R "${indexFile}" \
-I "${bqsrBam}" \
--dbsnp "${dbsnpVcf}" \
-ERC GVCF \
-O "${tmpGatkHaplotypeCallerGvcf}"

  mv "${tmpGatkHaplotypeCallerGvcf}" "${GatkHaplotypeCallerGvcf}"
  mv "${tmpGatkHaplotypeCallerGvcfidx}" "${GatkHaplotypeCallerGvcfidx}"
  echo "returncode: $?";
  echo "succes moving files";

  echo "## "$(date)" ##  $0 Done "
