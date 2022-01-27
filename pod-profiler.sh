#!/usr/bin/env bash

# Copies the profiler script to the container, runs it, and downloads the results

TARGET_POD="${1:-$TARGET_POD}"
NAMESPACE="${NAMESPACE:-default}"

if [ -z "${1// /}" ]; then
  echo >&2 "Please specify a pod."
  echo >&2 "Usage: profiler.sh <pod_name>"
  exit 1
fi

set -e

function kc() {
  kubectl --namespace "${NAMESPACE}" "${@}"
}

# TMP_DIR needs to match with a read-and-write-able filesystem
TMP_DIR="/app/tmp/rbspy"
DATESTAMP="$(date +%Y-%m-%d_%H%M)"
TARGET_FILE="${TMP_DIR}/results_${DATESTAMP}.svg"

set -x
echo "Copying profiler directory to pod:"
kc cp ./rbspy/ "${NAMESPACE}/${1}:${TMP_DIR}/"
echo

echo "Running profiler script:"
kc exec -it "pod/${1}" -- "${TMP_DIR}/profiler.sh" "${TARGET_FILE}"
echo

echo "Downloading rbspy results to ./results/:"
kc cp "${NAMESPACE}/${1}:${TARGET_FILE}" "results/${DATESTAMP}.svg"

echo "Cleaning up rbspy artifacts in pod"
kc exec -it "pod/${1}" -- rm -rfv "${TMP_DIR}"
