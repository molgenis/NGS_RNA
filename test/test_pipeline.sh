#!/bin/bash
#SBATCH --time=05:59:00
#SBATCH --cpus-per-task 1
#SBATCH --mem 1gb
#SBATCH --open-mode=append
#SBATCH --export=NONE
#SBATCH --get-user-env=60L

# ========================
# DEFAULTS
# ========================
SAMPLESHEET=""
WORKFLOW=""
OUTDIR=""
LOG_PREFIX="[TEST_PIPELINE]"
ERROR_PREFIX="[ERROR]"

# ========================
# HELP
# ========================
print_help() {
cat <<EOF
Usage:
  test_pipeline.sh --samplesheet <file> --workflow <file> --outdir <dir>

Required arguments:
  -s, --samplesheet   Path to samplesheet CSV
  -w, --workflow      Path to workflow CSV
  -o, --outdir        Output directory

Optional:
  -h, --help          Show this help

Example:
  test_pipeline.sh \\
    --samplesheet samplesheets/sr_hg38.csv \\
    --workflow workflows/workflow_STAR.csv \\
    --outdir runs/sr_hg38__STAR
EOF
}

# ========================
# LOGGING
# ========================
log() {
  echo -e "$(date '+%F %T') ${LOG_PREFIX} $*"
}
die() {
  echo -e "$(date '+%F %T') ${ERROR_PREFIX} $*"
}
# ========================
# ARG PARSING
# ========================
if [[ $# -eq 0 ]]; then
  print_help
  exit 1
fi

while [[ $# -gt 0 ]]; do
  case "${1}" in
    -s|--samplesheet)
      SAMPLESHEET="${2:-}"
      shift 2
      ;;
    -w|--workflow)
      WORKFLOW="${2:-}"
      shift 2
      ;;
    -o|--workdir)
      OUTDIR="${2:-}"
      shift 2
      ;;
    -h|--help)
      print_help
      exit 0
      ;;
    *)
      exit 1
      ;;
  esac
done

# ========================
# VALIDATION
# ========================
[[ -z "${SAMPLESHEET}" ]] && die "Missing --samplesheet"
[[ -z "${WORKFLOW}" ]] && die "Missing --workflow"
[[ -z "${OUTDIR}" ]] && die "Missing --outdir"

[[ -f "${SAMPLESHEET}" ]] || die "Samplesheet not found: ${SAMPLESHEET}"
[[ -f "${WORKFLOW}" ]] || die "Workflow not found: ${WORKFLOW}"

# ========================
# CONTEXT INFO
# ========================
log "Starting pipeline"
log "Samplesheet : ${SAMPLESHEET}"
log "Workflow    : ${WORKFLOW}"
log "Output dir  : ${OUTDIR}"
log "SLURM job   : ${SLURM_JOB_ID:-local}"

START_TIME=$(date +%s)

# ========================
# RUN PIPELINE
# ========================

	local _projectName="PlatinumSubset_NGS_RNA"
	local _generatedScriptsFolder="${workfolder}/generatedscripts/NGS_RNA/${_projectName}"

	rm -f "${workfolder}/logs/${_projectName}/run01.pipeline.finished"
	rsync -r --verbose --recursive --links --no-perms --times --group --no-owner --devices --specials "${pipelinefolder}/test/rawdata/MY_TEST_BAM_PROJECT/"SRR1552906[249]_[12].fq.gz "${workfolder}/rawdata/ngs/MY_TEST_BAM_PROJECT/"

	echo "rm -rf ${workfolder}/"{tmp,generatedscripts,projects}"/NGS_RNA/${_projectName}/"
	rm -rf "${workfolder}/"{tmp,generatedscripts,projects}"/NGS_RNA/${_projectName}/"
	mkdir -p "${_generatedScriptsFolder}/"

	echo "copy generate template"
	cp "${pipelinefolder}/templates/generate_template.sh" "${_generatedScriptsFolder}/generate_template.sh"


	module load NGS_RNA/betaAutotest
	module list

	perl -pi -e 's|WORKFLOW=\${EBROOTNGS_RNA}/workflow_\${PIPELINE}.csv|WORKFLOW=\${EBROOTNGS_RNA}/test_workflow_\${PIPELINE}.csv|' "${_generatedScriptsFolder}/generate_template.sh"

	cp "${pipelinefolder}/test/${_projectName}.csv" "${_generatedScriptsFolder}"
	perl -p -e "s|/groups/umcg-atd/tmp01/|${workfolder}/|g" "${_generatedScriptsFolder}/${_projectName}.csv" > "${_generatedScriptsFolder}/${_projectName}.csv.tmp"
	mv -v "${_generatedScriptsFolder}/${_projectName}.csv"{.tmp,}

	cd "${_generatedScriptsFolder}/"

	bash generate_template.sh -c "${EBROOTNGS_RNA}/create_external_samples_ngs_projects_workflow.csv"
	cd scripts

	perl -pi -e "s|workflow_GD.csv|test_workflow_GD.csv|" *.sh

	bash submit.sh

	cd "${workfolder}/projects/NGS_RNA/${_projectName}/run01/jobs/"

	pwd

	perl -pi -e 's|-ERC GVCF|-L 1:17383226-183837051 \\\n  -ERC GVCF|' s*_GatkHaplotypeCallerGvcf_*.sh
	perl -pi -e 's|-ERC GVCF|-L 1:17383226-183837051 \\\n  -ERC GVCF|' s*_GatkGenotypeGvcf_*.sh
	perl -pi -e 's|rsync -av .*.vip|#rsync -av .*.vip|g' s*_CopyToResultsDir_*.sh
	perl -pi -e 's|mem=40gb|mem=10gb|' *.sh
	perl -pi -e 's|--time=16:00:00|--time=05:59:00|' *.sh
	perl -pi -e 's|--time=23:00:00|--time=05:59:00|' *.sh
	perl -pi -e 's|--time=23:59:00|--time=05:59:00|' *.sh

	sh submit.sh



# ========================
# TIMING
# ========================

sleep 20

END_TIME=$(date +%s)
DURATION=$(( (END_TIME - START_TIME) / 60 ))

log "Pipeline finished successfully"
log "Duration: ${DURATION} min"

exit 0
