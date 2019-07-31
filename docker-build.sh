#!/bin/bash

FIRST_ARG=$1

BASE_TAG='ubuntu-18.04'

TAG_VERSIONS=(
	minimal
	base
)

for IMAGE_TAG in ${TAG_VERSIONS[@]}
do
	FULL_IMAGE_TAG="${BASE_TAG}-${IMAGE_TAG}"
	
	if [ -z "$FIRST_ARG" ] || [ "$FIRST_ARG" -eq "$IMAGE_TAG" ]
	then
		docker build -t "docker.io/gmaresca/azure-pipeline-agent:$FULL_IMAGE_TAG" -f "${IMAGE_TAG}/Dockerfile" .

		if [ $? -ne 0 ]
		then
			exit $?
		fi

		docker tag "docker.io/gmaresca/azure-pipeline-agent:$FULL_IMAGE_TAG" "docker.io/gmaresca/azure-pipeline-agent:${FULL_IMAGE_TAG}-dev"
	else
		echo "Not building docker.io/gmaresca/azure-pipeline-agent:$FULL_IMAGE_TAG - only building $FIRST_ARG"
	fi
done
