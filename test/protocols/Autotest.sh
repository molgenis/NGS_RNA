#MOLGENIS walltime=23:59:00 mem=4gb

#string tmpName
#string	project
#string groupname
#string projectResultsDir
#string logsDir

rm -rf /home/umcg-molgenis/output_NGS_RNA

module load ngs-utils

${EBROOTNGSMINUTILS}/vcf-compare_2.0.sh -1 ${projectResultsDir}/variants/PlatinumSubset_NGS_RNA.variant.calls.genotyped.chr1.vcf -2 /home/umcg-molgenis/NGS_RNA/PlatinumSubset_NGS_RNA.variant.calls.genotyped.chr1.true.vcf -o /home/umcg-molgenis/output_NGS_RNA

cmp --silent ${projectResultsDir}/expression/expressionTable/PlatinumSubset_NGS_RNA.expression.genelevel.v75.htseq.txt.table /home/umcg-molgenis/NGS_RNA/PlatinumSubset_NGS_RNA.expression.true.table || echo "there are differences in expression between the test and the original output" > /home/umcg-molgenis/output_NGS_RNA/expression.fail


if [[ -f /home/umcg-molgenis/output_NGS_RNA/notInVcf1.txt || -f /home/umcg-molgenis/output_NGS_RNA/notInVcf2.txt || -f /home/umcg-molgenis/output_NGS_RNA/inconsistent.txt  ]]
then
	echo "there are differences between the test and the original output"
        echo "please fix the bug or update this test"
        echo "the stats can be found here: /home/umcg-molgenis/output_NGS_RNA/vcfStats.txt"
        exit 1
else
	echo "test succeeded"
	head -2 /home/umcg-molgenis/output_NGS_RNA/vcfStats.txt

fi
