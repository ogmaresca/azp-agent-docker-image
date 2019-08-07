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

TAG_VERSIONS=(minimal base dotnet java go cpp haskell)

BUILD_IMAGE='gmaresca/azure-pipeline-agent'

#
# Docker build
#

for IMAGE_TAG in ${TAG_VERSIONS[@]}
do
	FULL_IMAGE_TAG="${DISTRO}-${DISTRO_VERSION}-${IMAGE_TAG}"
	
	if [ -z "$FIRST_ARG" ] || [ "$FIRST_ARG" == "$IMAGE_TAG" ] || [ "$FIRST_ARG" == "all" ] || [ "$FIRST_ARG" == "langs" ]
	then
		echo "Building ${BUILD_IMAGE}:${FULL_IMAGE_TAG}-dev"

		if [ -z "$DRY_RUN" ]; then docker build -t "${BUILD_IMAGE}:${FULL_IMAGE_TAG}-dev" -f "${IMAGE_TAG}/Dockerfile" ${BUILD_ARGS[@]} .; fi

		if [ $? -ne 0 ]
		then
			exit $?
		fi

		echo "Finished building ${BUILD_IMAGE}:$FULL_IMAGE_TAG"
	else
		echo "Not building ${BUILD_IMAGE}:$FULL_IMAGE_TAG - only building $FIRST_ARG"
	fi
done

if [ "$FIRST_ARG" == "permutations" ] || [ "$FIRST_ARG" == "all" ]
then
	for (( ITERATOR = 2; ITERATOR < ${#TAG_VERSIONS[@]}; ITERATOR++ ))
	do
		BASE_TAG_VERSION=${TAG_VERSIONS[$ITERATOR]}
		for (( INNER_ITERATOR = $ITERATOR + 1; INNER_ITERATOR < ${#TAG_VERSIONS[@]}; INNER_ITERATOR++ ))
		do
			CURRENT_IMAGE_TAG_VERSION=${TAG_VERSIONS[$INNER_ITERATOR]}
			FULL_IMAGE_TAG="${DISTRO}-${DISTRO_VERSION}-${BASE_TAG_VERSION}-${CURRENT_IMAGE_TAG_VERSION}"

			echo "Building ${BUILD_IMAGE}:${FULL_IMAGE_TAG}-dev"

			if [ -z "$DRY_RUN" ]; then docker build -t "${BUILD_IMAGE}:${FULL_IMAGE_TAG}-dev" -f "${CURRENT_IMAGE_TAG_VERSION}/Dockerfile" --build-arg AZP_AGENT_BASE_IMAGE=$BASE_TAG_VERSION ${BUILD_ARGS[@]} .; fi

			if [ $? -ne 0 ]
			then
				exit $?
			fi

			echo "Finished building ${BUILD_IMAGE}:$FULL_IMAGE_TAG"

			BASE_TAG_VERSION+="-$CURRENT_IMAGE_TAG_VERSION"
		done
	done
fi

if [ "$FIRST_ARG" == "standard" ] || [ "$FIRST_ARG" == "all" ]
then
	STANDARD_TAGS=()
	for (( ITERATOR = 2; ITERATOR <= ${#TAG_VERSIONS[@]} - 1; ITERATOR++ ))
	do
		STANDARD_TAGS+=(${TAG_VERSIONS[$ITERATOR]})
	done

	STANDARD_TAGS_STR=${STANDARD_TAGS[@]}
	STANDARD_TAGS_STR=${STANDARD_TAGS_STR// /-}

	echo "Using tag $STANDARD_TAGS_STR as base for standard"

	if [ -z "$DRY_RUN" ]; then docker tag "${BUILD_IMAGE}:${DISTRO}-${DISTRO_VERSION}-${STANDARD_TAGS_STR}-dev" "${BUILD_IMAGE}:${DISTRO}-${DISTRO_VERSION}-${FIRST_ARG}-dev"; fi

	if [ $? -ne 0 ]
	then
		exit $?
	fi

	echo "Finished building standard"

fi
