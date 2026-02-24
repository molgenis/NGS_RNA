set -e
set -u

function preparePipeline(){

	local _projectName="PlatinumSubset_NGS_RNA"
	local _generatedScriptsFolder="${TMPDIRECTORY}/generatedscripts/NGS_RNA/${_projectName}"

	rm -f "${TMPDIRECTORY}/logs/${_projectName}/run01.pipeline.finished"
	rsync -r --verbose --recursive --links --no-perms --times --group --no-owner --devices --specials "${TMPDIRECTORY}/test/rawdata/MY_TEST_BAM_PROJECT/"SRR1552906[249]_[12].fq.gz "${TMPDIRECTORY}/rawdata/ngs/MY_TEST_BAM_PROJECT/"

	echo "rm -rf ${TMPDIRECTORY}/"{tmp,generatedscripts,projects}"/NGS_RNA/${_projectName}/"
	rm -rf "${TMPDIRECTORY}/"{tmp,generatedscripts,projects}"/NGS_RNA/${_projectName}/"
	mkdir -p "${_generatedScriptsFolder}/"

	echo "copy generate template"
	cp "${TMPDIRECTORY}/templates/generate_template.sh" "${_generatedScriptsFolder}/generate_template.sh"


	module load NGS_RNA/betaAutotest
	module list

	perl -pi -e 's|WORKFLOW=\${EBROOTNGS_RNA}/workflow_\${PIPELINE}.csv|WORKFLOW=\${EBROOTNGS_RNA}/test_workflow_\${PIPELINE}.csv|' "${_generatedScriptsFolder}/generate_template.sh"

	cp "${TMPDIRECTORY}/test/${_projectName}.csv" "${_generatedScriptsFolder}"
	perl -p -e "s|/groups/umcg-atd/tmp01/|${workfolder}/|g" "${_generatedScriptsFolder}/${_projectName}.csv" > "${_generatedScriptsFolder}/${_projectName}.csv.tmp"
	mv -v "${_generatedScriptsFolder}/${_projectName}.csv"{.tmp,}

	cd "${_generatedScriptsFolder}/"

	bash generate_template.sh -c "${EBROOTNGS_RNA}/create_external_samples_ngs_projects_workflow.csv"
	cd scripts

	perl -pi -e "s|workflow_GD.csv|test_workflow_GD.csv|" *.sh

	bash submit.sh

	cd "${TMPDIRECTORY}/projects/NGS_RNA/${_projectName}/run01/jobs/"

	pwd

	perl -pi -e 's|-ERC GVCF|-L 1:17383226-183837051 \\\n  -ERC GVCF|' s*_GatkHaplotypeCallerGvcf_*.sh
	perl -pi -e 's|-ERC GVCF|-L 1:17383226-183837051 \\\n  -ERC GVCF|' s*_GatkGenotypeGvcf_*.sh
	perl -pi -e 's|rsync -av .*.vip|#rsync -av .*.vip|g' s*_CopyToResultsDir_*.sh
	perl -pi -e 's|mem=40gb|mem=10gb|' *.sh
	perl -pi -e 's|--time=16:00:00|--time=05:59:00|' *.sh
	perl -pi -e 's|--time=23:00:00|--time=05:59:00|' *.sh
	perl -pi -e 's|--time=23:59:00|--time=05:59:00|' *.sh

	sh submit.sh
}

function checkIfFinished(){
	local _projectName="PlatinumSubset_NGS_RNA"
	count=0
	minutes=0
	while [ ! -f "${TMPDIRECTORY}/projects/NGS_RNA/${_projectName}/run01/jobs/s15_Autotest_0.sh.finished" ]
	do

		echo "${_projectName} is not finished in $minutes minutes, sleeping for 2 minutes"
		sleep 120
		minutes=$((minutes+2))

		count=$((count+2))
		if [[ "${count}" -eq 35 ]]
		then
			echo "the test was not finished within 35 minutes, let's kill it"
			echo -e "\n"
			for i in "${TMPDIRECTORY}/projects/NGS_RNA/${_projectName}/run01/jobs/"*".sh"
			do
				if [[ ! -f "${i}.finished" ]]
				then
					echo "$(basename $i) is not finished"
				fi
			done
			exit 1
		fi
	done
	echo ""
	echo "${_projectName} test succeeded!"
	echo ""
}

pipeline='NGS_RNA'
TMPDIR='tmp08'

TMPDIRECTORY="/groups/umcg-atd/${TMPDIR}"
WORKDIR="${TMPDIRECTORY}/tmp/${pipeline}/betaAutotest"
TEMP="${WORKDIR}/temp"

## cleanup data to get new data
echo "cleaning up.."
rm -rvf "${WORKDIR}"
rm -rf "/tmp/${pipeline}"

echo "Create workdirs"
mkdir -p "${WORKDIR}"
mkdir -p "${WORKDIR}/tmp/NGS_RNA/testdata_true/"

PULLREQUEST="${1}"
cd /tmp
git clone "https://github.com/molgenis/${pipeline}.git"

cd "${pipeline}" || exit
git fetch --tags --progress https://github.com/molgenis/NGS_RNA/ +refs/pull/*:refs/remotes/origin/pr/*
COMMIT=$(git rev-parse refs/remotes/origin/pr/$PULLREQUEST/merge^{commit})
echo "checkout commit: COMMIT"
git checkout -f ${COMMIT}

cd /tmp
mv "${pipeline}" "${WORKDIR}"
cd "${WORKDIR}/${pipeline}"


cp 'workflow_GD.csv' 'test_workflow_GD.csv'
tail -1 'workflow_GD.csv' | perl -p -e 's|,|\t|g' | awk '{print "s17_Autotest,test/protocols/Autotest.sh,"$1}' >> 'test_workflow_GD.csv'

cp "${WORKDIR}/test/results/"* "${TMPDIRECTORY}/tmp/NGS_RNA/testdata_true/"

preparePipeline

checkIfFinished
