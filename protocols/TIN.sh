#MOLGENIS walltime=23:59:00 mem=40gb ppn=1

#Parameter mapping
#string stage
#string checkStage
#string sampleMergedBam
#string sampleMergedBai
#string RSeQCVersion
#string bed12
#string TinDir
#string tempDir
#string project
#string intermediateDir
#string groupname
#string tmpName
#string logsDir

#Load Picard module
module load "${RSeQCVersion}"
module list

echo "## "$(date)" Start $0"

mkdir -p "${TinDir}"
cd "${TinDir}"

tin.py -r "${bed12}" -i "${sampleMergedBam}"

cd -

echo "succes moving files";
echo "## "$(date)" ##  $0 Done "
