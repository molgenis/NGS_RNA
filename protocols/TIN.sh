#MOLGENIS walltime=23:59:00 mem=40gb ppn=1

#Parameter mapping
#string sampleMergedBam
#string sampleMergedBai
#string rSeQCVersion
#string samtoolsVersion
#string bedToolsVersion
#string externalSampleID
#string houseKeepingGenesBed
#string tinDir
#string tempDir
#string project
#string intermediateDir
#string groupname
#string tmpName
#string logsDir

echo "## $(date) Start $0"

makeTmpDir "${intermediateDir}"
tmpintermediateDir=${MC_tmpFile}

mkdir -p "${tinDir}"
cd "${tinDir}"

# Extract the alignment of housekeeping genes.
module load "${bedToolsVersion}"

bedtools intersect \
-a "${sampleMergedBam}" \
-b "${houseKeepingGenesBed}" > "${tmpintermediateDir}/${externalSampleID}.sorted.merged.housekeeping.bam"

# index BAM
module load "${samtoolsVersion}"

samtools index "${tmpintermediateDir}/${externalSampleID}.sorted.merged.housekeeping.bam"  > "${tmpintermediateDir}/${externalSampleID}.sorted.merged.housekeeping.bam.bai"

module load "${rSeQCVersion}"

tin.py \
-r "${houseKeepingGenesBed}" \
-i "${tmpintermediateDir}/${externalSampleID}.sorted.merged.housekeeping.bam"

mv "${tmpintermediateDir}/${externalSampleID}"* "${intermediateDir}"

cd -

echo "succes moving files";
echo "## $(date) ##  $0 Done "
