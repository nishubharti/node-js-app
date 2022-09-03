#!/bin/bash

set -x

echo "Inventory Add .....";
echo "GIT_COMMIT=${GIT_COMMIT}"
echo "GHE_ORG=${GHE_ORG}"
echo "GHE_REPO=${GHE_REPO}"
echo "SIGNATURE=${SIGNATURE}"
echo "BUILD_NUMBER=${BUILD_NUMBER}"
echo "PIPELINE_RUN_ID=${PIPELINE_RUN_ID}"
echo "APP_REPO_NAME=${APP_REPO_NAME}"
echo "APP_REPO=${APP_REPO}"
echo "ARTIFACT_PROVENANCE=${ARTIFACT_PROVENANCE}"
echo "SHA_VAL=${SHA_VAL}"
echo "VERSION=${VERSION}"
echo "TYPE=${TYPE}"
echo "BUILD_IMAGE_TAG=${BUILD_IMAGE_TAG}"
echo "IMAGE_NAME=${IMAGE_NAME}"
echo "COMMIT_BRANCH=${COMMIT_BRANCH}"

APP_ARTIFACTS='{ "signature": "'${SIGNATURE}'", "provenance": "'${ARTIFACT_PROVENANCE}'", "image_tag": "'${BUILD_IMAGE_TAG}'", "image_name": "'${IMAGE_NAME}'", "branch": "'${COMMIT_BRANCH}'" }'

cocoa inventory add \
    --artifact="${ARTIFACT_PROVENANCE}" \
    --repository-url="${APP_REPO}" \
    --commit-sha="${GIT_COMMIT}" \
    --build-number="${BUILD_NUMBER}" \
    --pipeline-run-id="${PIPELINE_RUN_ID}" \
    --version="${VERSION}" \
    --name="${APP_REPO_NAME}" \
    --app-artifacts="${APP_ARTIFACTS}" \
    --sha256="${SHA_VAL}" \
    --provenance="${ARTIFACT_PROVENANCE}" \
    --signature="${SIGNATURE}" \
    --type="${TYPE}"


echo "Uploaded to artifactory"


