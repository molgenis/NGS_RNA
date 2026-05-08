#!/usr/bin/bash
set -euo pipefail

RESULTSDIR="${1}"
TRUTHDIR="${2}"
OUTDIR="${3}"

test_name=$(basename ${RESULTSDIR})


# compare STAR Splice Junctions files.
diff "${TRUTHDIR}/star_sj/" "${RESULTSDIR}/star_sj/" > "${OUTDIR}/diff.txt" || true

# compare GATK Variants files.
module load ngs-utils

"${EBROOTNGSMINUTILS}/bin/vcf-compare_2.0.sh" -1 "${TRUTHDIR}/variants/${test_name}.variant.calls.genotyped.vcf.gz" -2 "${RESULTSDIR}/variants/${test_name}.variant.calls.genotyped.vcf.gz" -o "${OUTDIR}"
if grep 'TP rate: 100.00%' "${OUTDIR}/vcfStats.txt"
then
	echo 'OK'
else 
	cat ${OUTDIR}/vcfStats.txt >> "${OUTDIR}/diff.txt"
    exit 1
fi

exit 0