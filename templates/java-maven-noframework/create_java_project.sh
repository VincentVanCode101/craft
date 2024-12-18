#!/bin/bash

set -e

if [ -z "$1" ]; then
  echo "Usage: $0 <ARTIFACT_ID>"
  exit 1
fi

ARTIFACT_ID=$1
GROUP_ID="com.main"
OUTPUT_DIR="/build-space/$ARTIFACT_ID"
user_id=$(id -u)
GID=$(id -g)

DOCKER_IMAGE_NAME="maven-project-generator"

docker build \
  --build-arg UID=$user_id \
  --build-arg GID=$GID \
  --build-arg GROUP_ID=$GROUP_ID \
  --build-arg ARTIFACT_ID=$ARTIFACT_ID \
  -t $DOCKER_IMAGE_NAME .

docker run --rm \
  -v "$(pwd):/workspace" \
  $DOCKER_IMAGE_NAME \
  /bin/bash -c "cp -p -r /build-space/* /workspace"
