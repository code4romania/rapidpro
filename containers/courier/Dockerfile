FROM golang:latest as build

ARG ORG="nyaruka"
ARG REPO="courier"
ARG VERSION="7.4.0"
ARG CGO_ENABLED=0

ARG DEBIAN_FRONTEND=noninteractive
ARG SRC_DIR="/go/src/github.com/${ORG}/${REPO}"

WORKDIR $SRC_DIR

RUN set -ex; \
    curl -L https://github.com/${ORG}/${REPO}/archive/refs/tags/v${VERSION}.tar.gz | tar zxv --strip-components 1;

RUN set -ex; \
    go install -ldflags "-s -w -X 'main.version=v${VERSION}'" -trimpath github.com/${ORG}/${REPO}/cmd/${REPO}

FROM gcr.io/distroless/static:nonroot

COPY --from=build /go/bin/courier /courier

EXPOSE 8080

ENTRYPOINT [ "/courier" ]
