#MOLGENIS nodes=1 ppn=4 mem=4gb walltime=05:00:00

#Parameter mapping
#string seqType
#string peEnd1BarcodeFqGz
#string peEnd2BarcodeFqGz
#string srBarcodeFqGz

#string BarcodeFastQcFolderPE
#string BarcodeFastQcFolder

#string intermediateDir
#string BBMapVersion
#string project
#string groupname
#string tmpName

function checkAdapter {
        local fastqc_data=${1}
        parseLines="FALSE"
	adapter=""

        while read line
        do
          	if [[ $line == *"Overrepresented sequences"* ]]
                then
                        parseLines="TRUE"
                fi
                if [[ $parseLines == "TRUE" && $line == *"END_MODULE"* ]]
                then
                    	parseLines="FALSE"
                        break
                fi
                if [ $parseLines == "TRUE" ]
                then
                    	if [[ $line == *"truseq"* ]]
                        then
                            	adapter="truseq.fa.gz"
                        fi
                fi
        done <${fastqc_data}
	echo ${adapter}
}

#Load module
module load ${BBMapVersion}
module list

#If paired-end do cutadapt for both ends, else only for one
if [[ "${seqType}" == "PE" ]]
then
	adapter=$(checkAdapter ${BarcodeFastQcFolderPE}/fastqc_data.txt)

	if [[ "${adapter}" == "" ]]
        then
            	echo "skipping, no adapter found"
        else
		${EBROOTBBMAP}/bbduk.sh -Xmx3g \
		in1=${peEnd1BarcodeFqGz} \
		in2=${peEnd2BarcodeFqGz} \
		out1=${peEnd1BarcodeFqGz}.tmp \
		out2=${peEnd2BarcodeFqGz}.tmp \
		ref=${EBROOTBBMAP}/resources/${adapter} \
		overwrite=true \
		k=13 \
		ktrim=l \
	        qtrim=rl \
        	trimq=14 \
		minlength=20

		gzip ${peEnd1BarcodeFqGz}.tmp
		gzip ${peEnd2BarcodeFqGz}.tmp
		mv ${peEnd1BarcodeFqGz}.tmp.gz ${peEnd1BarcodeFqGz}
		mv ${peEnd2BarcodeFqGz}.tmp.gz ${peEnd2BarcodeFqGz}

		echo -e "\nBBMap bbduk.sh finished succesfull. Moving temp files to final.\n\n"
	fi
	
elif [[ "${seqType}" == "SR" ]]
then
	adapter=$(checkAdapter ${BarcodeFastQcFolder}/fastqc_data.txt)

	if [[ "${adapter}" == "" ]]
        then
            	echo "skipping, no adapter found"
        else
		${EBROOTBBMAP}/bbduk.sh -Xmx3g \
		in=${srBarcodeFqGz} \
		out=${srBarcodeFqGz}.tmp \
		ref=${EBROOTBBMAP}/resources/${adapter} \
		overwrite=true \
	       	k=13 \
		ktrim=l \
       		qtrim=rl \
       		trimq=14 \
	        minlength=20

		gzip ${srBarcodeFqGz}.tmp
		mv ${srBarcodeFqGz}.tmp.gz ${srBarcodeFqGz}
	fi
	echo -e "\nBBMap bbduk.sh finished succesfull. Moving temp files to final.\n\n"
fi
