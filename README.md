<h1> NGS_RNA pipeline</h1>

<h2>Description of the different steps used in the RNA analysis pipeline </h2>

<h3>Gene expression quantification </h3>
The trimmed fastQ files were aligned to a reference genome using Star [1] with default settings. Before gene quantification 
SAMtools [2] was used to sort the aligned reads. 
The gene level quantification was performed by HTSeq-count [3] using --mode=union. 
The gene annotation database which is included in the results dir in folder expression/. Deseq2 was used for differential expression analysis on STAR bams.
For experimental group conditions the 'condition' column in the samplesheet was used the distinct groups within the samples.

<h3>Calculate QC metrics on raw and aligned data </h3>
Quality control (QC) metrics are calculated for the raw sequencing data. This is done using 
the tool FastQC [4]. QC metrics are calculated for the aligned reads using 
Picard-tools [5], CollectRnaSeqMetrics, MarkDuplicates, CollectInsertSize-
Metrics and SAMtools flagstat.

<h3>Splicing event calling using Leafcutter</h3>
Leafcutter quantifies RNA splicing variation detection.

<h3>GATK variant calling</h3>
Variant calling was done using GATK. First, we use a GATK tool called SplitNCigarReads
developed specially for RNAseq, which splits reads into exon segments (getting rid of Ns
but maintaining grouping information) and hard-clip any sequences overhanging into the intronic regions.
The variant calling itself was done using HaplotypeCaller in GVCF mode. All  samples are 
then jointly genotyped by taking the gVCFs produced earlier and running GenotypeGVCFs 
on all of them together to create a set of raw SNP and indel calls. [6]

Results archive
The zipped archive contains the following data and subfolders:

- alignment: merged BAM file with index, md5sums and alignment statistics (.Log.final.out)
- expression: textfiles with gene level quantification per sample and per project. 
- fastqc: FastQC output
- qcmetrics: Multiple qcMetrics and images generated with Picard-tools or SAMTools Flagstat.
- leafcutter: Leafcutter and RegTools output files.
- expression/Deseq2 differential expression analysis.
- multiqc_data: Combined MultiQC tables used for multiqc report html.
- variants: Variants calls using GATK.
- rawdata: raw sequence file in the form of a gzipped fastq file (.fq.gz)

The root of the results directory contains the final QC report, README.txt, analysis results from each tool, 
and the samplesheet which formed the basis for this analysis. 

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


<h2>Manual</h2>

<h3>1) Copy rawdata to raw data ngs folder </h3>

```BASH
scp –r SEQSTARTDATE_SEQ_RUNTEST_FLOWCELLXX username@yourcluster:${root}/groups/$groupname/${tmpDir}/rawdata/ngs/YOURDIR
```
<h3>2) Create a folder in the generatedscripts folder </h3>

```BASH
mkdir ${root}/groups/$groupname/${tmpDir}/generatedscripts/TestRun
```
<h3>3) Copy samplesheet to generatedscripts folder </h3>

```BASH
scp –r TestRun.csv username@yourcluster:/groups/$groupname/${tmpDir}/generatedscripts/
```
Note: the name of the folder should be the same as samplesheet (.csv) file.
Note2: Example samplesheet can be found in $EBROOTNGS_RNA/templates/externalSamplesheet.csv

<h3>4) Run the generate script </h3>

```BASH
module load NGS_RNA
cd ${root}/groups/$groupname/${tmpDir}/generatedscripts/TestRun
cp $EBROOTNGS_RNA/generate_template.sh .
bash generate_template.sh
cd scripts
```
Note: If you want to run the pipeline locally, you should change the backend in the CreateInhouseProjects.sh script (this can be done almost at the end of the script where you have something like: sh ${EBROOTMOLGENISMINCOMPUTE}/molgenis_compute.sh search for –b slurm and change it into –b localhost

```BASH
bash submit.sh
```
<h3>5) Submit jobs </h3>

Navigate to jobs folder. The location of the jobs folder will be outputted at the step before this one (step 4).
```BASH
bash submit.sh
```
