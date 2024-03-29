FROM python:3.9-slim-bullseye as build

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
    # ^^^ install the "python3.XX-dev" package only if we will be using the Debian's default Python package
    rm -rf /var/lib/apt/lists/*; \
    #
    wget -q -O /tmp/rapidpro.tar.gz "https://github.com/${RAPIDPRO_ORG}/${RAPIDPRO_REPO}/archive/refs/tags/v${RAPIDPRO_VERSION}.tar.gz"; \
    tar -xzC /build --strip-components 1 -f /tmp/rapidpro.tar.gz; \
    #
    apt-get purge -y --auto-remove wget

# Python venv
COPY conf/poetry/poetry.lock /build/poetry.lock
RUN set -ex; \
    python3 -m venv $VIRTUAL_ENV; \
    # Older GDAL requires these package versions because newer ones use an incompatible install method.
    python3 -m pip install --no-cache-dir pip==23.0.1 setuptools==58.0 gunicorn[gevent] poetry==1.3.2; \
    python3 -m pip install --no-cache-dir GDAL==$(gdal-config --version); \
    poetry install --without dev

# The final image
FROM python:3.9-slim-bullseye

ENV PYTHONUNBUFFERED=1
ENV IS_CONTAINERIZED=True

RUN set -ex; \
    apt-get update; \
    apt-get upgrade -y; \
    apt-get install -y --no-install-recommends nodejs npm xz-utils nginx gettext gdal-bin tzdata; \
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
COPY conf/geojson /opt/geojson

ENV PATH=/opt/venv/bin:$PATH
ENV RUN_COLLECT_STATIC=yes
ENV DEBUG=false

ENV MAILROOM_HOST=mailroom
ENV MAILROOM_PORT=8090
ENV COURIER_HOST=courier
ENV COURIER_PORT=8080

# Application set up
RUN set -ex; \
    npm install less coffeescript npm-force-resolutions --global --no-audit; \
    npm ci --no-audit

COPY conf/settings.py temba/settings.py

EXPOSE 80
