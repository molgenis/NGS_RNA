set -o pipefail
#MOLGENIS nodes=1 ppn=1 mem=8gb walltime=05:00:00

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

function readCounting() {
	local _chrvcfid="${1}"
	local _chr="${2}"
	local _tmpdir="${3}"
	
	echo "bamFile:${sampleMergedBam}, vcfFile:${_chrvcfid}"
	checkReadGroup=$(samtools view -H "${sampleMergedBam}" | grep "@RG")
	
	echo "checkReadGroup:${checkReadGroup}"
	
	if [[ -z "${checkReadGroup}" ]]
	then
		printf "%s\n" "ERROR: BAM file doesnt contain Read Group Tag RG"
		printf "RG doesnt exist, it can be added using:\n"
		printf "   gatk AddOrReplaceGroups -R /path/to/reference -I /your/input.bam -O /your/output.bam --QUIET true\n"
		printf " https://gatk.broadinstitute.org/hc/en-us/articles/360037226472-AddOrReplaceReadGroups-Picard-\n"
		printf " Try rerunning this module using the BAM with RG tags\n"
		exit 1
	else
		printf "BAM contains read groups RG, continuing with ASEReadCounter...\n"
	fi
	
	local _chr_base_vcf
	_chr_base_vcf=$(basename -s .vcf.gz "${_chrvcfid}")
	echo "_chr_base_vcf=${_chr_base_vcf}"
	#base_vcf="${WGSvcfID%.vcf.gz}"
	
	# Remove INFO field, it sometimes contains whitespace or invalid line lengths
	echo "_______________________bcftools annotate________________"
	bcftools annotate -x "INFO" "${_chrvcfid}" -o "${_tmpdir}/noinfo_${_chr_base_vcf}.vcf"
	
	# Create index
	echo "_____________________gatk IndexFeatureFile______________________"
	gatk IndexFeatureFile -I "${_tmpdir}/noinfo_${_chr_base_vcf}.vcf"
	
	# Only select heterozygous variants and only SNPs
	echo "______________________gatk SelectVariants______________________"
	gatk SelectVariants -V "${_tmpdir}/noinfo_${_chr_base_vcf}.vcf" -O "${_tmpdir}/temp_${_chr_base_vcf}.vcf" -R "${indexSpecies}" --restrict-alleles-to BIALLELIC -select "vc.getHetCount()==1" --select-type-to-include SNP
	
	# Remove duplicates
	echo "____________________bcftools norm___________________"
	bcftools norm --rm-dup all "${_tmpdir}/temp_${_chr_base_vcf}.vcf" > "${_tmpdir}/temp_${_chr_base_vcf}.vcf.tmp" && mv "${_tmpdir}/temp_${_chr_base_vcf}.vcf.tmp" "${_tmpdir}/temp_${_chr_base_vcf}.vcf"
	
	# Create new index
	echo "________________________gatk IndexFeatureFile_______________________"
	gatk IndexFeatureFile -I "${_tmpdir}/temp_${_chr_base_vcf}.vcf"
	
	# Run ASEReadCounter
	echo "________________________gatk ASEReadCounter__________________________"
	echo "-I ${sampleMergedBam} -V ${_tmpdir}/temp_${_chr_base_vcf}.vcf -O ${_tmpdir}/${_chr_base_vcf}_temp_counts.tsv -R ${indexSpecies}"
	
	gatk ASEReadCounter -I "${sampleMergedBam}" -V "${_tmpdir}/temp_${_chr_base_vcf}.vcf" -L "${_chr}" -O "${_tmpdir}/${_chr_base_vcf}_temp_counts.tsv" -R "${indexSpecies}"
	
	# Sorting the count file
	echo "_______________last step, creating ${_chr_base_vcf}_maecounts.tsv_________________"
	(head -n 1 "${_tmpdir}/${_chr_base_vcf}_temp_counts.tsv" && tail -n +2 "${_tmpdir}/${_chr_base_vcf}_temp_counts.tsv" | sort -k1,1 -V -s) > "${_tmpdir}/${_chr_base_vcf}_maecounts.tsv"

	echo "vcf file: ${_chrvcfid}, with chr ${_chr} is done"
	

}

base_vcf=$(basename -s .vcf.gz "${WGSvcfID}")
echo "${base_vcf}"

mkdir -p "${intermediateDir}/split.${base_vcf}/"


# Get the list of chromosome names (skip the header)


#original part
if [[ "${MAEchrID}" == 'chr1' ]] || [[ "${MAEchrID}" == 'chr2' ]] 
then
	echo "Processing chromosome: ${MAEchrID}, for chr1 and chr2 do first only the chr1 and chr2 and then grep on chr1_ andn chr2_, if the grep is on chr1, it will also include chr10 trough chr19"
	readCounting "${intermediateDir}/split.${base_vcf}/split.${base_vcf}.${MAEchrID}.vcf.gz" "${MAEchrID}" "${intermediateDir}/split.${base_vcf}/"

	mapfile -t chroms < <(bcftools view "${WGSvcfID}" | grep -v '^#' | grep "${MAEchrID}_" | cut -f 1 | sort | uniq)
#	declare -a chroms=($(bcftools view "${WGSvcfID}" | grep -v '^#' | grep "${MAEchrID}_" | cut -f 1 | sort | uniq))

	for Chr in "${chroms[@]}"; do
		echo "Processing chromosome: ${Chr}"
		readCounting "${intermediateDir}/split.${base_vcf}/split.${base_vcf}.${Chr}.vcf.gz" "${Chr}" "${intermediateDir}/split.${base_vcf}/"
	done
else
	mapfile -t chroms < <(bcftools view "${WGSvcfID}" | grep -v '^#' | grep "${MAEchrID}" | cut -f 1 | sort | uniq)
#	declare -a chroms=($(bcftools view "${WGSvcfID}" | grep -v '^#' | grep "${MAEchrID}" | cut -f 1 | sort | uniq))
	for Chr in "${chroms[@]}"; do
		echo "Processing chromosome: ${Chr}"
		readCounting "${intermediateDir}/split.${base_vcf}/split.${base_vcf}.${Chr}.vcf.gz" "${Chr}" "${intermediateDir}/split.${base_vcf}/"
	done
fi

echo "script finished!!!!!!!!!!"