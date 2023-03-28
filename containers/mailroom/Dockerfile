FROM golang:latest as build

ARG ORG="nyaruka"
ARG REPO="mailroom"
ARG VERSION="7.4.0"
ARG CGO_ENABLED=0

ARG DEBIAN_FRONTEND=noninteractive
ARG SRC_DIR="/go/src/github.com/${ORG}/${REPO}"

ADD https://github.com/${ORG}/${REPO}/archive/refs/tags/v${VERSION}.tar.gz .

RUN set -ex; \
    mkdir -p $SRC_DIR; \
    curl -L https://github.com/${ORG}/${REPO}/archive/refs/tags/v${VERSION}.tar.gz | tar zxv --strip-components 1 -C $SRC_DIR

# Monkeypatch the docs path
RUN sed -i 's/http.Dir("docs")/http.Dir("\/docs")/' "${SRC_DIR}/web/docs/docs.go"

WORKDIR $SRC_DIR

RUN set -ex; \
    GOFLOW_VERSION=$(grep goflow go.mod | cut -d" " -f2 | cut -c2-); \
    curl -L https://github.com/nyaruka/goflow/releases/download/v${GOFLOW_VERSION}/docs.tar.gz | tar zxv -C $SRC_DIR

RUN go install -ldflags '-s -w' -trimpath github.com/${ORG}/${REPO}/cmd/${REPO}

FROM gcr.io/distroless/static:nonroot

COPY --from=build /go/bin/mailroom /mailroom
COPY --from=build /go/src/github.com/nyaruka/mailroom/docs /docs

EXPOSE 8090

ENTRYPOINT [ "/mailroom" ]
