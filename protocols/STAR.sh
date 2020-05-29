#MOLGENIS nodes=1 ppn=1 mem=34gb walltime=05:00:00

#Parameter mapping
#string intermediateDir
#string externalSampleID
#string project
#string starIndex
#string	starVersion
#string leftbarcodefqgz
#string rightbarcodefqgz
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
module load ${starVersion}
module list

makeTmpDir ${intermediateDir}
tmpintermediateDir=${MC_tmpFile}

makeTmpDir ${sortedBai}
tmpsortedBai=${MC_tmpFile}

echo "## "$(date)" Start $0"
echo "ID (project-internalSampleID-lane): ${project}-${externalSampleID}-L${lane}"

uniqueID="${project}-${externalSampleID}-L${lane}"

echo "STAR SR for RNA"

        $EBROOTSTAR/bin/STAR \
	--genomeDir ${starIndex} \
	--runThreadN 2 \
	--sjdbOverhang 100 \
	--readFilesIn ${leftbarcodefqgz} ${rightbarcodefqgz} --readFilesCommand zcat \
	--twopassMode Basic \
	--outSAMattributes NH NM MD \
	--outSAMtype BAM SortedByCoordinate \
	--limitBAMsortRAM 45000000000 \
	--outSAMunmapped Within \
	--outSAMmapqUnique 50 \
	--outFilterType BySJout \
	--outSJfilterCountUniqueMin -1 2 2 2 \
	--outSJfilterCountTotalMin -1 2 2 2 \
	--outFilterIntronMotifs RemoveNoncanonical \
	--chimSegmentMin 12 \
	--chimJunctionOverhangMin 12 \
	--chimScoreDropMax 30 \
	--chimSegmentReadGapMax 5 \
	--chimScoreSeparation 5 \
	--chimOutType WithinBAM \
	--outFileNamePrefix ${tmpintermediateDir}/${filePrefix}_${barcode}.

	mv "${tmpintermediateDir}"/${filePrefix}_${barcode}.Aligned.sortedByCoord.out.bam ${sortedBam}
	mv "${tmpintermediateDir}"/${filePrefix}_${barcode}.Log.final.out ${intermediateDir}
	#mv ${tmpsortedBai} ${sortedBai}
	#mv ${tmpIntermediateDir}/${uniqueID}.bamLog.final.out ${intermediateDir}/${uniqueID}.final.log

echo "succes moving files";
echo "## "$(date)" ##  $0 Done "
