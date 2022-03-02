#MOLGENIS walltime=24:00:00 nodes=1 cores=1 mem=2gb

#string intermediateDir
#string externalSampleID
#string projectHTseqExpressionTable
#string NGSRNAVersion
#string project
#string projectResultsDir
#string annotationGtf
#string tmpTmpDataDir
#string groupname
#string tmpName
#string logsDir
#string sifDir

module load ${NGSRNAVersion}

#make output dir
mkdir -p "${projectResultsDir}/outrider/${externalSampleID}/QC"

#run outrider
singularity exec --pwd $PWD --bind ${sifDir}:/sifDir,/apps:/apps,/groups:/groups \
"${sifDir}/outrider_latest.sif" \
Rscript "${EBROOTNGS_RNA}/scripts/outrider.R" \
"${projectHTseqExpressionTable}" \
"${intermediateDir}/${externalSampleID}.outrider.design.tsv" \
"${projectResultsDir}/outrider/${externalSampleID}" \
"${annotationGtf}"

#run outrider with given sample and expexted effected gene

#singularity exec --pwd $PWD \
#--bind /groups/umcg-atd/tmp10/gvdvries/singularity/OUTRIDER:/OUTRIDER,\
#/groups/umcg-atd/tmp10/projects/testproject/run02/results/expression:/expression \
#outrider_latest.sif \
#Rscript /OUTRIDER/outrider.R \
#/expression/expressionTable/testproject.expression.genelevel.v75.counts.table \
#/OUTRIDER/sample_design.txt \
#/OUTRIDER \
#SID.10017.counts.txt \
#AGRN
