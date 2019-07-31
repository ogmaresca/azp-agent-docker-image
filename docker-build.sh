#!/bin/bash

FIRST_ARG=$1

BASE_TAG='ubuntu-18.04'

DISTRO_FRIENDLY_NAME='bionic'

TAG_VERSIONS=(
	minimal
	base
	dotnet
)

BUILD_IMAGE='gmaresca/azure-pipeline-agent'

for IMAGE_TAG in ${TAG_VERSIONS[@]}
do
	FULL_IMAGE_TAG="${BASE_TAG}-${IMAGE_TAG}"
	
	if [ -z "$FIRST_ARG" ] || [ "$FIRST_ARG" -eq "$IMAGE_TAG" ]
	then
		echo "Building ${BUILD_IMAGE}:${FULL_IMAGE_TAG}-dev"

		docker build -t "${BUILD_IMAGE}:${FULL_IMAGE_TAG}-dev" -f "${IMAGE_TAG}/Dockerfile" --build-arg DISTRO=${BASE_TAG%%-*} --build-arg DISTRO_FRIENDLY=$DISTRO_FRIENDLY_NAME --build-arg DISTRO_VERSION=${BASE_TAG##*-} .

		if [ $? -ne 0 ]
		then
			exit $?
		fi

		docker tag "${BUILD_IMAGE}:${FULL_IMAGE_TAG}-dev" "${BUILD_IMAGE}:${FULL_IMAGE_TAG}"

		if [ $? -ne 0 ]
		then
			exit $?
		fi

		echo "Finished building ${BUILD_IMAGE}:$FULL_IMAGE_TAG"
	else
		echo "Not building ${BUILD_IMAGE}:$FULL_IMAGE_TAG - only building $FIRST_ARG"
	fi
done
