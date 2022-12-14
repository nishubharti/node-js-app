#!/usr/bin/env bash

# shellcheck source=/dev/null
source "${ONE_PIPELINE_PATH}"/tools/retry

export IMAGE_TAG="$(load_artifact app-image name)"

echo "############################################################################";
echo "IMAGE_TAG=${IMAGE_TAG}"
echo "############################################################################";


if [ -f /config/api-key ]; then
  IBMCLOUD_API_KEY="$(cat /config/api-key)" # pragma: allowlist secret
else
  IBMCLOUD_API_KEY="$(get_env ibmcloud-api-key)" # pragma: allowlist secret
fi

export IBMCLOUD_API_KEY

IBMCLOUD_API=$(get_env ibmcloud-api "https://cloud.ibm.com")
IBMCLOUD_IKS_REGION="$(get_env dev-region | awk -F ":" '{print $NF}')"
IBMCLOUD_IKS_CLUSTER_NAME="$(get_env cluster-name)"

if [[ -f "/config/break_glass" ]]; then
    export KUBECONFIG
    KUBECONFIG=/config/cluster-cert
else
    IBMCLOUD_IKS_REGION=$(echo "${IBMCLOUD_IKS_REGION}" | awk -F ":" '{print $NF}')
    ibmcloud config --check-version false
    retry 5 2 \
        ibmcloud login -r "${IBMCLOUD_IKS_REGION}" -a "$IBMCLOUD_API"

    retry 5 2 \
        ibmcloud ks cluster config --cluster "${IBMCLOUD_IKS_CLUSTER_NAME}"

    ibmcloud ks cluster get --cluster "${IBMCLOUD_IKS_CLUSTER_NAME}" --json > "${IBMCLOUD_IKS_CLUSTER_NAME}.json"
    IBMCLOUD_IKS_CLUSTER_ID=$(jq -r '.id' "${IBMCLOUD_IKS_CLUSTER_NAME}.json")

    echo "steps completed for " ${IBMCLOUD_IKS_CLUSTER_ID}
fi

echo "************* Applying deployment.yaml ****************";
    envsubst < deployment/deployment.yaml | kubectl apply -f -
    if [[ $? -ne 0 ]]; then
        echo "Error applying deployment.yaml"
        exit 1;
    fi
echo

echo "************* Applying service.yaml ****************";
    kubectl apply -f deployment/service.yaml
    if [[ $? -ne 0 ]]; then
        echo echo "Error applying service.yaml"
        exit 1;
    fi
echo

echo "************* fetch app url ****************";
    kubectl get service
    if [[ $? -ne 0 ]]; then
        echo echo "Error applying service.yaml"
        exit 1;
    fi
echo

echo "************* Deployment successful ****************";

