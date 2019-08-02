ARG AZP_AGENT_IMAGE_VERSION=v1
ARG AZP_AGENT_BASE_IMAGE=base

ARG DISTRO=ubuntu
ARG DISTRO_VERSION=18.04
ARG DISTRO_FRIENDLY=bionic

ARG GO_VERSION=1.12.7

FROM docker.io/golang:${GO_VERSION} AS golang_official

FROM gmaresca/azure-pipeline-agent:${DISTRO}-${DISTRO_VERSION}-${AZP_AGENT_BASE_IMAGE}-${AZP_AGENT_IMAGE_VERSION} AS golang

COPY --from=golang_official /usr/local/go /usr/local/go

ENV GOPATH /go
ENV PATH $PATH:/usr/local/go/bin:$GOPATH/bin

ENV go /usr/bin/go
ENV golang /usr/bin/go

RUN mkdir -p $GOPATH/bin && mkdir -p $GOPATH/pkg && mkdir -p $GOPATH/src

FROM golang AS godep

RUN apt-get update && apt-get install -y --no-install-recommends \
  go-dep

FROM godep AS gotools

RUN go get -u golang.org/x/lint/golint

# Cleanup
FROM gotools AS final
RUN apt-get clean && rm -rf /var/lib/apt/lists/* && rm -rf /etc/apt/sources.list.d/*

