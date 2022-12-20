#MOLGENIS walltime=23:59:00 mem=4gb

#string tmpName
#string	project
#string groupname
#string projectResultsDir
#string logsDir


testResults="/groups/umcg-atd/tmp01/tmp/NGS_RNA/testdata_true/"
mkdir -p "${testResults}/output_NGS_RNA"

module load ngs-utils

"${EBROOTNGSMINUTILS}/bin/vcf-compare_2.0.sh" -1 "${projectResultsDir}/variants/PlatinumSubset_NGS_RNA.variant.calls.genotyped.vcf.gz" -2 "${testResults}/PlatinumSubset_NGS_RNA.variant.calls.genotyped.vcf.gz" -o "${testResults}/output_NGS_RNA/"

cmp --silent "${testResults}/PlatinumSubset_NGS_RNA.expression.counts.table" "${projectResultsDir}/expression/PlatinumSubset_NGS_RNA.expression.counts.table" || echo "there are differences in expression between the test and the original output" > "${testResults}/output_NGS_RNA/expression.fail"

cmp --silent "${testResults}/PlatinumSubset_NGS_RNA_deseq2_control_vs_sample.csv" "${projectResultsDir}/PlatinumSubset_NGS_RNA_deseq2_control_vs_sample.csv" || echo "files are different."  > "${testResults}/output_NGS_RNA/deseq2.fail"

for sample in SRR15529062 SRR15529064 SRR15529069
do
	cmp --silent "${testResults}/${sample}.leafcutter.report.tsv" "${projectResultsDir}/${sample}.leafcutter.report.tsv" || echo "Leafcutter failed" > "${testResults}/output_NGS_RNA/leafcutter.fail"
	cmp --silent "${testResults}/${sample}.rMATS.format.tsv" "${projectResultsDir}/${sample}.rMATS.format.tsv" || echo "RMats failed" > "${testResults}/output_NGS_RNA/RMats.fail"
	cmp --silent "${testResults}/${sample}.SJ.filtered.annotated.tsv" "${projectResultsDir}/${sample}.SJ.filtered.annotated.tsv" || echo "STAR failed" > "${testResults}/output_NGS_RNA/STAR.fail"
done

if [[ -f "${testResults}/output_NGS_RNA/notInVcf1.txt" || -f "${testResults}/output_NGS_RNA/notInVcf2.txt" || -f "${testResults}/output_NGS_RNA/inconsistent.txt" || "${testResults}/output_NGS_RNA/"*.fail ]]
then
	echo "there are differences between the test and the original output"
        echo "please fix the bug or update this test"
        echo "the stats can be found here: ${testResults}/output_NGS_RNA/vcfStats.txt"
        exit 1
else
	echo "test succeeded"
	head -2 "${testResults}/output_NGS_RNA/vcfStats.txt"
fi
