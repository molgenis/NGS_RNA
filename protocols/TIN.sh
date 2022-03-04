#MOLGENIS walltime=23:59:00 mem=40gb ppn=1

#Parameter mapping
#string stage
#string checkStage
#string sampleMergedBam
#string sampleMergedBai
#string RSeQCVersion
#string samtoolsVersion
#string BEDToolsVersion
#string externalSampleID
#string houseKeepingGenesBed
#string TinDir
#string tempDir
#string project
#string intermediateDir
#string groupname
#string tmpName
#string logsDir

echo "## "$(date)" Start $0"

mkdir -p "${TinDir}"
cd "${TinDir}"

# Extract the alignment of housekeeping genes.
module load "${BEDToolsVersion}"
bedtools intersect -a "${sampleMergedBam}"  -b "${houseKeepingGenesBed}" > "${intermediateDir}/${externalSampleID}.sorted.merged.housekeeping.bam"

# index BAM
module load "${samtoolsVersion}"
samtools index "${intermediateDir}/${externalSampleID}.sorted.merged.housekeeping.bam"  > "${intermediateDir}/${externalSampleID}.sorted.merged.housekeeping.bam.bai"

module load "${RSeQCVersion}"
tin.py -r "${houseKeepingGenesBed}" -i "${intermediateDir}/${externalSampleID}.sorted.merged.housekeeping.bam"

cd -

echo "succes moving files";
echo "## "$(date)" ##  $0 Done "
