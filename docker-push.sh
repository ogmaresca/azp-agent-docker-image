#!/bin/bash

AZP_AGENT_VERSION=$(cat version) && \
AZP_AGENT_VERSION_SHORT=${AZP_AGENT_VERSION%%-v*} && \
AZP_AGENT_VERSION_SHORTEST=${AZP_AGENT_VERSION_SHORT%%-*} && \
echo "Uploading azp-agent $AZP_AGENT_VERSION" && \
docker tag azp-agent:dev docker.io/gmaresca/azure-pipeline-agent:$AZP_AGENT_VERSION && \
docker tag azp-agent:dev docker.io/gmaresca/azure-pipeline-agent:$AZP_AGENT_VERSION_SHORT && \
docker tag azp-agent:dev docker.io/gmaresca/azure-pipeline-agent:$AZP_AGENT_VERSION_SHORTEST && \
docker tag azp-agent:dev docker.io/gmaresca/azure-pipeline-agent:latest && \
docker push docker.io/gmaresca/azure-pipeline-agent:$AZP_AGENT_VERSION && \
docker push docker.io/gmaresca/azure-pipeline-agent:$AZP_AGENT_VERSION_SHORT && \
docker push docker.io/gmaresca/azure-pipeline-agent:$AZP_AGENT_VERSION_SHORTEST && \
docker push docker.io/gmaresca/azure-pipeline-agent:latest && \
docker rmi docker.io/gmaresca/azure-pipeline-agent:$AZP_AGENT_VERSION && \
docker rmi docker.io/gmaresca/azure-pipeline-agent:$AZP_AGENT_VERSION_SHORT && \
docker rmi docker.io/gmaresca/azure-pipeline-agent:$AZP_AGENT_VERSION_SHORTEST && \
docker rmi docker.io/gmaresca/azure-pipeline-agent:latest && \
echo "Finished uploading azp-agent: [${AZP_AGENT_VERSION}, ${AZP_AGENT_VERSION_SHORT}, ${AZP_AGENT_VERSION_SHORTEST}, latest]"
