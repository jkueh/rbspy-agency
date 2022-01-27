#!/usr/bin/env bash

# Check that we have a target file specified
TARGET_FILE="${1?"Target file not specified (Usage: ./profiler.sh <path_to_desired_file>)"}"

# If it exists, remove it
[ -e "${TARGET_FILE}" ] && rm "${TARGET_FILE}"

# Change to the parent directory of the target file
PARENT_DIR="$(dirname "${TARGET_FILE}")"
cd "${PARENT_DIR}" || exit

RBSPY_URL="https://github.com/rbspy/rbspy/releases/download/v0.10.0/rbspy-x86_64-unknown-linux-gnu.tar.gz"
RBSPY_EXPECTED_MD5="79d95a84ead9e617cf21c1fe24654f63"

# Curl or wget needs to be available in the container's PATH
echo "Downloading rbspy: ${RBSPY_URL}"
curl --location -o rbspy.tar.gz "${RBSPY_URL}"

echo "Verifying rbspy archive matches MD5 checksum: ${RBSPY_ARCHIVE_MD5}"
ARCHIVE_MD5="$(md5sum "rbspy.tar.gz" | awk '{print $1}')"

if [ "${ARCHIVE_MD5}" != "${RBSPY_EXPECTED_MD5}" ]; then
  echo >&2 "MD5 of downloaded rbspy release archive " \
    "(${ARCHIVE_MD5}) and expected MD5 (${RBSPY_EXPECTED_MD5}) do not match."
  rm -v rbspy.tar.gz
  exit 1
fi

# Tar needs to be available in the container's PATH
echo "Extracting rbspy archive"
tar zxvf rbspy.tar.gz && ls -l

# The filename inside the tar.gz archive may change over time, so hardcoding it here
# This will change if you choose a different architecture's build of rbspy
RBSPY_EXEC="rbspy-x86_64-unknown-linux-gnu"

chmod +x "${RBSPY_EXEC}"

# This is the script that runs in the target pod
echo "Running rbspy..."
TARGET_PROCESS_NAME="sidekiq"
"./${RBSPY_EXEC}" record -p "$(pgrep -n -f "${TARGET_PROCESS_NAME}")" \
  --subprocesses \
  --duration 30 \
  --nonblocking \
  --file "${TARGET_FILE}"
