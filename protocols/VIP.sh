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
#string projectResultsDir
#string project
#string groupname
#string tmpName
#string logsDir

makeTmpDir ${projectBatchGenotypedVIPPrefix}
tmpProjectBatchGenotypedVIPPrefix=${MC_tmpFile}

#Load modules
${stage} "${VIPVersion}"
#Check modules
${checkStage}

	echo "## "$(date)" Start $0"

	bash "${EBROOTVIP}"/pipeline.sh \
	-i "${projectBatchGenotypedVariantCalls}" \
	-o "${projectBatchGenotypedVIPPrefix}.vcf.gz"

	printf "VIP ..done\n"

	cd "${intermediateDir}"
	md5sum $(basename ${projectBatchGenotypedVIPPrefix}.vcf.gz)> $(basename ${projectBatchGenotypedVIPPrefix}.vcf.gz).md5
	mkdir -p "${projectResultsDir}/variants/vip"
	mv "${projectBatchGenotypedVIPPrefix}."* "${projectResultsDir}/variants/vip/"
	cd -
	echo "succes moved files"
