#!/usr/bin/env bash

. "${ONE_PIPELINE_PATH}/tools/get_repo_params"

APP_REPO="$(load_repo app-repo url)"
APP_REPO_ORG=${APP_REPO%/*}
APP_REPO_ORG=${APP_REPO_ORG##*/}
APP_REPO_NAME=${APP_REPO##*/}
APP_REPO_NAME=${APP_REPO_NAME%.git}


COMMIT_SHA="$(load_repo app-repo commit)"

APP_ABSOLUTE_SCM_TYPE=$(get_absolute_scm_type "$APP_REPO")

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

