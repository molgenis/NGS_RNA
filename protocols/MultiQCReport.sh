#MOLGENIS nodes=1 ppn=1 mem=5gb walltime=03:00:00

#Parameter mapping

#string projectResultsDir
#string project
#string intermediateDir
#string projectLogsDir
#string projectQcDir
#list externalSampleID
#string contact
#string qcMatricsList
#string gcPlotList
#string seqType
#string rVersion
#string wkhtmltopdfVersion
#string fastqcVersion
#string samtoolsVersion
#string picardVersion
#string multiqcVersion
#string anacondaVersion
#string starVersion
#string indexFileID
#string ensembleReleaseVersion
#string prepKit
#string ngsVersion
#string groupname
#string tmpName
#string jdkVersion
#string rVersion
#string htseqVersion
#string pythonVersion
#string sifDir
#string gatkVersion
#string ensembleReleaseVersion
#string logsDir

cat > "${intermediateDir}/${project}_QC_config.yaml" <<'_EOF'

report_header_info:
  - 'Contact E-mail' : '${contact}'
  - 'Pipeline Version' : '${ngsVersion}'
  - 'Project' : '${project}'
  - 'prepKit' : '${prepKit}'
  - '' : ''
  - 'Used toolversions' : ' '
  - '' : ''
  - '' : ${jdkVersion}
  - '' : ${fastqcVersion}
  - '' : ${starVersion}
  - '' : ${samtoolsVersion}
  - '' : ${rVersion}
  - '' : ${wkhtmltopdfVersion}
  - '' : ${picardVersion}
  - '' : ${htseqVersion}
  - '' : ${pythonVersion}
  - '' : ${gatkVersion}
  - '' : ${multiqcVersion}
  - '' : ''
  - 'pipeline description' : ''
  - 'Gene expression quantification' : ''
  - '' : 'The trimmed fastQ files where aligned to build ${indexFileID} reference genome using'
  - '' : '${starVersion} [1] allowing for 2 mismatches. Before gene quantification'
  - '' : '${samtoolsVersion} [2] was used to sort the aligned reads.'
  - '' : 'The gene level quantification was performed by ${htseqVersion} [3] using --mode=union'
  - '' : '--stranded=no and, Ensembl version 75 was used as gene annotation database which is included'
  - '' : 'in folder expression/.'
  - '' : ''
  - 'QC metrics' : ''
  - '' : 'Quality control (QC) metrics are calculated for the raw sequencing data. This is done using'
  - '' : 'the tool FastQC FastQC [4]. QC metrics are calculated for the aligned reads using'
  - '' : 'Picard-tools [5] CollectRnaSeqMetrics, MarkDuplicates, CollectInsertSize-'
  - '' : 'Metrics and SAMtools flagstat.These QC metrics form the basis in this final QC report.'
  - '' : ''
  - 'references' : ''
  - '' : ''
  - '' : '1. Dobin A, Davis C a, Schlesinger F, Drenkow J, Zaleski C, Jha S, Batut P, Chaisson M,'
  - '' : 'Gingeras TR: STAR: ultrafast universal RNA-seq aligner. Bioinformatics 2013, 29:15–21.'
  - '' : '2. Li H, Handsaker B, Wysoker A, Fennell T, Ruan J, Homer N, Marth G, Abecasis G, Durbin R,'
  - '' : 'Subgroup 1000 Genome Project Data Processing: The Sequence Alignment/Map format and SAMtools.'
  - '' : 'Bioinforma 2009, 25 (16):2078–2079.'
  - '' : '3. Anders S, Pyl PT, Huber W: HTSeq – A Python framework to work with high-throughput sequencing data'
  - '' : 'HTSeq – A Python framework to work with high-throughput sequencing data. 2014:0–5.'
  - '' : '4. Andrews, S. (2010). FastQC a Quality Control Tool for High Throughput Sequence Data [Online].'
  - '' : 'Available online at: http://www.bioinformatics.babraham.ac.uk/projects/fastqc/ ${samtoolsVersion}'
  - '' : '5. Picard Sourceforge Web site. http://picard.sourceforge.net/ ${picardVersion}'
_EOF


# generate multiqc QC rapport

singularity exec --bind "${intermediateDir}:/intermediateDir,${projectResultsDir}:/projectResultsDir" "${sifDir}${multiqcVersion}" \
multiqc -c "/intermediateDir/${project}_QC_config.yaml" \
-f "/intermediateDir/" \
-o "/projectResultsDir/"

mv "${projectResultsDir}/multiqc_report.html" "${projectResultsDir}/${project}_multiqc_report.html"
