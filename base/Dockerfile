FROM gmaresca/azure-pipeline-agent:ubuntu-18.04-minimal AS build

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
  locales \
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
FROM python AS powershell_download

ENV POWERSHELL_VERSION 6.2.2
RUN curl -LO https://github.com/PowerShell/PowerShell/releases/download/v${POWERSHELL_VERSION}/powershell-${POWERSHELL_VERSION}-linux-x64.tar.gz && \
  mkdir -p /usr/local/powershell && \
  tar -zxvf powershell-${POWERSHELL_VERSION}-linux-x64.tar.gz -C /usr/local/powershell && \
  ln /usr/local/powershell/pwsh /usr/local/powershell/powershell && \
  chmod +x /usr/local/powershell/pwsh && \
  chmod +x /usr/local/powershell/powershell

FROM powershell_download AS powershell

COPY --from=powershell_download /usr/local/powershell /usr/local/powershell

ENV PATH $PATH:/usr/local/powershell

ENV pwsh /usr/bin/pwsh
ENV powershell /usr/bin/powershell

# Docker utils
FROM powershell AS docker_download

ENV DOCKER_VERSION 18.09.8
RUN curl -fsSLO https://download.docker.com/linux/static/stable/x86_64/docker-${DOCKER_VERSION}.tgz && \
  tar zxvf docker-${DOCKER_VERSION}.tgz -C /usr/local

FROM powershell AS docker

COPY --from=docker_download /usr/local/docker /usr/local/docker

ENV PATH $PATH:/usr/local/docker

ENV docker /usr/bin/docker/docker

# Kubernetes utils
FROM docker AS k8s_download

ENV KUBECTL_VERSION 1.15.1
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl && \
  chmod +x ./kubectl && \
  mv ./kubectl /usr/local/bin/kubectl

ENV HELM_VERSION 2.14.2
RUN curl -LO https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz && \
  tar -zxvf helm-v${HELM_VERSION}-linux-amd64.tar.gz && \
  chmod +x ./linux-amd64/helm && \
  mv ./linux-amd64/helm /usr/local/bin/helm

FROM python AS k8s

COPY --from=k8s_download /usr/local/bin/kubectl /usr/local/bin/kubectl
ENV kubectl /usr/local/bin/kubectl
COPY --from=k8s_download /usr/local/bin/helm /usr/local/bin/helm
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
