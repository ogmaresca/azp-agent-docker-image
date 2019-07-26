FROM ubuntu:18.04 AS base

ENV DEBIAN_FRONTEND noninteractive

# Install some common packages
RUN apt-get update && apt-get install -y --no-install-recommends \
  apt-transport-https \
  apt-utils \
  bc \
  build-essential \
  bzr \
  ca-certificates \
  curl \
  dc \
  dnsutils \
  ed \
  file \
  ftp \
  gawk \
  gettext \
  git \
  gnupg \
  go-dep \
  gpg \
  grep \
  jq \
  iproute2 \
  iputils-ping \
  less \
  locales \
  lsb-release \
  make \
  net-tools \
  netcat \
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

# C/C++ utils
FROM base AS cplusplus

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

# Java/JVM languages utils
FROM cplusplus AS java

RUN apt-get update && apt-get install -y --no-install-recommends \
  ant \
  clojure \
  gradle \
  maven \
  openjdk-8-jre \
  openjdk-8-jdk \
  openjdk-11-jre \
  openjdk-11-jdk \
  scala

ENV ant /usr/bin/ant
ENV clojure /usr/bin/clojure
ENV gradle /usr/bin/gradle
ENV java /usr/bin/java
ENV maven /usr/bin/maven
ENV scala /usr/bin/scala
ENV ANT_HOME=/usr/share/ant
ENV GRADLE_HOME=/usr/share/gradle
ENV M2_HOME=/usr/share/maven
ENV JAVA_HOME=/usr/lib/jvm/openjdk-11

# C#/Powershell utils
FROM java AS dotnet

RUN wget -q https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb && \
  dpkg -i packages-microsoft-prod.deb && rm packages-microsoft-prod.deb && \
  apt-get update && apt-get install -y --no-install-recommends \
    dotnet-host \
    dotnet-runtime-2.1 \
    dotnet-runtime-2.2 \
    dotnet-sdk-2.1 \
    dotnet-sdk-2.2 \
    nuget \
	powershell \
  && apt-get clean && rm -rf /var/lib/apt/lists/* && rm -rf /etc/apt/sources.list.d/*

ENV dotnet /usr/bin/dotnet
ENV nuget /usr/bin/nuget
ENV powershell /usr/bin/pwsh

# Go utils
FROM dotnet AS golang_download

ENV GO_VERSION 1.12.7

RUN curl -LO https://dl.google.com/go/go${GO_VERSION}.linux-amd64.tar.gz
RUN tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz

FROM dotnet AS golang

COPY --from=golang_download /usr/local/go /usr/local/go

ENV PATH $PATH:/usr/local/go/bin

RUN apt-get update && apt-get install -y --no-install-recommends \
  #golang-1.12 \
  go-dep

ENV go /usr/bin/go
ENV golang /usr/bin/go

# Python utils
FROM golang AS python

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

# Javascript utils
FROM python AS js

RUN apt-get update && apt-get install -y --no-install-recommends \
  cjs \
  gjs \
  nodejs \
  npm

ENV node /usr/bin/nodejs
ENV nodejs /usr/bin/nodejs
ENV npm /usr/bin/npm

# Ruby utils
FROM js AS ruby

RUN apt-get update && apt-get install -y --no-install-recommends \
  gem \
  ruby

ENV gem /usr/bin/gem
ENV ruby /usr/bin/ruby

# Haskell utils
FROM ruby AS haskell

RUN apt-get update && apt-get install -y --no-install-recommends \
  haskell-platform

ENV ghc /usr/bin/ghc
ENV haskell /usr/bin/ghc

# Docker utils
FROM haskell AS docker_download

ENV DOCKER_VERSION 18.09.8
RUN curl -fsSLO https://download.docker.com/linux/static/stable/x86_64/docker-${DOCKER_VERSION}.tgz
RUN tar zxvf docker-${DOCKER_VERSION}.tgz -C /usr/local

FROM haskell AS docker

COPY --from=docker_download /usr/local/docker /usr/local/docker

ENV PATH $PATH:/usr/local/docker

ENV docker /usr/bin/docker/docker

# Kubernetes utils
FROM docker AS k8s_download

ENV KUBECTL_VERSION 1.15.1
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl
RUN chmod +x ./kubectl

ENV HELM_VERSION 2.14.2
RUN curl -LO https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz
RUN tar -zxvf helm-v${HELM_VERSION}-linux-amd64.tar.gz
RUN chmod +x ./linux-amd64/helm

FROM docker AS k8s

COPY --from=k8s_download /kubectl /usr/local/bin/kubectl
ENV kubectl /usr/local/bin/kubectl
COPY --from=k8s_download /linux-amd64/helm /usr/local/bin/helm
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

WORKDIR /azp

COPY start.sh /azp/start.sh

RUN chmod +x /azp/start.sh

CMD ["/azp/start.sh"]
