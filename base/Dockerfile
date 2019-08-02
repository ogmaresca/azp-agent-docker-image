ARG AZP_AGENT_IMAGE_VERSION=v1
ARG DISTRO=ubuntu
ARG DISTRO_VERSION=18.04
ARG DISTRO_FRIENDLY=bionic

ARG POWERSHELL_VERSION=6.2.2
ARG DOCKER_VERSION=19.03.1
ARG KUBECTL_VERSION=1.15.1
ARG HELM_VERSION=2.14.2

FROM bitnami/kubectl:${KUBECTL_VERSION} AS kubectl

FROM gmaresca/azure-pipeline-agent:${DISTRO}-${DISTRO_VERSION}-minimal-${AZP_AGENT_IMAGE_VERSION} AS build

# Install common packages
RUN apt-get update && apt-get install -y --no-install-recommends \
  apt-transport-https \
  apt-utils \
  bc \
  build-essential \
  bzr \
  dc \
  dnsutils \
  ed \
  file \
  firefox \
  ftp \
  gawk \
  gettext \
  gnupg \
  go-dep \
  gpg \
  grep \
  iproute2 \
  less \
  lsb-release \
  make \
  net-tools \
  nmap \
  openssh-client \
  openssl \
  openvpn \
  rsync \
  ssl-cert \
  sudo \
  tcpdump \
  telnet \
  time \
  tree \
  unrar \
  unzip \
  wget \
  zip

# Install Chrome
FROM build AS chrome

RUN sudo apt-get update && sudo apt-get install -y --no-install-recommends \
    libappindicator3-1 \
    libasound2 \
    libnspr4 \
    libnss3 \
    libxss1 \
    libxtst6 \
    fonts-liberation \
    xdg-utils && \
  wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
  sudo dpkg -i google-chrome-stable_current_amd64.deb && \
  rm google-chrome-stable_current_amd64.deb

ENV chrome /usr/bin/chrome

# Python utils
FROM chrome AS python

RUN apt-get update && apt-get install -y --no-install-recommends \
  #python2 \
  python \
  python3 \
  python3-pip

ENV python /usr/bin/python3
ENV python2 /usr/bin/python2
ENV python2 /usr/bin/python3
ENV pip /usr/bin/pip3
ENV pip3 /usr/bin/pip3

RUN python3 -m pip install \
  setuptools

RUN python3 -m pip install \
  yq

# Powershell utils
FROM python AS powershell

ARG POWERSHELL_VERSION=6.2.2

RUN curl -LO https://github.com/PowerShell/PowerShell/releases/download/v${POWERSHELL_VERSION}/powershell-${POWERSHELL_VERSION}-linux-x64.tar.gz && \
  mkdir -p /usr/local/bin/powershell && \
  tar -zxvf powershell-${POWERSHELL_VERSION}-linux-x64.tar.gz -C /usr/local/bin/powershell && \
  chmod +x /usr/local/bin/powershell/pwsh && \
  ln -s /usr/local/bin/powershell/pwsh /usr/local/bin/powershell/powershell && \
  rm powershell-${POWERSHELL_VERSION}-linux-x64.tar.gz

ENV PATH $PATH:/usr/local/bin/powershell

ENV pwsh /usr/local/bin/powershell/pwsh
ENV powershell /usr/local/bin/powershell/powershell

# Docker utils
FROM powershell AS docker

ARG DOCKER_VERSION=19.03.1

RUN curl -fsSLO https://download.docker.com/linux/static/stable/x86_64/docker-${DOCKER_VERSION}.tgz && \
  tar zxvf docker-${DOCKER_VERSION}.tgz -C /usr/local/bin && \
  rm docker-${DOCKER_VERSION}.tgz

ENV PATH $PATH:/usr/local/bin/docker

ENV docker /usr/local/bin/docker/docker

# Kubernetes utils
FROM docker AS k8s

ARG HELM_VERSION=2.14.2

COPY --from=kubectl /opt/bitnami/kubectl/bin/kubectl /usr/local/bin/kubectl
ENV kubectl /usr/local/bin/kubectl

RUN curl -LO https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz && \
  tar -zxvf helm-v${HELM_VERSION}-linux-amd64.tar.gz && \
  chmod +x ./linux-amd64/helm && \
  mv ./linux-amd64/helm /usr/local/bin/helm && \
  rm -rf ./linux-amd64
ENV helm /usr/local/bin/helm

# Database utils
FROM k8s AS db

RUN apt-get update && apt-get install -y --no-install-recommends \
  mongodb-clients \
  mysql-client \
  #postgresql-client-11 \
  postgresql-client-10 \
  sqlite3

ENV mongo /usr/bin/mongo
ENV mongodb /usr/bin/mongo
ENV mysql /usr/bin/mysql
ENV psql /usr/bin/psql
ENV postgresql /usr/bin/psql
ENV sqlite /use/bin/sqlite3
ENV sqlite3 /use/bin/sqlite3

# Cloud provider utils
## AWS CLI
FROM db AS awscli
RUN python3 -m pip install \
  awscli

ENV aws /usr/local/bin/aws
ENV awscli /usr/local/bin/aws

## Azure CLI
FROM awscli AS azcli
RUN curl -sL https://packages.microsoft.com/keys/microsoft.asc | \
    gpg --dearmor | \
    sudo tee /etc/apt/trusted.gpg.d/microsoft.asc.gpg > /dev/null && \
    echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $(lsb_release -cs) main" | \
    sudo tee /etc/apt/sources.list.d/azure-cli.list && \
    apt-get update && apt-get install -y --no-install-recommends azure-cli && \
    apt-get clean && rm -rf /var/lib/apt/lists/* && rm -rf /etc/apt/sources.list.d/*

ENV az /usr/bin/az
ENV azure /usr/bin/az
ENV azurecli /usr/bin/az

## GCE CLI
FROM azcli AS gcecli
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" | \
    sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && \
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | \
    sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add - && \
    apt-get update && apt-get install -y --no-install-recommends google-cloud-sdk && \
    apt-get clean && rm -rf /var/lib/apt/lists/* && rm -rf /etc/apt/sources.list.d/*

ENV gce /usr/bin/gcloud
ENV gcloud /usr/bin/gcloud

# Cleanup
FROM gcecli AS final
RUN apt-get clean && rm -rf /var/lib/apt/lists/* && rm -rf /etc/apt/sources.list.d/*
