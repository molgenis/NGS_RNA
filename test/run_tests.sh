#!/usr/bin/env bash
set -euo pipefail

tmpdirectory="tmp08" # "${2}"
groupName="umcg-atd" # "${3}"

workDir="/groups/${groupName}/${tmpdirectory}//tmp/NGS_RNA/betaAutotest"
pipelineDir="${workDir}/NGS_RNA"
projectsDir="/groups/${groupName}/${tmpdirectory}/projects/NGS_RNA/"
TruthSetDir="${pipelineDir}/test/results"
runDir="${workDir}/runs"
NGS_RNA_VERSION="NGS_DNA/betaAutotest"
CONFIG="${pipelineDir}/test/config.tsv"
LAST_LINES=0

# ------------------------
# DEFAULTS
# ------------------------
declare -a workflows=("workflow_STAR.csv" "workflow_GD.csv")
declare -A JOBID_TO_TEST

FILTER_TESTS=""
FILTER_SAMPLE=""
FILTER_WORKFLOW=""

# ------------------------
# HELP FUNCTION
# ------------------------
function print_help() {
cat <<EOF

NGS_RNA test wrapper

Usage:
	./run_tests.sh [options]

Options:
	-t, --tests				Comma-separated list of tests
										example: PlatinumSubset_pe_hg38_workflow_STAR

	-s, --samplesheet Filter by sample name
										example: PlatinumSubset_GRCh37_PE
	-w, --workflow		Filter by workflow
										example: STAR, GD
	-p, --pullrequestid NR
	-h, --help			 	Show this help message

Examples:
	# Run all tests
	./run_tests.sh

	# Run only STAR workflow
	./run_tests.sh -w STAR or GD

	# Run specific tests
	./run_tests.sh -t	( PlatinumSubset_GRCh37_PE, PlatinumSubset_GRCh38_PE, PlatinumSubset_GRCh37_SR PlatinumSubset_GRCh38_SR )

Notes:
	- Tests are automatically generated as:
			<sampleheet>_<workflow>

	- Output is written to:
			runs/<test_name>/

	- SLURM logs are stored per test in:
			runs/<test_name>/*.out and *.err

EOF
}

# ------------------------
# ARGUMENT PARSING
# ------------------------
while [[ $# -gt 0 ]]; do
	case "${1}" in
		-t|--tests)
			FILTER_TESTS="${2}"
			shift 2
			;;
		-s|--sample)
			FILTER_SAMPLE="${2}"
			shift 2
			;;
		-w|--workflow)
			FILTER_WORKFLOW="${2}"
			shift 2
			;;
		-p|--pullrequestid)
			PULLREQUEST="${2}"
			shift 2
			;;
		-h|--help)
			print_help
			exit 0
			;;
		*)
			echo "Unknown argument: ${1}"
			exit 1
			;;
	esac
done

# split comma-separated lists
IFS=',' read -r -a TEST_LIST <<< "${FILTER_TESTS}"
IFS=',' read -r -a SAMPLE_LIST <<< "${FILTER_SAMPLE}"
IFS=',' read -r -a WORKFLOW_LIST <<< "${FILTER_WORKFLOW}"


# ------------------------
# FILTER FUNCTION
# ------------------------
function contains() {
	local value="${1}"
	shift
	for item in "${@}"; do
		[[ "${item}" == "${value}" ]] && return 0
	done
	return 1
}

get_slurm_state() {
	local jobid="${1}"
	local state=""

	state=$(sacct -j "${jobid}" --format=State -n 2>/dev/null \
		| head -n 1 \
		| xargs \
		| cut -d' ' -f1 || true)

	echo "${state:-UNKNOWN}"
}

function should_run_test() {
	local sample="${1}"
	local workflow="${2}"
	local test_name="${sample}_${workflow}"

	# filter op specifieke tests
	if [[ -n "${FILTER_TESTS}" ]]; then
		contains "${test_name}" "${TEST_LIST[@]}" || return 1
	fi

	# filter op sample
	if [[ -n "${FILTER_SAMPLE}" ]]; then
		contains "${sample}" "${SAMPLE_LIST[@]}" || return 1
	fi

	# filter op workflow
	if [[ -n "${FILTER_WORKFLOW}" ]]; then
		contains "${workflow}" "${WORKFLOW_LIST[@]}" || return 1
	fi

	return 0
}

function prepareEnv (){
	#cleanup
	rm -rf "${workDir}/*"
	mkdir -p "${pipelineDir}"
	mkdir -p "${runDir}"

	# EXTRA STEP TO GET THE DATA ON THE MACHINE
	cd "${workDir}"
	git clone https://github.com/molgenis/NGS_RNA.git
	
	# COPY DATA TO PIPELINEFOLDER
# mv NGS_RNA "${pipelinefolder}/"
	cd "${pipelineDir}"
	
	##BACK TO NORMAL FROM NOW ON
	git fetch --tags --progress https://github.com/molgenis/NGS_RNA/ +refs/pull/*:refs/remotes/origin/pr/*
	COMMIT=$(git rev-parse refs/remotes/origin/pr/"${PULLREQUEST}"/merge^{commit})
	echo "checkout commit: COMMIT"
	git checkout -f "${COMMIT}"
}
echo "=== PREPARE ENVIRONMENT ==="
prepareEnv

echo "=== SUBMITTING TESTS ==="
pwd
while read -r name sheet truth; do
	[[ "${name}" =~ ^#.*$ || -z "${name}" ]] && continue

	for wf in "${workflows[@]}"; do
		wf_name=$(basename "${wf}" .csv)

		if ! should_run_test "${name}" "${wf_name}"; then
			continue
		fi

		test_name="${name}_${wf_name}"
		outdir="${runDir}/${test_name}"

		mkdir -p "${outdir}"

		echo "Submitting ${test_name}"
		echo "sbatch --parsable --job-name="${test_name}" --output=${outdir}/%x-%j.out --error=${outdir}/%x-%j.err ${pipelineDir}/test/test_pipeline.sh --samplesheet ${sheet} --workflow ${wf} --workdir ${outdir} --pipeline ${pipelineDir}"

		jobid=$(sbatch --parsable --job-name="${test_name}" --output="${outdir}/%x-%j.out" --error="${outdir}/%x-%j.err" ${pipelineDir}/test/test_pipeline.sh \
		--samplesheet "${sheet}" \
		--workflow "${wf}" \
		--workdir "${outdir}" \
		--pipeline ${pipelineDir})

		JOBID_TO_TEST["${jobid}"]="${test_name}"
		
	done
done < "${CONFIG}"

# ------------------------
# WAIT FOR JOBS
# ------------------------
echo "=== WAITING FOR JOBS ==="

function job_running() {
	local jobid="${1}"
	squeue -j "${jobid}" -h | grep -q .
}

print_live_status() {
	local lines=0
	local last="${LAST_LINES:-0}"

	[[ "$last" =~ ^[0-9]+$ ]] || last=0

	if [[ "${last}" -gt 0 ]]; then
		printf "\033[%dA" "$last"
	fi
	echo "=== TEST STATUS ==="
	printf "%-40s (%-10s)\n" \
			"test_name" "slurm_status"
	lines="${lines}"+1

	for jobid in "${!JOBID_TO_TEST[@]}"; do
		test_name="${JOBID_TO_TEST[$jobid]}"
		slurm_state="$(get_slurm_state "${jobid}" || echo UNKNOWN)"
		
		printf "%-40s %-10s\n" \
			"${test_name}:" "${slurm_state}"

		lines="${lines}"+1
	done

	LAST_LINES="${lines}"
}
while true; do
	running=0

	for jobid in "${!JOBID_TO_TEST[@]}"; do
		if job_running "${jobid}"; then
			running=1
		fi
	done
	clear
	print_live_status
	[[ "${running}" -eq 0 ]] && break
	sleep 10
done

# ------------------------
# COMPARE RESULTS
# ------------------------
echo "=== COMPARING RESULTS ==="

while read -r name sheet truth; do
	[[ "${name}" =~ ^#.*$ || -z "${name}" ]] && continue

	for wf in "${workflows[@]}"; do
		wf_name=$(basename "${wf}" .csv)

		if ! should_run_test "${name}" "${wf_name}"; then
			continue
		fi

		test_name="${name}_${wf_name}/"
		resultsDir="${projectsDir}/${test_name}/run01/results/"
		truthDir="${pipelineDir}/test/results/${name}/${wf_name}/"

		echo "Comparing ${test_name}"

		echo "diff -r ${truthDir} ${resultsDir}"
		diff -rq --exclude='alignment' --exclude='fastqs' --exclude='qcmetrics' --exclude='RNASeQC' "${truthDir}" "${resultsDir}" > "${outdir}/diff.txt" || true

		if [[ -s "${outdir}/diff.txt" ]]; then
			echo "FAIL" > "${outdir}/status"
		else
			echo "PASS" > "${outdir}/status"
		fi
	done
done < "${CONFIG}"

# ------------------------
# SUMMARY
# ------------------------
echo ""
echo "=== TEST SUMMARY ==="

for dir in "${runDir}"/*; do
	name=$(basename "${dir}")

	if [[ -f "${dir}/status" ]]; then
		status=$(cat "${dir}/status")
	else
		status="SKIPPED"
	fi

	printf "%-3s %s\n" "${name}" "${status}"
done