set -o pipefail
#MOLGENIS nodes=1 ppn=1 mem=1gb walltime=05:00:00

#Parameter mapping
#string pythonPlusVersion
#string project
#string ngsVersion
#string rnaSeQCDir
#string tempTmpDir
#string logsDir
#string intermediateDir

#Load module
module load "${ngsVersion}"
module load "${pythonPlusVersion}"
module list


mkdir -p "${rnaSeQCDir}/plots"


python "${EBROOTNGS_RNA}/scripts/plot_statistics.py" \
--input_dir "${rnaSeQCDir}" \
--output_dir "${rnaSeQCDir}/plots/" \
--plot_config "${EBROOTNGS_RNA}/scripts/plot_statistics.json"
