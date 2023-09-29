set -o pipefail
#MOLGENIS nodes=1 ppn=1 mem=34gb walltime=05:00:00

#Parameter mapping
#string intermediateDir
#string externalSampleID
#string project
#string logsDir
#string projectJobsDir
#string strandedness
#string annotationGtf
#string annotationTxt
#string gencodeHg19AllExons
#string sampleMergedBamExt
#string leafcutterVersion
#string python2Version
#string sifDir

makeTmpDir "${intermediateDir}"
tmpintermediateDir=${MC_tmpFile}

#Load module


        singularity exec --bind "/groups/:/groups,/apps/:/apps" "${sifDir}/leafcutter_0.2.10.sif" \
	/app/leafcutter/scripts/leafcutter_ds.R \
	-e "${annotationTxt}" \
	--num_threads 4 \
	-i 1 \
	-g 1 \
	-c 3 \
	-o "${tmpintermediateDir}/${externalSampleID}.leafcutter.outlier" \
	"${intermediateDir}/${project}_leafcutter_cluster_regtools_perind_numers.counts.gz" \
	"${intermediateDir}/${externalSampleID}.SJ.design.tsv"

	mv "${tmpintermediateDir}/${externalSampleID}"* "${intermediateDir}"
