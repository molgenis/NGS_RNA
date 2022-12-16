#MOLGENIS walltime=5:00:00 nodes=1 cores=1 mem=50gb

#string intermediateDir
#list externalSampleID
#list geneOfInterest
#string projectHTseqExpressionTable
#string ngsVersion
#string project
#string projectResultsDir
#string outriderVersion
#string annotationGtf
#string tmpTmpDataDir
#string groupname
#string tmpName
#string logsDir
#string sifDir

module load "${ngsVersion}"
module list

#make output dirs
mkdir -p "${projectResultsDir}/outrider/QC"
for sample in "${externalSampleID[@]}"
do
	mkdir -p "${projectResultsDir}/outrider/${sample}/QC"
done
#run outrider QC part
singularity exec --pwd $PWD --bind "${sifDir}:/sifDir,/apps:/apps,/groups:/groups" \
"${sifDir}/${outriderVersion}" \
Rscript "${EBROOTNGS_RNA}/scripts/outrider-qc.R" \
"${projectHTseqExpressionTable}" \
"${intermediateDir}/${externalSampleID[0]}.outrider.design.tsv" \
"${projectResultsDir}/outrider/" \
"${annotationGtf}"


max_index="${#externalSampleID[@]}-1"
for ((samplenumber = 0; samplenumber <= max_index; samplenumber++))
do
	for sample in "${externalSampleID[@]}"
	do
		head -1 "${projectResultsDir}/outrider/outrider.tsv" > "${projectResultsDir}/outrider/${sample}/${sample}.outrider.tsv"
		grep "${sample}" "${projectResultsDir}/outrider/outrider.tsv" >> "${projectResultsDir}/outrider/${sample}/${sample}.outrider.tsv"

		#get geneOfInterest from samplessheet of provided,
		#or else get top 3 most significate genes from outrider output.
		GENE="${geneOfInterest[samplenumber]}"
		if [[ ! -z "${GENE}" ]]
		then
			echo "${GENE}" > "${projectResultsDir}/outrider/${sample}/${sample}.genesOfInterest.tsv"
		else
			tail -n +2 "${projectResultsDir}/outrider/${sample}/${sample}.outrider.tsv" | awk '{print $2}' | head -3 > "${projectResultsDir}/outrider/${sample}/${sample}.genesOfInterest.tsv"
		fi
	done
done

#Run outrider to genarate plots per sample, and top 3 significant gene.
singularity exec --pwd $PWD --bind "${sifDir}:/sifDir,/apps:/apps,/groups:/groups" \
"${sifDir}/${outriderVersion}" \
Rscript "${EBROOTNGS_RNA}/scripts/outrider.R" \
"${projectResultsDir}/outrider/"
#"${geneOfInterest}"

#run outrider with given sample and expexted effected gene

#singularity exec --pwd $PWD \
#--bind ${sifDir}:/sifDir,/apps:/apps,/groups:/groups \
#"${sifDir}/outrider_latest.sif" \
#Rscript "${EBROOTNGS_RNA}/scripts/outrider.R" \
#"${projectHTseqExpressionTable}" \
#"${intermediateDir}/${externalSampleID}.outrider.design.tsv" \
#${annotationGtf}" \
#SID.10017.counts.txt \
#AGRN
