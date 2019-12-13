#!/bin/bash

module load NGS_RNA/3.3.0
module list

ENVIRONMENT=$(hostname -s)
TMPDIR=$(basename $(cd ../../ && pwd ))
group=$(basename $(cd ../../../ && pwd ))

workDir="/groups/${group}/${TMPDIR}"
PIPELINE="hisat" # hisat, lexogen

#defaults
BUILD="GRCh37"
SPECIESS="homo_sapiens"
PROJECT=${filePrefix}

function showHelp() {
	#
	# Display commandline help on STDOUT.
	#
	cat <<EOH
===============================================================================================================
Script to copy (sync) data from a succesfully finished analysis project from tmp to prm storage.
Usage:
	$(basename $0) OPTIONS
Options:
	-h   Show this help.
	-a   sampleType (DNA or RNA) (default=DNA)
	-g   group (default=basename of ../../../ )
	-f   filePrefix (default=basename of this directory)
	-r   runID (default=run01)
	-t   tmpDirectory (default=basename of ../../ )
	-w   workdir (default=/groups/\${group}/\${tmpDirectory})
===============================================================================================================
EOH
	trap - EXIT
	exit 0
}


while getopts "t:g:w:f:r:h" opt;
do
	case $opt in h)showHelp;; t)tmpDirectory="${OPTARG}";; g)group="${OPTARG}";; w)workDir="${OPTARG}";; f)filePrefix="${OPTARG}";; r)runID="${OPTARG}";;
	esac
done

if [[ -z "${tmpDirectory:-}" ]]; then tmpDirectory=$(basename $(cd ../../ && pwd )) ; fi ; echo "tmpDirectory=${tmpDirectory}"
if [[ -z "${group:-}" ]]; then group=$(basename $(cd ../../../ && pwd )) ; fi ; echo "group=${group}"
if [[ -z "${workDir:-}" ]]; then workDir="/groups/${group}/${tmpDirectory}" ; fi ; echo "workDir=${workDir}"
if [[ -z "${filePrefix:-}" ]]; then filePrefix=$(basename $(pwd )) ; fi ; echo "filePrefix=${filePrefix}"
if [[ -z "${runID:-}" ]]; then runID="run01" ; fi ; echo "runID=${runID}"

genScripts="${workDir}/generatedscripts/${filePrefix}/"
samplesheet="${genScripts}/${filePrefix}.csv" ; mac2unix "${samplesheet}"

python "${EBROOTNGS_RNA}/scripts/sampleSheetChecker.py" "${samplesheet}"
if [ -f "${samplesheet}.temp" ]
then
        mv "${samplesheet}.temp" "${samplesheet}"
fi

## get only uniq lines and removing txt.tmp file
for i in $(ls *.txt.tmp); do cat "${i}" | sort -u > ${i%.*} ; rm "${i}" ;done


if [ -s build.txt ]; then BUILD=$(cat build.txt);fi
if [ -s species.txt ];then SPECIES=$(cat species.txt); fi
#if [ -s project.txt ];then PROJECT=$(cat project.txt); fi

WORKFLOW=${EBROOTNGS_RNA}/workflow_${PIPELINE}.csv

if [ -f .compute.properties ];
then
     rm .compute.properties
fi

if [ -f ${GAF}/generatedscripts/${PROJECT}/out.csv  ];
then
	rm -rf ${GAF}/generatedscripts/${PROJECT}/out.csv
fi

echo "BUILD ${BUILD}"
echo "SPECIES ${SPECIES}"
echo "ENVIRONMENT ${ENVIRONMENT}"


perl ${EBROOTNGS_RNA}/convertParametersGitToMolgenis.pl ${EBROOTNGS_RNA}/parameters.csv > \
${workDir}/generatedscripts/${PROJECT}/parameters.csv

perl ${EBROOTNGS_RNA}/convertParametersGitToMolgenis.pl ${EBROOTNGS_RNA}/parameters.${BUILD}.csv > \
${workDir}/generatedscripts/${PROJECT}/parameters.${BUILD}.csv

perl ${EBROOTNGS_RNA}/convertParametersGitToMolgenis.pl ${EBROOTNGS_RNA}/parameters.${SPECIESS}.csv > \
${workDir}/generatedscripts/${PROJECT}/parameters.${SPECIESS}.csv

perl ${EBROOTNGS_RNA}/convertParametersGitToMolgenis.pl ${EBROOTNGS_RNA}/parameters.${ENVIRONMENT}.csv > \
${workDir}/generatedscripts/${PROJECT}/parameters.${ENVIRONMENT}.csv

sh ${EBROOTMOLGENISMINCOMPUTE}/molgenis_compute.sh \
-p ${workDir}/generatedscripts/${PROJECT}/parameters.csv \
-p ${workDir}/generatedscripts/${PROJECT}/parameters.${BUILD}.csv \
-p ${workDir}/generatedscripts/${PROJECT}/parameters.${SPECIESS}.csv \
-p ${workDir}/generatedscripts/${PROJECT}/parameters.${ENVIRONMENT}.csv \
-p ${workDir}/generatedscripts/${PROJECT}/${PROJECT}.csv \
-p ${EBROOTNGS_RNA}/chromosomes.${SPECIESS}.csv \
-w ${EBROOTNGS_RNA}/create_in-house_ngs_projects_workflow.csv \
-rundir ${workDir}/generatedscripts/${PROJECT}/scripts \
--runid ${runID} \
--weave \
--generate \
-o "workflowpath=${WORKFLOW};outputdir=scripts/jobs;\
groupname=${group};\
mainParameters=${workDir}/generatedscripts/${PROJECT}/parameters.csv;\
ngsversion=$(module list | grep -o -P 'NGS_RNA(.+)');\
worksheet=${workDir}/generatedscripts/${PROJECT}/${PROJECT}.csv;\
parameters_build=${workDir}/generatedscripts/${PROJECT}/parameters.${BUILD}.csv;\
parameters_species=${workDir}/generatedscripts/${PROJECT}/parameters.${SPECIESS}.csv;\
parameters_chromosomes=${EBROOTNGS_RNA}/chromosomes.${SPECIESS}.csv;\
parameters_environment=${workDir}/generatedscripts/${PROJECT}/parameters.${ENVIRONMENT}.csv;"
