FROM debian:trixie AS base
RUN apt-get update && apt-get upgrade -y \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean
LABEL maintainer="Chris Clark"
WORKDIR /tmp/src


FROM base AS openssl

ENV DEBIAN_FRONTEND=noninteractive \
    VERSION_OPENSSL=openssl-3.5.6 \
    SHA256_OPENSSL=deae7c80cba99c4b4f940ecadb3c3338b13cb77418409238e57d7f31f2a3b736 \
    SOURCE_OPENSSL=https://www.openssl.org/source/ \
    # OpenSSL OMC
    OPGP_OPENSSL_1=EFC0A467D613CB83C7ED6D30D894E2CE8B3D79F5 \
    # Richard Levitte
    OPGP_OPENSSL_2=7953AC1FBC3DC8B3B292393ED5E9E43F7DF9EE8C \
    # Matt Caswell
    OPGP_OPENSSL_3=8657ABB260F056B1E5190839D9C4D26D0E604491 \
    # Paul Dale
    OPGP_OPENSSL_4=B7C1C14360F353A36862E4D5231C84CDDCC69C45 \
    # Tomas Mraz
    OPGP_OPENSSL_5=A21FAB74B0088AA361152586B8EF1A6BA9DA2D5C \
    # Tim Hudson
    OPGP_OPENSSL_6=C1F33DD8CE1D4CC613AF14DA9195C48241FBF7DD \
    # Kurt Roeckx
    OPGP_OPENSSL_7=E5E52560DD91C556DDBDA5D02064C53641C25E5D \
    # OpenSSL
    OPGP_OPENSSL_8=BA5473A2B0587B07FB27CF2D216094DFD0CB81EF

RUN set -e -x && \
    build_deps="build-essential ca-certificates curl dirmngr gnupg libidn2-0-dev libssl-dev" && \
    apt-get update && apt-get install -y --no-install-recommends \
      $build_deps && \
    curl -L $SOURCE_OPENSSL$VERSION_OPENSSL.tar.gz -o openssl.tar.gz && \
    echo "${SHA256_OPENSSL} ./openssl.tar.gz" | sha256sum -c - && \
    curl -L $SOURCE_OPENSSL$VERSION_OPENSSL.tar.gz.asc -o openssl.tar.gz.asc && \
    GNUPGHOME="$(mktemp -d)" && \
    export GNUPGHOME && \
    gpg --no-tty --keyserver keyserver.ubuntu.com --recv-keys "$OPGP_OPENSSL_1" "$OPGP_OPENSSL_2" "$OPGP_OPENSSL_3" "$OPGP_OPENSSL_4" "$OPGP_OPENSSL_5" "$OPGP_OPENSSL_6" "$OPGP_OPENSSL_7" "$OPGP_OPENSSL_8" && \
    gpg --batch --verify openssl.tar.gz.asc openssl.tar.gz && \
    tar xzf openssl.tar.gz && \
    cd $VERSION_OPENSSL && \
    ./config \
      --prefix=/opt/openssl \
      --openssldir=/opt/openssl \
      no-weak-ssl-ciphers \
      no-ssl3 \
      no-shared \
      enable-ec_nistp_64_gcc_128 \
      -DOPENSSL_NO_HEARTBEATS \
      -fstack-protector-strong && \
    make depend && \
    nproc | xargs -I % make -j% && \
    make install_sw && \
    apt-get purge -y --auto-remove \
      $build_deps && \
    rm -rf \
        /tmp/* \
        /var/tmp/* \
        /var/lib/apt/lists/* && \
    apt-get clean

FROM base AS unbound_build

ENV DEBIAN_FRONTEND=noninteractive \
    NAME=unbound \
    UNBOUND_VERSION=1.19.2 \
    UNBOUND_SHA256=cc560d345734226c1b39e71a769797e7fdde2265cbb77ebce542704bba489e55 \
    UNBOUND_DOWNLOAD_URL=https://nlnetlabs.nl/downloads/unbound/unbound-1.19.2.tar.gz

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
    cd unbound-1.19.2 && \
    groupadd _unbound && \
    useradd -g _unbound -s /usr/sbin/nologin -d /opt/unbound _unbound && \
    ./configure \
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
        /var/lib/apt/lists/* && \
    apt-get clean


FROM base AS unbound

ENV DEBIAN_FRONTEND=noninteractive \
    NAME=unbound \
    UNBOUND_VERSION=1.19.2 \
    SUMMARY="${NAME} is a validating, recursive, and caching DNS resolver." \
    DESCRIPTION="${NAME} is a validating, recursive, and caching DNS resolver."

COPY --from=unbound_build /opt /opt

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
    useradd -g _unbound -s /usr/sbin/nologin -d /opt/unbound _unbound && \
    apt-get purge -y --auto-remove && \
    rm -rf \
        /opt/unbound/share/man \
        /tmp/* \
        /var/tmp/* \
        /var/lib/apt/lists/* && \
    apt-get clean

COPY data/ /

RUN chmod +x /unbound.sh

WORKDIR /opt/unbound/

ENV PATH=/opt/unbound/sbin:"$PATH"

ARG IMAGE_DESCRIPTION="unbound - a validating, recursive, and caching DNS resolver" \
    IMAGE_URL=c2dalark/unbound \
    IMAGE_REPO=https://github.com/c2dalark/unbound-docker \
    IMAGE_AUTHOR="Christopher Clark <c2dalark@users.noreply.github.com>"

LABEL maintainer=${IMAGE_AUTHOR} \
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
