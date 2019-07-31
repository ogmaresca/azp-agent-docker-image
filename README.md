# azp-agent-docker-image
Docker images for Azure Pipeline Agents.

## Goals:
* Create an Azure Pipelines agent docker image with newer packages, primarly `kubectl` and `helm`.
* Include the latest Azure Pipeline `start.sh` script compared to the existing `microsoft/vsts-agents` images.
* Provide environment variables that can be used as [agent demands](https://docs.microsoft.com/en-us/azure/devops/pipelines/process/demands?view=azure-devops&tabs=yaml) in pipelines.

The sizes of individual APT packages are listed in [package-sizes](package-sizes). The results are retrieved by running
``` bash
dpkg-query --show --showformat='${Package;-50}\t${Installed-Size}\n' | sort -k 2 -n
```
inside of the container.

The `start.sh` script comes from [https://docs.microsoft.com/en-us/azure/devops/pipelines/agents/docker?view=azure-devops](https://docs.microsoft.com/en-us/azure/devops/pipelines/agents/docker?view=azure-devops).

## Tags

The Docker images are hosted in the [Docker Hub repository](https://hub.docker.com/r/gmaresca/azure-pipeline-agent) `docker.io/gmaresca/azure-pipeline-agent`.

| Tag                  | Size   | Notes                                                                | Dockerfile                       |
| -------------------- | ------ | -------------------------------------------------------------------- | -------------------------------- |
| ubuntu-18.04-minimal | 207MB  | The bare minimum required to run the agents.                         | [Dockerfile](minimal/Dockerfile) |
| ubuntu-18.04-base    | 1.92GB | The image with all non-language-specific tools and Python installed. | [Dockerfile](base/Dockerfile)    |
| ubuntu-18.04-base    | 2.07GB | The image with dotnet tools installed.                               | [Dockerfile](dotnet/Dockerfile)  |


## Installation

You can find a Helm chart for running the agents in Kubernetes [here](https://github.com/ggmaresca/azp-agent).

## Generic packages

The following packages are installed in the `minimal` image (and every other image):

* ca-certificates
* curl
* git
* jq
* iputils-ping
* libicu60
* libcurl4
* libunwind8
* netcat

The following package are also installed in the `base` image (and every other image besides `minimal`):

* apt-transport-https
* apt-utils
* bc
* build-essential
* bzr
* chrome
* dc
* dnsutils
* ed
* file
* firefox
* ftp
* gawk
* gettext
* gnupg
* go-dep
* gpg
* grep
* iproute2
* less
* locales
* lsb-release
* make
* net-tools
* nmap
* openssh-client
* openssl
* openvpn
* rsync
* ssl-cert
* sudo
* tcpdump
* telnet
* time
* tree
* unrar
* unzip
* wget
* zip

Addition software that are also installed:

* awscli
* az
* docker
* gcloud
* helm
* kubectl
* mongo-client
* mysql-client
* postgresql-client
* powershell
* sqlite3
* xq (XML version of `jq`)
* yq (YAML version of `jq`)

Note: although Docker is installed, the standard version of Docker installed does not work in a containerized environment. You must set the `DOCKER_HOST` environment variable that points to a working Docker instance or mount `/var/run/docker.sock` from the host for Docker to work.

### Environment Variables

All images, besides `minimal`, have the following environment variables:

* aws
* awcli
* az
* azure
* azurecli
* chrome
* docker
* firefox
* gce
* gcloud
* mongo
* mongodb
* mysql
* postgresql
* psql
* powershell
* pwsh
* sqlite
* sqlite3

## Versions

### v1

The `v1` images contain the following versions of packages. If the package is not listed here, it will be the version included in Ubuntu 18.04, or the latest if it comes from a third-party repository.

* Docker: 18.09
* Helm: 1.14.2
* Kubectl: 1.15.1
* Powershell: 6.2.2

## Language Support

### Python

The `base` image has Python installed to install `yq` and `awscli`.

* python2
* python3
* python3-pip

#### Environment Variables

* python
* python2
* python3
* pip
* pip3

### C/C++

* clang
* cpp
* cppcheck
* g++
* gcc

#### Environment Variables

* clang
* c++
* cpp
* g++
* gcc
* gpp

### Java

* ant
* clojure
* gradle
* maven
* openjdk-8-jre
* openjdk-8-jdk
* openjdk-11-jre
* openjdk-11-jdk
* scala

#### Environment Variables

* ant
* clojure
* gradle
* java
* maven
* scala

### C#

* .NET Core SDK 2.1
* .NET Core SDK 2.2
* coverlet.console (`dotnet` tool)
* dotnet-sqldb (`dotnet` tool)
* GitVersion.Tool (`dotnet` tool)
* nbgv (`dotnet` tool)
* nuget

#### Environment Variables

* coverlet
* dotnet
* dotnet-gitversion
* dotnet-sqldb
* dotnet-stryker
* nbgv
* nuget

### Go

Installed version is 1.12.

* golang
* go-dep

#### Environment Variables

* go
* golang

### Javascript/Node

Installed Node version is 8.10.0.

* cjs
* gjs
* nodejs
* npm

#### Environment Variables

* node
* nodejs
* npm

### Ruby

Installed version is 2.5.1.

* gem
* ruby

#### Environment Variables

* gem
* ruby

### Haskell

Installed version is 8.0.2.

* haskell-platform

#### Environment Variables

* ghc
* haskell

## Docker Hub

[View the Docker Hub page.](https://hub.docker.com/r/gmaresca/azure-pipeline-agent)
