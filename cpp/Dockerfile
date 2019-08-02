ARG AZP_AGENT_IMAGE_VERSION=v1
ARG AZP_AGENT_BASE_IMAGE=base

ARG DISTRO=ubuntu
ARG DISTRO_VERSION=18.04
ARG DISTRO_FRIENDLY=bionic

FROM gmaresca/azure-pipeline-agent:${DISTRO}-${DISTRO_VERSION}-${AZP_AGENT_BASE_IMAGE}-${AZP_AGENT_IMAGE_VERSION} AS cpp

RUN apt-get update && apt-get install -y --no-install-recommends \
  clang \
  cpp \
  cppcheck \
  g++ \
  gcc

ENV clang /usr/bin/clang
ENV c++ /usr/bin/cpp
ENV cpp /usr/bin/cpp
ENV g++ /usr/bin/g++
ENV gpp /usr/bin/g++
ENV gcc /usr/bin/gcc

# Cleanup
FROM cpp AS final
RUN apt-get clean && rm -rf /var/lib/apt/lists/* && rm -rf /etc/apt/sources.list.d/*

