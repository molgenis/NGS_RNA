set -o pipefail
#MOLGENIS walltime=23:59:00 nodes=1 cores=1 mem=4gb

#Parameter mapping

#string projectResultsDir
#string project
#string logsDir
#string intermediateDir
#string projectLogsDir
#string projectQcDir
#string projectJobsDir
#string projectHTseqExpressionTable
#string annotationGtf
#string indexFileID
#string seqType
#string jdkVersion
#string fastqcVersion
#string samtoolsVersion
#string RVersion
#string picardVersion
#string starVersion
#string htseqVersion
#string pythonVersion
#string gatkVersion
#string projectBatchGenotypedVIPPrefix
#string projectBatchGenotypedVariantCalls
#string ensembleReleaseVersion
#string trimGaloreVersion
#string rSeQCVersion
#string leafcutterVersion
#string multiqcVersion
#string rMATsVersion
#string outriderVersion
#string groupname
#string tmpName
#string logsDir

# Make result directories
mkdir -p "${projectResultsDir}/alignment"
mkdir -p "${projectResultsDir}/fastqc"
mkdir -p "${projectResultsDir}/variants/concordance"
mkdir -p "${projectResultsDir}/star_sj"
mkdir -p "${projectResultsDir}/qcmetrics"

# Copy project csv file to project results directory

	rsync -av "${projectJobsDir}/${project}.csv" "${projectResultsDir}"

# Copy fastQC output to results directory

	rsync -av "${projectQcDir}/"* "${projectResultsDir}/fastqc/"

# Copy BAM plus index plus md5 sum to results directory

	rsync -avL "${intermediateDir}"/*.sorted.merged.bam "${projectResultsDir}/alignment/"
	rsync -avL "${intermediateDir}"/*.sorted.merged.bam.{md5sum,bai,bai.md5sum} "${projectResultsDir}/alignment/"

# copy qc metrics to qcmetrics folder

	rsync -av "${intermediateDir}"/*.quality_by_cycle_metrics "${projectResultsDir}/qcmetrics/"
	rsync -av "${intermediateDir}"/*.quality_by_cycle.pdf "${projectResultsDir}/qcmetrics/"
	rsync -av "${intermediateDir}"/*.quality_distribution.pdf "${projectResultsDir}/qcmetrics/"
	rsync -av "${intermediateDir}"/*.quality_distribution_metrics "${projectResultsDir}/qcmetrics/"
	rsync -av "${intermediateDir}"/*.base_distribution_by_cycle.pdf "${projectResultsDir}/qcmetrics/"
	rsync -av "${intermediateDir}"/*.base_distribution_by_cycle_metrics "${projectResultsDir}/qcmetrics/"
	rsync -av "${intermediateDir}"/*.alignment_summary_metrics "${projectResultsDir}/qcmetrics/"
	rsync -av "${intermediateDir}"/*.flagstat "${projectResultsDir}/qcmetrics/"
	rsync -av "${intermediateDir}"/*.idxstats "${projectResultsDir}/qcmetrics/"
	rsync -av "${intermediateDir}"/*.collectrnaseqmetrics "${projectResultsDir}/qcmetrics/"

	if [[ "${seqType}" == "PE" ]]
	then
		rsync -av "${intermediateDir}"/*.insert_size_metrics "${projectResultsDir}/qcmetrics/"
	else
		echo "Skip insertSizeMetrics. seqType is: ${seqType}"
	fi

# Copy QC images and report to results directory

	rsync -av "${intermediateDir}"/*.collectrnaseqmetrics.pdf "${projectResultsDir}/qcmetrics/"

# Copy variant vcfs.

	rsync -av "${projectBatchGenotypedVariantCalls}"* "${projectResultsDir}/variants/"
	rsync -av "${intermediateDir}/"*".concordance.vcf"* "${projectResultsDir}/variants/concordance/"

# Copy STAR annotated SpliceJunctions
	rsync -av "${intermediateDir}/"*.SJ.* "${projectResultsDir}/star_sj/"
#only available with PE
	if [[ "${seqType}" == "PE" ]]
	then
		rsync -av "${intermediateDir}"/*.insert_size_* "${projectResultsDir}/qcmetrics/"
	else
		echo "Skip insertSizeMetrics. seqType is: ${seqType}"
	fi

	DESeq2data=$(find "${projectJobsDir}" -maxdepth 1 -mindepth 1 -type f -name "*DE*")
	LeafcutterData=$(find "${projectJobsDir}" -maxdepth 1 -mindepth 1 -type f -name "*Leafcutter*")
	VIPData=$(find "${projectJobsDir}" -maxdepth 1 -mindepth 1 -type f -name "*VIP*")
	HTSeqData=$(find "${projectJobsDir}" -maxdepth 1 -mindepth 1 -type f -name "*HTSeq*")
	
	OutriderData=$(find "${projectJobsDir}" -maxdepth 1 -mindepth 1 -type f -name "*OUTRIDER*")
	rMatsData=$(find "${projectJobsDir}" -maxdepth 1 -mindepth 1 -type f -name "*rMats*")

	if [[ "${DESeq2data}" -eq '0' ]]
	then
		echo "no DESeq2 data available"
	else
		# Make research results directories
		mkdir -p "${projectResultsDir}/expression"
		mkdir -p "${projectResultsDir}/expression/deseq2"
		# copy Deseq2 results to results directory
		mkdir -p "${projectResultsDir}/expression"
		rsync -av "${intermediateDir}"/*deseq2_* "${projectResultsDir}/expression/deseq2/"
		rsync -av "${intermediateDir}"/*design.csv "${projectResultsDir}/expression/deseq2/"
		rsync -av "${intermediateDir}"/*.svg "${projectResultsDir}/expression/deseq2/"
	fi

	if [[ "${LeafcutterData}" -eq '0' ]]
	then
		echo "no Leafcutter Data data available"
	else
		# Copy leafcutter
		mkdir -p "${projectResultsDir}/leafcutter"
		# shellcheck source=/dev/null
		source "${intermediateDir}/conditionCount.txt"
		if [[ "${conditionCount}" == 2 ]]
		then
			rsync -av "${intermediateDir}"/*leafcutter_ds* "${projectResultsDir}/leafcutter/"
		else
			rsync -av "${intermediateDir}"/*leafcutter.outlier* "${projectResultsDir}/leafcutter/"
		fi
	fi

	if [[ "${HTSeqData}" -eq '0' ]]
	then
		echo "no HTSeq Data data available"
	else
		# copy GeneCounts to results directory
		rsync -av "${intermediateDir}"/*.counts.txt "${projectResultsDir}/expression/"
		rsync -av "${annotationGtf}" "${projectResultsDir}/expression/"
		rsync -av "${projectHTseqExpressionTable}" "${projectResultsDir}/expression/"
	fi

	if [[ "${VIPData}" -eq '0' ]]
	then
		echo "no VIP Data data available"
	else
		# Copy VIP vcf
		mkdir -p "${projectResultsDir}/variants/vip"
		rsync -av "${projectBatchGenotypedVIPPrefix}"* "${projectResultsDir}/variants/vip/"
	fi

echo "pipeline is finished"

runNumber=$(basename "$(dirname "${projectResultsDir}")")

if [[ -f "${logsDir}/${project}/${runNumber}.pipeline.started" ]]
then
	mv "${logsDir}/${project}/${runNumber}.pipeline".{started,finished}
fi

touch "${logsDir}/${project}/${runNumber}.pipeline.finished"

echo "finished: $(date +%FT%T%z)" >> "${logsDir}/${project}/${runNumber}.pipeline.totalRuntime"
rm -f "${logsDir}/${project}/${runNumber}.pipeline.failed"
echo "${logsDir}/${project}/${runNumber}.pipeline.finished is created"


touch pipeline.finished

# write README.txt file

cat > "${projectResultsDir}"/README.txt <<'endmsg'

Morris A. Swertz
University of Groningen, University Medical Center Groningen, Genomics Coordination Center, Groningen, the Netherlands
University of Groningen, University Medical Center Groningen, Department of Genetics, Groningen, the Netherlands

Description of the different steps used in the RNA analysis pipeline

Gene expression quantification
The trimmed fastQ files using ${trimGaloreVersion} where aligned to build ${indexFileID} ensembleRelease ${ensembleReleaseVersion}
reference genome using ${starVersion} [1] with default settings. Before gene quantification
${samtoolsVersion} [2] was used to sort the aligned reads.
The gene level quantification was performed by HTSeq-count ${htseqVersion} [3] using --mode=union,
Ensembl version ${ensembleReleaseVersion} was used as gene annotation database which is included
in folder expression/. Deseq2 was used for differential expression analysis on STAR bams.
For experimental group conditions the 'conditions' column in the samplesheet was used the
distinct groups within the samples. and can be filtered using a 'geneOfIterest' column in the samplesheet.

As an alternative Outrider ${outriderVersion} [8] is used for aberrant gene expression. Outliers genes are identified a
read counts that significantly deviate. Furthermore, OUTRIDER provides useful plotting functions to
analyze and visualize the results.Output can be filtered using a 'geneOfIterest' column in the samplesheet,
alternatively the top 3 calles are visualized.

Calculate QC metrics on raw and aligned data
Quality control (QC) metrics are calculated for the raw sequencing data. This is done using
the tool FastQC ${fastqcVersion} [4]. QC metrics are calculated for the aligned reads using
Picard-tools ${picardVersion} [5] CollectRnaSeqMetrics, MarkDuplicates, CollectInsertSize-
Metrics and ${samtoolsVersion} flagstat.

Splicing events calling
LeafCutter ${leafcutterVersion}, RMats ${rMATsVersion} [9] and STAR ${starVersion} are used
to call splice variants.
The output is annotated and filtered on significance.

GATK variant calling
Variant calling was done using GATK. First, we use a GATK tool called SplitNCigarReads
developed specially for RNAseq, which splits reads into exon segments (getting rid of Ns
but maintaining grouping information) and hard-clip any sequences overhanging into the intronic regions.
The variant calling it self was done using HaplotypeCaller in GVCF mode. All  samples are
then jointly genotyped by taking the gVCFs produced earlier and running GenotypeGVCFs
on all of them together to create a set of raw SNP and indel calls. [6]

Results directory
This directory contains the following data and subfolders:

- alignment: merged BAM file with index, md5sums and alignment statistics (.Log.final.out)
- expression: textfiles with gene level quantification per sample and per project.
- fastqc: FastQC output
- qcmetrics: Multiple qcMetrics and images generated with Picard-tools or SAMTools Flagstat.
- leafcutter: Leafcutter and RegTools output files
- rmats: rMATs output files per sample.
- expression/Deseq2: Deseq2 was used for differential expression analysis.
- multiqc_data: Combined MultiQC tables used for multiqc report html.
- star_sj: Annotated and filter STAR splice junctions per sample.
- outrider: DROP Outrider abberant gene expression per sample.
- variants: Variants calls using GATK.
- rawdata: raw sequence file in the form of a gzipped fastq file (.fq.gz)

The root of the results directory contains the final QC report, README.txt and the samplesheet which
form the basis for this analysis.

Used toolversions:

${multiqcVersion}
${fastqcVersion}
${samtoolsVersion}
${RVersion}
${trimGaloreVersion}
${picardVersion}
${htseqVersion}
${pythonVersion}
${gatkVersion}
${rSeQCVersion}
${starVersion}
${leafcutterVersion}
${rMATsVersion}
${outriderVersion}

1. Alexander Dobin  1 , Carrie A Davis, Felix Schlesinger, Jorg Drenkow, Chris Zaleski,
	Sonali Jha, Philippe Batut, Mark Chaisson, Thomas R Gingeras: STAR: ultrafast universal RNA-seq aligner
	2013 Jan 1;29(1):15-21.  doi: 10.1093/bioinformatics/bts635.  Epub 2012 Oct 25.
2. Li H, Handsaker B, Wysoker A, Fennell T, Ruan J, Homer N, Marth G, Abecasis G, Durbin R,
	Subgroup 1000 Genome Project Data Processing: The Sequence Alignment/Map format and SAMtools.
	Bioinforma 2009, 25 (16):2078–2079.
3. Anders S, Pyl PT, Huber W: HTSeq – A Python framework to work with high-throughput sequencing data
	HTSeq – A Python framework to work with high-throughput sequencing data. 2014:0–5.
4. Andrews, S. (2010). FastQC a Quality Control Tool for High Throughput Sequence Data [Online].
	Available online at: http://www.bioinformatics.babraham.ac.uk/projects/fastqc/ ${samtoolsVersion}
5. Picard Sourceforge Web site. http://picard.sourceforge.net/ ${picardVersion}
6. The Genome Analysis Toolkit: a MapReduce framework for analyzing next-generation DNA sequencing data.
	McKenna A et al.2010 GENOME RESEARCH 20:1297-303, Version: ${gatkVersion}
7. Li YI, Knowles DA, Humphrey J, et al. Annotation-free quantification of RNA splicing using LeafCutter.
	Nat Genet. 2018;50(1):151-158. doi:10.1038/s41588-017-0004-9
8. Brechtmann F, Mertes C, Matusevičiūtė A, Yépez VA, Avsec Ž, Herzog M, Bader DM, Prokisch H, Gagneur J (2018).
	OUTRIDER: A Statistical Method for Detecting Aberrantly Expressed Genes in RNA Sequencing Data.
	The American Journal of Human Genetics, 103, 907 - 917. ISSN 0002-9297, doi: 10.1016/j.ajhg.2018.10.025.
9. Shen S., Park JW., Lu ZX., Lin L., Henry MD., Wu YN., Zhou Q., Xing Y.
	rMATS: Robust and Flexible Detection of Differential Alternative Splicing from Replicate RNA-Seq Data.
	PNAS, 111(51):E5593-601. doi: 10.1073/pnas.1419161111
endmsg

