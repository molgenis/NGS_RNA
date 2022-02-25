#MOLGENIS nodes=1 ppn=4 mem=4gb walltime=05:59:00

#Parameter mapping
#string RPlusVersion
#string intermediateDir
#string project
#string groupname
#string tmpName
#string logsDir
#string ngsversion
#string projectRawtmpDataDir
#string projectQcDir
#string projectJobsDir
#string annotationFile

module load "${RPlusVersion}"
module load "${ngsversion}"
module list

cd "${intermediateDir}"

#cleanup old file if present
rm -f "${intermediateDir}/design.txt"
cp "${projectJobsDir}/${project}.csv" "${intermediateDir}/metadata.csv"

perl -pi -e 's|externalFastQ_1|samplename|g' "${intermediateDir}/metadata.csv"

echo "creating design file."
Rscript "${EBROOTNGS_RNA}/scripts/design.R" "${intermediateDir}/metadata.csv"

echo "running: deseq2 analysis"
Rscript "${EBROOTNGS_RNA}/scripts/deseq2_analysis.R" "${intermediateDir}/metadata.csv" "${annotationFile}"

cd -
