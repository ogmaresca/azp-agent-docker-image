#!/bin/bash

FIRST_ARG=$1

BASE_TAG='ubuntu-18.04'

TAG_VERSIONS=(
	minimal
	base
	dotnet
)

AZP_AGENT_VERSION=$(cat version)

if [ -z "$AZP_AGENT_VERSION" ]
then
	exit 1
fi

BUILD_IMAGE='gmaresca/azure-pipeline-agent'

for IMAGE_TAG in ${TAG_VERSIONS[@]}
do
	DEV_IMAGE_TAG="${BASE_TAG}-${IMAGE_TAG}-dev"
	FULL_IMAGE_TAG="${BASE_TAG}-${IMAGE_TAG}-${AZP_AGENT_VERSION}"
	SHORT_IMAGE_TAG="${BASE_TAG}-${IMAGE_TAG}"
	SHORTEST_IMAGE_TAG="${BASE_TAG%%-*}-${IMAGE_TAG}"
	
	if [ -z "$FIRST_ARG" ] || [ "$FIRST_ARG" -eq "$IMAGE_TAG" ]
	then
		TAGS_TO_UPLOAD=(
			$FULL_IMAGE_TAG
			$SHORT_IMAGE_TAG
			$SHORTEST_IMAGE_TAG
		)

		if [ "$IMAGE_TAG" == "standard" ]
		then
			TAGS_TO_UPLOAD+=(
				${BASE_TAG}
				${BASE_TAG%%-*}
				latest
			)
		fi

		echo "Uploading azp-agent: [${TAGS_TO_UPLOAD[@]}]"

		for TAG_TO_UPLOAD in ${TAGS_TO_UPLOAD[@]}
		do
			docker tag "${BUILD_IMAGE}:${DEV_IMAGE_TAG}" "docker.io/${BUILD_IMAGE}:${TAG_TO_UPLOAD}"

			if [ $? -ne 0 ]
			then
				exit $?
			fi
		done

		for TAG_TO_UPLOAD in ${TAGS_TO_UPLOAD[@]}
		do
			docker push "docker.io/${BUILD_IMAGE}:${TAG_TO_UPLOAD}"

			if [ $? -ne 0 ]
			then
				exit $?
			fi
		done

		for TAG_TO_UPLOAD in ${TAGS_TO_UPLOAD[@]}
		do
			if [ "$TAG_TO_UPLOAD" != "$SHORT_IMAGE_TAG" ]
			then
				docker rmi "docker.io/${BUILD_IMAGE}:${TAG_TO_UPLOAD}"

				if [ $? -ne 0 ]
				then
					exit $?
				fi
			fi
		done

		echo "Finished uploading azp-agent: [${TAGS_TO_UPLOAD[@]}]"
	else
		echo "Not pushing ${BUILD_IMAGE}:$FULL_IMAGE_TAG - only pushing $FIRST_ARG"
	fi
done
