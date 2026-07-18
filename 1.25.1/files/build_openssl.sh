#!/usr/bin/env bash

set -e -x
build_deps="build-essential ca-certificates curl dirmngr gnupg libidn2-0-dev libssl-dev"
apt-get update && apt-get install -y --no-install-recommends $build_deps
curl -L $SOURCE_OPENSSL$VERSION_OPENSSL.tar.gz -o openssl.tar.gz
echo "${SHA256_OPENSSL} ./openssl.tar.gz" | sha256sum -c -
curl -L $SOURCE_OPENSSL$VERSION_OPENSSL.tar.gz.asc -o openssl.tar.gz.asc
GNUPGHOME="$(mktemp -d)"
gpg --no-tty --keyserver keyserver.ubuntu.com --recv-keys "$OPGP_OPENSSL_1" "$OPGP_OPENSSL_2" "$OPGP_OPENSSL_3" "$OPGP_OPENSSL_4" "$OPGP_OPENSSL_5" "$OPGP_OPENSSL_6" "$OPGP_OPENSSL_7" "$OPGP_OPENSSL_8"
gpg --batch --verify openssl.tar.gz.asc openssl.tar.gz
tar xzf openssl.tar.gz
cd $VERSION_OPENSSL
config_flags="--prefix=/opt/openssl --openssldir=/opt/openssl no-weak-ssl-ciphers no-ssl3 no-shared -DOPENSSL_NO_HEARTBEATS -fstack-protector-strong "
if [ $TARGETPLATFORM == "linux/amd64" ]; then
  config_flags="$config_flags enable-ec_nistp_64_gcc_128 "
elif [ $TARGETPLATFORM == "linux/i386" ]; then
  config_flags="$config_flags"
elif [ $TARGETPLATFORM == "linux/arm64"  ]; then
  config_flags="$config_flags enable-ec_nistp_64_gcc_128 "
elif [ $TARGETPLATFORM == "linux/arm/v7" ]; then
  config_flags="linux-32 $config_flags"
elif [ $TARGETPLATFORM == "linux/arm/v5" ]; then
  config_flags="$linux-32 config_flags"
else
  echo "Unsupported target/build arch!"
  exit 1
fi
./config "$config_flags"
make depend
nproc | xargs -I % make -j%
make install_sw
apt-get purge -y --auto-remove \
  $build_deps
