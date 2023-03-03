FROM python:3.9-slim as build

ARG RAPIDPRO_ORG="rapidpro"
ARG RAPIDPRO_REPO="rapidpro"
ARG RAPIDPRO_VERSION="7.4.2"

ENV PYTHONUNBUFFERED=1
ENV VIRTUAL_ENV=/opt/venv
ENV PATH=/opt/venv/bin:$PATH

WORKDIR /build

RUN set -ex; \
    apt-get update; \
    apt-get upgrade -y; \
    apt-get install -y --no-install-recommends wget build-essential gettext libpq-dev gdal-bin libgdal-dev git python3.9-dev; \
    rm -rf /var/lib/apt/lists/*; \
    #
    wget -q -O /tmp/rapidpro.tar.gz "https://github.com/${RAPIDPRO_ORG}/${RAPIDPRO_REPO}/archive/refs/tags/v${RAPIDPRO_VERSION}.tar.gz"; \
    tar -xzC /build --strip-components 1 -f /tmp/rapidpro.tar.gz; \
    #
    apt-get purge -y --auto-remove wget

# Python venv
RUN set -ex; \
    python3 -m venv $VIRTUAL_ENV; \
    python3 -m pip install --upgrade pip --no-cache-dir setuptools==58.0; \
    python3 -m pip install poetry gunicorn[gevent] GDAL==$(gdal-config --version); \
    poetry install; \
    poetry add git+https://github.com/danniel/django-tembaimporter.git

RUN ls -lah /build

FROM node:alpine as assets

WORKDIR /build

COPY --from=build /build/package.* .

RUN npm install less coffeescript --global --no-audit
RUN npm install

# The final image
FROM python:3.9-slim

ENV PYTHONUNBUFFERED=1
ENV IS_CONTAINERIZED=True

RUN set -ex; \
    apt-get update; \
    apt-get upgrade -y; \
    apt-get install -y --no-install-recommends xz-utils nginx gettext gdal-bin; \
    rm -rf /var/lib/apt/lists/*

# Supervision
ARG S6_OVERLAY_VERSION=3.1.4.1
ENV S6_CMD_WAIT_FOR_SERVICES_MAXTIME 0

ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz /tmp
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-x86_64.tar.xz /tmp
RUN tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz \
    && tar -C / -Jxpf /tmp/s6-overlay-x86_64.tar.xz

ENTRYPOINT ["/init"]

COPY docker/s6-rc.d /etc/s6-overlay/s6-rc.d

# NGINX
COPY docker/nginx.conf /etc/nginx/templates/default

WORKDIR /var/www

# Application files
COPY --from=build /opt/venv /opt/venv
COPY --from=build /build /var/www
COPY --from=assets /build/node_modules /var/www/node_modules

ENV PATH=/opt/venv/bin:$PATH

# Application set up
COPY docker/settings.py temba/settings.py
RUN set -ex; \
    python3 manage.py collectstatic

EXPOSE 80
