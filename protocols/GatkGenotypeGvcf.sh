set -o pipefail
#MOLGENIS walltime=23:59:00 mem=17gb ppn=3 nodes=1

#string gatkVersion
#string tempDir
#string tmpDataDir
#string dbsnpVcf
#string gatkVersion
#string htsLibVersion
#string indexFile
#list externalSampleID,gatkHaplotypeCallerGvcf
#string intermediateDir
#string projectPrefix
#string projectBatchCombinedVariantCalls
#string projectBatchGenotypedVariantCalls
#string projectJobsDir
#string project
#string groupname
#string tmpName
#string logsDir

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

makeTmpDir "${projectBatchGenotypedVariantCalls}"
tmpProjectBatchGenotypedVariantCalls=${MC_tmpFile}

makeTmpDir "${projectBatchCombinedVariantCalls}"
tmpProjectBatchCombinedVariantCalls=${MC_tmpFile}

#Load modules
module load "${gatkVersion}"
module load "${htsLibVersion}"
#Check modules
module list

INPUTS=()
ALLGVCFs=()

for external in "${externalSampleID[@]}"
do
	array_contains INPUTS "${external}" || INPUTS+=("${external}")    # If vcfFile does not exist in array add it
done

SAMPLESIZE=${#INPUTS[@]}
numberofbatches=$(("${SAMPLESIZE}" / 200))

for b in $(seq 0 "${numberofbatches}")
do
	if [[ -f "${gatkHaplotypeCallerGvcf}.${b}" ]]
	then
		ALLGVCFs+=("--variant ${gatkHaplotypeCallerGvcf}.${b}")
	fi
done

if [[ "${SAMPLESIZE}" -gt 200 ]]
then
	for b in $(seq 0 "${numberofbatches}")
	do
		if [[ -f "${projectBatchCombinedVariantCalls}.${b}" ]]
		then
			ALLGVCFs+=("--variant=${projectBatchCombinedVariantCalls}.${b}")
		fi
	done
else
	for sampleGvcf in "${gatkHaplotypeCallerGvcf[@]}"
	do
		if [[ -f "${sampleGvcf}" ]]
		then
			array_contains ALLGVCFs "--variant=${sampleGvcf}" || ALLGVCFs+=("--variant=${sampleGvcf}")
		fi
	done
fi


GvcfSize=${#ALLGVCFs[@]}

if [[ ${GvcfSize} -ne 0 ]]
then

	gatk --java-options "-Xmx5g -Djava.io.tmpdir=${tempDir}" CombineGVCFs \
	--reference="${indexFile}" \
	"${ALLGVCFs[@]}" \
	--output="${tmpProjectBatchCombinedVariantCalls}"

	gatk --java-options "-Xmx7g -XX:ParallelGCThreads=2 -Djava.io.tmpdir=${tempDir}" GenotypeGVCFs \
	--reference="${indexFile}" \
	--variant="${tmpProjectBatchCombinedVariantCalls}" \
	--dbsnp="${dbsnpVcf}" \
	--output="${tmpProjectBatchGenotypedVariantCalls}"

	mv "${tmpProjectBatchGenotypedVariantCalls}" "${projectBatchGenotypedVariantCalls}"
	echo "moved ${tmpProjectBatchGenotypedVariantCalls} to ${projectBatchGenotypedVariantCalls}"

	tabix -p vcf "${projectBatchGenotypedVariantCalls}"

	echo "${projectBatchGenotypedVariantCalls} ..done"

	cd "${intermediateDir}" || exit
	md5sum "$(basename "${projectBatchGenotypedVariantCalls}")" > "$(basename "${projectBatchGenotypedVariantCalls}").md5"
	cd - || exit 
	echo "succes moving files"

else
	echo ""
	echo "there is nothing to genotype, skipped"
	echo ""
fi
