#MOLGENIS walltime=05:59:00 mem=5gb ppn=1 nodes=1

#string stage
#string checkStage
#string tmpTmpDataDir
#string tmpDataDir
#string HTSLibVersion
#string VIPVersion
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

makeTmpDir ${projectBatchGenotypedVIPPrefix}
tmpProjectBatchGenotypedVIPPrefix=${MC_tmpFile}

#Load modules
${stage} "${VIPVersion}"
#Check modules
${checkStage}

	cp "$EBROOTVIP/config/default.cfg" "${intermediateDir}/vip.config"
	echo "annotate_vep_plugin_SpliceAI=${spliceaiSnv},${spliceaiIndel}" >> "${intermediateDir}/vip.config"

	echo "## "$(date)" Start $0"
	cd "${EBROOTVIP}"
	bash pipeline.sh \
	-c "${intermediateDir}/vip.config" \
	-i "${projectBatchGenotypedVariantCalls}" \
	-o "${projectBatchGenotypedVIPPrefix}.vcf.gz"
	cd -
	printf "VIP ..done\n"

	cd "${intermediateDir}"
	md5sum $(basename ${projectBatchGenotypedVIPPrefix}.vcf.gz)> $(basename ${projectBatchGenotypedVIPPrefix}.vcf.gz).md5
	cd -
	echo "succes moving files"
