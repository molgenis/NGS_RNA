set -o pipefail
#MOLGENIS walltime=23:59:00 mem=8gb ppn=6

#Parameter mapping
#string picardVersion
#string mergeSamFilesJar
#string sampleMergedBam
#string sampleMergedBai
#string tempTmpDir
#list addOrReplaceGroupsBam,addOrReplaceGroupsBai
#string tmpDataDir
#string project
#string intermediateDir
#string picardJar
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

makeTmpDir "${sampleMergedBam}"
tmpSampleMergedBam="${MC_tmpFile}"

makeTmpDir "${sampleMergedBai}"
tmpSampleMergedBai="${MC_tmpFile}"

#Load Picard module
module load "${picardVersion}"
module list

#Create string with input BAM files for Picard
#This check needs to be performed because Compute generates duplicate values in array
INPUTS=()
INPUTBAMS=()
UNIQUEBAIS=()

for bamFile in "${addOrReplaceGroupsBam[@]}"
do
	array_contains INPUTS "INPUT=${bamFile}" || INPUTS+=("INPUT=${bamFile}")    # If bamFile does not exist in array add it
	array_contains INPUTBAMS "${bamFile}" || INPUTBAMS+=("${bamFile}")    # If bamFile does not exist in array add it
done

for baiFile in "${addOrReplaceGroupsBai[@]}"
do
	array_contains UNIQUEBAIS "${baiFile}" || UNIQUEBAIS+=("${baiFile}")    # If baiFile does not exist in array add it
done

if [[ "${#INPUTS[@]}" == 1 ]]
then
	mv -v "${INPUTBAMS[0]}" "${sampleMergedBam}"
	mv -v "${UNIQUEBAIS[0]}" "${sampleMergedBai}"
	echo "nothing to merge because there is only one sample"

	cd "${intermediateDir}" || exit
	md5sum "$(basename "${sampleMergedBam}")" > "$(basename "${sampleMergedBam}").md5sum"
	md5sum "$(basename "${sampleMergedBai}")" > "$(basename "${sampleMergedBai}").md5sum"
	cd - || exit

else
	java -XX:ParallelGCThreads=4 -jar -Xmx6g "${EBROOTPICARD}/${picardJar}" "${mergeSamFilesJar}" \
	"${INPUTS[@]}" \
	SORT_ORDER=coordinate \
	CREATE_INDEX=true \
	USE_THREADING=true \
	TMP_DIR="${tempTmpDir}" \
	MAX_RECORDS_IN_RAM=6000000 \
	VALIDATION_STRINGENCY=LENIENT \
	OUTPUT="${tmpSampleMergedBam}"

	echo -e "\nsampleMergedBam finished succesfull. Moving temp files to final.\n\n"
	mv "${tmpSampleMergedBam}" "${sampleMergedBam}"
	mv "${tmpSampleMergedBai}" "${sampleMergedBai}"

	cd "${intermediateDir}" || exit
	md5sum "$(basename "${sampleMergedBam}")" > "$(basename "${sampleMergedBam}").md5sum"
	md5sum "$(basename "${sampleMergedBai}")" > "$(basename "${sampleMergedBai}").md5sum"
	cd - || exit
fi
