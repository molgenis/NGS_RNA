set -o pipefail
#MOLGENIS nodes=1 ppn=1 mem=10gb walltime=05:00:00

#Parameter mapping
#string rSeQCVersion
#string project
#string strandedness
#string bed12
#string logsDir
#string intermediateDir
#string externalSampleID
#string genome

#Load module
module load "${rSeQCVersion}"
module list

makeTmpDir "${intermediateDir}"
tmpStrandednessDir=${MC_tmpFile}


i=$(find "${intermediateDir}" -name "${externalSampleID}.sorted.merged.bam")

infer_experiment.py -r "${bed12}" -i "${i}" > "${tmpStrandednessDir}/${externalSampleID}.strandedness.tmp.txt"

mv "${tmpStrandednessDir}/${externalSampleID}.strandedness.tmp.txt" "${intermediateDir}/${externalSampleID}.strandedness.txt"

# for the transcriptone-analysis-pipeline we need the build version
echo "${genome}" > "${intermediateDir}/${externalSampleID}.build.txt"


