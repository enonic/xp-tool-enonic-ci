#!/bin/bash

set -ex

DOCKER_REPOSITORY="enonic/enonic-ci"
ENONIC_CLI_VERSION="1.0.12"
XP_DISTRO_VERSIONS=( # Only use 1 of each minor version
    '7.0.3'
    '7.1.1'
)

# Here you can add more base images to build. Key in the map is the base
# image tag and the value in the map is the postfix added to the final
# image tag.
BASE_IMAGES=(
    'circleci/buildpack-deps:stable::'
#    'circleci/node::-node'
)

function build_and_push() {
    # Create tag
    IMG=$2:$(echo $3 | awk -F"." '{print $1"."$2}')$4

    # Build our image
    docker build \
    --no-cache \
    --pull \
    --build-arg ENONIC_CLI_VERSION=$ENONIC_CLI_VERSION \
    --build-arg ENONIC_DISTRO_VERSION=$3 \
    --build-arg BASE_DOCKER_IMAGE=$1 \
    -t $IMG \
    .

    # Push the image
    docker push $IMG
}

for BASE in "${BASE_IMAGES[@]}"
do
    for DISTRO in "${XP_DISTRO_VERSIONS[@]}"
    do
        build_and_push ${BASE%%::*} $DOCKER_REPOSITORY $DISTRO ${BASE##*::}
    done
done
