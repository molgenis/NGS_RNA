set -o pipefail
#MOLGENIS nodes=1 ppn=1 mem=8gb walltime=05:59:00

#Parameter mapping
#string seqType
#string intermediateDir
#string sampleMergedBam
#string sampleMergedDedupBam
#string annotationRefFlat
#string annotationIntervalList
#string indexSpecies
#string insertsizeMetrics
#string insertsizeMetricspdf
#string insertsizeMetricspng
#string tempDir
#string flagstatMetrics
#string recreateinsertsizepdfR
#string qcMatrics
#string strandedness
#string rnaSeqMetrics
#string dupStatMetrics
#string idxstatsMetrics
#string alignmentMetrics
#string externalSampleID
#string picardVersion
#string samtoolsVersion
#string ngsVersion
#string rPlusVersion
#string pythonVersion
#string picardJar
#string project
#string collectMultipleMetricsPrefix
#string groupname
#string tmpName
#string logsDir

#Load module
module load "${picardVersion}"
module load "${samtoolsVersion}"
module load "${pythonVersion}"
module load "${ngsVersion}"
module load "${rPlusVersion}"
module list

# Get strandness.
num1="$(tail -n 2 "${strandedness}" | awk '{print $7}' | head -n 1)"
num2="$(tail -n 1 "${strandedness}" | awk '{print $7}')"

STRANDED=$(echo -e "${num1}\t${num2}" | awk '{if ($1 > 0.6){print "FIRST_READ_TRANSCRIPTION_STRAND"}else if($2 > 0.6){print "SECOND_READ_TRANSCRIPTION_STRAND"}else if($1 < 0.6 && $2 < 0.6){print "NONE"} }')

#If paired-end do fastqc for both ends, else only for one
if [[ "${seqType}" == "PE" ]]
then
	echo -e "generate CollectMultipleMetrics"

	# Picard CollectMultipleMetrics
	java -jar -Xmx6g -XX:ParallelGCThreads=4 "${EBROOTPICARD}/${picardJar}" CollectMultipleMetrics \
	I="${sampleMergedDedupBam}" \
	O="${collectMultipleMetricsPrefix}" \
	R="${indexSpecies}" \
	PROGRAM=CollectAlignmentSummaryMetrics \
	PROGRAM=QualityScoreDistribution \
	PROGRAM=MeanQualityByCycle \
	PROGRAM=CollectInsertSizeMetrics \
	TMP_DIR="${tempDir}/processing"


	#Flagstat for reads mapping to the genome.
	samtools flagstat "${sampleMergedDedupBam}" >  "${flagstatMetrics}"

	# Fagstats idxstats, reads per chr.
	samtools idxstats "${sampleMergedDedupBam}" > "${idxstatsMetrics}"

	#CollectRnaSeqMetrics.jar
	java -XX:ParallelGCThreads=4 -jar -Xmx6g "${EBROOTPICARD}/${picardJar}" CollectRnaSeqMetrics \
	REF_FLAT="${annotationRefFlat}" \
	I="${sampleMergedDedupBam}" \
	STRAND_SPECIFICITY="${STRANDED}" \
	VALIDATION_STRINGENCY=LENIENT \
	O="${rnaSeqMetrics}" \
	CHART_OUTPUT="${rnaSeqMetrics}.pdf"
	#RIBOSOMAL_INTERVALS="${annotationIntervalList}" \


	# Collect QC data from several QC matricses, and write a tablular output file.

elif [[ "${seqType}" == "SR" ]]
then

	#Flagstat for reads mapping to the genome.
	samtools flagstat "${sampleMergedDedupBam}" > "${flagstatMetrics}"

	# Fagstats idxstats, reads per chr.
	samtools idxstats "${sampleMergedDedupBam}" > "${idxstatsMetrics}"

	echo -e "generate CollectMultipleMetrics"

	# Picard CollectMultipleMetrics
	java -jar -Xmx6g -XX:ParallelGCThreads=4 "${EBROOTPICARD}/${picardJar}" CollectMultipleMetrics \
	I="${sampleMergedDedupBam}" \
	O="${collectMultipleMetricsPrefix}" \
	R="${indexSpecies}" \
	PROGRAM=CollectAlignmentSummaryMetrics \
	PROGRAM=QualityScoreDistribution \
	PROGRAM=MeanQualityByCycle \
	PROGRAM=CollectInsertSizeMetrics \
	TMP_DIR="${tempDir}/processing"

	#CollectRnaSeqMetrics.jar
	java -XX:ParallelGCThreads=4 -jar -Xmx6g "${EBROOTPICARD}/${picardJar}" CollectRnaSeqMetrics \
	REF_FLAT="${annotationRefFlat}" \
	I="${sampleMergedDedupBam}" \
	STRAND_SPECIFICITY="${STRANDED}" \
	RIBOSOMAL_INTERVALS="${annotationIntervalList}" \
	VALIDATION_STRINGENCY=LENIENT \
	O="${rnaSeqMetrics}" \
	CHART_OUTPUT="${rnaSeqMetrics}.pdf"
fi
