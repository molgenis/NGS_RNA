set -o pipefail
#MOLGENIS nodes=1 ppn=1 mem=34gb walltime=05:00:00

#Parameter mapping
#string intermediateDir
#list externalSampleID
#string project
#string logsDir
#string projectJobsDir
#string strandedness
#string sampleMergedBamExt
#string annotationTxt
#string leafcutterAllExon
#string sifDir

makeTmpDir "${intermediateDir}"
tmpintermediateDir=${MC_tmpFile}

# detect strand for RegTools
num1="$(tail -n 2 "${strandedness}" | awk '{print $7}' | head -n 1)"
num2="$(tail -n 1 "${strandedness}" | awk '{print $7}')"

STRANDED=$(echo -e "${num1}\t${num2}" | awk '{if ($1 > 0.6){print "1"}else if($2 > 0.6){print "2"}else if($1 < 0.6 && $2 < 0.6){print "0"} }')

#detect number of conditions
col=$(col="condition"; head -n1 "${projectJobsDir}/${project}.csv" | tr "," "\n" | grep -n "${col}")
# shellcheck disable=SC2206
colArray=(${col//:/ })
conditionCount=$(tail -n +2 "${projectJobsDir}/${project}.csv" | cut -d "," -f "${colArray[0]}" | sort | uniq | wc -l)

echo -e "\nWith strandedness type: ${STRANDED},
where (0 = unstranded, 1 = first-strand/RF, 2, = second-strand/FR)."

echo "create group_list"
col=$(col="externalSampleID"; head -n1 "${projectJobsDir}/${project}.csv" | tr "," "\n" | grep -n "${col}")
# shellcheck disable=SC2206
colID=(${col//:/ })
awk -F',' -v id="${colID[0]}" -v con="${colArray[0]}" '{print $id".sorted.merged.bam\t"$con}' "${projectJobsDir}/${project}.csv" \
> "${intermediateDir}${project}_groups_file.txt"

sed 1d "${intermediateDir}${project}_groups_file.txt" > "${intermediateDir}${project}"_groups_file.txt.tmp
mv "${intermediateDir}${project}_groups_file.txt.tmp" "${intermediateDir}${project}_groups_file.txt"

echo "conditionCount = ${conditionCount}"
if [[ "${conditionCount}" -gt 1 ]]
then
	echo "Differential Splicing with ${conditionCount} groups."
	singularity exec --bind "/groups/:/groups,/apps/:/apps" "${sifDir}/leafcutter_0.2.10.sif" \
	"/app/leafcutter/scripts/leafcutter_ds.R" \
	--num_threads 4 \
	-i 1 \
	-g 1 \
	-c 3 \
	-e "${annotationTxt}" \
	-o "${tmpintermediateDir}/${project}_leafcutter_ds" \
	"${intermediateDir}${project}_leafcutter_cluster_regtools_perind_numers.counts.gz" \
	"${intermediateDir}${project}_groups_file.txt"

	mv "${tmpintermediateDir}/${project}"* "${intermediateDir}"
else
	echo "Outlier Splicing, ${conditionCount} conditions found."
	singularity exec --bind "/groups/:/groups,/apps/:/apps" "${sifDir}/leafcutter_0.2.10.sif" \
	"/app/leafcutter/scripts/leafcutterMD.R" \
	--num_threads 8 \
	-o "${tmpintermediateDir}${project}" \
	"${intermediateDir}${project}_leafcutter_cluster_regtools_perind_numers.counts.gz"

	mv "${tmpintermediateDir}/${project}"* "${intermediateDir}"
fi
