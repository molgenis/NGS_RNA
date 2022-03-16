#MOLGENIS walltime=24:00:00 nodes=1 cores=1 mem=6gb

#Parameter mapping
#string sampleMergedBam
#string tempDir
#string annotationGtf
#string sampleHTseqExpressionText
#string strandedness
#string htseqVersion
#string samtoolsVersion
#string project
#string prepKit
#string groupname
#string tmpName
#string logsDir

module load "${htseqVersion}"
module load "${samtoolsVersion}"
module list

set -o pipefail

makeTmpDir "${sampleHTseqExpressionText}"
tmpSampleHTseqExpressionText=${MC_tmpFile}


# detect strand for HTSeq
STRANDED="$(num1="$(tail -n 2 "${strandedness}" | awk '{print $7}' | head -n 1)"; num2="$(tail -n 2 "${strandedness}" | awk '{print $7}' | tail -n 1)"; if (( $(echo "$num1 > 0.6" | bc -l) )); then echo "yes"; fi; if (( $(echo "$num2 > 0.6" | bc -l) )); then echo "reverse"; fi; if (( $(echo "$num1 < 0.6 && $num2 < 0.6" | bc -l) )); then echo "no"; fi)"

echo -e "\nQuantifying expression, with strandedness: ${STRANDED}"

  samtools \
        view -h \
        "${sampleMergedBam}" | \
        htseq-count \
        -m union \
        -s "${STRANDED}" \
        - \
        "${annotationGtf}" \
        > "${tmpSampleHTseqExpressionText}"

        echo "Gene count succesfull"
        mv "${tmpSampleHTseqExpressionText}" "${sampleHTseqExpressionText}"

	echo "Finished!"
