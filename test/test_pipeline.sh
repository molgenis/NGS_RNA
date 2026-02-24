set -e
set -u

function preparePipeline(){

	local _projectName="PlatinumSubset_NGS_RNA"
	local _generatedScriptsFolder="${workfolder}/generatedscripts/NGS_RNA/${_projectName}"

	rm -f "${workfolder}/logs/${_projectName}/run01.pipeline.finished"
	rsync -r --verbose --recursive --links --no-perms --times --group --no-owner --devices --specials "${pipelinefolder}/test/rawdata/MY_TEST_BAM_PROJECT/"SRR1552906[249]_[12].fq.gz "${workfolder}/rawdata/ngs/MY_TEST_BAM_PROJECT/"

	echo "rm -rf ${workfolder}/"{tmp,generatedscripts,projects}"/NGS_RNA/${_projectName}/"
	rm -rf "${workfolder}/"{tmp,generatedscripts,projects}"/NGS_RNA/${_projectName}/"
	mkdir -p "${_generatedScriptsFolder}/"

	echo "copy generate template"
	cp "${pipelinefolder}/templates/generate_template.sh" "${_generatedScriptsFolder}/generate_template.sh"


	module load NGS_RNA/betaAutotest
	module list

	perl -pi -e 's|WORKFLOW=\${EBROOTNGS_RNA}/workflow_\${PIPELINE}.csv|WORKFLOW=\${EBROOTNGS_RNA}/test_workflow_\${PIPELINE}.csv|' "${_generatedScriptsFolder}/generate_template.sh"

	cp "${pipelinefolder}/test/${_projectName}.csv" "${_generatedScriptsFolder}"
	perl -p -e "s|/groups/umcg-atd/tmp01/|${workfolder}/|g" "${_generatedScriptsFolder}/${_projectName}.csv" > "${_generatedScriptsFolder}/${_projectName}.csv.tmp"
	mv -v "${_generatedScriptsFolder}/${_projectName}.csv"{.tmp,}

	cd "${_generatedScriptsFolder}/"

	bash generate_template.sh -c "${EBROOTNGS_RNA}/create_external_samples_ngs_projects_workflow.csv"
	cd scripts

	perl -pi -e "s|workflow_GD.csv|test_workflow_GD.csv|" *.sh

	bash submit.sh

	cd "${workfolder}/projects/NGS_RNA/${_projectName}/run01/jobs/"

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
	while [ ! -f "${workfolder}/projects/NGS_RNA/${_projectName}/run01/jobs/s15_Autotest_0.sh.finished" ]
	do

		echo "${_projectName} is not finished in $minutes minutes, sleeping for 2 minutes"
		sleep 120
		minutes=$((minutes+2))

		count=$((count+2))
		if [[ "${count}" -eq 35 ]]
		then
			echo "the test was not finished within 35 minutes, let's kill it"
			echo -e "\n"
			for i in "${workfolder}/projects/NGS_RNA/${_projectName}/run01/jobs/"*".sh"
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
tmpdirectory="tmp08"
groupName="umcg-atd"
NGS_RNA_VERSION="NGS_RNA/betaAutotest"
workfolder="/groups/${groupName}/${tmpdirectory}"
pipelinefolder="/groups/${groupName}/${tmpdirectory}/tmp/NGS_RNA/betaAutotest"

rm -rf "/groups/${groupName}/${tmpdirectory}/tmp/NGS_RNA/"
rm -rf "/tmp/NGS_RNA/"
mkdir -p "${pipelinefolder}/"
mkdir -p "${workfolder}/tmp/NGS_RNA/testdata_true/"
cd "${pipelinefolder}"

PULLREQUEST="${1}"
# EXTRA STEP TO GET THE DATA ON THE MACHINE
#cd /tmp
git clone https://github.com/molgenis/NGS_RNA.git
#cd "NGS_RNA" || exit
# COPY DATA TO PIPELINEFOLDER
mv "NGS_RNA" "${pipelinefolder}/"
cd "${pipelinefolder}/NGS_RNA"
##BACK TO NORMAL FROM NOW ON
git fetch --tags --progress https://github.com/molgenis/NGS_RNA/ +refs/pull/*:refs/remotes/origin/pr/*
COMMIT=$(git rev-parse refs/remotes/origin/pr/$PULLREQUEST/merge^{commit})
echo "checkout commit: ${COMMIT}"
git checkout -f ${COMMIT}

mv * ../
cd ..
rm -rf 'NGS_RNA/'

cp 'workflow_GD.csv' 'test_workflow_GD.csv'
tail -1 'workflow_GD.csv' | perl -p -e 's|,|\t|g' | awk '{print "s17_Autotest,test/protocols/Autotest.sh,"$1}' >> 'test_workflow_GD.csv'

cp "${pipelinefolder}/test/results/"* "${workfolder}/tmp/NGS_RNA/testdata_true/"

preparePipeline

checkIfFinished
