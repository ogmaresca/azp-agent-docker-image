ARG AZP_AGENT_IMAGE_VERSION=v1
ARG AZP_AGENT_BASE_IMAGE=base

ARG DISTRO=ubuntu
ARG DISTRO_VERSION=18.04
ARG DISTRO_FRIENDLY=bionic

FROM gmaresca/azure-pipeline-agent:${DISTRO}-${DISTRO_VERSION}-${AZP_AGENT_BASE_IMAGE}-${AZP_AGENT_IMAGE_VERSION} AS haskell

RUN apt-get update && apt-get install -y --no-install-recommends \
  haskell-platform

ENV ghc /usr/bin/ghc
ENV haskell /usr/bin/ghc

# Cleanup
FROM haskell AS final
RUN apt-get clean && rm -rf /var/lib/apt/lists/* && rm -rf /etc/apt/sources.list.d/*

