#!/usr/bin/env bash

set -euo pipefail

# shellcheck disable=SC2086
docker build $DOCKER_BUILD_ARGS .
docker push "${IMAGE}"
