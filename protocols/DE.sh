set -o pipefail
#MOLGENIS nodes=1 ppn=1 mem=4gb walltime=05:59:00

#Parameter mapping
#string rPlusVersion
#string intermediateDir
#string project
#list externalSampleID
#string groupname
#string tmpName
#string logsDir
#string ngsVersion
#string projectQcDir
#string projectJobsDir

module load "${rPlusVersion}"
module load "${ngsVersion}"
module list

#Function to check if array contains value
array_contains () {
	local array="$1[@]"
	local seeking="${2}"
	local in=1
	for element in "${!array-}"; do
		if [[ "${element}" == "${seeking}" ]]; then
			in=0
			break
		fi
	done
	return "${in}"
}

UNIQUESAMPLES=()

for sampleId in "${externalSampleID[@]}"
do
	array_contains UNIQUESAMPLES "${sampleId}" || UNIQUESAMPLES+=("${sampleId}")    # If sampleId does not exist in array add it
done

cd "${intermediateDir}" || exit

#detect number of conditions
col=$(col="condition"; head -n1 "${projectJobsDir}/${project}.csv" | tr "," "\n" | grep -n "${col}")
# shellcheck disable=SC2206
colArray=(${col//:/ })
conditionCount=$(tail -n +2 "${projectJobsDir}/${project}.csv" | cut -d "," -f "${colArray[0]}" | sort | uniq | wc -l)

if [[ "${conditionCount}" -eq 1 ]]
then
	echo "creating design file for ${conditionCount} conditions in samplesheet."

	for sample in "${UNIQUESAMPLES[@]}"
	do
		#cleanup old file if present
		rm -f "${intermediateDir}/design.txt"

		echo "creating design file for sample ${sample}."
		Rscript "${EBROOTNGS_RNA}/scripts/design.R" "${intermediateDir}/${sample}.DE.design.csv"

		echo "running: deseq2 analysis for sample ${sample}"
		Rscript "${EBROOTNGS_RNA}/scripts/deseq2_analysis.R" "${intermediateDir}/${sample}.DE.design.csv" "${sample}"
	done
else
	#cleanup old file if present
	rm -f "${intermediateDir}/design.txt"

	echo "creating design file for ${conditionCount} conditions in samplesheet ."
	Rscript "${EBROOTNGS_RNA}/scripts/design.R" "${projectJobsDir}/${project}.csv"

	echo "running: deseq2 analysis"
	Rscript "${EBROOTNGS_RNA}/scripts/deseq2_analysis.R" "${projectJobsDir}/${project}.csv" "${project}"
fi
cd - || exit
