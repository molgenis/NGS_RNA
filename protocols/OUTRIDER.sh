#MOLGENIS walltime=24:00:00 nodes=1 cores=1 mem=10gb

#string intermediateDir
#string externalSampleID
#string projectHTseqExpressionTable
#string ngsversion
#string project
#string projectResultsDir
#string annotationGtf
#string tmpTmpDataDir
#string groupname
#string tmpName
#string logsDir
#string sifDir

module load "${ngsversion}"

#make output dir
mkdir -p "${projectResultsDir}/outrider/${externalSampleID}/QC"

#run outrider
singularity exec --pwd $PWD --bind ${sifDir}:/sifDir,/apps:/apps,/groups:/groups \
"${sifDir}/outrider_latest.sif" \
Rscript "${EBROOTNGS_RNA}/scripts/outrider.R" \
"${projectHTseqExpressionTable}" \
"${intermediateDir}/${externalSampleID}.outrider.design.tsv" \
"${projectResultsDir}/outrider/${externalSampleID}" \
"${annotationGtf}" \
"${externalSampleID}"

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
