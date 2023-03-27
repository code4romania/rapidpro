FROM golang:latest as build

ARG ORG="nyaruka"
ARG REPO="rp-archiver"
ARG VERSION="7.4.0"
ARG CGO_ENABLED=0

ENV DEBIAN_FRONTEND=noninteractive
ENV SRC_DIR="/go/src/github.com/${ORG}/${REPO}"

ADD https://github.com/${ORG}/${REPO}/archive/refs/tags/v${VERSION}.tar.gz .

RUN set -ex; \
    apt-get update -y; \
    apt-get install -y --no-install-recommends ca-certificates wget tzdata; \
    update-ca-certificates --fresh; \
    #
    mkdir -p $SRC_DIR; \
    tar -zxvf v${VERSION}.tar.gz --strip-components 1 -C $SRC_DIR;

WORKDIR $SRC_DIR

RUN go install -ldflags '-s -w' -trimpath github.com/${ORG}/${REPO}/cmd/${REPO}

FROM scratch

COPY --from=build /go/bin/rp-archiver /archiver

EXPOSE 8080

ENTRYPOINT "[ "/archiver" ]"
