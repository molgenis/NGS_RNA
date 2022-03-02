#MOLGENIS nodes=1 ppn=1 mem=34gb walltime=05:00:00

#Parameter mapping
#string intermediateDir
#string project
#string logsDir
#string projectJobsDir
#string strandedness
#string sampleMergedBamExt
#string leafcutterVersion
#string python2Version

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

rm -f "${intermediateDir}${project}_juncfiles.txt"
cd "${intermediateDir}"
for bamfile in $(ls *.${sampleMergedBamExt}); do

    echo Converting "${bamfile}" to "${bamfile}".junc
    samtools index "${bamfile}"

    #BUG: set to standed 0.
    regtools junctions extract \
    -a 8 \
    -m 50 \
    -M 500000 \
    -s 0 \
    "${bamfile}" \
    -o "${bamfile}.junc"

    echo "${intermediateDir}${bamfile}.junc" >> "${intermediateDir}${project}_juncfiles.txt"
done

python "${EBROOTLEAFCUTTER}/clustering/leafcutter_cluster_regtools.py" \
-j "${intermediateDir}/${project}_juncfiles.txt" \
-m 50 \
-r "${intermediateDir}" \
-o "${project}_leafcutter_cluster_regtools" \
-l 500000 \
--checkchrom

cd -
