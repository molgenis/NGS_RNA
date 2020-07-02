#MOLGENIS nodes=1 ppn=1 mem=10gb walltime=05:00:00

#Parameter mapping
#string.RSeQCVersion
#string alignedFilteredBam
#string sortedBam
#string sortedBai
#string tempDir
#string logsDir
#string intermediateDir

#Load module
module load "${RSeQCVersion}"
module list

makeTmpDir ${intermediateDir}
tmpintermediateDir=${MC_tmpFile}


echo "## "$(date)" Start $0"

for i in $(ls "${intermediateDir}"/*.Aligned.sortedByCoord.out.bam -1 |shuf -n 1)
do 
	infer_experiment.py -r /apps/data/Ensembl/GrCh37.75/All_Exon/Ensembl.GRCh37.75-AllExons_+20_-20bp.bed -i "${i}"
done > "{tmpintermediateDir}"/"${i}".stranded.txt


mv "{tmpintermediateDir}"/"${i}".stranded.txt "${intermediateDir}"

echo "succes moving files";
echo "## "$(date)" ##  $0 Done "


