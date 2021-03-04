#MOLGENIS nodes=1 ppn=4 mem=4gb walltime=05:59:00

#Parameter mapping
#string seqType
#string peEnd1BarcodeFqGz
#string peEnd2BarcodeFqGz
#string srBarcodeFqGz
#string intermediateDir
#string TrimGaloreVersion
#string project
#string groupname
#string tmpName
#string externalSampleID
#string lane
#string logsDir
#string projectRawtmpDataDir
#string projectQcDir

#Echo parameter values
echo "seqType: ${seqType}"
echo "peEnd1BarcodeFqGz: ${peEnd1BarcodeFqGz}"
echo "peEnd2BarcodeFqGz: ${peEnd2BarcodeFqGz}"
echo "srBarcodeFqGz: ${srBarcodeFqGz}"
echo "intermediateDir: ${intermediateDir}"
echo "outputDir: ${projectRawtmpDataDir}"

module load "${TrimGaloreVersion}"
module list

#If paired-end do cutadapt for both ends, else only for one, and fastQC calculations.
if [ ${seqType} == "PE" ]
then

	trim_galore --paired --fastqc --gzip --output_dir "${intermediateDir}" "${peEnd1BarcodeFqGz}" "${peEnd2BarcodeFqGz}" # --clip_R1 --clip_R2

	fastQfileName1=$(basename -s .fq.gz "${peEnd1BarcodeFqGz}")
	fastQfileName2=$(basename -s .fq.gz "${peEnd2BarcodeFqGz}")

	mv "${intermediateDir}/${fastQfileName1}.fq.gz_trimming_report.txt" "${projectQcDir}/"
	mv "${intermediateDir}/${fastQfileName1}_val_1_fastqc.html" "${projectQcDir}/"
	mv "${intermediateDir}/${fastQfileName1}_val_1_fastqc.zip" "${projectQcDir}/"
	mv "${intermediateDir}/${fastQfileName1}_val_1.fq.gz" "${projectRawtmpDataDir}/"
	
	mv "${intermediateDir}/${fastQfileName2}.fq.gz_trimming_report.txt" "${projectQcDir}/"
	mv "${intermediateDir}/${fastQfileName2}_val_2_fastqc.html" "${projectQcDir}/"
	mv "${intermediateDir}/${fastQfileName2}_val_2_fastqc.zip" "${projectQcDir}/"
	mv "${intermediateDir}/${fastQfileName2}_val_2.fq.gz" "${projectRawtmpDataDir}/"
	
	echo -e "\nTrimGalore finished succesfull. Moving files to final.\n\n"

elif [ ${seqType} == "SR" ]
then

	trim_galore --fastqc --gzip --output_dir "${intermediateDir}" "${srBarcodeFqGz}"

	fastQfileName=$(basename -s .fq.gz "${srBarcodeFqGz}")

	mv "${intermediateDir}/${fastQfileName}.fq.gz_trimming_report.txt" "${projectQcDir}/"
	mv "${intermediateDir}/${fastQfileName}_trimmed_fastqc.html" "${projectQcDir}/"
	mv "${intermediateDir}/${fastQfileName}_trimmed_fastqc.zip" "${projectQcDir}/"
	mv "${intermediateDir}/${fastQfileName}_trimmed.fq.gz" "${projectRawtmpDataDir}/"

	echo -e "\nTrimGalore finished succesfull. Moving temp files to final.\n\n"
fi
