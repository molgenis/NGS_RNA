set -e
set -u

function preparePipeline(){

	local _projectName="PlatinumSubset_NGS_RNA"
	local _generatedScriptsFolder="${workfolder}/generatedscripts/${_projectName}"

	TMPHOME=/home/umcg-gvdvries/git/NGS_RNA
	rm -f ${workfolder}/logs/${_projectName}/run01.pipeline.finished
	#rsync -r --verbose --recursive --links --no-perms --times --group --no-owner --devices --specials ${TMPHOME}/test/rawdata/MY_TEST_BAM_PROJECT/SRR1552906[249]_[12].fq.gz ${workfolder}/rawdata/ngs/MY_TEST_BAM_PROJECT/
	rsync -r --verbose --recursive --links --no-perms --times --group --no-owner --devices --specials ${pipelinefolder}/test/rawdata/MY_TEST_BAM_PROJECT/SRR1552906[249]_[12].fq.gz ${workfolder}/rawdata/ngs/MY_TEST_BAM_PROJECT/

	rm -rf ${workfolder}/{tmp,generatedscripts,projects}/NGS_RNA/${_projectName}/
	mkdir -p ${workfolder}/generatedscripts/${_projectName}/

	echo "copy generate template"
	cp ${pipelinefolder}/templates/generate_template.sh ${workfolder}/generatedscripts/${_projectName}/generate_template.sh


	module load NGS_RNA/betaAutotest
	#EBROOTNGS_RNA="${workfolder}/tmp/NGS_RNA/"
	module list
	#echo "${EBROOTNGS_RNA}"

	## Grep used version of molgenis compute out of the parameters file
	#perl -pi -e "s|module load ${NGS_RNA_VERSION}|EBROOTNGS_RNA=${workfolder}/tmp/NGS_RNA/|" ${workfolder}/generatedscripts/${_projectName}/generate_template.sh
	#perl -pi -e 's|create_in-house_ngs_projects_workflow.csv|create_external_samples_ngs_projects_workflow.csv|' ${workfolder}/generatedscripts/${_projectName}/generate_template.sh
	#perl -pi -e 's|ngsversion=.*|ngsversion="test";\\|' ${workfolder}/generatedscripts/${_projectName}/generate_template.sh
	#perl -pi -e 's|sh \$EBROOTMOLGENISMINCOMPUTE/molgenis_compute.sh|module load Molgenis-Compute/dummy\nsh \$EBROOTMOLGENISMINCOMPUTE/molgenis_compute.sh|' ${workfolder}/generatedscripts/${_projectName}/generate_template.sh
	#perl -pi -e "s|module load Molgenis-Compute/dummy|module load Molgenis-Compute/\$mcVersion|" ${workfolder}/generatedscripts/${_projectName}/generate_template.sh
	perl -pi -e 's|WORKFLOW=\${EBROOTNGS_RNA}/workflow_\${PIPELINE}.csv|WORKFLOW=\${EBROOTNGS_RNA}/test_workflow_\${PIPELINE}.csv|' ${workfolder}/generatedscripts/${_projectName}/generate_template.sh

	cp "${pipelinefolder}/test/${_projectName}.csv" "${_generatedScriptsFolder}"
	perl -p -e "s|/groups/umcg-atd/tmp01/|${workfolder}/|g" "${_generatedScriptsFolder}/${_projectName}.csv" > "${_generatedScriptsFolder}/${_projectName}.csv.tmp"
	mv -v "${_generatedScriptsFolder}/${_projectName}.csv"{.tmp,}

	#perl -pi -e "s|/groups/umcg-atd/tmp03/|${workfolder}/|g" ${workfolder}/generatedscripts/${_projectName}/${_projectName}.csv

	cd ${workfolder}/generatedscripts/${_projectName}/

	sh generate_template.sh
	cd scripts

	###### Load a version of molgenis compute
	perl -pi -e "s|workflow_STAR.csv|test_workflow_STAR.csv|" *.sh
#	perl -pi -e "s|/apps/software/${NGS_RNA_VERSION}/|${workfolder}/tmp/NGS_RNA/|g" *.sh

#	perl -pi -e 's|slurm/header_tnt.ftl|slurm/header.ftl|' *.sh
#	perl -pi -e 's|slurm/footer_tnt.ftl|slurm/footer.ftl|' *.sh

	sh submit.sh

	cd ${workfolder}/projects/${_projectName}/run01/jobs/

	pwd

	perl -pi -e 's|--emitRefConfidence|-L 1:1-1200000 \\\n  --emitRefConfidence|' s*_GatkHaplotypeCallerGvcf_0.sh
	perl -pi -e 's|-stand_emit_conf|-L 1:1-1200000 \\\n  -stand_emit_conf|' s*_GatkGenotypeGvcf_*.sh
	perl -pi -e 's|cp |touch /groups/umcg-atd//tmp04/tmp//PlatinumSubset_NGS_RNA/run01//MY_TEST_BAM_PROJECT_L1_None_1.fq_fastqc/Images/per_sequence_gc_content.png\n\t cp |' s*_FastQC_*.sh
	perl -pi -e 's|--time=16:00:00|--time=05:59:00|' *.sh
	perl -pi -e 's|--time=23:00:00|--time=05:59:00|' *.sh
	perl -pi -e 's|--time=23:59:00|--time=05:59:00|' *.sh

	sh submit.sh
}

function checkIfFinished(){
	local _projectName="PlatinumSubset_NGS_RNA"
	count=0
	minutes=0
	while [ ! -f ${workfolder}/projects/${_projectName}/run01/jobs/Autotest_0.sh.finished ]
	do

		echo "${_projectName} is not finished in $minutes minutes, sleeping for 2 minutes"
		sleep 120
		minutes=$((minutes+2))

		count=$((count+2))
		if [ $count -eq 30 ]
		then
			echo "the test was not finished within 30 minutes, let's kill it"
			echo -e "\n"
			for i in $(ls ${workfolder}/projects/${_projectName}/run01/jobs/*.sh)
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
tmpdirectory="tmp01"
groupName="umcg-atd"
NGS_RNA_VERSION="NGS_DNA/betaAutotest"

workfolder="/groups/${groupName}/${tmpdirectory}"

##
pipelinefolder="/groups/${groupName}/${tmpdirectory}/tmp/NGS_RNA/betaAutotest/"
workfolder="/groups/${groupName}/${tmpdirectory}/"

rm -rf "${pipelinefolder}"
mkdir -p "${pipelinefolder}"
cd "${pipelinefolder}"

#echo "pr number: ${1}"

PULLREQUEST=35

git clone https://github.com/molgenis/NGS_RNA.git
cd NGS_RNA

git fetch --tags --progress https://github.com/molgenis/NGS_RNA/ +refs/pull/*:refs/remotes/origin/pr/*
COMMIT=$(git rev-parse refs/remotes/origin/pr/$PULLREQUEST/merge^{commit})
echo "checkout commit: COMMIT"
git checkout -f ${COMMIT}

mv * ../
cd ..
rm -rf NGS_RNA/

### tmp !!!
#cp -r /home/umcg-gvdvries/git/NGS_RNA ${workfolder}/tmp/NGS_RNA/

### create testworkflow
#cd ${workfolder}/tmp/NGS_RNA/
pwd

cp workflow_STAR.csv test_workflow_STAR.csv
tail -1 workflow_STAR.csv | perl -p -e 's|,|\t|g' | awk '{print "s15_Autotest,test/protocols/Autotest.sh,"$1}' >> test_workflow_STAR.csv

#exclude steps.
perl -pi -e 's|s09_OUTRIDER|#s09_OUTRIDER|g' test_workflow_STAR.csv
perl -pi -e 's|s12_VIP|#s12_VIP|g' test_workflow_STAR.csv
#cp ${workfolder}/tmp/NGS_RNA/test/results/PlatinumSubset_NGS_RNA.variant.calls.genotyped.chr1.true.vcf /home/umcg-molgenis/NGS_RNA/
#cp ${workfolder}/tmp/NGS_RNA/test/results/PlatinumSubset_NGS_RNA.expression.true.table /home/umcg-molgenis/NGS_RNA/

#cp test/results/* /groups/umcg-atd/tmp01/tmp/NGS_RNA/testdata_true/
cp /home/umcg-gvdvries/git/NGS_RNA/test/results/* /groups/umcg-atd/tmp01/tmp/NGS_RNA/testdata_true/

preparePipeline

checkIfFinished
