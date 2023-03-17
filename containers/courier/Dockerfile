FROM ubuntu:22.10

ARG COURIER_ORG="nyaruka"
ARG COURIER_REPO="courier"
ARG COURIER_VERSION="7.4.0"

ENV IS_CONTAINERIZED=True
ENV DEBIAN_FRONTEND=noninteractive

RUN set -ex; \
    addgroup --system courier; \
    adduser --system --ingroup courier courier; \
    #
    apt-get update; \
    apt-get install -y --no-install-recommends ca-certificates wget tzdata; \
    update-ca-certificates; \
    rm -rf /var/lib/apt/lists/*; \
    #
    wget -q -O courier.tar.gz "https://github.com/${COURIER_ORG}/${COURIER_REPO}/releases/download/v${COURIER_VERSION}/${COURIER_REPO}_${COURIER_VERSION}_linux_amd64.tar.gz"; \
    mkdir /tmp/courier; \
    tar -xzC /tmp/courier -f courier.tar.gz; \
    #
    mv /tmp/courier/courier /usr/local/bin/courier; \
    rm -rf /tmp/courier courier.tar.gz; \
    #
    apt-get purge -y --auto-remove wget

EXPOSE 8080

USER courier

ENTRYPOINT [ "courier" ]
