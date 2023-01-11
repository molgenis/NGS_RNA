
#MOLGENIS nodes=1 ppn=1 mem=34gb walltime=05:00:00

#Parameter mapping
#string intermediateDir
#string externalSampleID
#string project
#string logsDir
#string projectJobsDir
#string NGSRNAVersion
#string sampleMergedBamExt
#string leafcutterVersion
#string python2Version

#Load module
module load "${leafcutterVersion}"
module load "${NGSRNAVersion}"
module load "${python2Version}"
module list


OUTPUTFILE="${intermediateDir}${externalSampleID}.leafcutter.report.tsv"

# adding coordinates to leafcutter results
TMPOUTFILE="${intermediateDir}${externalSampleID}.leafcutter.format.tsv.tmp"

"${EBROOTNGS_RNA}/scripts/format_leafcutter.py" \
-i "${intermediateDir}${externalSampleID}.leafcutter.outlier_cluster_significance.txt" \
-e "${intermediateDir}${externalSampleID}.leafcutter.outlier_effect_sizes.txt" \
-o "${intermediateDir}${externalSampleID}.leafcutter.format.tsv"

# omim annotation
TMPINFILE="${TMPOUTFILE}"
TMPOUTFILE="${intermediateDir}${externalSampleID}.leafcutter.format.omim.tsv"
"${EBROOTNGS_RNA}/scripts/annotate_leafcutter_events.py" \
-i "${TMPINFILE}" \
-d "/groups/umcg-solve-rd/tmp01/resources/GAD/others/OMIM2.list" \
-o "${TMPOUTFILE}"

# filter and produce the final report
echo "Command : grep '^cluster' ${TMPOUTFILE} > ${OUTPUTFILE} && awk -F '\t' '($6<0.05){print $0}' ${TMPOUTFILE} >> ${OUTPUTFILE}"
grep "^cluster" "${TMPOUTFILE}" > "${OUTPUTFILE}"
awk -F "\t" '($6<0.05){print $0}' "${TMPOUTFILE}" >> "${OUTPUTFILE}"
