#!/usr/bin/env bash

set -o errexit -o pipefail -o nounset

if [ "$#" -eq 0 ]; then
	echo "usage: lint.sh [target pattern...]"
	exit 1
fi

fix=""
buildevents=$(mktemp)
filter='.namedSetOfFiles | values | .files[] | select(.name | endswith($ext)) | ((.pathPrefix | join("/")) + "/" + .name)'

args=()

args=("--aspects=$(echo //tools/lint:linters.bzl%ruff)")

args+=(
	"--norun_validations"
	"--build_event_json_file=$buildevents"
	"--output_groups=rules_lint_human"
	"--remote_download_regex='.*AspectRulesLint.*'"
)

# `--fail-on-violation` parameter，add sign
if [ "$#" -gt 0 ] && [ "$1" == "--fail-on-violation" ]; then
    args+=(
        "--@aspect_rules_lint//lint:fail_on_violation"
    )
    shift
fi

# Allow a `--fix` option on the command-line.
if [ "$#" -gt 0 ] && [ "$1" == "--fix" ]; then
	fix="patch"
	args+=(
		"--@aspect_rules_lint//lint:fix"
		"--output_groups=rules_lint_patch"
	)
	shift
fi

# Check jq and download
JQ_URL="https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64"
JQ_CHECKSUM="af986793a515d500ab2d35f8d2aecd656e764504b789b66d7e1a0b727a124c44"
JQ_BIN=$(mktemp)
trap 'rm -rf -- "$JQ_BIN"' EXIT

if command -v jq &> /dev/null; then
	JQ_CMD="jq"
else
	echo "jq not found, downloading..."
	curl -L -o "$JQ_BIN" "$JQ_URL" || { echo "Download failed! Exiting..."; exit 1; }
	if ! echo "$JQ_CHECKSUM  $JQ_BIN" | sha256sum --check --status; then
		echo "Checksum verification failed! Exiting..."
		exit 1
	fi
	chmod +x "$JQ_BIN"
	JQ_CMD="$JQ_BIN"
fi

# Run linters
set +e  # catch non-zero exit
bazel build ${args[@]} $@
exit_code=$?  # get Bazel exit mode
set -e  # restore default mode

# if Bazel returns 0 mode，exit
if [ $exit_code -ne 0 ]; then
    echo "Linting failed. Exiting."
    exit $exit_code
fi

# jq on windows outputs CRLF which breaks this script
valid_reports=$("$JQ_CMD" --arg ext .out --raw-output "$filter" "$buildevents" | tr -d '\r')

# Show the results.
while IFS= read -r report; do
	# Exclude coverage reports, and check if the output is empty.
	if [[ "$report" == *coverage.dat ]] || [[ ! -s "$report" ]]; then
		# Report is empty. No linting errors.
		continue
	fi
	echo "From ${report}:"
	cat "${report}"
	echo
done <<<"$valid_reports"

if [ -n "$fix" ]; then
	valid_patches=$("$JQ_CMD" --arg ext .patch --raw-output "$filter" "$buildevents" | tr -d '\r')
	while IFS= read -r patch; do
		# Exclude coverage, and check if the patch is empty.
		if [[ "$patch" == *coverage.dat ]] || [[ ! -s "$patch" ]]; then
			# Patch is empty. No linting errors.
			continue
		fi

		case "$fix" in
		"print")
			echo "From ${patch}:"
			cat "${patch}"
			echo
			;;
		"patch")
			patch -p1 <${patch}
			;;
		*)
			echo >2 "ERROR: unknown fix type $fix"
			exit 1
			;;
		esac

	done <<<"$valid_patches"
fi
