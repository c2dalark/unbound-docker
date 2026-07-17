FROM debian:trixie AS base
ARG TARGETPLATFORM
ARG BUILDPLATFORM
RUN apt-get update && apt-get upgrade -y \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean
WORKDIR /tmp/src

FROM base AS openssl

ENV DEBIAN_FRONTEND=noninteractive \
    VERSION_OPENSSL=openssl-3.5.6 \
    SHA256_OPENSSL=deae7c80cba99c4b4f940ecadb3c3338b13cb77418409238e57d7f31f2a3b736

COPY ./files/install_openssl.sh .
RUN ./install_openssl.sh


FROM base AS unbound

ENV DEBIAN_FRONTEND=noninteractive \
    NAME=unbound \
    UNBOUND_VERSION=1.25.1 \
    UNBOUND_SHA256=0fe8b6277b0959cfd17562debac0aa5f71e0b02dc4ffa9c60271c583edab586f \
    UNBOUND_DOWNLOAD_URL=https://nlnetlabs.nl/downloads/unbound/unbound-1.25.1.tar.gz

COPY --from=openssl /opt/openssl /opt/openssl

RUN build_deps="bison build-essential curl flex gcc libc-dev libevent-dev libexpat1-dev libnghttp2-dev make" && \
    set -x && \
    apt-get update && apt-get install -y --no-install-recommends \
      $build_deps \
      bsdmainutils \
      ca-certificates \
      ldnsutils \
      libevent-2.1-7 \
      libexpat1 \
      libprotobuf-c-dev \
      protobuf-c-compiler && \
    curl -sSL $UNBOUND_DOWNLOAD_URL -o unbound.tar.gz && \
    echo "${UNBOUND_SHA256} *unbound.tar.gz" | sha256sum -c - && \
    tar xzf unbound.tar.gz && \
    rm -f unbound.tar.gz && \
    cd unbound-1.25.1 && \
    groupadd _unbound && \
    useradd -g _unbound -s /dev/null -d /etc _unbound && \
    ./configure \
        --disable-dependency-tracking \
        --prefix=/opt/unbound \
        --with-pthreads \
        --with-username=_unbound \
        --with-ssl=/opt/openssl \
        --with-libevent \
        --with-libnghttp2 \
        --enable-dnstap \
        --enable-tfo-server \
        --enable-tfo-client \
        --enable-event-api \
        --enable-subnet && \
    make install && \
    mv /opt/unbound/etc/unbound/unbound.conf /opt/unbound/etc/unbound/unbound.conf.example && \
    apt-get purge -y --auto-remove \
      $build_deps && \
    rm -rf \
        /opt/unbound/share/man \
        /tmp/* \
        /var/tmp/* \
        /var/lib/apt/lists/*


FROM base AS app

ARG NAME=unbound

ENV DEBIAN_FRONTEND=noninteractive \
    UNBOUND_VERSION=1.25.1 \
    NAME=${NAME} \
    SUMMARY="${NAME} is a validating, recursive, and caching DNS resolver." \
    DESCRIPTION="${NAME} is a validating, recursive, and caching DNS resolver."

COPY --from=unbound /opt /opt

RUN set -x && \
    apt-get update && apt-get install -y --no-install-recommends \
      bsdmainutils \
      ca-certificates \
      ldnsutils \
      libevent-2.1-7 \
      libnghttp2-14 \
      libexpat1 \
      libprotobuf-c1 && \
    groupadd _unbound && \
    useradd -g _unbound -s /dev/null -d /etc _unbound && \
    apt-get purge -y --auto-remove && \
    rm -rf \
        /opt/unbound/share/man \
        /tmp/* \
        /var/tmp/* \
        /var/lib/apt/lists/*

COPY data/ /

RUN chmod +x /unbound.sh

WORKDIR /opt/unbound/

ENV PATH=/opt/unbound/sbin:"$PATH"

ARG CREATE_TIME="2026-05-31 17:27:26-04:00" \
    IMAGE_DESCRIPTION="unbound - a validating, recursive, and caching DNS resolver" \
    IMAGE_URL=c2dalark/unbound \
    IMAGE_REPO=https://github.com/c2dalark/unbound-docker \
    IMAGE_AUTHOR="Christopher Clark <c2dalark@users.noreply.github.com>"

LABEL maintainer=${IMAGE_AUTHOR} \
      org.opencontainers.image.created=${CREATE_TIME} \
      org.opencontainers.image.authors=${IMAGE_AUTHOR} \
      org.opencontainers.image.url=${IMAGE_REPO} \
      org.opencontainers.image.documentation=${IMAGE_REPO} \
      org.opencontainers.image.source=${IMAGE_REPO} \
      org.opencontainers.image.version=${UNBOUND_VERSION} \
      org.opencontainers.image.revision=${UNBOUND_VERSION} \
      org.opencontainers.image.vendor=${IMAGE_AUTHOR} \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.ref.name=${UNBOUND_VERSION} \
      org.opencontainers.image.title=${IMAGE_URL} \
      org.opencontainers.image.description=${IMAGE_DESCRIPTION}

EXPOSE 53/tcp
EXPOSE 53/udp

HEALTHCHECK --interval=30s --timeout=30s --start-period=10s --retries=3 CMD drill @127.0.0.1 cloudflare.com || exit 1

CMD ["/unbound.sh"]