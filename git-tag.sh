#!/bin/bash

BASE_TAG='ubuntu-18.04'

AZP_AGENT_VERSION=$(cat version) && \
git tag -a version -m $AZP_AGENT_VERSION && \
git tag -a ubuntu_version -m $BASE_TAG && \
echo "Finished tagging version=$AZP_AGENT_VERSION ubuntu_version=$BASE_TAG"
