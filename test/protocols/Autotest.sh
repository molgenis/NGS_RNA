#MOLGENIS walltime=23:59:00 mem=4gb

#string tmpName
#string	project
#string groupname
#string projectResultsDir
#string logsDir

#tmp fix
export TERM='xterm'

testResults="/groups/umcg-atd/${tmpName}/tmp/NGS_RNA/testdata_true/"
mkdir -p "${testResults}/output_NGS_RNA"

module load ngs-utils

"${EBROOTNGSMINUTILS}/bin/vcf-compare_2.0.sh" -1 "${projectResultsDir}/variants/GS_001-RNA_v1.variant.calls.genotyped.vcf.gz" -2 "${testResults}/GS_001-RNA_v1.variant.calls.genotyped.vcf.gz" -o "${testResults}/output_NGS_RNA/"


if [[ -f "${testResults}/output_NGS_RNA/notInVcf1.txt" || -f "${testResults}/output_NGS_RNA/notInVcf2.txt" || -f "${testResults}/output_NGS_RNA/inconsistent.txt" || -f "${testResults}/output_NGS_RNA/"*.fail ]]
then
	echo "There are differences between the test and the original output."
	echo "Please fix the bug or update this test."
	echo "The stats can be found here: ${testResults}/output_NGS_RNA/vcfStats.txt"
	exit 1
else
	echo "Test succeeded."
	head -2 "${testResults}/output_NGS_RNA/vcfStats.txt"
fi

#check if concordanceCheck made the correct calls
if [[ ! -f "${projectResultsDir}/variants/concordance/1111111_123456_HG001_0000000_GS001A_WGS_000001_12348765.concordance.vcf" ]]
then
	echo "1111111_123456_HG001_0000000_GS001A_WGS_000001_12348765.concordanceCheckCalls.vcf does not exist"
	exit 1
else
	## check if the variants are called
	grep -v '^#' "${projectResultsDir}/variants/concordance/1111111_123456_HG001_0000000_GS001A_WGS_000001_12348765.concordance.vcf" | awk 'BEGIN {FS="\t"}{OFS="\t"}{print $1,$2,$3,$4,$5,$10}' > "${testResults}/output_NGS_RNA//concordanceCheckCalls.vcf"
	diffInConcordance='no'
	diff -q "${testResults}/trueConcordanceCheckCalls.vcf" "${testResults}/output_NGS_RNA/concordanceCheckCalls.vcf" || diffInConcordance='yes'

	if [[ "${diffInConcordance}" == 'yes' ]]
	then
		echo "There are some differences in the concordanceCheckCalls.vcf file"
		echo "TRUE:"
		cat "${testResults}/trueConcordanceCheckCalls.vcf"
		echo -e "\n\n NEW FILE:"
		cat "${testResults}/output_NGS_RNA/concordanceCheckCalls.vcf"
		exit 1
	fi
fi
