#MOLGENIS nodes=1 ppn=1 mem=34gb walltime=05:00:00

#Parameter mapping
#string intermediateDir
#string externalSampleID
#string project
#string starIndex
#string	starVersion
#string sambambaTools
#string trimmedLeftBarcodeFqGz
#string trimmedRightBarcodeFqGz
#string trimmedSingleBarcodeFqGz
#string alignedFilteredBam
#string sortedBam
#string sortedBai
#string sequencer
#string library
#string flowcell
#string run
#string barcode
#string lane
#string tempDir
#string filePrefix
#string seqType
#string groupname
#string tmpName
#string logsDir

#Load module
module load "${starVersion}"
module load "${sambambaTools}"
module list

makeTmpDir ${intermediateDir}
tmpintermediateDir=${MC_tmpFile}

makeTmpDir ${sortedBai}
tmpsortedBai=${MC_tmpFile}

echo "## "$(date)" Start $0"
echo "ID (project-internalSampleID-lane): ${project}-${externalSampleID}-L${lane}"

uniqueID="${project}-${externalSampleID}-L${lane}"

if [ "${seqType}" == 'SR' ]
then
	echo "seqType = "${seqType}";FastQ: ${trimmedSingleBarcodeFqGz}"
	inputs="--readFilesIn ${trimmedSingleBarcodeFqGz}"
else
	echo "seqType = "${seqType}";FastQs: ${trimmedLeftBarcodeFqGz} ${trimmedRightBarcodeFqGz}"
    	inputs="--readFilesIn ${trimmedLeftBarcodeFqGz} ${trimmedRightBarcodeFqGz}"
fi

echo "STAR for RNA"

	"${EBROOTSTAR}"/bin/STAR \
	--genomeDir "${starIndex}" \
	--runThreadN 8 \
	"${inputs}" \
	--readFilesCommand zcat \
	--twopassMode Basic \
 	--genomeLoad NoSharedMemory \
 	--quantMode GeneCounts \
        --outSAMtype BAM SortedByCoordinate \
        --limitBAMsortRAM 45000000000 \
        --outSAMstrandField intronMotif \
	--outSAMunmapped Within \
	--outFileNamePrefix "${tmpintermediateDir}"/"${filePrefix}"_"${barcode}".

	#index bam
	sambamba index \
	"${tmpintermediateDir}"/"${filePrefix}"_"${barcode}".Aligned.sortedByCoord.out.bam \
	"${tmpintermediateDir}"/"${filePrefix}"_"${barcode}".Aligned.sortedByCoord.out.bai

	mv -f "${tmpintermediateDir}"/"${filePrefix}_${barcode}."* "${intermediateDir}"

echo "succes moving files";
echo "## "$(date)" ##  $0 Done "
