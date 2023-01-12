set -o pipefail
#!/bin/bash
#MOLGENIS walltime=23:59:00 mem=8gb ppn=6

#Parameter mapping
#string picardVersion
#string sampleMergedBam
#string sampleMergedBai
#string sampleMergedDedupBam
#string sampleMergedDedupBai
#string dupStatMetrics
#string tempDir
#string tmpDataDir
#string project
#string intermediateDir
#string picardJar
#string project
#string picardVersion
#string sambambaVersion
#string groupname
#string tmpName
#string logsDir


#Function to check if array contains value
array_contains () {
	local array="$1[@]"
	local seeking="${2}"
	local in=1
	for element in "${!array-}"; do
		if [[ "${element}" == "${seeking}" ]]; then
			in=0
			break
		fi
	done
	return "${in}"
}

makeTmpDir "${sampleMergedDedupBam}"
tmpSampleMergedDedupBam="${MC_tmpFile}"

makeTmpDir "${sampleMergedDedupBai}"
tmpSampleMergedDedupBai="${MC_tmpFile}"

module load "${sambambaVersion}"
module list

#Duplicates statistics.
##Run picard, sort BAM file and create index on the fly
sambamba markdup \
--nthreads=4 \
--overflow-list-size 1000000 \
--hash-table-size 1000000 \
-p \
--tmpdir="${tempDir}" \
"${sampleMergedBam}" "${tmpSampleMergedDedupBam}"

mv "${tmpSampleMergedDedupBam}" "${sampleMergedDedupBam}"
mv "${tmpSampleMergedDedupBai}" "${sampleMergedDedupBai}"

cd "${intermediateDir}" || exit
md5sum "${sampleMergedDedupBam}" > "$(basename "${sampleMergedDedupBam}").md5"
md5sum "${sampleMergedDedupBai}" > "$(basename "${sampleMergedDedupBai}").md5"
cd - || exit
