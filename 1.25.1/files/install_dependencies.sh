set -x -e

if [ $TARGETPLATFORM == "linux/amd64" ] || [ $TARGETPLATFORM == "linux/arm64"  ]; then
    dependencies="libevent-2.1-7 "
elif [ $TARGETPLATFORM == "linux/arm/v7" ]; then
    dependencies="libevent-2.1-7t64 "
else
    echo "Unsupported target/build arch!"
    exit 1
fi

DEBIAN_FRONTEND=noninteractive apt-get update && apt-get upgrade -y && apt-get install -y --no-install-recommends \
  bsdmainutils \
  ca-certificates \
  ldnsutils \
  libnghttp2-14 \
  libexpat1 \
  libprotobuf-c1 \
  $dependencies
groupadd _unbound
useradd -g _unbound -s /usr/sbin/nologin -d /opt/unbound _unbound
apt-get purge -y --auto-remove