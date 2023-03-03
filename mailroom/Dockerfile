FROM ubuntu:22.10

ARG MAILROOM_ORG="rapidpro"
ARG MAILROOM_REPO="mailroom"
ARG MAILROOM_VERSION="7.4.1"

ENV IS_CONTAINERIZED=True
ENV DEBIAN_FRONTEND=noninteractive

RUN set -ex; \
    addgroup --system mailroom; \
    adduser --system --ingroup mailroom mailroom; \
    #
    apt-get update; \
    apt-get install -y --no-install-recommends ca-certificates wget; \
    update-ca-certificates; \
    rm -rf /var/lib/apt/lists/*; \
    #
    wget -q -O mailroom.tar.gz "https://github.com/${MAILROOM_ORG}/${MAILROOM_REPO}/releases/download/v${MAILROOM_VERSION}/${MAILROOM_REPO}_${MAILROOM_VERSION}_linux_amd64.tar.gz"; \
    mkdir /tmp/mailroom; \
    tar -xzC /tmp/mailroom -f mailroom.tar.gz; \
    #
    mv /tmp/mailroom/mailroom /usr/local/bin/mailroom; \
    rm -rf /tmp/mailroom mailroom.tar.gz; \
    #
    apt-get purge -y --auto-remove wget

EXPOSE 8090

USER mailroom

ENTRYPOINT [ "mailroom", "--debug-conf" ]
