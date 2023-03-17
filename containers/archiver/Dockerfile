FROM ubuntu:22.10

ARG ARCHIVER_ORG="nyaruka"
ARG ARCHIVER_REPO="rp-archiver"
ARG ARCHIVER_VERSION="7.4.0"

ENV IS_CONTAINERIZED=True
ENV DEBIAN_FRONTEND=noninteractive

RUN set -ex; \
    addgroup --system archiver; \
    adduser --system --ingroup archiver archiver; \
    #
    apt-get update; \
    apt-get install -y --no-install-recommends ca-certificates wget tzdata; \
    update-ca-certificates; \
    rm -rf /var/lib/apt/lists/*; \
    #
    wget -q -O rp-archiver.tar.gz "https://github.com/${ARCHIVER_ORG}/${ARCHIVER_REPO}/releases/download/v${ARCHIVER_VERSION}/${ARCHIVER_REPO}_${ARCHIVER_VERSION}_linux_amd64.tar.gz"; \
    mkdir /tmp/rp-archiver; \
    tar -xzC /tmp/rp-archiver -f rp-archiver.tar.gz; \
    #
    mv /tmp/rp-archiver/rp-archiver /usr/local/bin/archiver; \
    rm -rf /tmp/rp-archiver rp-archiver.tar.gz; \
    #
    apt-get purge -y --auto-remove wget

EXPOSE 8080

USER archiver

ENTRYPOINT [ "archiver" ]
