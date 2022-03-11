#MOLGENIS nodes=1 ppn=1 mem=34gb walltime=05:00:00

#Parameter mapping
#string intermediateDir
#list externalSampleID
#string project
#string logsDir
#string projectJobsDir
#string strandedness
#string sampleMergedBamExt
#string leafcutterVersion
#string python2Version
#string annotationTxt

makeTmpDir ${intermediateDir}
tmpintermediateDir=${MC_tmpFile}

#Load module
module load "${leafcutterVersion}"
module load "${python2Version}"
module list

# detect strand for RegTools
STRANDED="$(num1="$(tail -n 2 "${strandedness}" | awk '{print $7'} | head -n 1)"; num2="$(tail -n 2 "${strandedness}" | awk '{print $7'} | tail -n 1)"; if (( $(echo "$num1 > 0.6" | bc -l) )); then echo "1"; fi; if (( $(echo "$num2 > 0.6" | bc -l) )); then echo "2"; fi; if (( $(echo "$num1 < 0.6 && $num2 < 0.6" | bc -l) )); then echo "0"; fi)"

#detect number of conditions
col=$(col="condition"; head -n1 "${projectJobsDir}/${project}.csv" | tr "," "\n" | grep -n $col)
colArray=(${col//:/ })
conditionCount=$(tail -n +2 "${projectJobsDir}/${project}.csv" | cut -d "," -f "${colArray[0]}" | sort | uniq | wc -l)

echo -e "\nWith strandedness type: ${STRANDED},
where (0 = unstranded, 1 = first-strand/RF, 2, = second-strand/FR)."

echo "create group_list"
col=$(col="externalSampleID"; head -n1 "${projectJobsDir}/${project}.csv" | tr "," "\n" | grep -n $col)
colID=(${col//:/ })
awk -F',' -v id=${colID[0]} -v con=${colArray[0]} '{print $id".sorted.merged.bam\t"$con}' "${projectJobsDir}/${project}.csv" \
> "${intermediateDir}${project}_groups_file.txt"

sed 1d "${intermediateDir}${project}_groups_file.txt" > "${intermediateDir}${project}"_groups_file.txt.tmp
mv "${intermediateDir}${project}_groups_file.txt.tmp" "${intermediateDir}${project}_groups_file.txt"

echo "conditionCount = ${conditionCount}"
if [[ "${conditionCount}" -gt 1 ]]
then
	echo "Differential Splicing with ${conditionCount} groups."
	Rscript "${EBROOTLEAFCUTTER}/scripts/leafcutter_ds.R" \
	--num_threads 4 \
        -i 1 \
        -g 1 \
        -c 3 \
	-e "${annotationTxt}" \
	-o "${tmpintermediateDir}${project}_leafcutter_ds" \
	"${intermediateDir}${project}_leafcutter_cluster_regtools_perind_numers.counts.gz" \
	"${intermediateDir}${project}_groups_file.txt"

	Rscript "${EBROOTLEAFCUTTER}/scripts/ds_plots.R" \
	-e "${EBROOTLEAFCUTTER}/annotation_codes/gencode_hg19/gencode_hg19_all_exons.txt.gz" \
	-o "${tmpintermediateDir}${project}_leafcutter_ds" \
	"${intermediateDir}${project}_leafcutter_cluster_regtools_perind_numers.counts.gz" \
	"${intermediateDir}${project}_groups_file.txt" \
	"${tmpintermediateDir}${project}_leafcutter_ds_cluster_significance.txt" \
	-f 0.05

	mv "${tmpintermediateDir}"/"${project}"* "${intermediateDir}"
else
       echo "Outlier Splicing, $conditionCount conditions found."
	Rscript	"${EBROOTLEAFCUTTER}/scripts/leafcutterMD.R" \
	--num_threads 8 \
	-o "${tmpintermediateDir}${project}" \
	"${intermediateDir}${project}_leafcutter_cluster_regtools_perind_numers.counts.gz"

	mv "${tmpintermediateDir}${project}"* "${intermediateDir}"
fi
