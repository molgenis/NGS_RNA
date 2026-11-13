set -o pipefail
#MOLGENIS walltime=05:59:00 mem=5gb ppn=1 nodes=1

#string tmpDataDir
#string htsLibVersion
#string vipVersion
#string intermediateDir
#string projectPrefix
#string projectBatchGenotypedVariantCalls
#string projectBatchGenotypedVIPPrefix
#string projectJobsDir
#string project
#string groupname
#string tmpName
#string logsDir
#string spliceaiIndel
#string spliceaiSnv

#Load modules
module load "${vipVersion}"
#Check modules
module list

	cp "${EBROOTVIP}/config/default.cfg" "${intermediateDir}/vip.config"
	echo "annotate_vep_plugin_SpliceAI=${spliceaiSnv},${spliceaiIndel}" >> "${intermediateDir}/vip.config"

	cd "${EBROOTVIP}" || exit
	bash pipeline.sh \
	-c "${intermediateDir}/vip.config" \
	-i "${projectBatchGenotypedVariantCalls}" \
	-o "${projectBatchGenotypedVIPPrefix}.vcf.gz"
	cd - || exit
	printf "VIP ..done\n"

	cd "${intermediateDir}" || exit
	md5sum "$(basename "${projectBatchGenotypedVIPPrefix}.vcf.gz")" > "$(basename "${projectBatchGenotypedVIPPrefix}.vcf.gz").md5"
	cd - || exit
	echo "succes moving files"
