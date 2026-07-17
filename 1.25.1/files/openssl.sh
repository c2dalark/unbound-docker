#!/usr/bin/env bash
set -e -x
SOURCE_OPENSSL="https://www.openssl.org/source/"
    # OpenSSL OMC
OPGP_OPENSSL_1="EFC0A467D613CB83C7ED6D30D894E2CE8B3D79F5"
    # Richard Levitte
OPGP_OPENSSL_2="7953AC1FBC3DC8B3B292393ED5E9E43F7DF9EE8C"
    # Matt Caswell
OPGP_OPENSSL_3="8657ABB260F056B1E5190839D9C4D26D0E604491"
    # Paul Dale
OPGP_OPENSSL_4="B7C1C14360F353A36862E4D5231C84CDDCC69C45"
    # Tomas Mraz
OPGP_OPENSSL_5="A21FAB74B0088AA361152586B8EF1A6BA9DA2D5C"
    # Tim Hudson
OPGP_OPENSSL_6="C1F33DD8CE1D4CC613AF14DA9195C48241FBF7DD"
    # Kurt Roeckx
OPGP_OPENSSL_7="E5E52560DD91C556DDBDA5D02064C53641C25E5D"
    # OpenSSL
OPGP_OPENSSL_8="BA5473A2B0587B07FB27CF2D216094DFD0CB81EF"

build_deps="build-essential ca-certificates curl dirmngr gnupg libidn2-0-dev \
  libssl-dev"
apt-get update && apt-get install -y --no-install-recommends \
  $build_deps
curl -L $SOURCE_OPENSSL$VERSION_OPENSSL.tar.gz -o openssl.tar.gz
echo "${SHA256_OPENSSL} ./openssl.tar.gz" | sha256sum -c -
curl -L $SOURCE_OPENSSL$VERSION_OPENSSL.tar.gz.asc -o openssl.tar.gz.asc
GNUPGHOME="$(mktemp -d)"
gpg --no-tty --keyserver keyserver.ubuntu.com --recv-keys "$OPGP_OPENSSL_1" \
  "$OPGP_OPENSSL_2" "$OPGP_OPENSSL_3" "$OPGP_OPENSSL_4" "$OPGP_OPENSSL_5" \
  "$OPGP_OPENSSL_6" "$OPGP_OPENSSL_7" "$OPGP_OPENSSL_8"
gpg --batch --verify openssl.tar.gz.asc openssl.tar.gz
tar xzf openssl.tar.gz
cd $VERSION_OPENSSL
./config --prefix=/opt/openssl --openssldir=/opt/openssl no-weak-ssl-ciphers \
  no-ssl3 no-shared enable-ec_nistp_64_gcc_128 -DOPENSSL_NO_HEARTBEATS \
  -fstack-protector-strong
make depend
nproc | xargs -I % make -j%
make install_sw
apt-get purge -y --auto-remove \
  $build_deps
