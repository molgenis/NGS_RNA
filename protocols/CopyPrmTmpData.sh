set -o pipefail
#MOLGENIS walltime=01:59:00 mem=4gb

#string allRawNgstmpDataDir
#string allRawNgsPrmDataDir

#list seqType
#list sequencingStartDate
#list sequencer
#list run
#list flowcell
#string logsDir
#string mainParameters
#string worksheet
#string outputdir
#string workflowpath

#list internalSampleID
#string project
#string groupname

#list barcode
#list lane

max_index="${#internalSampleID[@]}"-1

for ((samplenumber = 0; samplenumber <= max_index; samplenumber++))
do

	RUNNAME="${sequencingStartDate[samplenumber]}_${sequencer[samplenumber]}_${run[samplenumber]}_${flowcell[samplenumber]}"
	PRMDATADIR="${allRawNgsPrmDataDir}/${RUNNAME}"
	TMPDATADIR="${allRawNgstmpDataDir}/${RUNNAME}"

	if [[ "${seqType[samplenumber]}" == "SR" ]]
	then
		mkdir -p "${TMPDATADIR}"
		if [[ "${barcode[samplenumber]}" == "None" ]]
		then
			rsync -a -v \
			"${PRMDATADIR}/${RUNNAME}_L${lane[samplenumber]}.fq.gz" \
			"${TMPDATADIR}/${RUNNAME}_L${lane[samplenumber]}.fq.gz"
			rsync -a -v \
			"${PRMDATADIR}/${RUNNAME}_L${lane[samplenumber]}.fq.gz.md5" \
			"${TMPDATADIR}/${RUNNAME}_L${lane[samplenumber]}.fq.gz.md5"
		else
			rsync -a -v \
			"${PRMDATADIR}/${RUNNAME}_L${lane[samplenumber]}_${barcode[samplenumber]}.fq.gz" \
			"${TMPDATADIR}/${RUNNAME}_L${lane[samplenumber]}_${barcode[samplenumber]}.fq.gz"
			rsync -a -v \
			"${PRMDATADIR}/${RUNNAME}_L${lane[samplenumber]}_${barcode[samplenumber]}.fq.gz.md5" \
			"${TMPDATADIR}/${RUNNAME}_L${lane[samplenumber]}_${barcode[samplenumber]}.fq.gz.md5"
		fi
	elif [[ "${seqType[samplenumber]}" == "PE" ]]
	then
		mkdir -p "${TMPDATADIR}"
		if [[ "${barcode[samplenumber]}" == "None" ]]
		then
		rsync -a -v \
			"${PRMDATADIR}/${RUNNAME}_L${lane[samplenumber]}_1.fq.gz" \
			"${TMPDATADIR}/${RUNNAME}_L${lane[samplenumber]}_1.fq.gz"
		rsync -a -v \
			"${PRMDATADIR}/${RUNNAME}_L${lane[samplenumber]}_2.fq.gz" \
			"${TMPDATADIR}/${RUNNAME}_L${lane[samplenumber]}_2.fq.gz"
		rsync -a -v \
			"${PRMDATADIR}/${RUNNAME}_L${lane[samplenumber]}_1.fq.gz.md5" \
			"${TMPDATADIR}/${RUNNAME}_L${lane[samplenumber]}_1.fq.gz.md5"
		rsync -a -v \
			"${PRMDATADIR}/${RUNNAME}_L${lane[samplenumber]}_2.fq.gz.md5" \
			"${TMPDATADIR}/${RUNNAME}_L${lane[samplenumber]}_2.fq.gz.md5"
		else
		rsync -a -v \
			"${PRMDATADIR}/${RUNNAME}_L${lane[samplenumber]}_${barcode[samplenumber]}_1.fq.gz" \
			"${TMPDATADIR}/${RUNNAME}_L${lane[samplenumber]}_${barcode[samplenumber]}_1.fq.gz"
		rsync -a -v \
			"${PRMDATADIR}/${RUNNAME}_L${lane[samplenumber]}_${barcode[samplenumber]}_2.fq.gz" \
			"${TMPDATADIR}/${RUNNAME}_L${lane[samplenumber]}_${barcode[samplenumber]}_2.fq.gz"
		rsync -a -v \
			"${PRMDATADIR}/${RUNNAME}_L${lane[samplenumber]}_${barcode[samplenumber]}_1.fq.gz.md5" \
			"${TMPDATADIR}/${RUNNAME}_L${lane[samplenumber]}_${barcode[samplenumber]}_1.fq.gz.md5"
		rsync -a -v \
			"${PRMDATADIR}/${RUNNAME}_L${lane[samplenumber]}_${barcode[samplenumber]}_2.fq.gz.md5" \
			"${TMPDATADIR}/${RUNNAME}_L${lane[samplenumber]}_${barcode[samplenumber]}_2.fq.gz.md5"
		fi
	fi

done

cd "${TMPDATADIR}" || exit
if md5sum -c ./*.md5 > "${RUNNAME}.md5.log" 2>&1
then
	echo 'PASS'
else
	echo 'FAILED'
fi
cd - || exit
