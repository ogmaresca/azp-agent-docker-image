# azp-agent-docker-image
Docker images for Azure Pipeline Agents.

#### Goals:
* Create an Azure Pipelines agent docker image with newer packages, primarly `kubectl` and `helm`.
* Include the latest Azure Pipeline `start.sh` script compared to the existing `microsoft/vsts-agents` images.
* Provide environment variables that can be used as [agent demands](https://docs.microsoft.com/en-us/azure/devops/pipelines/process/demands?view=azure-devops&tabs=yaml) in pipelines.

Current image size: 6.16GB. The sizes of individual APT packages are listed in [package-sizes](package-sizes). The results are retrieved by running
``` bash
dpkg-query --show --showformat='${Package;-50}\t${Installed-Size}\n' | sort -k 2 -n
```
inside of the container.

The `start.sh` script comes from [https://docs.microsoft.com/en-us/azure/devops/pipelines/agents/docker?view=azure-devops](https://docs.microsoft.com/en-us/azure/devops/pipelines/agents/docker?view=azure-devops).

## Installation

You can find a Helm chart for running the agents in Kubernetes [here](https://github.com/ggmaresca/azp-agent).

## Generic packages

The following packages are installed:

* apt-transport-https
* apt-utils
* bc
* build-essential
* bzr
* ca-certificates
* curl
* dc
* dnsutils
* ed
* file
* ftp
* gawk
* gettext
* git
* gnupg
* go-dep
* gpg
* grep
* jq
* iproute2
* iputils-ping
* less
* libcurl3
* libicu55
* locales
* lsb-release
* make
* net-tools
* netcat
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

Addition software are installed:

* awscli
* az
* docker 18.09
* gcloud
* helm 1.14.2
* kubectl 1.15.1
* mongo-client
* mysql-client
* postgresql-client
* powershell
* sqlite3
* xq (XML version of `jq`)
* yq (YAML version of `jq`)

Note: although Docker is installed, the standard version of Docker installed does not work in a containerized environment. You must set the `DOCKER_HOST` environment variable that points to a working Docker instance or mount `/var/run/docker.sock` from the host for Docker to work.

#### Environment Variables

* aws
* awcli
* az
* azure
* azurecli
* gce
* gcloud
* mongo
* mongodb
* mysql
* postgresql
* psql
* powershell
* sqlite
* sqlite3

## Language Support

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

* dotnet-host
* dotnet-runtime-2.1
* dotnet-runtime-2.2
* dotnet-sdk-2.1
* dotnet-sdk-2.2
* nuget

#### Environment Variables

* dotnet
* nuget

### Go

Installed version is 1.12.

* golang
* go-dep

#### Environment Variables

* go
* golang

### Python

Python 2 version is 2.7.15.
Python 3 version is 3.6.8.

* python2
* python3
* python3-pip

#### Environment Variables

* python
* python2
* python3
* pip
* pip3

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
