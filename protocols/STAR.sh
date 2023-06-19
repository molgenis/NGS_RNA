set -o pipefail
#MOLGENIS nodes=1 ppn=8 mem=40gb walltime=23:00:00

#Parameter mapping
#string intermediateDir
#string externalSampleID
#string project
#string starIndex
#string	starVersion
#string sambambaVersion
#string mergedLeftBarcodeFqGz
#string mergedRightBarcodeFqGz
#string mergedSingleBarcodeFqGz
#string annotationGtf
#string tempDir
#string seqType
#string groupname
#string tmpName
#string logsDir

#Load module
module load "${starVersion}"
module load "${sambambaVersion}"
module list

makeTmpDir "${intermediateDir}"
tmpintermediateDir=${MC_tmpFile}

if [[ "${seqType}" == 'SR' ]]
then
	echo "seqType = ${seqType}; FastQ: ${mergedSingleBarcodeFqGz}"
	inputs="--readFilesIn ${mergedSingleBarcodeFqGz}"
else
	echo "seqType = ${seqType}; FastQs: ${mergedLeftBarcodeFqGz} ${mergedRightBarcodeFqGz}"
	inputs="--readFilesIn ${mergedLeftBarcodeFqGz} ${mergedRightBarcodeFqGz}"
fi

echo "STAR for RNA"

	"${EBROOTSTAR}/bin/STAR" \
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
	--outFileNamePrefix "${tmpintermediateDir}/${externalSampleID}".

	#index bam
	sambamba index \
	"${tmpintermediateDir}/${externalSampleID}".Aligned.sortedByCoord.out.bam \
	"${tmpintermediateDir}/${externalSampleID}".Aligned.sortedByCoord.out.bai

	mv -f "${tmpintermediateDir}/${externalSampleID}."* "${intermediateDir}"

echo "succes moving files";
