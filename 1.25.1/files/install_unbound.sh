#!/usr/bin/env bash

config_flags=""
if [ $TARGETPLATFORM == "linux/amd64" ] || [ $TARGETPLATFORM == "linux/arm64"  ]; then
    echo "Building configure flags for 64bit arch"
    config_flags="$config_flags"
elif [ $TARGETPLATFORM == "linux/arm/v7" ]; then
    echo "Building configure flags for 32bit arch"
    config_flags="$config_flags"
else
    echo "Unsupported target/build arch!"
    exit 1
fi
