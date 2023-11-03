set -o pipefail
#MOLGENIS walltime=23:59:00 mem=4gb ppn=4

#Parameter mapping
#string tempDir
#string tmpDataDir
#string project
#string ngsVersion
#string python2PlusVersion
#string intermediateDir
#string strandedness
#string rMATsOutputDir
#string annotationGtf
#string projectJobsDir
#string project
#string groupname
#string tmpName
#string logsDir

makeTmpDir "${intermediateDir}"
tmpintermediateDir=${MC_tmpFile}

module load "${ngsVersion}"
module load "${python2PlusVersion}"
module list

ZSCORE=3
DELTAPSY=0.2

echo "reformatting format_rMATS.py"
"${EBROOTNGS_RNA}/scripts/format_rMATS.py" \
-i "${rMATsOutputDir}/${project}/" \
-o "${tmpintermediateDir}${project}.rMATS.format.tsv"

# filter output
"${EBROOTNGS_RNA}/scripts/filter_rMATS.py" \
-i "${tmpintermediateDir}${project}.rMATS.format.tsv" \
-o "${tmpintermediateDir}${project}.rMATS.filtered.tsv" \
-d "${DELTAPSY}" \
-z "${ZSCORE}"

# convert to bed
"${EBROOTNGS_RNA}/scripts/convert_rMATS_to_bed.py" \
-i "${tmpintermediateDir}${project}.rMATS.filtered.tsv" \
-o "${tmpintermediateDir}${project}.rMATs.final.bed"

mv "${tmpintermediateDir}/${project}."* "${rMATsOutputDir}/${project}/"
echo "Created ${rMATsOutputDir}/${project}/${project}.rMATs.final.bed"
