# NGS_RNA pipeline description

Morris A. Swertz
University of Groningen, University Medical Center Groningen, Genomics Coordination Center, Groningen, the Netherlands
University of Groningen, University Medical Center Groningen, Department of Genetics, Groningen, the Netherlands
Please use both affiliations

# Methods
This describes how the analysis of high troughput sequencing data was performed by our facility for expression quantification of RNAseq.

#### Alignment
Hisat version 0.1.5-beta [1] was used for aligning to the human genome reference build 37 created by the 1000 genomes phase 1 project [4]. Before gene quantification SAMtools version 1.2 [2] was used to sort the aligned reads.

#### Gene quantification default
The gene level quantification was performed by HTSeq version 0.6.1p1 [3] using ‘--mode=union ’, disregarding strandedness and for annotation the Ensembl version 75 [5] gene annotation was used.

#### Gene quantification lexogen
The gene level quantification was performed by HTSeq version 0.6.1p1 [3] using ‘--mode=union ’, enabling strandedness, and for annotation the Ensembl version 75 [5] gene annotation was used.

1. Kim D, Langmead B, Salzberg SL: HISAT: a fast spliced aligner with low memory requirements.Nature Methods 2015,  12:357–360, doi:10.1038/nmeth.3317.
2. Li H, Handsaker B, Wysoker A, Fennell T, Ruan J, Homer N, Marth G, Abecasis G, Durbin R,
Subgroup 1000 Genome Project Data Processing: The Sequence Alignment/Map format and SAMtools. Bioinformatics  2009 Aug 15;25(16):2078-9.
3. Anders S, Pyl PT, Huber W: HTSeq -- A Python framework to work with high-throughput sequencing data.  Bioinformatics. 2015 Jan 15;31(2):166-9.
4.The 1000 Genomes Project Consortium: A global reference for human genetic variation. Nature 2015, 526:68–74 doi:10.1038/nature15393.
5. Flicek P, Amode MR, Barrell D, Beal K, Billis K, Brent S, Carvalho-Silva D, Clapham P, Coates G, Fitzgerald S, Gil L, Girón CG, Gordon L, Hourlier T, Hunt S, Johnson N, Juettemann T, Kähäri AK, Keenan S, Kulesha E, Martin FJ, Maurel T, McLaren WM, Murphy DN, Nag R, Overduin B, Pignatelli M, Pritchard B, Pritchard E, Riat HS, Ruffier M, Sheppard D, Taylor K, Thormann A, Trevanion SJ, Vullo A, Wilder SP, Wilson M, Zadissa A, Aken BL, Birney E, Cunningham F, Harrow J, Herrero J, Hubbard TJ, Kinsella R, Muffato M, Parker A, Spudich G, Yates A, Zerbino DR, Searle SM: Ensembl 2014. Nucleic Acids Res. 2014 Jan;42(Database issue):D749-55. doi: 10.1093/nar/gkt1196. Epub 2013 Dec 6.
