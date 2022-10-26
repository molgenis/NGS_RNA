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

makeTmpDir "${intermediateDir}"
tmpintermediateDir=${MC_tmpFile}

#Load module
module load "${leafcutterVersion}"
module load "${python2Version}"
module list

	"${EBROOTLEAFCUTTER}/scripts/leafcutter_ds.R" \
	-e "${annotationTxt}" \
	--num_threads 4 \
	-i 1 \
	-g 1 \
	-c 3 \
	-o "${tmpintermediateDir}/${externalSampleID}.leafcutter.outlier" \
	"${intermediateDir}/${project}_leafcutter_cluster_regtools_perind_numers.counts.gz" \
	"${intermediateDir}/${externalSampleID}.SJ.design.tsv"

	Rscript "${EBROOTLEAFCUTTER}/scripts/ds_plots.R" \
	-e "${gencodeHg19AllExons}" \
	-o "${tmpintermediateDir}/${externalSampleID}_leafcutter_ds" \
	"${intermediateDir}/${project}_leafcutter_cluster_regtools_perind_numers.counts.gz" \
	"${intermediateDir}/${externalSampleID}.SJ.design.tsv" \
	"${tmpintermediateDir}/${externalSampleID}.leafcutter.outlier_cluster_significance.txt" \
	-f 0.05

	mv "${tmpintermediateDir}/${externalSampleID}"* "${intermediateDir}"
