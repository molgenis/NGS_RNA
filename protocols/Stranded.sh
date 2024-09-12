set -o pipefail
#MOLGENIS nodes=1 ppn=1 mem=10gb walltime=05:00:00

#Parameter mapping
#string rSeQCVersion
#string project
#string strandedness
#string bed12
#string logsDir
#string intermediateDir

#Load module
module load "${rSeQCVersion}"
module list

makeTmpDir "${strandedness}"
tmpStrandedness=${MC_tmpFile}


i=$(find "${intermediateDir}" -name "*.Aligned.sortedByCoord.out.bam" | shuf -n 1)

infer_experiment.py -r "${bed12}" -i "${i}" > "${tmpStrandedness}"

mv "${tmpStrandedness}" "${strandedness}"
