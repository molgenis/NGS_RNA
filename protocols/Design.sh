#MOLGENIS nodes=1 ppn=4 mem=4gb walltime=05:59:00

#Parameter mapping
#string RPlusVersion
#string intermediateDir
#list externalSampleID
#string project
#string groupname
#string tmpName
#string logsDir

module load "${RPlusVersion}"
module list

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

#Create string with input BAM files for Picard
#This check needs to be performed because Compute generates duplicate values in array
UNIQUESAMPLES=()

for sample in "${externalSampleID[@]}"
do
	array_contains UNIQUESAMPLES "${sample}" || UNIQUESAMPLES+=("${sample}")    # If bamFile does not exist in array add it
done

cd "${intermediateDir}"

#cleanup old file if present
rm -f "${intermediateDir}/*.design.tsv"

# manage a design file for each sample detected
# the design is simple : 1 vs all other

for currentSample in "${UNIQUESAMPLES[@]}"
do
        # rewrite a new design file

	echo -e "sample\ttype" > "${intermediateDir}/$currentSample.outrider.design.tsv"
        echo -e "${currentSample}\tsample" >> "${intermediateDir}/$currentSample.outrider.design.tsv"
        echo -e "externalSampleID,conditions" > "${intermediateDir}/$currentSample.DE.design.csv"
        echo -e "${currentSample},sample" >> "${intermediateDir}/$currentSample.DE.design.csv"
        echo -e "${currentSample}.sorted.merged.bam\tsample" > "${intermediateDir}/$currentSample.SJ.design.tsv"

        # all the other sample in the batch are controls
        for tmpSample in "${UNIQUESAMPLES[@]}"
        do
                if [[ "$currentSample" != "$tmpSample" ]]
                then
                        echo -e "${tmpSample}\tcontrol" >> "${intermediateDir}/$currentSample.outrider.design.tsv"
                        echo -e "${tmpSample},control" >> "${intermediateDir}/$currentSample.DE.design.csv"
                        echo -e "${tmpSample}.sorted.merged.bam\tcontrol" >> "${intermediateDir}/$currentSample.SJ.design.tsv"
                fi
        done
done

echo "files written to: ${intermediateDir}/ *.design.tsv"

cd -
