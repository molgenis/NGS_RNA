set -o pipefail
#MOLGENIS walltime=23:59:00 mem=4gb ppn=4

#Parameter mapping
#string tempDir
#string tmpDataDir
#string project
#string intermediateDir
#string strandedness
#string sifDir
#string rMATsVersion
#string rMATsOutputDir
#string annotationGtf
#string projectJobsDir
#string project
#string groupname
#string tmpName
#string logsDir

#read number of conditions
source "${intermediateDir}/conditionCount.txt"

echo "conditionCount = ${conditionCount}"
if [[ "${conditionCount}" -gt 1 ]]
then

	mkdir -p "${rMATsOutputDir}/${project}/tmp"
	# create list of bam files from design, and tmp.
	rm -f "${intermediateDir}/${project}.B"{1,2}".txt"
	rm -r "${rMATsOutputDir}/${project}/tmp/"

	while read -r line
	do
		# reading each line
		read -r name status <<< "${line}"
		if [[ "${status}" == "sample" ]]
		then
			echo "${name} is a ${status} : in ${project}.B1.txt"
			echo -n "${intermediateDir}/${name}," >> "${intermediateDir}/${project}.B1.txt"
		else
			echo "${name} is a ${status} : in ${project}.B2.txt"
			echo -n "${intermediateDir}/${name}," >> "${intermediateDir}/${project}.B2.txt"
		fi
		echo "${status}"
	done < "${intermediateDir}${project}_groups_file.txt"


	# Get strandness.

	num1="$(tail -n 2 "${strandedness}" | awk '{print $7}' | head -n 1)"
	num2="$(tail -n 1 "${strandedness}" | awk '{print $7}')"

	STRANDED=$(echo -e "${num1}\t${num2}" | awk '{if ($1 > 0.6){print "fr-firststrand"}else if($2 > 0.6){print "fr-secondstrand"}else if($1 < 0.6 && $2 < 0.6){print "fr-unstranded"} }')

	singularity exec --bind "${intermediateDir}":/intermediateDir,/apps:/apps,/groups:/groups "${sifDir}/${rMATsVersion}" python /rmats/rmats.py \
	--b1 "/intermediateDir/${project}.B1.txt" --b2 "/intermediateDir/${project}.B2.txt" \
	--gtf "${annotationGtf}" \
	-t paired \
	--readLength 150 \
	--variable-read-length \
	--cstat 0.05 \
	--nthread 4 \
	--libType "${STRANDED}" \
	--od "${rMATsOutputDir}/${project}/" \
	--tmp "${rMATsOutputDir}/${project}/tmp/"

	#cleanup tmpdir
	rm -r "${rMATsOutputDir}/${project}/tmp/"
else
	echo "Group number is ${conditionCount}, no DE analysis."
fi
