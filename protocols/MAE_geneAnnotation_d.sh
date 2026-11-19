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
#string RbundleBioconductor
#string maeSif
#string sifDir
#string build
#string ngsVersion
#string RDepBundle
#string RbundleCRAN
#string fraser_outriderSif
#string geneAnnotation

set -e
set -u

#ml "${RbundleBioconductor}"
#ml "${RDepBundle}"
#ml "${RbundleCRAN}"
ml "${ngsVersion}"
module list

base_vcf=$(basename -s .vcf.gz "${WGSvcfID}")

echo "${base_vcf}"
echo "${EBROOTNGS_RNA}/"

apptainer exec "${sifDir}/${maeSif}" Rscript "${EBROOTNGS_RNA}/scripts/get_MAE_results.R" "${intermediateDir}/split.${base_vcf}/${base_vcf}.results_mae.tsv" "${intermediateDir}/split.${base_vcf}/${base_vcf}_result_mae_tmp.tsv" "${base_vcf}"

echo "apptainer exec ${sifDir}/${maeSif} Rscript ${EBROOTNGS_RNA}/scripts/get_MAE_results.R ${intermediateDir}/split.${base_vcf}/${base_vcf}.results_mae.tsv ${intermediateDir}/split.${base_vcf}/${base_vcf}_result_mae_tmp.tsv ${base_vcf}"

apptainer exec "${sifDir}/${fraser_outriderSif}" Rscript "${EBROOTNGS_RNA}/scripts/get_gene_annotations.R" "${intermediateDir}/split.${base_vcf}/${base_vcf}_result_mae_tmp.tsv" "${intermediateDir}/split.${base_vcf}/${base_vcf}_result_mae_final.tsv" "${geneAnnotation}"

echo "Rscript ${EBROOTNGS_RNA}/scripts/get_gene_annotations.R ${intermediateDir}/split.${base_vcf}/${base_vcf}_result_mae_tmp.tsv ${intermediateDir}/split.${base_vcf}/${base_vcf}_result_mae_final.tsv ${geneAnnotation}"