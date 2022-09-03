#!/usr/bin/env bash

#
# prepare data for the release step. Here we upload all the metadata to the Inventory Repo.
# If you want to add any information or artifact to the inventory repo then use the "cocoa inventory add command"
#

# shellcheck source=/dev/null
. "${ONE_PIPELINE_PATH}/tools/get_repo_params"

APP_REPO="$(load_repo app-repo url)"
APP_REPO_ORG=${APP_REPO%/*}
APP_REPO_ORG=${APP_REPO_ORG##*/}
APP_REPO_NAME=${APP_REPO##*/}
APP_REPO_NAME=${APP_REPO_NAME%.git}

COMMIT_SHA="$(load_repo app-repo commit)"

INVENTORY_TOKEN_PATH="./inventory-token"
read -r INVENTORY_REPO_NAME INVENTORY_REPO_OWNER INVENTORY_SCM_TYPE INVENTORY_API_URL < <(get_repo_params "$(get_env INVENTORY_URL)" "$INVENTORY_TOKEN_PATH")
#
# collect common parameters into an array
#
params=(
    --repository-url="${APP_REPO}"
    --commit-sha="${COMMIT_SHA}"
    --version="${COMMIT_SHA}"
    --build-number="${BUILD_NUMBER}"
    --pipeline-run-id="${PIPELINE_RUN_ID}"
    --org="$INVENTORY_REPO_OWNER"
    --repo="$INVENTORY_REPO_NAME"
    --git-provider="$INVENTORY_SCM_TYPE"
    --git-token-path="$INVENTORY_TOKEN_PATH"
    --git-api-url="$INVENTORY_API_URL"
)

echo "APP_REPO name" ${APP_REPO}
echo "COMMIT_SHA value" ${COMMIT_SHA}
echo "BUILD_NUMBER value" ${BUILD_NUMBER}
echo "PIPELINE_RUN_ID value" ${PIPELINE_RUN_ID}
echo "INVENTORY_REPO_OWNER name" $INVENTORY_REPO_OWNER
echo "INVENTORY_REPO_NAME name" $INVENTORY_REPO_NAME
echo "INVENTORY_SCM_TYPE value" $INVENTORY_SCM_TYPE
echo "INVENTORY_TOKEN_PATH value" $INVENTORY_TOKEN_PATH
echo "INVENTORY_API_URL url" $INVENTORY_API_URL


#
# add all built images as build artifacts to the inventory
#
while read -r artifact; do
    image="$(load_artifact "${artifact}" name)"
    signature="$(load_artifact "${artifact}" signature)"
    digest="$(load_artifact "${artifact}" digest)"
    tags="$(load_artifact "${artifact}" tags)"

    APP_NAME="$(get_env app-name)"
    APP_ARTIFACTS='{ "app": "'${APP_NAME}'", "tags": "'${tags}'" }'

    echo "image name" ${image}
    echo "signature name" ${signature}
    echo "digest name" ${digest}
    echo "tags name" ${tags}
    echo "APP_NAME name" ${APP_NAME}
    echo "APP_ARTIFACTS name" ${APP_ARTIFACTS}



    cocoa inventory add \
        --artifact="${image}@${digest}" \
        --name="${APP_REPO_NAME}" \
        --app-artifacts="${APP_ARTIFACTS}" \
        --signature="${signature}" \
        --provenance="${image}@${digest}" \
        --sha256="${digest}" \
        --type="image" \
        "${params[@]}"
done < <(list_artifacts)
