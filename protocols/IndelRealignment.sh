#MOLGENIS nodes=1 ppn=8 mem=11gb walltime=23:59:00

#string project
#string stage
#string checkStage
#string gatkVersion
#string intermediateDir
#string	externalSampleID
#string splitAndTrimBam
#string splitAndTrimBai
#string IndelRealignedBam
#string	IndelRealignedBai
#string indelRealignmentTargets
#string oneKgPhase1IndelsVcf
#string goldStandardVcf
#string tmpDataDir
#string indexFile
#string tmpTmpDataDir
#string project
#string groupname
#string tmpName
#string logsDir

makeTmpDir "${IndelRealignedBam}"
tmpIndelRealignedBam=${MC_tmpFile}

makeTmpDir "${IndelRealignedBai}"
tmpIndelRealignedBai=${MC_tmpFile}

#Load Modules
module load "${gatkVersion}"

#check modules
module list

echo "Running GATK IndelRealignment:"

java -Xmx10g -XX:ParallelGCThreads=8 -Djava.io.tmpdir="${tmpTmpDataDir}" -jar "${EBROOTGATK}/GenomeAnalysisTK.jar" \
-T IndelRealigner \
-R "${indexFile}" \
-I "${splitAndTrimBam}" \
-o "${tmpIndelRealignedBam}" \
-targetIntervals "${indelRealignmentTargets}" \
-known "${oneKgPhase1IndelsVcf}" \
-known "${goldStandardVcf}" \
-U ALLOW_N_CIGAR_READS \
--consensusDeterminationModel KNOWNS_ONLY \
--LODThresholdForCleaning 0.4

mv "${tmpIndelRealignedBam}" "${IndelRealignedBam}"
mv "${tmpIndelRealignedBai}" "${IndelRealignedBai}"

echo "succes moving files";

