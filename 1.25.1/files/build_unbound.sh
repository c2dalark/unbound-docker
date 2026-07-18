#!/usr/bin/env bash
set -e -x

build_deps="bison build-essential curl flex gcc libc-dev libevent-dev libexpat1-dev libnghttp2-dev make"
apt-get update && apt-get install -y --no-install-recommends \
  $build_deps \
  bsdmainutils \
  ca-certificates \
  ldnsutils \
  libevent-2.1-7 \
  libexpat1 \
  libprotobuf-c-dev \
  protobuf-c-compiler
curl -sSL $UNBOUND_DOWNLOAD_URL -o unbound.tar.gz
echo "${UNBOUND_SHA256} *unbound.tar.gz" | sha256sum -c -
tar xzf unbound.tar.gz
rm -f unbound.tar.gz
cd unbound-1.25.1
groupadd _unbound
useradd -g _unbound -s /usr/sbin/nologin -d /opt/unbound _unbound
if [ $TARGETPLATFORM == "linux/amd64" ]; then
    config_flags="--host=x86_64-pc-linux-gnu "
elif [ $TARGETPLATFORM == "linux/i386" ]; then
    config_flags="--host=i386-pc-linux-gnu "
elif [ $TARGETPLATFORM == "linux/arm64"  ]; then
    config_flags="--host=armv64-pc-linux-gnu "
elif [ $TARGETPLATFORM == "linux/arm/v7" ]; then
    config_flags="--host=armv7l-pc-linux-gnu "
elif [ $TARGETPLATFORM == "linux/arm/v5" ]; then
    config_flags="--host=armv5-pc-linux-gnu "
else
    echo "Unsupported target/build arch!"
    exit 1
fi
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
    --enable-subnet \
    $config_flags
make install
mv /opt/unbound/etc/unbound/unbound.conf /opt/unbound/etc/unbound/unbound.conf.example
apt-get purge -y --auto-remove \
  $build_deps
