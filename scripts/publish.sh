#!/bin/bash

set -o errexit
set -o pipefail
set -o nounset

PROJECT="crm"
BUCKET="kkvesper-jenkins-artifacts"
TAG_NUMBER=$(echo ${GIT_BRANCH} | cut -d'/' -f3)
BUILD_ARTIFACT_PATH="dist/${PROJECT}.tar.gz"

echo "Git branch: ${GIT_BRANCH}
Git tag: ${TAG_NUMBER}
Git commit: ${GIT_COMMIT}
Build number: ${BUILD_NUMBER}" | tee ./REVISION

umask 007

if [ ! -f ${BUILD_ARTIFACT_PATH} ]; then
    echo "${BUILD_ARTIFACT_PATH} does not exist."
    exit 1
fi

url="s3://${BUCKET}/${PROJECT}/${JOB_NAME}/${BUILD_NUMBER}.tar.gz"
aws s3 cp --sse -- "${BUILD_ARTIFACT_PATH}" "${url}"

echo "Build uploaded to ${url}"

echo "Adding build to Snowball"
/usr/local/bin/snowball publish \
    -p "${PROJECT}" \
    -e "staging" \
    -e "production" \
    -u "${url}" \
    -s "https://snowball.kkvesper.net"

echo "Done!"
