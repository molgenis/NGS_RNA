#MOLGENIS nodes=1 ppn=1 mem=5gb walltime=03:00:00

#Parameter mapping

#string projectResultsDir
#string project
#string intermediateDir
#string projectLogsDir
#string projectQcDir
#string scriptDir
#list externalSampleID
#string contact
#string qcMatricsList
#string gcPlotList
#string seqType
#string RVersion
#string wkhtmltopdfVersion
#string fastqcVersion
#string samtoolsVersion
#string picardVersion
#string multiqcVersion
#string anacondaVersion
#string hisatVersion
#string indexFileID
#string ensembleReleaseVersion
#string prepKit
#string NGSRNAVersion
#string groupname
#string tmpName
#string jdkVersion
#string RVersion
#string htseqVersion
#string pythonVersion
#string gatkVersion
#string ghostscriptVersion
#string kallistoVersion
#string ensembleReleaseVersion


#Function to check if array contains value
array_contains () { 
    local array="$1[@]"
    local seeking=$2
    local in=1
    for element in "${!array-}"; do
        if [[ "$element" == "$seeking" ]]; then
            in=0
            break
        fi
    done
    return $in
}

cat > ${intermediateDir}/${project}_QC_config.yaml <<'_EOF'

report_header_info:
    - Contact E-mail: '${contact}'
    - Pipeline Version: '${NGSRNAVersion}'
    - Project : '${project}'
    - prepKit : '${prepKit}'
    - '' : ''
    - Used toolversions: ' '
    - '' : ''
    - '': ${jdkVersion}
    - '': ${fastqcVersion}
    - '': ${hisatVersion}
    - '': ${samtoolsVersion}
    - '': ${RVersion}
    - '': ${wkhtmltopdfVersion}
    - '': ${picardVersion}
    - '': ${htseqVersion}
    - '': ${pythonVersion}
    - '': ${gatkVersion}
    - '': ${multiqcVersion}
    - '': ${ghostscriptVersion}
    - '' : ''
    - pipeline description : ''
    - Gene expression quantification : ''
    - '': 'The trimmed fastQ files where aligned to build human_g1k_v37 ensembleRelease 75 reference genome using'
    - '': 'hisat/0.1.5-beta-foss-2015b [1] allowing for 2 mismatches. Before gene quantification'
    - '': 'SAMtools/1.2-foss-2015b [2] was used to sort the aligned reads.'
    - '': 'The gene level quantification was performed by HTSeq/0.6.1p1-foss-2015b [3] using --mode=union'
    - '': '--stranded=no and, Ensembl version 75 was used as gene annotation database which is included'
    - '': 'in folder expression/.'
    - '' : ''
    - QC metrics: ''
    - '': 'Quality control (QC) metrics are calculated for the raw sequencing data. This is done using'
    - '': 'the tool FastQC FastQC/0.11.3-Java-1.7.0_80 [4]. QC metrics are calculated for the aligned reads using'
    - '': 'Picard-tools picard/1.130-Java-1.7.0_80 [5] CollectRnaSeqMetrics, MarkDuplicates, CollectInsertSize-'
    - '': 'Metrics and SAMtools/1.2-foss-2015b flagstat.These QC metrics form the basis in this final QC report.'
    - '' : ''
    - references: ''
    - '' : ''
    - '': '1. Dobin A, Davis C a, Schlesinger F, Drenkow J, Zaleski C, Jha S, Batut P, Chaisson M,'
    - '': 'Gingeras TR: STAR: ultrafast universal RNA-seq aligner. Bioinformatics 2013, 29:15–21.'
    - '': '2. Li H, Handsaker B, Wysoker A, Fennell T, Ruan J, Homer N, Marth G, Abecasis G, Durbin R,'
    - '': 'Subgroup 1000 Genome Project Data Processing: The Sequence Alignment/Map format and SAMtools.'
    - '': 'Bioinforma 2009, 25 (16):2078–2079.'
    - '': '3. Anders S, Pyl PT, Huber W: HTSeq – A Python framework to work with high-throughput sequencing data'
    - '': 'HTSeq – A Python framework to work with high-throughput sequencing data. 2014:0–5.'
    - '': '4. Andrews, S. (2010). FastQC a Quality Control Tool for High Throughput Sequence Data [Online].'
    - '': 'Available online at: http://www.bioinformatics.babraham.ac.uk/projects/fastqc/ ${samtoolsVersion}'
    - '': '5. Picard Sourceforge Web site. http://picard.sourceforge.net/ ${picardVersion}'
_EOF


# generate multiqc QC rapport

module load ${multiqcVersion}
module list

multiqc -c ${intermediateDir}/${project}_QC_config.yaml -f ${intermediateDir} ${fastqcFolder} -o ${projectResultsDir}

mv ${projectResultsDir}/multiqc_report.html ${projectResultsDir}/${project}_multiqc_report.html
