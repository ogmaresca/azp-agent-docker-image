#!/bin/bash

BUILD_ARGS=()

BUILD_PROPERTIES_FILE='build.properties'

if [ ! -f "$BUILD_PROPERTIES_FILE" ]
then
	echo "Properties file $BUILD_PROPERTIES_FILE was not found" 1>&2
	exit 1
fi

DISTRO=''
DISTRO_VERSION=''

while IFS='=' read -r KEY VALUE
do
	if [ ! -z "$KEY" ] && [ ! -z "${KEY:0:1}" ] && [ "${KEY:0:1}" != "#" ]
	then
		if [ "$KEY" == "AZP_AGENT_IMAGE_VERSION" ]; then
			BUILD_ARGS+=('--build-arg' "${KEY}=dev")
		else
			BUILD_ARGS+=('--build-arg' "${KEY}=$VALUE")
		fi

		if [ "$KEY" == 'DISTRO' ]; then
			DISTRO=$VALUE
		elif [ "$KEY" == 'DISTRO_VERSION' ]; then
			DISTRO_VERSION=$VALUE
		fi
	fi
done < $BUILD_PROPERTIES_FILE

echo 'Build args:' ${BUILD_ARGS[@]}

FIRST_ARG=$1

TAG_VERSIONS=(
	minimal
	base
	dotnet
	java
)

BUILD_IMAGE='gmaresca/azure-pipeline-agent'

#
# Docker build
#

for IMAGE_TAG in ${TAG_VERSIONS[@]}
do
	FULL_IMAGE_TAG="${DISTRO}-${DISTRO_VERSION}-${IMAGE_TAG}"
	
	if [ -z "$FIRST_ARG" ] || [ "$FIRST_ARG" == "$IMAGE_TAG" ]
	then
		echo "Building ${BUILD_IMAGE}:${FULL_IMAGE_TAG}-dev"

		docker build -t "${BUILD_IMAGE}:${FULL_IMAGE_TAG}-dev" -f "${IMAGE_TAG}/Dockerfile" ${BUILD_ARGS[@]} .

		if [ $? -ne 0 ]
		then
			exit $?
		fi

		echo "Finished building ${BUILD_IMAGE}:$FULL_IMAGE_TAG"
	else
		echo "Not building ${BUILD_IMAGE}:$FULL_IMAGE_TAG - only building $FIRST_ARG"
	fi
done


if [ "$FIRST_ARG" == "standard" ]
then

	echo "Building standard - inheritance: dotnet, java, standard"

	docker build -t "${BUILD_IMAGE}:${DISTRO}-${DISTRO_VERSION}-dotnet-dev" -f "dotnet/Dockerfile" --build-arg AZP_AGENT_BASE_IMAGE=base ${BUILD_ARGS[@]} .

	if [ $? -ne 0 ]
	then
		exit $?
	fi

	docker build -t "${BUILD_IMAGE}:${DISTRO}-${DISTRO_VERSION}-java-dev" -f "java/Dockerfile" --build-arg AZP_AGENT_BASE_IMAGE=dotnet ${BUILD_ARGS[@]} .

	if [ $? -ne 0 ]
	then
		exit $?
	fi

	docker build -t "${BUILD_IMAGE}:${DISTRO}-${DISTRO_VERSION}-standard-dev" -f "standard/Dockerfile" --build-arg AZP_AGENT_BASE_IMAGE=java ${BUILD_ARGS[@]} .

	if [ $? -ne 0 ]
	then
		exit $?
	fi

	echo "Finished building standard"

fi
