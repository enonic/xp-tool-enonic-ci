#!/bin/bash

set -e

declare -A BASE_IMAGES

BASE_IMAGES=(
    ["circleci/buildpack-deps"]=""
#    ["circleci/node"]="-node"
)
DOCKER_REPOSITORY="gbbirkisson/enonic-ci"
XP_DISTRO_VERSIONS="7.0.1 7.1.0"
ENONIC_CLI_VERSION="1.0.12"

function build_and_push() {
    IMG=$2:$3$4
    docker pull $1
    docker build \
    --build-arg ENONIC_CLI_VERSION=$ENONIC_CLI_VERSION \
    --build-arg ENONIC_DISTRO_VERSION=$3 \
    --build-arg BASE_DOCKER_IMAGE=$1 \
    -t $IMG \
    .

    docker push $IMG
}

for BASE in "${!BASE_IMAGES[@]}"
do
    for DISTRO in $XP_DISTRO_VERSIONS
    do
        build_and_push $BASE $DOCKER_REPOSITORY $DISTRO ${BASE_IMAGES[$BASE]}
    done
done



