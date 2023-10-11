set -o pipefail
#MOLGENIS walltime=24:00:00 nodes=1 cores=1 mem=6gb

#Parameter mapping
#string sampleMergedBam
#string tempDir
#string sampleConcordanceVcf
#string samtoolsVersion
#string python2Version
#string BCFtoolsVersion
#string project
#string indexSpecies
#string comonSnpsBed
#string groupname
#string tmpName
#string logsDir

module load  "${BCFtoolsVersion}"
module load "${python2Version}"
module load "${samtoolsVersion}"
module list

set -o pipefail

makeTmpDir "${sampleConcordanceVcf}"
tmpSampleConcordanceVcf=${MC_tmpFile}


	bcftools mpileup \
	-Ou -f "${indexSpecies}" \
	"${sampleMergedBam}" \
	-R "${comonSnpsBed}" \
	| bcftools call \
	-mv -Ob -o "${tmpSampleConcordanceVcf}"

	mv "${tmpSampleConcordanceVcf}" "${sampleConcordanceVcf}"
	echo "Finished!"
