set -o pipefail
#MOLGENIS nodes=1 ppn=1 mem=4gb walltime=01:00:00

#Parameter mapping
#string project
#string logsDir
#string intermediateDir
#string BCFtoolsVersion
#string WGSvcfID
#string sampleMergedBam
#string indexSpecies
#string gatkVersion
#string samtoolsVersion

set -e
set -u

ml "${BCFtoolsVersion}"
ml "${gatkVersion}"
ml "${samtoolsVersion}"

base_vcf=$(basename -s .vcf.gz "${WGSvcfID}")
echo "${base_vcf}"

chr_files=("${intermediateDir}/split.${base_vcf}/split.${base_vcf}"*_maecounts.tsv)


head -n 1 "${chr_files[0]}" > "${intermediateDir}/split.${base_vcf}/tmp.${base_vcf}.results_mae.tsv"

for file in "${chr_files[@]}"
do
	echo "file:${file}"
	tail -n+2 "${file}" >> "${intermediateDir}/split.${base_vcf}/tmp.${base_vcf}.results_mae.tsv"
done


cp "${intermediateDir}/split.${base_vcf}/tmp.${base_vcf}.results_mae.tsv" "${intermediateDir}/split.${base_vcf}/${base_vcf}.results_mae.tsv"


