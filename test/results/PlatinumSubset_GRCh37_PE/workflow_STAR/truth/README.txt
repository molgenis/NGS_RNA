
Morris A. Swertz
University of Groningen, University Medical Center Groningen, Genomics Coordination Center, Groningen, the Netherlands
University of Groningen, University Medical Center Groningen, Department of Genetics, Groningen, the Netherlands

Description of the different steps used in the RNA analysis pipeline

Gene expression quantification
The trimmed fastQ files using TrimGalore/0.6.7-GCCcore-11.3.0 where aligned to build Homo_sapiens.GRCh37.dna.primary_assembly.fa ensembleRelease 75
reference genome using STAR/2.7.9a-GCC-11.3.0 [1] with default settings. Before gene quantification
SAMtools/1.16.1-GCCcore-11.3.0 [2] was used to sort the aligned reads.
The gene level quantification was performed by HTSeq-count HTSeq/0.12.3-GCCcore-11.3.0-Python-3.10.4 [3] using --mode=union,
Ensembl version 75 was used as gene annotation database which is included
in folder expression/. Deseq2 was used for differential expression analysis on STAR bams.
For experimental group conditions the 'conditions' column in the samplesheet was used the
distinct groups within the samples. and can be filtered using a 'geneOfIterest' column in the samplesheet.

As an alternative Outrider outrider_latest.sif [8] is used for aberrant gene expression. Outliers genes are identified a
read counts that significantly deviate. Furthermore, OUTRIDER provides useful plotting functions to
analyze and visualize the results.Output can be filtered using a 'geneOfIterest' column in the samplesheet,
alternatively the top 3 calles are visualized.

Calculate QC metrics on raw and aligned data
Quality control (QC) metrics are calculated for the raw sequencing data. This is done using
the tool FastQC FastQC/0.11.9-Java-11-LTS [4]. QC metrics are calculated for the aligned reads using
Picard-tools picard/2.26.10-Java-8-LTS [5] CollectRnaSeqMetrics, MarkDuplicates, CollectInsertSize-
Metrics and SAMtools/1.16.1-GCCcore-11.3.0 flagstat.

Splicing events calling
LeafCutter leafcutter_0.2.10.sif, RMats ${rMATsVersion} [9] and STAR STAR/2.7.9a-GCC-11.3.0 are used
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

multiqc_v1.12.sif
FastQC/0.11.9-Java-11-LTS
SAMtools/1.16.1-GCCcore-11.3.0
R/4.4.0-foss-2022a-bare
TrimGalore/0.6.7-GCCcore-11.3.0
picard/2.26.10-Java-8-LTS
HTSeq/0.12.3-GCCcore-11.3.0-Python-3.10.4
Python/3.10.4-GCCcore-11.3.0-bare
GATK/4.2.4.1-Java-8-LTS
RSeQC/3.0.1-GCCcore-11.3.0-Python-3.10.4
STAR/2.7.9a-GCC-11.3.0
leafcutter_0.2.10.sif
${rMATsVersion}
outrider_latest.sif

1. Alexander Dobin  1 , Carrie A Davis, Felix Schlesinger, Jorg Drenkow, Chris Zaleski,
	Sonali Jha, Philippe Batut, Mark Chaisson, Thomas R Gingeras: STAR: ultrafast universal RNA-seq aligner
	2013 Jan 1;29(1):15-21.  doi: 10.1093/bioinformatics/bts635.  Epub 2012 Oct 25.
2. Li H, Handsaker B, Wysoker A, Fennell T, Ruan J, Homer N, Marth G, Abecasis G, Durbin R,
	Subgroup 1000 Genome Project Data Processing: The Sequence Alignment/Map format and SAMtools.
	Bioinforma 2009, 25 (16):2078–2079.
3. Anders S, Pyl PT, Huber W: HTSeq – A Python framework to work with high-throughput sequencing data
	HTSeq – A Python framework to work with high-throughput sequencing data. 2014:0–5.
4. Andrews, S. (2010). FastQC a Quality Control Tool for High Throughput Sequence Data [Online].
	Available online at: http://www.bioinformatics.babraham.ac.uk/projects/fastqc/ SAMtools/1.16.1-GCCcore-11.3.0
5. Picard Sourceforge Web site. http://picard.sourceforge.net/ picard/2.26.10-Java-8-LTS
6. The Genome Analysis Toolkit: a MapReduce framework for analyzing next-generation DNA sequencing data.
	McKenna A et al.2010 GENOME RESEARCH 20:1297-303, Version: GATK/4.2.4.1-Java-8-LTS
7. Li YI, Knowles DA, Humphrey J, et al. Annotation-free quantification of RNA splicing using LeafCutter.
	Nat Genet. 2018;50(1):151-158. doi:10.1038/s41588-017-0004-9
8. Brechtmann F, Mertes C, Matusevičiūtė A, Yépez VA, Avsec Ž, Herzog M, Bader DM, Prokisch H, Gagneur J (2018).
	OUTRIDER: A Statistical Method for Detecting Aberrantly Expressed Genes in RNA Sequencing Data.
	The American Journal of Human Genetics, 103, 907 - 917. ISSN 0002-9297, doi: 10.1016/j.ajhg.2018.10.025.
9. Shen S., Park JW., Lu ZX., Lin L., Henry MD., Wu YN., Zhou Q., Xing Y.
	rMATS: Robust and Flexible Detection of Differential Alternative Splicing from Replicate RNA-Seq Data.
	PNAS, 111(51):E5593-601. doi: 10.1073/pnas.1419161111
