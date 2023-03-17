FROM ubuntu:22.10

ARG INDEXER_ORG="nyaruka"
ARG INDEXER_REPO="rp-indexer"
ARG INDEXER_VERSION="7.4.0"

ENV IS_CONTAINERIZED=True
ENV DEBIAN_FRONTEND=noninteractive

RUN set -ex; \
    addgroup --system indexer; \
    adduser --system --ingroup indexer indexer; \
    #
    apt-get update; \
    apt-get install -y --no-install-recommends ca-certificates wget tzdata; \
    update-ca-certificates; \
    rm -rf /var/lib/apt/lists/*; \
    #
    wget -q -O rp-indexer.tar.gz "https://github.com/${INDEXER_ORG}/${INDEXER_REPO}/releases/download/v${INDEXER_VERSION}/${INDEXER_REPO}_${INDEXER_VERSION}_linux_amd64.tar.gz"; \
    mkdir /tmp/rp-indexer; \
    tar -xzC /tmp/rp-indexer -f rp-indexer.tar.gz; \
    #
    mv /tmp/rp-indexer/rp-indexer /usr/local/bin/indexer; \
    rm -rf /tmp/rp-indexer rp-indexer.tar.gz; \
    #
    apt-get purge -y --auto-remove wget

EXPOSE 8080

USER indexer

ENTRYPOINT [ "indexer" ]
