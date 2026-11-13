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
#string reportSif
#string externalSampleID

set -e
set -u


####This part is added to determine GenePanel, keep out for now, add maybe later######

#         # Determine if samplesheet contains a "genePanel" column
#         header=$(head -n1 "$samplesheet")
#         has_gene_panel=false
#         gene_panel_index=-1
# 
#         IFS=$"\t" read -r -a header_cols <<< "${header}"
#         # the ! in "${!header_cols[@]}" makes it an assosiative array, im not sure if this works like this, see during testing.
#         for i in "${!header_cols[@]}"; do
#             echo "'${!header_cols[@]}': ${!header_cols[@]}"
#             if [[ "${header_cols[$i]}" == "genePanel" ]]; then
#                 has_gene_panel=true
#                 gene_panel_index="${i}"
#                 echo "Detected genePanel column at index ${gene_panel_index}"
#             fi
#         done
# 
#         # Process rows
#         tail -n +2 "${samplesheet}" | while IFS=$"\t" read -r -a row; do
#             sampleid="${row[0]}"
# 
#             echo "Now processing ${sampleid}:"
# 
#             #outrider_path="${sampleid}_result_table_outrider.tsv"
#             #fraser_path="${sampleid}_result_table_fraser.tsv"
#             mae_path="${sampleid}_result_mae.tsv"
#             output_path="${sampleid}_report.html"
# 
#             # Samples without a bam (OUTRIDER only) have no FRASER results: no report
#             #if [[ ! -f "${fraser_path}" ]]; then
#             #    echo "No FRASER results for ${sampleid}, skipping report"
#             #    continue
#             #fi
# 
#             # Handle optional MAE file
#             if [[ -f "${mae_path}" ]]; then
#                 echo "${mae_path}"
#             else
#                 mae_path="-"
#             fi
#             gene_panel_path=""
#             
#             # Detect genePanel file if column exists
#             if [[ "${has_gene_panel}" = true ]]; then
#                 gene_panel_value="${row[${gene_panel_index}]}"
# 
#                 gene_panel_path=$(basename "${gene_panel_value}")
# 
#                 # Only check if value is non-empty
#                 if [[ -n "${gene_panel_value}" ]]; then
# 
#                     if [[ -f "${gene_panel_path}" ]]; then
#                         echo "Found genePanel file: ${gene_panel_path}"
#                     else
#                         echo "No .txt or .bed genePanel file found for value: ${gene_panel_path}"
#                         gene_panel_path=""
# 
#                     fi
#                 fi
#             fi

ml "${ngsVersion}"
module list



apptainer exec "${sifDir}/${reportSif}" bash -c '
            # Build command
            # the original command
            #cmd="python3 ${EBROOTNGS_RNA}/scripts/embed_data.py -or ${outrider_path} -fr \${fraser_path} -ma \${mae_path} -t ${params.report.htmlTemplate} -s \${sampleid} -o \${output_path}"
            base_vcf=$(basename -s .vcf.gz "${WGSvcfID}")
            mae_path="${intermediateDir}/split.${base_vcf}/${base_vcf}_result_mae_final.tsv"
            echo "mae_path: ${mae_path}"
            
            python3 "${EBROOTNGS_RNA}/scripts/embed_data.py" -ma "${mae_path}" -t "${EBROOTNGS_RNA}/scripts/template.html" -s "${WGSvcfID}" -o "${intermediateDir}/${externalSampleID}_mae_report.html"

            # Add genePanel argument only when file exists
            #if [[ -n "\$gene_panel_path" ]]; then
            #    cmd="\$cmd -g \$gene_panel_path"
            #fi

            #echo "Running: ${cmd}"
            #eval "${cmd}"


'
 


