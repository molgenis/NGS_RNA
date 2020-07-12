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
#string srBarcodeFqGz
#string alignedSam
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

echo "STAR for RNA"

	"${EBROOTSTAR}"/bin/STAR \
	--genomeDir "${starIndex}" \
	--runThreadN 8 \
	--readFilesIn "${trimmedLeftBarcodeFqGz}" "${trimmedRightBarcodeFqGz}" \
	--readFilesCommand zcat \
	--twopassMode Basic \
 	--genomeLoad NoSharedMemory \
 	--outFilterMultimapNmax 1 \
 	--quantMode GeneCounts \
        --outSAMtype BAM SortedByCoordinate \
        --limitBAMsortRAM 45000000000 \
	--outSAMunmapped Within \
	--outFileNamePrefix "${tmpintermediateDir}"/"${filePrefix}"_"${barcode}".

	#index bam
	"${sambambaTools}" index \
	"${tmpintermediateDir}"/"${filePrefix}"_"${barcode}".Aligned.sortedByCoord.out.bam \
	"${tmpintermediateDir}"/"${filePrefix}"_"${barcode}".Aligned.sortedByCoord.out.bai \

	mv "${tmpintermediateDir}"/"${filePrefix}_${barcode}."* "${intermediateDir}"

echo "succes moving files";
echo "## "$(date)" ##  $0 Done "
