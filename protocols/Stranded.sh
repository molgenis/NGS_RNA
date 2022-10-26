#MOLGENIS nodes=1 ppn=1 mem=10gb walltime=05:00:00

#Parameter mapping
#string rSeQCVersion
#string project
#string strandedness
#string bed12
#string tempDir
#string logsDir
#string intermediateDir

#Load module
module load "${rSeQCVersion}"
module list

makeTmpDir "${strandedness}"
tmpStrandedness=${MC_tmpFile}


echo "## $(date) Start $0"

i=$(ls "${intermediateDir}"/*.Aligned.sortedByCoord.out.bam -1 |shuf -n 1)

infer_experiment.py -r "${bed12}" -i "${i}" > "${tmpStrandedness}"

mv "${tmpStrandedness}" "${strandedness}"

echo "succes moving files";
echo "## $(date) ##  $0 Done "


