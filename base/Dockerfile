ARG AZP_AGENT_IMAGE_VERSION=v1
ARG DISTRO=ubuntu
ARG DISTRO_VERSION=18.04
ARG DISTRO_FRIENDLY=bionic

ARG DOTNET_CURRENT_VERSION=3.0.100

ARG KUBECTL_VERSION=1.16.2

FROM bitnami/kubectl:${KUBECTL_VERSION} AS kubectl

FROM mcr.microsoft.com/dotnet/core/sdk:${DOTNET_CURRENT_VERSION}-${DISTRO_FRIENDLY} AS dotnet_current_official

FROM gmaresca/azure-pipeline-agent:${DISTRO}-${DISTRO_VERSION}-minimal-${AZP_AGENT_IMAGE_VERSION} AS build

# Install common packages
RUN apt-get update && apt-get install -y --no-install-recommends \
  apt-transport-https \
  apt-utils \
  bc \
  build-essential \
  bzr \
  cron \
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
  uuid \
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

# Powershell utils
FROM chrome AS powershell

ARG POWERSHELL_VERSION=6.2.3

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

ARG DOCKER_VERSION=19.03.4

RUN curl -fsSLO https://download.docker.com/linux/static/stable/x86_64/docker-${DOCKER_VERSION}.tgz && \
  tar zxvf docker-${DOCKER_VERSION}.tgz -C /usr/local/bin && \
  rm docker-${DOCKER_VERSION}.tgz

ENV PATH $PATH:/usr/local/bin/docker

ENV docker /usr/local/bin/docker/docker

# Kubernetes utils
FROM docker AS k8s

ARG HELM_VERSION=2.16.0

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

RUN curl -sL https://packages.microsoft.com/keys/microsoft.asc | \
    gpg --dearmor | \
    sudo tee /etc/apt/trusted.gpg.d/microsoft.asc.gpg > /dev/null && \
    echo "deb [arch=amd64] https://packages.microsoft.com/ubuntu/$(lsb_release -rs)/prod $(lsb_release -cs) main" | \
    sudo tee /etc/apt/sources.list.d/microsoft.list && \
    apt-get update && apt-get install -y --no-install-recommends \
    mongodb-clients \
    mysql-client \
    #postgresql-client-11 \
    postgresql-client-10 \
    mssql-tools \
    sqlite3 && \
    apt-get clean && rm -rf /var/lib/apt/lists/* && rm -rf /etc/apt/sources.list.d/*

ENV mongo /usr/bin/mongo
ENV mongodb /usr/bin/mongo
ENV mysql /usr/bin/mysql
ENV psql /usr/bin/psql
ENV postgresql /usr/bin/psql
ENV sqlcmd /opt/mssql-tools/bin/sqlcmd
ENV sqlite /use/bin/sqlite3
ENV sqlite3 /use/bin/sqlite3
ENV PATH $PATH:/opt/mssql-tools/bin

## Azure CLI
FROM db AS azcli
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

# AZCopy
FROM azcli AS dotnet

# Install .NET dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
  libc6 \
  libgcc1 \
  libgssapi-krb5-2 \
  liblttng-ust0 \
  libssl1.1 \
  libstdc++6 \
  zlib1g

COPY --from=dotnet_current_official /usr/share/dotnet /usr/share/dotnet

ENV DOTNET_ROOT /usr/share/dotnet

RUN ln -s $DOTNET_ROOT/dotnet /usr/bin/dotnet

ENV PATH $PATH:$DOTNET_ROOT

ENV dotnet $DOTNET_ROOT/dotnet

FROM dotnet AS azcopy

RUN curl -fsL https://aka.ms/downloadazcopylinux64 | tar zxvf - -C /usr/local/bin -x azcopy

ENV PATH $PATH:/usr/local/bin/azcopy

ENV azcopy /usr/local/bin/azcopy/azcopy

## GCE CLI
FROM azcopy AS gcecli

RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" | \
    sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && \
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | \
    sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add - && \
    apt-get update && apt-get install -y --no-install-recommends google-cloud-sdk && \
    apt-get clean && rm -rf /var/lib/apt/lists/* && rm -rf /etc/apt/sources.list.d/*

ENV gce /usr/bin/gcloud
ENV gcloud /usr/bin/gcloud

FROM gcecli AS node

RUN apt-get update && apt-get install -y --no-install-recommends \
    cjs \
    gjs \
    nodejs \
    npm \
    yarn

ENV node /usr/bin/nodejs
ENV nodejs /usr/bin/nodejs
ENV npm /usr/bin/npm
ENV yarn /usr/bin/yarn

FROM node AS hostedtoolcache

RUN azcopy --recursive \
  --source https://vstsagenttools.blob.core.windows.net/tools/hostedtoolcache/ubuntu-1804 \
  --destination $AGENT_TOOLSDIRECTORY

RUN ORIGINAL_DIR=$(pwd) && \
  SETUP_SCRIPTS=$(find $AGENT_TOOLSDIRECTORY -name setup.sh) && \
  for SETUP_SCRIPT in $SETUP_SCRIPTS; do chmod +x $SETUP_SCRIPT && cd $(dirname $SETUP_SCRIPT) && ./$(basename $SETUP_SCRIPT); done;

RUN ln -s $AGENT_TOOLSDIRECTORY/Ruby/$(ls $AGENT_TOOLSDIRECTORY/Ruby | sort | tail -1)/x64/bin /usr/local/bin/ruby

ENV bundle /usr/local/bin/ruby/bundle
ENV bundler /usr/local/bin/ruby/bundler
ENV erb /usr/local/bin/ruby/erb
ENV gem /usr/local/bin/ruby/gem
ENV irb /usr/local/bin/ruby/irb
ENV rake /usr/local/bin/ruby/rake
ENV rdoc /usr/local/bin/ruby/rdoc
ENV ri /usr/local/bin/ruby/ri
ENV ruby /usr/local/bin/ruby/ruby
ENV PATH $PATH:/usr/local/bin/ruby

RUN ln -s $AGENT_TOOLSDIRECTORY/Python/$(ls $AGENT_TOOLSDIRECTORY/Python | grep -e ^3. | sort | tail -1)/x64/bin /usr/local/bin/python3

ENV pip /usr/local/bin/python3/pip
ENV pip3 /usr/local/bin/python3/pip3
ENV python /usr/local/bin/python3/python
ENV python3 /usr/local/bin/python3/python3
ENV PATH $PATH:/usr/local/bin/python3

RUN ln -s $AGENT_TOOLSDIRECTORY/Python/$(ls $AGENT_TOOLSDIRECTORY/Python | grep -e ^2. | sort | tail -1)/x64/bin /usr/local/bin/python2

ENV pip2 /usr/local/bin/python2/pip2
ENV python2 /usr/local/bin/python2/python2
ENV PATH $PATH:/usr/local/bin/python2

# Pip3 tools
FROM hostedtoolcache AS python_tools

RUN pip3 install setuptools yq awscli

ENV yq /usr/local/bin/yq
ENV xq /usr/local/bin/xq

ENV aws /usr/local/bin/aws
ENV awscli /usr/local/bin/aws

# Cleanup
FROM python_tools AS final

RUN apt-get clean && rm -rf /var/lib/apt/lists/* && rm -rf /etc/apt/sources.list.d/*
