set -e 
set -u

function preparePipeline(){

	local _projectName="PlatinumSubset_NGS_RNA"
	rm -f ${workfolder}/logs/${_projectName}/run01.pipeline.finished
	rsync -r --verbose --recursive --links --no-perms --times --group --no-owner --devices --specials ${workfolder}/tmp/NGS_RNA/test/rawdata/MY_TEST_BAM_PROJECT/small_revertsam_RNA_[12].fq.gz ${workfolder}/rawdata/ngs/MY_TEST_BAM_PROJECT/

	if [ -d ${workfolder}/generatedscripts/${_projectName} ] 
	then
		rm -rf ${workfolder}/generatedscripts/${_projectName}/
	fi

	if [ -d ${workfolder}/projects/${_projectName} ] 
	then
		rm -rf ${workfolder}/projects/${_projectName}/
	fi

	if [ -d ${workfolder}/tmp/${_projectName} ] 
	then
		rm -rf ${workfolder}/tmp/${_projectName}/
	fi
	mkdir ${workfolder}/generatedscripts/${_projectName}/
	echo "copy generate template"
	cp ${workfolder}/tmp/NGS_RNA/templates/generate_template.sh ${workfolder}/generatedscripts/${_projectName}/generate_template.sh

	#fgrep "computeVersion," ${workfolder}/tmp/NGS_RNA/parameters.csv > ${workfolder}/generatedscripts/${_projectName}/mcVersion.txt

	echo "module load ${NGS_RNA_VERSION}"
	module load ${NGS_RNA_VERSION}
	EBROOTNGS_RNA="${workfolder}/tmp/NGS_RNA/"
	echo "${EBROOTNGS_RNA}"

	## Grep used version of molgenis compute out of the parameters file
	perl -pi -e "s|module load ${NGS_RNA_VERSION}|EBROOTNGS_RNA=${workfolder}/tmp/NGS_RNA/|" ${workfolder}/generatedscripts/${_projectName}/generate_template.sh
	perl -pi -e 's|ngsversion=.*|ngsversion="test";\\|' ${workfolder}/generatedscripts/${_projectName}/generate_template.sh
	perl -pi -e 's|sh \$EBROOTMOLGENISMINCOMPUTE/molgenis_compute.sh|module load Molgenis-Compute/dummy\nsh \$EBROOTMOLGENISMINCOMPUTE/molgenis_compute.sh|' ${workfolder}/generatedscripts/${_projectName}/generate_template.sh
	perl -pi -e "s|module load Molgenis-Compute/dummy|module load Molgenis-Compute/\$mcVersion|" ${workfolder}/generatedscripts/${_projectName}/generate_template.sh

	perl -pi -e 's|workflow=\${EBROOTNGS_RNA}/workflow_hisat.csv|workflow=\${EBROOTNGS_RNA}/test_workflow_hisat.csv|' ${workfolder}/generatedscripts/${_projectName}/generate_template.sh
	cp ${workfolder}/tmp/NGS_RNA/test/${_projectName}.csv ${workfolder}/generatedscripts/${_projectName}/
	perl -pi -e "s|/groups/umcg-atd/tmp03/|${workfolder}/|g" ${workfolder}/generatedscripts/${_projectName}/${_projectName}.csv
	cd ${workfolder}/generatedscripts/${_projectName}/

	sh generate_template.sh
	cd scripts
	###### Load a version of molgenis compute
	perl -pi -e "s|module load test| module load ${NGS_RNA_VERSION}|" *.sh
	######
	perl -pi -e "s|/apps/software/${NGS_RNA_VERSION}/|${workfolder}/tmp/NGS_RNA/|g" *.sh
	sh submit.sh

	cd ${workfolder}/projects/${_projectName}/run01/jobs/

	perl -pi -e 's|--emitRefConfidence|-L 1:1-1200000 \\\n  --emitRefConfidence|' s*_GatkHaplotypeCallerGvcf_0.sh
	perl -pi -e 's|-stand_emit_conf|-L 1:1-1200000 \\\n  -stand_emit_conf|' s*_GatkGenotypeGvcf_*.sh
	perl -pi -e 's|cp |touch /groups/umcg-atd//tmp04/tmp//PlatinumSubset_NGS_RNA/run01//MY_TEST_BAM_PROJECT_L1_None_1.fq_fastqc/Images/per_sequence_gc_content.png\n\t cp |' s*_FastQC_*.sh
	perl -pi -e 's|mem 32gb|mem 4gb|' s*_GatkMergeGvcf_*.sh
	perl -pi -e 's|time=43:59:00|time=3:59:00|' s*_GatkMergeGvcf_*.sh
	perl -pi -e 's|--time=16:00:00|--time=05:59:00|' *.sh
	perl -pi -e 's|--time=23:59:00|--time=05:59:00|' *.sh

	sh submit.sh --qos=dev



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
tmpdirectory="tmp03"
groupName="umcg-atd"

if [ $(hostname) == "calculon" ]
then
	tmpdirectory="tmp04"
fi

workfolder="/groups/${groupName}/${tmpdirectory}"

cd ${workfolder}/tmp/
if [ -d ${workfolder}/tmp/NGS_RNA ]
then
	rm -rf ${workfolder}/tmp/NGS_RNA/
	echo "removed ${workfolder}/tmp/NGS_RNA/"
fi

echo "pr number: $1"

PULLREQUEST=$1
NGS_RNA_VERSION=NGS_RNA/3.3.0

git clone https://github.com/molgenis/NGS_RNA.git
cd ${workfolder}/tmp/NGS_RNA

git fetch --tags --progress https://github.com/molgenis/NGS_RNA/ +refs/pull/*:refs/remotes/origin/pr/*
COMMIT=$(git rev-parse refs/remotes/origin/pr/$PULLREQUEST/merge^{commit})
echo "checkout commit: COMMIT"
git checkout -f ${COMMIT}

### create testworkflow
cd ${workfolder}/tmp/NGS_RNA/
cp ${workfolder}/tmp/NGS_RNA/workflow_hisat.csv ${workfolder}/tmp/NGS_RNA/test_workflow_hisat.csv 
tail -1 ${workfolder}/tmp/NGS_RNA/workflow_hisat.csv | perl -p -e 's|,|\t|g' | awk '{print "Autotest,test/protocols/Autotest.sh,"$1}' >> ${workfolder}/tmp/NGS_RNA/test_workflow_hisat.csv

cp ${workfolder}/tmp/NGS_RNA/test/results/PlatinumSubset_NGS_RNA.variant.calls.genotyped.chr1.true.vcf /home/umcg-molgenis/NGS_RNA/
cp ${workfolder}/tmp/NGS_RNA/test/results/PlatinumSubset_NGS_RNA.expression.true.table /home/umcg-molgenis/NGS_RNA/

preparePipeline

checkIfFinished
