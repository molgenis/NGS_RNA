#MOLGENIS nodes=1 ppn=4 mem=4gb walltime=00:59:00

#Parameter mapping
#string RPlusVersion
#string intermediateDir
#string project
#string groupname
#string tmpName
#string logsDir
#string projectRawtmpDataDir
#string projectQcDir

module load "${RPlusVersion}"
module list

Rscript design.R

