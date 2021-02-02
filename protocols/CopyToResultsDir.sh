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
#string anacondaVersion
#string indexFileID
#string seqType
#string jdkVersion
#string fastqcVersion
#string samtoolsVersion
#string RVersion
#string wkhtmltopdfVersion
#string picardVersion
#string hisatVersion
#string htseqVersion
#string pythonVersion
#string gatkVersion
#string ghostscriptVersion
#string ensembleReleaseVersion
#string groupname
#string tmpName
#string logsDir

# Change permissions

umask 0007

# Make result directories
mkdir -p ${projectResultsDir}/alignment
mkdir -p ${projectResultsDir}/fastqc
mkdir -p ${projectResultsDir}/expression
mkdir -p ${projectResultsDir}/expression/perSampleExpression
mkdir -p ${projectResultsDir}/expression/expressionTable
mkdir -p ${projectResultsDir}/images
mkdir -p ${projectResultsDir}/qcmetrics

# Copy project csv file to project results directory

cp ${projectJobsDir}/${project}.csv ${projectResultsDir}

# Copy fastQC output to results directory

	cp ${intermediateDir}/*_fastqc.zip ${projectResultsDir}/fastqc

# Copy BAM plus index plus md5 sum to results directory

usedWorkflow=$(basename ${workflow})

	cp ${intermediateDir}/*.sorted.merged.dedup.bam ${projectResultsDir}/alignment
        cp ${intermediateDir}/*.sorted.merged.dedup.bam.md5 ${projectResultsDir}/alignment
        cp ${intermediateDir}/*.sorted.merged.dedup.bai ${projectResultsDir}/alignment
        cp ${intermediateDir}/*.sorted.merged.dedup.bai.md5 ${projectResultsDir}/alignment

# copy qc metrics to qcmetrics folder

#	cp ${intermediateDir}/*.hisat.log ${projectResultsDir}/qcmetrics
	cp ${intermediateDir}/*.quality_by_cycle_metrics ${projectResultsDir}/qcmetrics
	cp ${intermediateDir}/*.quality_by_cycle.pdf ${projectResultsDir}/qcmetrics
	cp ${intermediateDir}/*.quality_distribution.pdf ${projectResultsDir}/qcmetrics
	cp ${intermediateDir}/*.quality_distribution_metrics ${projectResultsDir}/qcmetrics
	cp ${intermediateDir}/*.base_distribution_by_cycle.pdf ${projectResultsDir}/qcmetrics 
	cp ${intermediateDir}/*.base_distribution_by_cycle_metrics ${projectResultsDir}/qcmetrics
	cp ${intermediateDir}/*.alignment_summary_metrics ${projectResultsDir}/qcmetrics
        cp ${intermediateDir}/*.flagstat ${projectResultsDir}/qcmetrics
	cp ${intermediateDir}/*.idxstats ${projectResultsDir}/qcmetrics
	cp ${intermediateDir}/*.mdupmetrics ${projectResultsDir}/qcmetrics
	cp ${intermediateDir}/*.collectrnaseqmetrics ${projectResultsDir}/qcmetrics

	if [ "${seqType}" == "PE" ]
        then
		cp ${intermediateDir}/*.insert_size_metrics ${projectResultsDir}/qcmetrics
	else
		echo "Skip insertSizeMetrics. seqType is: ${seqType}"
	fi

# copy GeneCounts to results directory

	cp ${intermediateDir}/*.counts.txt ${projectResultsDir}/expression/perSampleExpression
	cp ${projectHTseqExpressionTable} ${projectResultsDir}/expression/expressionTable
	cp ${annotationGtf} ${projectResultsDir}/expression/

# Copy QC images and report to results directory

	cp ${intermediateDir}/*.collectrnaseqmetrics.png ${projectResultsDir}/images

#only available with PE
	if [ "${seqType}" == "PE" ]
	then
		cp ${intermediateDir}/*.insert_size_histogram.png ${projectResultsDir}/images
		cp ${intermediateDir}/*.insert_size_histogram.pdf ${projectResultsDir}/images
	else
                echo "Skip insertSizeMetrics. seqType is: ${seqType}"
	fi


# write README.txt file

cat > ${projectResultsDir}/README.txt <<'endmsg'

Morris A. Swertz
University of Groningen, University Medical Center Groningen, Genomics Coordination Center, Groningen, the Netherlands
University of Groningen, University Medical Center Groningen, Department of Genetics, Groningen, the Netherlands

Description of the different steps used in the RNA analysis pipeline

Gene expression quantification
The trimmed fastQ files where aligned to build ${indexFileID} ensembleRelease ${ensembleReleaseVersion} 
reference genome using ${hisatVersion} [1] with default settings. Before gene quantification 
${samtoolsVersion} [2] was used to sort the aligned reads. 
The gene level quantification was performed by HTSeq-count ${htseqVersion} [3] using --mode=union, 
Ensembl version ${ensembleReleaseVersion} was used as gene annotation database which is included
in folder expression/. 

Calculate QC metrics on raw and aligned data
Quality control (QC) metrics are calculated for the raw sequencing data. This is done using 
the tool FastQC ${fastqcVersion} [4]. QC metrics are calculated for the aligned reads using 
Picard-tools ${picardVersion} [5] CollectRnaSeqMetrics, MarkDuplicates, CollectInsertSize-
Metrics and ${samtoolsVersion} flagstat.

GATK variant calling
Variant calling was done using GATK. First, we use a GATK tool called SplitNCigarReads
developed specially for RNAseq, which splits reads into exon segments (getting rid of Ns
but maintaining grouping information) and hard-clip any sequences overhanging into the intronic regions.
The variant calling it self was done using HaplotypeCaller in GVCF mode. All  samples are 
then jointly genotyped by taking the gVCFs produced earlier and running GenotypeGVCFs 
on all of them together to create a set of raw SNP and indel calls per chomosome. [6]



Results archive
The zipped archive contains the following data and subfolders:

- alignment: merged BAM file with index, md5sums and alignment statistics (.Log.final.out)
- expression: textfiles with gene level quantification per sample and per project. 
- fastqc: FastQC output
- images: QC images
- qcmetrics: Multiple qcMetrics generated with Picard-tools or SAMTools Flagstat.
- variants: Variants calls using GATK. (optional)
- rawdata: raw sequence file in the form of a gzipped fastq file (.fq.gz)

The root of the results directory contains the final QC report, README.txt and the samplesheet which 
form the basis for this analysis. 

Used toolversions:

${jdkVersion}
${fastqcVersion}
${samtoolsVersion}
${RVersion}
${wkhtmltopdfVersion}
${picardVersion}
${htseqVersion}
${pythonVersion}
${gatkVersion}
${ghostscriptVersion}
${hisatVersion}

1. Daehwan Kim, Ben Langmead & Steven L Salzberg: HISAT: a fast spliced aligner with low
memory requirements. Nature Methods 12, 357–360 (2015)
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

endmsg

# Create zip file for all "small text" files

cd ${projectResultsDir}

zip -gr ${projectResultsDir}/${project}.zip fastqc
zip -g ${projectResultsDir}/${project}.zip ${project}.csv
zip -gr ${projectResultsDir}/${project}.zip qcmetrics
zip -gr ${projectResultsDir}/${project}.zip expression
zip -gr ${projectResultsDir}/${project}.zip variants
zip -gr ${projectResultsDir}/${project}.zip images
zip -g ${projectResultsDir}/${project}.zip ${project}_multiqc_report.html
zip -g ${projectResultsDir}/${project}.zip README.txt

# Create md5sum for zip file

cd ${projectResultsDir}
md5sum ${project}.zip > ${projectResultsDir}/${project}.zip.md5
cd ${projectJobsDir}

CURRENT_DIR=$(pwd)

runNumber=$(basename $( dirname "${projectResultsDir}"))
if [ -f "${logsDir}/${project}/${runNumber}.pipeline.started" ]
then
	mv "${logsDir}/${project}/${runNumber}.pipeline".{started,finished}
else
	touch "${logsDir}/${project}/${runNumber}.pipeline.finished"
fi
rm -f "${logsDir}/${project}/${runNumber}.pipeline.failed"
echo "${logsDir}/${project}/${runNumber}.pipeline.finished is created"

