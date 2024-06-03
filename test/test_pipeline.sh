set -e
set -u

function preparePipeline(){

	local _projectName="PlatinumSubset_NGS_RNA"
	local _generatedScriptsFolder="${workfolder}/generatedscripts/${_projectName}"

	rm -f "${workfolder}/logs/${_projectName}/run01.pipeline.finished"
	rsync -r --verbose --recursive --links --no-perms --times --group --no-owner --devices --specials "${pipelinefolder}/test/rawdata/MY_TEST_BAM_PROJECT/"SRR1552906[249]_[12].fq.gz "${workfolder}/rawdata/ngs/MY_TEST_BAM_PROJECT/"

	echo "rm -rf ${workfolder}/"{tmp,generatedscripts,projects}"/${_projectName}/"
	rm -rf "${workfolder}/"{tmp,generatedscripts,projects}"/${_projectName}/"
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

	sh generate_template.sh
	cd scripts

	###### Load a version of molgenis compute
	perl -pi -e "s|workflow_STAR.csv|test_workflow_STAR.csv|" *.sh

	sh submit.sh

	cd "${workfolder}/projects/${_projectName}/run01/jobs/"

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
	while [ ! -f "${workfolder}/projects/${_projectName}/run01/jobs/s15_Autotest_0.sh.finished" ]
	do

		echo "${_projectName} is not finished in $minutes minutes, sleeping for 2 minutes"
		sleep 120
		minutes=$((minutes+2))

		count=$((count+2))
		if [ $count -eq 35 ]
		then
			echo "the test was not finished within 35 minutes, let's kill it"
			echo -e "\n"
			for i in ${workfolder}/projects/${_projectName}/run01/jobs/*.sh
			do
				if [ ! -f $i.finished ]
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
NGS_RNA_VERSION="NGS_DNA/betaAutotest"

workfolder="/groups/${groupName}/${tmpdirectory}"

##
pipelinefolder="/groups/${groupName}/${tmpdirectory}/tmp/NGS_RNA/betaAutotest"

workfolder="/groups/${groupName}/${tmpdirectory}/"

rm -rf "/groups/${groupName}/${tmpdirectory}/tmp/NGS_RNA/"
mkdir -p "${pipelinefolder}/"
mkdir -p "${workfolder}/tmp/NGS_RNA/testdata_true/"
cd "${pipelinefolder}"

PULLREQUEST="${1}"

git clone https://github.com/molgenis/NGS_RNA.git
cd NGS_RNA

git fetch --tags --progress https://github.com/molgenis/NGS_RNA/ +refs/pull/*:refs/remotes/origin/pr/*
COMMIT=$(git rev-parse refs/remotes/origin/pr/$PULLREQUEST/merge^{commit})
echo "checkout commit: COMMIT"
git checkout -f ${COMMIT}

mv * ../
cd ..
rm -rf NGS_RNA/


cp workflow_STAR.csv test_workflow_STAR.csv
tail -1 workflow_STAR.csv | perl -p -e 's|,|\t|g' | awk '{print "s15_Autotest,test/protocols/Autotest.sh,"$1}' >> test_workflow_STAR.csv

#exclude steps.
perl -pi -e 's|s09_OUTRIDER|#s09_OUTRIDER|g' test_workflow_STAR.csv
perl -pi -e 's|s12_VIP|#s12_VIP|g' test_workflow_STAR.csv

cp "${pipelinefolder}/test/results/"* "${workfolder}/tmp/NGS_RNA/testdata_true/"

preparePipeline

checkIfFinished
