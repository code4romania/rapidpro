FROM python:3.9-slim as build

ARG UREPORT_ORG="code4romania"
ARG UREPORT_REPO="ureport"
ARG UREPORT_VERSION="1.2.51-10"

ENV PYTHONUNBUFFERED=1
ENV VIRTUAL_ENV=/opt/venv
ENV PATH=/opt/venv/bin:$PATH

WORKDIR /build

RUN set -ex; \
    apt-get update; \
    apt-get upgrade -y; \
    apt-get install -y --no-install-recommends wget build-essential gettext libpq-dev git python3.9-dev; \
    rm -rf /var/lib/apt/lists/*; \
    #
    wget -q -O /tmp/ureport.tar.gz "https://github.com/${UREPORT_ORG}/${UREPORT_REPO}/archive/refs/tags/v${UREPORT_VERSION}.tar.gz"; \
    tar -xzC /build --strip-components 1 -f /tmp/ureport.tar.gz; \
    #
    apt-get purge -y --auto-remove wget

# Python venv
RUN set -ex; \
    python3 -m venv $VIRTUAL_ENV; \
    python3 -m pip install --no-cache-dir gunicorn[gevent] poetry==1.4.2; \
    poetry install --without dev

# The final image
FROM python:3.9-slim

ENV PYTHONUNBUFFERED=1
ENV IS_CONTAINERIZED=True

RUN set -ex; \
    apt-get update; \
    apt-get upgrade -y; \
    apt-get install -y --no-install-recommends nodejs npm libpq5 xz-utils nginx gettext tzdata; \
    rm -rf /var/lib/apt/lists/*

# Supervision
ARG S6_OVERLAY_VERSION=3.1.4.1
ENV S6_CMD_WAIT_FOR_SERVICES_MAXTIME 0

ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz /tmp
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-x86_64.tar.xz /tmp
RUN tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz \
    && tar -C / -Jxpf /tmp/s6-overlay-x86_64.tar.xz

ENTRYPOINT ["/init"]

COPY conf/s6-rc.d /etc/s6-overlay/s6-rc.d

# NGINX
COPY conf/nginx.conf /etc/nginx/templates/nginx.conf

WORKDIR /var/www

# Application files
COPY --from=build /opt/venv /opt/venv
COPY --from=build /build /var/www

ENV PATH=/opt/venv/bin:$PATH
ENV RUN_COLLECT_STATIC=yes
ENV DEBUG=false

# Application set up
RUN set -ex; \
    npm install less coffeescript npm-force-resolutions --global --no-audit; \
    npm ci --no-audit

COPY conf/settings.py ureport/settings.py

EXPOSE 80
