#!/bin/bash

if module list | grep -o -P 'NGS_RNA(.+)'
then
	echo "RNA pipeline loaded, proceeding"
else
	echo "No RNA pipeline loaded, exiting"
	exit 1
fi

module list

host=$(hostname -s)
#environmentParameters="parameters_${host}"

function showHelp() {
	#
	# Display commandline help on STDOUT.
	#
	cat <<EOH
===============================================================================================================
Script to start the generation of the RNA pipeline, to analyse Diagnostic and research RNA data.
Usage:
	$(basename $0) OPTIONS
Options:
	-h   Show this help.
	-p   projectname
	-g   group (default=basename of ../../../ )
	-f   filePrefix (default=basename of this directory)
	-r   runID (default=run01)
	-t   tmpDirectory (default=basename of ../../ )
	-w   workdir (default= current dir, ${pwd)
	-c   createWorkflow (default=create_in-house_ngs_projects_workflow.csv, option "${EBROOTNGS_RNA}/create_external_samples_ngs_projects_workflow.csv")
	-o   pipeline (default=GD, options: "STAR", "hisat", "lexogen")
===============================================================================================================
EOH
	trap - EXIT
	exit 0
}


while getopts "t:g:w:f:p:r:c:o:h" opt;
do
	case $opt in
		h)
			showHelp;;
		t)
			tmpDirectory="${OPTARG}";;
		g)
			group="${OPTARG}";;
		w)
			workDir="${OPTARG}";;
		f)
			filePrefix="${OPTARG}";;
		p)
			project="${OPTARG}";;
		r)
			runID="${OPTARG}";;
		c)
			createWorkflow="${OPTARG}";;
		o)
			pipeline="${OPTARG}";;
	esac
done

if [[ -z "${tmpDirectory:-}" ]]; then tmpDirectory=$(basename $(cd ../../../ && pwd )) ; fi ; echo "tmpDirectory=${tmpDirectory}"
if [[ -z "${group:-}" ]]; then group=$(basename $(cd ../../../../ && pwd )) ; fi ; echo "group=${group}"
if [[ -z "${workDir:-}" ]]; then workDir=$( pwd ) ; fi ; echo "workDir=${workDir}"
if [[ -z "${filePrefix:-}" ]]; then filePrefix=$(basename $(pwd)) ; fi ; echo "filePrefix=${filePrefix}"
if [[ -z "${runID:-}" ]]; then runID="run01" ; fi ; echo "runID=${runID}"
if [[ -z "${project:-}" ]]; then project="${filePrefix}" ; fi ; echo "project=${project}"
if [[ -z "${createWorkflow:-}" ]]; then createWorkflow="${EBROOTNGS_RNA}/create_in-house_ngs_projects_workflow.csv" ; fi ; echo createWorkflow="${EBROOTNGS_RNA}/create_in-house_ngs_projects_workflow.csv"
if [[ -z "${pipeline:-}" ]]; then pipeline="GD" ; fi ; echo "pipeline=GD"

if [ ! -d "/groups/${group}" ]
then
	echo "Group directory /groups/${group} DOES NOT exists. use -g GROUP to set the group manually"
	exit 1
fi

build="GRCh37" # GRCh37, HG19
species="homo_sapiens"
workflow="${EBROOTNGS_RNA}/workflow_${pipeline}.csv"
customParameters="${EBROOTNGS_RNA}/parameters.${host}.csv"

if [ -f .compute.properties ];
then
	rm .compute.properties
fi

perl ${EBROOTNGS_RNA}/convertParametersGitToMolgenis.pl "${EBROOTNGS_RNA}/parameters.${species}.${build}.csv" > \
"${workDir}/parameters.${species}.${build}.csv"

perl ${EBROOTNGS_RNA}/convertParametersGitToMolgenis.pl "${customParameters}" > \
"${workDir}/parameters.${host}.csv"


sh "${EBROOTMOLGENISMINCOMPUTE}/molgenis_compute.sh" \
-p "${workDir}/parameters.${host}.csv" \
-p "${workDir}/parameters.${species}.${build}.csv" \
-p "${workDir}/${project}.csv" \
-p "${EBROOTNGS_RNA}/chromosomes.${species}.csv" \
-w "${createWorkflow}" \
-rundir "${workDir}/scripts" \
--runid "${runID}" \
--weave \
--generate \
-o "workflowpath=${workflow};outputdir=scripts/jobs;\
groupname=${group};\
ngsVersion=$(module list | grep -o -P 'NGS_RNA(.+)');\
worksheet=${workDir}/${project}.csv;\
parameters_build=${workDir}/parameters.${species}.${build}.csv;\
parameters_chromosomes=${EBROOTNGS_RNA}/chromosomes.${species}.csv;\
parameters_environment=${workDir}/parameters.${host}.csv"
