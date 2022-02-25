#MOLGENIS walltime=24:00:00 nodes=1 cores=1 mem=2gb

#string intermediateDir
#list externalSampleID
#string projectHTseqExpressionTable
#string NGSRNAVersion
#string project
#string tmpTmpDataDir
#string groupname
#string tmpName
#string logsDir

module load ${NGSRNAVersion}

#Function to check if array contains value
array_contains () {
    local array="$1[@]"
    local seeking=$2
    local in=1
    for element in "${!array-}"; do
        if [[ "$element" == "$seeking" ]]; then
            in=0
            break
        fi
    done
    return $in
}

makeTmpDir ${projectHTseqExpressionTable}
tmpProjectHTseqExpressionTable=${MC_tmpFile}

rm -f ${intermediateDir}/fileList.txt

INPUTS=()
for sample in "${externalSampleID[@]}"
do
	array_contains INPUTS "$sample" || INPUTS+=("$sample")
done

for sampleID in "${INPUTS[@]}"
do
	echo -e "${intermediateDir}/${sampleID}.counts.txt" >> ${intermediateDir}/fileList.txt
done


	python ${EBROOTNGS_RNA}/scripts/create_counts_matrix.py \
	-i ${intermediateDir}/fileList.txt \
	-o ${tmpProjectHTseqExpressionTable} \
	-e $intermediateDir/create_counts_matrix.log

        echo "table create succesfull"
        mv ${tmpProjectHTseqExpressionTable} ${projectHTseqExpressionTable}

