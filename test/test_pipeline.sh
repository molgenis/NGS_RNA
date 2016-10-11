set -e 
set -u

scancel -u umcg-molgenis

workfolder="/groups/umcg-gaf/tmp04/"

cd ${workfolder}/tmp/
if [ -d ${workfolder}/tmp/NGS_RNA ]
then
	rm -rf ${workfolder}/tmp/NGS_RNA/
	echo "removed ${workfolder}/tmp/NGS_RNA/"
fi

echo "pr number: $1"

PULLREQUEST=$1

git clone https://github.com/molgenis/NGS_RNA.git
cd ${workfolder}/tmp/NGS_RNA

git fetch --tags --progress https://github.com/molgenis/NGS_RNA/ +refs/pull/*:refs/remotes/origin/pr/*
COMMIT=$(git rev-parse refs/remotes/origin/pr/$PULLREQUEST/merge^{commit})
echo "checkout commit: COMMIT"
git checkout -f ${COMMIT}

if [ ! -d ${workfolder}/rawdata/ngs/MY_TEST_BAM_PROJECT/ ] 
then
	cp -r test/rawdata/MY_TEST_BAM_PROJECT/ ${workfolder}/rawdata/ngs/
fi

if [ -d ${workfolder}/generatedscripts/PlatinumSubset_NGS_RNA ] 
then
	rm -rf ${workfolder}/generatedscripts/PlatinumSubset_NGS_RNA/
fi

if [ -d ${workfolder}/projects/PlatinumSubset_NGS_RNA ] 
then
	rm -rf ${workfolder}/projects/PlatinumSubset_NGS_RNA/
fi

if [ -d ${workfolder}/tmp/PlatinumSubset_NGS_RNA ]
then
    	rm -rf ${workfolder}/tmp/PlatinumSubset_NGS_RNA/
fi

mkdir ${workfolder}/generatedscripts/PlatinumSubset_NGS_RNA/

### create testworkflow
cd ${workfolder}/tmp/NGS_RNA/
cp workflow_hisat.csv test_workflow_hisat.csv 
tail -1 workflow_hisat.csv | perl -p -e 's|,|\t|g' | awk '{print "Autotest,test/protocols/Autotest.sh,"$1}' >> test_workflow_hisat.csv

cp test/results/PlatinumSubset_NGS_RNA.variant.calls.genotyped.chr1.true.vcf /home/umcg-molgenis/NGS_RNA/
cp test/results/PlatinumSubset_NGS_RNA.expression.true.table /home/umcg-molgenis/NGS_RNA/
cp test/autotest_generate_template.sh ${workfolder}/generatedscripts/PlatinumSubset_NGS_RNA/generate_template.sh
cp test/PlatinumSubset_NGS_RNA.csv ${workfolder}/generatedscripts/PlatinumSubset_NGS_RNA/

cd ${workfolder}/generatedscripts/PlatinumSubset_NGS_RNA/

sh generate_template.sh 

cd scripts
perl -pi -e 's|module load \$ngsversion|EBROOTNGS_RNA=/groups/umcg-gaf/tmp04/tmp/NGS_RNA/|' *.sh  

sh submit.sh

cd ${workfolder}/projects/PlatinumSubset_NGS_RNA/run01/jobs/
perl -pi -e 's|--emitRefConfidence|-L 1:1-1200000 \\\n  --emitRefConfidence|' s*_GatkHaplotypeCallerGvcf_0.sh
perl -pi -e 's|-stand_emit_conf|-L 1:1-1200000 \\\n  -stand_emit_conf|' s*_GatkGenotypeGvcf_*.sh
perl -pi -e 's|cp|touch /groups/umcg-gaf//tmp04/tmp//PlatinumSubset_NGS_RNA/run01//MY_TEST_BAM_PROJECT_L1_None_1.fq_fastqc/Images/per_sequence_gc_content.png\n\t cp|' s*_FastQC_*.sh
perl -pi -e 's|--time=16:00:00|--time=05:59:00|' *.sh
perl -pi -e 's|--time=23:59:00|--time=05:59:00|' *.sh

sh submit.sh --qos=dev

count=0
minutes=0
while [ ! -f /groups/umcg-gaf/tmp04/projects/PlatinumSubset_NGS_RNA/run01/jobs/Autotest_0.sh.finished ]
do

        echo "not finished in $minutes minutes, sleeping for 1 minute"
        sleep 60
        minutes=$((minutes+1))

        count=$((count+1))
        if [ $count -eq 20 ]
        then
                echo "the test was not finished within 1 hour, let's kill it"
		echo -e "\n"
		for i in $(ls /groups/umcg-gaf/tmp04/projects/PlatinumSubset_NGS_RNA/run01/jobs/*.sh)
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
echo "Test succeeded!"
echo ""

head -2 /home/umcg-molgenis/output_NGS_RNA/vcfStats_RNA.txt
