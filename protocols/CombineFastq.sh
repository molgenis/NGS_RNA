#MOLGENIS walltime=23:59:00 mem=8gb ppn=6

#Parameter mapping
#string tempDir
#list trimmedLeftBarcodeFqGz,trimmedRightBarcodeFqGz
#string mergedLeftBarcodeFqGz
#string mergedRightBarcodeFqGz
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

makeTmpDir "${mergedLeftBarcodeFqGz}"
tmpMergedLeftBarcodeFqGz="${MC_tmpFile}"

makeTmpDir "${mergedRightBarcodeFqGz}"
tmpMergedRightBarcodeFqGz="${MC_tmpFile}"

#Create string with input BAM files for Picard
#This check needs to be performed because Compute generates duplicate values in array
INPUTSLEFT=()
INPUTSRIGHT=()

for FqFileLeft in "${trimmedLeftBarcodeFqGz[@]}"
do
	array_contains INPUTSLEFT "${FqFileLeft}" || INPUTSLEFT+=("${FqFileLeft}")    # If bamFile does not exist in array add it
done

for FqFileRight in "${trimmedRightBarcodeFqGz[@]}"
do
	array_contains INPUTSRIGHT "${FqFileRight}" || INPUTSRIGHT+=("${FqFileRight}")    # If baiFile does not exist in array add it
done

if [[ "${#INPUTSLEFT[@]}" == 1 ]]
then
	ln -sf $(basename "${INPUTSLEFT[0]}") "${mergedLeftBarcodeFqGz}"
	ln -sf $(basename "${INPUTSRIGHT[0]}") "${mergedRightBarcodeFqGz}"
	echo "nothing to merge because there is only one sample"
else
	cat "${INPUTSLEFT[@]}" > "${tmpMergedLeftBarcodeFqGz}"
	cat "${INPUTSRIGHT[@]}" > "${tmpMergedRightBarcodeFqGz}"
  mv "${tmpMergedLeftBarcodeFqGz}" "${mergedLeftBarcodeFqGz}"
  mv "${tmpMergedRightBarcodeFqGz}" "${mergedRightBarcodeFqGz}"
fi