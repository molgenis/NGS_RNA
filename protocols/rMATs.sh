#MOLGENIS walltime=23:59:00 mem=4gb ppn=4

#Parameter mapping
#list sampleMergedBam
#string sampleMergedBamExt
#string tempDir
#string tmpDataDir
#string project
#string externalSampleID
#string intermediateDir
#string strandedness
#string sifDir
#string rMATsOutputDir
#string annotationGtf
#string projectJobsDir
#string project
#string groupname
#string tmpName
#string logsDir


makeTmpDir "${intermediateDir}"
tmpSampleMergedDedupBam="${MC_tmpFile}"

mkdir -p "${rMATsOutputDir}/${externalSampleID}/tmp"

# create list of bam files from design
rm -f "${intermediateDir}/${externalSampleID}.B{1,2}.txt"

while read line
do
  # reading each line
  status=$(echo "${line}" | cut -d " " -f2)
  name=$(echo "${line}" | cut -d " " -f1)
  if [ "${status}" = "sample" ]
  then
    echo "${name} is a ${status} : in ${externalSampleID}.B1.txt"
    echo -n "${intermediateDir}/${name}," >> "${intermediateDir}/${externalSampleID}.B1.txt"
  else
    echo "$Pname} is a $Pstatus} : in ${externalSampleID}.B2.txt"
    echo -n "${intermediateDir}/${name}," >> "${intermediateDir}/${externalSampleID}.B2.txt"
  fi
  echo ${status}
done < "${intermediateDir}${externalSampleID}.SJ.design.tsv"

  # Get strandness.
  STRANDED="$(num1="$(tail -n 2 "${strandedness}" | awk '{print $7'} | head -n 1)"; num2="$(tail -n 2 "${strandedness}" | awk '{print $7'} | tail -n 1)"; if (( $(echo "$num1 > 0.6" | bc -l) )); then echo "fr-secondstrand"; fi; if (( $(echo "$num2 > 0.6" | bc -l) )); then echo "fr-firststrand"; fi; if (( $(echo "$num1 < 0.6 && $num2 < 0.6" | bc -l) )); then echo "fr-unstranded"; fi)"

  singularity exec --bind "${intermediateDir}":/intermediateDir,/apps:/apps,/groups:/groups "${sifDir}/rmats_v4.1.2.sif" python /rmats/rmats.py \
  --b1 "/intermediateDir/${externalSampleID}.B1.txt" --b2 "/intermediateDir/${externalSampleID}.B2.txt" \
  --gtf "${annotationGtf}" \
  -t paired \
  --readLength 150 \
  --variable-read-length \
  --cstat 0.05 \
  --nthread 4 \
  --libType "${STRANDED}" \
  --od "${rMATsOutputDir}/${externalSampleID}/" \
  --tmp "${rMATsOutputDir}/${externalSampleID}/tmp/"

  #cleanup tmpdir
  rm -r "${rMATsOutputDir}/${externalSampleID}/tmp/"
