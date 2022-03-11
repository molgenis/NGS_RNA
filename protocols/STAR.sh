#MOLGENIS nodes=1 ppn=1 mem=40gb walltime=23:00:00

#Parameter mapping
#string intermediateDir
#string externalSampleID
#string project
#string starIndex
#string	starVersion
#string sambambaVersion
#string trimmedLeftBarcodeFqGz
#string trimmedRightBarcodeFqGz
#string trimmedSingleBarcodeFqGz
#string annotationGtf
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
module load "${sambambaVersion}"
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
	--sjdbGTFfile "${annotationGtf}" \
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
	--outFileNamePrefix "${tmpintermediateDir}"/"${externalSampleID}".

	#index bam
	sambamba index \
	"${tmpintermediateDir}"/"${externalSampleID}".Aligned.sortedByCoord.out.bam \
	"${tmpintermediateDir}"/"${externalSampleID}".Aligned.sortedByCoord.out.bai

	mv -f "${tmpintermediateDir}"/"${externalSampleID}."* "${intermediateDir}"

echo "succes moving files";
echo "## "$(date)" ##  $0 Done "
