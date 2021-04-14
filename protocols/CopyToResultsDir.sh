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
#string TrimGaloreVersion
#string samtoolsVersion
#string RVersion
#string picardVersion
#string htseqVersion
#string pythonVersion
#string gatkVersion
#string RSeQCVersion
#string starVersion
#string leafcutterVersion
#string multiqcVersion
#string ensembleReleaseVersion
#string groupname
#string tmpName
#string logsDir

# Change permissions

umask 0007

# Make result directories
mkdir -p "${projectResultsDir}/alignment"
mkdir -p "${projectResultsDir}/fastqc"
mkdir -p "${projectResultsDir}/expression"
mkdir -p "${projectResultsDir}/expression/perSampleExpression"
mkdir -p "${projectResultsDir}/expression/expressionTable"
mkdir -p "${projectResultsDir}/expression/deseq2"
mkdir -p "${projectResultsDir}/variants"
mkdir -p "${projectResultsDir}/leafcutter"
mkdir -p "${projectResultsDir}/qcmetrics"

# Copy project csv file to project results directory

cp "${projectJobsDir}/${project}.csv" "${projectResultsDir}"

# Copy fastQC output to results directory

	cp "${projectQcDir}/"* "${projectResultsDir}/fastqc/"

# Copy BAM plus index plus md5 sum to results directory

usedWorkflow=$(basename ${workflow})

	cp "${intermediateDir}"/*.sorted.merged.bam "${projectResultsDir}/alignment"
        cp "${intermediateDir}"/*.sorted.merged.bam.md5 "${projectResultsDir}/alignment"
        cp "${intermediateDir}"/*.sorted.merged.bai "${projectResultsDir}/alignment"
        cp "${intermediateDir}"/*.sorted.merged.bai.md5 "${projectResultsDir}/alignment"

# copy qc metrics to qcmetrics folder

	cp "${intermediateDir}"/*.quality_by_cycle_metrics "${projectResultsDir}/qcmetrics"
	cp "${intermediateDir}"/*.quality_by_cycle.pdf "${projectResultsDir}/qcmetrics"
	cp "${intermediateDir}"/*.quality_distribution.pdf "${projectResultsDir}/qcmetrics"
	cp "${intermediateDir}"/*.quality_distribution_metrics "${projectResultsDir}/qcmetrics"
	cp "${intermediateDir}"/*.base_distribution_by_cycle.pdf "${projectResultsDir}/qcmetrics" 
	cp "${intermediateDir}"/*.base_distribution_by_cycle_metrics "${projectResultsDir}/qcmetrics"
	cp "${intermediateDir}"/*.alignment_summary_metrics "${projectResultsDir}/qcmetrics"
        cp "${intermediateDir}"/*.flagstat "${projectResultsDir}/qcmetrics"
	cp "${intermediateDir}"/*.idxstats "${projectResultsDir}/qcmetrics"
	cp "${intermediateDir}"/*.mdupmetrics "${projectResultsDir}/qcmetrics"
	cp "${intermediateDir}"/*.collectrnaseqmetrics "${projectResultsDir}/qcmetrics"

	if [ "${seqType}" == "PE" ]
        then
		cp "${intermediateDir}"/*.insert_size_metrics "${projectResultsDir}/qcmetrics"
	else
		echo "Skip insertSizeMetrics. seqType is: ${seqType}"
	fi

#copy variant to results directory.

	cp "${intermediateDir}/${project}.variant.calls.genotyped.vcf" "${projectResultsDir}/variants/"
	cp "${intermediateDir}/${project}.variant.calls.genotyped.vcf.md5" "${projectResultsDir}/variants/"

# copy GeneCounts to results directory

	cp "${intermediateDir}"/*.counts.txt "${projectResultsDir}/expression/perSampleExpression"
	cp "${projectHTseqExpressionTable}" "${projectResultsDir}/expression/expressionTable"
	cp "${annotationGtf}" "${projectResultsDir}/expression/"

	cp "${intermediateDir}/deseq2_"* "${projectResultsDir}/expression/deseq2/"
	cp "${intermediateDir}/metadata.csv" "${projectResultsDir}/expression/deseq2/"
	cp "${intermediateDir}/design.txt" "${projectResultsDir}/expression/deseq2/"
	cp "${intermediateDir}/pca_deseq2"* "${projectResultsDir}/expression/deseq2/"
	cp "${intermediateDir}/volcano_plot_"* "${projectResultsDir}/expression/deseq2/"

# Copy QC images and report to results directory

	cp "${intermediateDir}/"*".collectrnaseqmetrics.pdf" "${projectResultsDir}/qcmetrics"

# Copy leafcutter
	cp "${intermediateDir}/leafcutter_"* "${projectResultsDir}/leafcutter/"
	cp "${intermediateDir}/${project}"*"_perind_"* "${projectResultsDir}/leafcutter/"

#only available with PE
	if [ "${seqType}" == "PE" ]
	then
		cp "${intermediateDir}/"*".insert_size_"* "${projectResultsDir}/qcmetrics"
	else
                echo "Skip insertSizeMetrics. seqType is: ${seqType}"
	fi


# write README.txt file

cat > "${projectResultsDir}"/README.txt <<'endmsg'

Morris A. Swertz
University of Groningen, University Medical Center Groningen, Genomics Coordination Center, Groningen, the Netherlands
University of Groningen, University Medical Center Groningen, Department of Genetics, Groningen, the Netherlands

Description of the different steps used in the RNA analysis pipeline

Gene expression quantification
The trimmed fastQ files using ${TrimGaloreVersion} where aligned to build ${indexFileID} ensembleRelease ${ensembleReleaseVersion} 
reference genome using ${starVersion} [1] with default settings. Before gene quantification 
${samtoolsVersion} [2] was used to sort the aligned reads. 
The gene level quantification was performed by HTSeq-count ${htseqVersion} [3] using --mode=union, 
Ensembl version ${ensembleReleaseVersion} was used as gene annotation database which is included
in folder expression/. Deseq2 was used for differential expression analysis on STAR bams.
For experimental group conditions the 'condition' column in the samplesheet was used the 
distinct groups within the samples. 

Calculate QC metrics on raw and aligned data
Quality control (QC) metrics are calculated for the raw sequencing data. This is done using 
the tool FastQC ${fastqcVersion} [4]. QC metrics are calculated for the aligned reads using 
Picard-tools ${picardVersion} [5] CollectRnaSeqMetrics, MarkDuplicates, CollectInsertSize-
Metrics and ${samtoolsVersion} flagstat.

Splicing event calling using LeafCutter
Leafcutter quantifies RNA splicing variation detection.

GATK variant calling
Variant calling was done using GATK. First, we use a GATK tool called SplitNCigarReads
developed specially for RNAseq, which splits reads into exon segments (getting rid of Ns
but maintaining grouping information) and hard-clip any sequences overhanging into the intronic regions.
The variant calling it self was done using HaplotypeCaller in GVCF mode. All  samples are 
then jointly genotyped by taking the gVCFs produced earlier and running GenotypeGVCFs 
on all of them together to create a set of raw SNP and indel calls. [6]

Results archive
The zipped archive contains the following data and subfolders:

- alignment: merged BAM file with index, md5sums and alignment statistics (.Log.final.out)
- expression: textfiles with gene level quantification per sample and per project. 
- fastqc: FastQC output
- qcmetrics: Multiple qcMetrics and images generated with Picard-tools or SAMTools Flagstat.
- leafcutter: Leafcutter and RegTools output files.
- multiqc_data: Combined MultiQC tables used for multiqc report html.
- variants: Variants calls using GATK. (optional)
- rawdata: raw sequence file in the form of a gzipped fastq file (.fq.gz)

The root of the results directory contains the final QC report, README.txt and the samplesheet which 
form the basis for this analysis. 

Used toolversions:

${multiqcVersion}
${fastqcVersion}
${samtoolsVersion}
${RVersion}
${TrimGaloreVersion}
${picardVersion}
${htseqVersion}
${pythonVersion}
${gatkVersion}
${RSeQCVersion}
${starVersion}
${leafcutterVersion}


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

endmsg

# Create zip file for all "small text" files

cd "${projectResultsDir}"

zip -gr "${projectResultsDir}/${project}.zip" fastqc
zip -g  "${projectResultsDir}/${project}.zip" "${project}.csv"
zip -gr "${projectResultsDir}/${project}.zip" qcmetrics
zip -gr "${projectResultsDir}/${project}.zip" expression
zip -gr "${projectResultsDir}/${project}.zip" leafcutter
zip -gr "${projectResultsDir}/${project}.zip" multiqc_data
zip -g  "${projectResultsDir}/${project}.zip" "${project}_multiqc_report.html"
zip -g  "${projectResultsDir}/${project}.zip" README.txt

# Create md5sum for zip file

cd "${projectResultsDir}"
md5sum "${project}".zip > "${projectResultsDir}/${project}".zip.md5
cd "${projectJobsDir}"
