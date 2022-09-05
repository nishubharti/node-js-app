#!/usr/bin/env bash

set -euo pipefail

# shellcheck disable=SC2086
docker build $DOCKER_BUILD_ARGS .
docker run -it --memory="1g" --memory-swap="2g" "${IMAGE}"
docker push "${IMAGE}"

DIGEST="$(docker inspect --format='{{index .RepoDigests 0}}' "${IMAGE}" | awk -F@ '{print $2}')"

#
# Save the artifact to the pipeline, 
# so it can be scanned and signed later
#
save_artifact app-image \
    type=image \
    "name=${IMAGE}" \
    "digest=${DIGEST}" \
    "tags=${IMAGE_TAG}"

url="$(load_repo app-repo url)"
sha="$(load_repo app-repo commit)"

save_artifact app-image \
"source=${url}.git#${sha}"
