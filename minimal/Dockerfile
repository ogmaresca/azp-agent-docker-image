ARG DISTRO=ubuntu
ARG DISTRO_VERSION=18.04
ARG DISTRO_FRIENDLY=bionic
FROM ${DISTRO}:${DISTRO_VERSION} AS build

# Remove need for adding -y to apt-get install commads
ENV DEBIAN_FRONTEND noninteractive
RUN echo "APT::Get::Assume-Yes \"true\";" > /etc/apt/apt.conf.d/90assumeyes

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
  netcat

# Cleanup
FROM build AS clean
RUN apt-get clean && rm -rf /var/lib/apt/lists/* && rm -rf /etc/apt/sources.list.d/*

FROM clean AS final

WORKDIR /azp

# Default workspace path to /workspace
ENV AZP_WORK /workspace

COPY start.sh /azp/start.sh

RUN chmod +x /azp/start.sh

CMD ["/azp/start.sh"]
