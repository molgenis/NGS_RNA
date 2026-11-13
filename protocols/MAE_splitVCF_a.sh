set -o pipefail
#MOLGENIS nodes=1 ppn=1 mem=8gb walltime=01:00:00

#Parameter mapping
#string project
#string logsDir
#string intermediateDir
#string BCFtoolsVersion
#string WGSvcfID
#string MAEchrID
#string sampleMergedBam
#string indexSpecies
#string gatkVersion
#string samtoolsVersion

set -e
set -u

ml "${BCFtoolsVersion}"
ml "${gatkVersion}"
ml "${samtoolsVersion}"

if [[ -f "${WGSvcfID}" ]]
then
	base_vcf=$(basename -s .vcf.gz "${WGSvcfID}")
	echo "${base_vcf}"
else
	echo "There is no WGS vcf provided in the samplesheet, can't calculate MAE"
	exit 
fi

mkdir -p "${intermediateDir}/split.${base_vcf}/"

 # Index the VCF if not indexed already
if [[ -f "${WGSvcfID}".csi ]]
then
	echo "index file already excists"
else
	echo "make an index files for ${WGSvcfID}"
	bcftools index -f "${WGSvcfID}"
fi

# Get the list of chromosome names (skip the header)


if [[ "${MAEchrID}" == 'chr1' ]] || [[ "${MAEchrID}" == 'chr2' ]] 
then
	echo "Processing chromosome: ${MAEchrID}, for chr1 and chr2 do first only the chr1 and chr2 and then grep on chr1_ andn chr2_, if the grep is on chr1, it will also include chr10 trough chr19"
	bcftools view -O z -o "${intermediateDir}/split.${base_vcf}/split.${base_vcf}.${MAEchrID}.vcf.gz" "${WGSvcfID}" "${MAEchrID}"
	
	declare -a chroms=($(bcftools view "${WGSvcfID}" | grep -v '^#' | grep "${MAEchrID}_" | cut -f 1 | sort | uniq))

	for Chr in "${chroms[@]}"; do
		echo "Processing chromosome: ${Chr}"
		bcftools view -O z -o "${intermediateDir}/split.${base_vcf}/split.${base_vcf}.${Chr}.vcf.gz" "${WGSvcfID}" "${Chr}"
	done
else
	declare -a chroms=($(bcftools view "${WGSvcfID}" | grep -v '^#' | grep "${MAEchrID}" | cut -f 1 | sort | uniq))
	for Chr in "${chroms[@]}"; do
		echo "Processing chromosome: ${Chr}"
		bcftools view -O z -o "${intermediateDir}/split.${base_vcf}/split.${base_vcf}.${Chr}.vcf.gz" "${WGSvcfID}" "${Chr}"

	done
fi


