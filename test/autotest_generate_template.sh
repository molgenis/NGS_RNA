#!/bin/bash


EBROOTNGS_RNA=/groups/umcg-gaf/tmp04/tmp/NGS_RNA/

HOST=$(hostname)
##Running script for checking the environment variables
sh ${EBROOTNGS_RNA}/checkEnvironment.sh ${HOST}

ENVIRONMENT=$(awk '{print $1}' ./environment_checks.txt)
TMPDIR=$(awk '{print $2}' ./environment_checks.txt)
GROUP=$(awk '{print $3}' ./environment_checks.txt)

PROJECT="PlatinumSubset_NGS_RNA"
RUNID="run01"

WORKDIR="/groups/${GROUP}/${TMPDIR}"
BUILD="b37" # b37, b38
SPECIES="homo_sapiens" # callithrix_jacchus, mus_musculus, homo_sapiens
PIPELINE="hisat" # hisat, lexogen

WORKFLOW=${EBROOTNGS_RNA}/workflow_${PIPELINE}.csv

if [ -f .compute.properties ];
then
     rm .compute.properties
fi

if [ -f ${GAF}/generatedscripts/${PROJECT}/out.csv  ];
then
	rm -rf ${GAF}/generatedscripts/${PROJECT}/out.csv
fi

perl ${EBROOTNGS_RNA}/convertParametersGitToMolgenis.pl ${EBROOTNGS_RNA}/parameters.csv > \
${WORKDIR}/generatedscripts/${PROJECT}/parameters.csv

perl ${EBROOTNGS_RNA}/convertParametersGitToMolgenis.pl ${EBROOTNGS_RNA}/parameters.${BUILD}.csv > \
${WORKDIR}/generatedscripts/${PROJECT}/parameters.${BUILD}.csv

perl ${EBROOTNGS_RNA}/convertParametersGitToMolgenis.pl ${EBROOTNGS_RNA}/parameters.${SPECIES}.csv > \
${WORKDIR}/generatedscripts/${PROJECT}/parameters.${SPECIES}.csv

perl ${EBROOTNGS_RNA}/convertParametersGitToMolgenis.pl ${EBROOTNGS_RNA}/parameters.${ENVIRONMENT}.csv > \
${WORKDIR}/generatedscripts/${PROJECT}/parameters.${ENVIRONMENT}.csv

module load Molgenis-Compute/v16.05.1-Java-1.8.0_45

sh ${EBROOTMOLGENISMINCOMPUTE}/molgenis_compute.sh \
-p ${WORKDIR}/generatedscripts/${PROJECT}/parameters.csv \
-p ${WORKDIR}/generatedscripts/${PROJECT}/parameters.${BUILD}.csv \
-p ${WORKDIR}/generatedscripts/${PROJECT}/parameters.${SPECIES}.csv \
-p ${WORKDIR}/generatedscripts/${PROJECT}/parameters.${ENVIRONMENT}.csv \
-p ${WORKDIR}/generatedscripts/${PROJECT}/${PROJECT}.csv \
-p ${EBROOTNGS_RNA}/chromosomes.${SPECIES}.csv \
-w ${EBROOTNGS_RNA}/create_external_samples_ngs_projects_workflow.csv \
-rundir ${WORKDIR}/generatedscripts/${PROJECT}/scripts \
--runid ${RUNID} \
--weave \
--generate \
-o "workflowpath=${WORKFLOW};outputdir=scripts/jobs;\
groupname=${GROUP};\
mainParameters=${WORKDIR}/generatedscripts/${PROJECT}/parameters.csv;\
ngsversion='NGS_RNA/3.2.4-Molgenis-Compute-v16.05.1-Java-1.8.0_45';\
worksheet=${WORKDIR}/generatedscripts/${PROJECT}/${PROJECT}.csv;\
parameters_build=${WORKDIR}/generatedscripts/${PROJECT}/parameters.${BUILD}.csv;\
parameters_species=${WORKDIR}/generatedscripts/${PROJECT}/parameters.${SPECIES}.csv;\
parameters_chromosomes=${EBROOTNGS_RNA}/chromosomes.${SPECIES}.csv;\
parameters_environment=${WORKDIR}/generatedscripts/${PROJECT}/parameters.${ENVIRONMENT}.csv;"

cd scripts
perl -pi -e 's|echo pwd|EBROOTNGS_RNA=/groups/umcg-gaf/tmp04/tmp/NGS_RNA/|' CreateExternSamplesProjects_0.sh
