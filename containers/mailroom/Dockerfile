FROM golang:latest as build

ARG ORG="nyaruka"
ARG REPO="mailroom"
ARG VERSION="7.4.0"
ARG CGO_ENABLED=0

ENV DEBIAN_FRONTEND=noninteractive
ENV SRC_DIR="/go/src/github.com/${ORG}/${REPO}"

ADD https://github.com/${ORG}/${REPO}/archive/refs/tags/v${VERSION}.tar.gz .

RUN set -ex; \
    mkdir -p $SRC_DIR; \
    tar -zxvf v${VERSION}.tar.gz --strip-components 1 -C $SRC_DIR;

WORKDIR $SRC_DIR

RUN go install -ldflags '-s -w' -trimpath github.com/${ORG}/${REPO}/cmd/${REPO}

FROM gcr.io/distroless/static:nonroot

COPY --from=build /go/bin/mailroom /mailroom

EXPOSE 8080

ENTRYPOINT [ "/mailroom" ]
