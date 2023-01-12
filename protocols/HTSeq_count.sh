set -o pipefail
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
ROWNR=$(wc -l "${strandedness}" | awk '{ print $1 }')

if [[ "${ROWNR}" == 6 ]]
then
	num1="$(tail -n 2 "${strandedness}" | awk '{print $7}' | head -n 1)"
	num2="$(tail -n 1 "${strandedness}" | awk '{print $7}')"

	STRANDED=$(echo -e "${num1}\t${num2}" | awk '{if ($1 > 0.6){print "yes"}else if($2 > 0.6){print "reverse"}else if($1 < 0.6 && $2 < 0.6){print "no"} }')

else
	echo "strandedness detection failed, STRANDED='yes'"
	STRANDED='yes'
fi

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
