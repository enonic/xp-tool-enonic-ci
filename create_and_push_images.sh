#!/bin/bash

set -e

DOCKER_REPOSITORY="enonic/enonic-ci"
XP_DISTRO_VERSIONS="7.0.3 7.1.1"
ENONIC_CLI_VERSION="1.0.12"

declare -A BASE_IMAGES
# Here you can add more base images to build. Key in the map is the base
# image tag and the value in the map is the postfix added to the final
# image tag.
BASE_IMAGES=(
    ["circleci/buildpack-deps:stable"]=""
#    ["circleci/node"]="-node"
)

function build_and_push() {
    # Create tag
    IMG=$2:$3$4

    # Pull base image and build our image
    docker pull $1
    docker build \
    --build-arg ENONIC_CLI_VERSION=$ENONIC_CLI_VERSION \
    --build-arg ENONIC_DISTRO_VERSION=$3 \
    --build-arg BASE_DOCKER_IMAGE=$1 \
    -t $IMG \
    .

    # Push the image
    docker push $IMG
}

for BASE in "${!BASE_IMAGES[@]}"
do
    for DISTRO in $XP_DISTRO_VERSIONS
    do
        build_and_push $BASE $DOCKER_REPOSITORY $DISTRO ${BASE_IMAGES[$BASE]}
    done
done