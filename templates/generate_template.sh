#!/bin/bash

module list

thisDir=$(pwd)

ENVIRONMENT=$(hostname -s)

if [[ -z "${TMPDIR:-}" ]]; then TMPDIR=$(basename $(cd ../../ && pwd )) ; fi ; echo "TMPDIR=${TMPDIR}"
if [[ -z "${GROUP:-}" ]]; then GROUP=$(basename $(cd ../../../ && pwd )) ; fi ; echo "GROUP=${GROUP}"
if [[ -z "${WORKDIR:-}" ]]; then WORKDIR="/groups/${GROUP}/${TMPDIR}" ; fi ; echo "WORKDIR=${WORKDIR}"
if [[ -z "${FILEPREFIX:-}" ]]; then FILEPREFIX=$(basename $(pwd )) ; fi ; echo "FILEPREFIX=${FILEPREFIX}"
if [[ -z "${RUNID:-}" ]]; then RUNID="run01" ; fi ; echo "RUNID=${RUNID}"
if [[ -z "${PROJECT:-}" ]]; then PROJECT="${FILEPREFIX}" ; fi ; echo "PROJECT=${PROJECT}"

BUILD="GRCh37" # GRCh37, GRCh38
SPECIES="homo_sapiens" # callithrix_jacchus, mus_musculus, homo_sapiens
PIPELINE="STAR" # hisat, lexogen

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

sh ${EBROOTMOLGENISMINCOMPUTE}/molgenis_compute.sh \
-p ${WORKDIR}/generatedscripts/${PROJECT}/parameters.csv \
-p ${WORKDIR}/generatedscripts/${PROJECT}/parameters.${BUILD}.csv \
-p ${WORKDIR}/generatedscripts/${PROJECT}/parameters.${SPECIES}.csv \
-p ${WORKDIR}/generatedscripts/${PROJECT}/parameters.${ENVIRONMENT}.csv \
-p ${WORKDIR}/generatedscripts/${PROJECT}/${PROJECT}.csv \
-p ${EBROOTNGS_RNA}/chromosomes.${SPECIES}.csv \
-w ${EBROOTNGS_RNA}/create_in-house_ngs_projects_workflow.csv \
-rundir ${WORKDIR}/generatedscripts/${PROJECT}/scripts \
--runid ${RUNID} \
--weave \
--generate \
-o "workflowpath=${WORKFLOW};outputdir=scripts/jobs;\
groupname=${GROUP};\
mainParameters=${WORKDIR}/generatedscripts/${PROJECT}/parameters.csv;\
ngsversion=$(module list | grep -o -P 'NGS_RNA(.+)');\
worksheet=${WORKDIR}/generatedscripts/${PROJECT}/${PROJECT}.csv;\
parameters_build=${WORKDIR}/generatedscripts/${PROJECT}/parameters.${BUILD}.csv;\
parameters_species=${WORKDIR}/generatedscripts/${PROJECT}/parameters.${SPECIES}.csv;\
parameters_chromosomes=${EBROOTNGS_RNA}/chromosomes.${SPECIES}.csv;\
parameters_environment=${WORKDIR}/generatedscripts/${PROJECT}/parameters.${ENVIRONMENT}.csv;"
