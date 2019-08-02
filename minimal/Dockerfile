ARG DISTRO=ubuntu
ARG DISTRO_VERSION=18.04
ARG DISTRO_FRIENDLY=bionic

ARG SYSTEM_LANG=en_US.UTF-8
ARG SYSTEM_LANGUAGE=en_US:en

FROM ${DISTRO}:${DISTRO_VERSION} AS build

# Remove need for adding -y to apt-get install commads
ENV DEBIAN_FRONTEND noninteractive
RUN echo "APT::Get::Assume-Yes \"true\";" > /etc/apt/apt.conf.d/90assumeyes

ENV AGENT_TOOLSDIRECTORY=/opt/hostedtoolcache
RUN mkdir $AGENT_TOOLSDIRECTORY

ENV ACCEPT_EULA Y

# Install some common packages
RUN apt-get update && apt-get install -y --no-install-recommends \
  ca-certificates \
  curl \
  git \
  jq \
  iputils-ping \
  libicu60 \
  libcurl4 \
  libunwind8 \
  locales \
  netcat

FROM build AS language

ARG SYSTEM_LANG=en_US.UTF-8
ARG SYSTEM_LANGUAGE=en_US:en

ENV LANG $SYSTEM_LANG
ENV LC_ALL $SYSTEM_LANG
ENV LANGUAGE $SYSTEM_LANGUAGE

RUN locale-gen $SYSTEM_LANG && update-locale LANG=$SYSTEM_LANG

# Cleanup
FROM language AS clean
RUN apt-get clean && rm -rf /var/lib/apt/lists/* && rm -rf /etc/apt/sources.list.d/*

FROM clean AS final

WORKDIR /azp

# Default workspace path to /workspace
ENV AZP_WORK /workspace

COPY start.sh /azp/start.sh

RUN chmod +x /azp/start.sh

CMD ["/azp/start.sh"]
