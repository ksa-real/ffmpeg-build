#!/usr/bin/env bash

set -xeu

cd $(dirname $0)
BASE_DIR=$(pwd)

source common.sh

if [ ! -e $FFMPEG_TARBALL ]
then
	wget $FFMPEG_TARBALL_URL
fi

: ${ARCH?}
OS=${OS:-linux}

TARGET=ffmpeg-$FFMPEG_VERSION-audio-$OS-$ARCH

case $ARCH in
i686)
    FFMPEG_CONFIGURE_FLAGS+=(--cc="gcc -m32")
    ;;
arm*)
    FFMPEG_CONFIGURE_FLAGS+=(
        --enable-cross-compile
        --cross-prefix=arm-$OS-gnueabihf-
        --target-os=$OS
        --arch=arm
    )
    case $ARCH in
    armv7-a)
        FFMPEG_CONFIGURE_FLAGS+=(
            --cpu=armv7-a
        )
        ;;
    armv8-a)
        FFMPEG_CONFIGURE_FLAGS+=(
            --cpu=armv8-a
        )
        ;;
    armhf-rpi2)
        FFMPEG_CONFIGURE_FLAGS+=(
            --cpu=cortex-a7
            --extra-cflags='-fPIC -mcpu=cortex-a7 -mfloat-abi=hard -mfpu=neon-vfpv4 -mvectorize-with-neon-quad'
        )
        ;;
    armhf-rpi3)
        FFMPEG_CONFIGURE_FLAGS+=(
            --cpu=cortex-a53
            --extra-cflags='-fPIC -mcpu=cortex-a53 -mfloat-abi=hard -mfpu=neon-fp-armv8 -mvectorize-with-neon-quad'
        )
        ;;
    esac
    ;;
x86_64)
    ;;
*)
    echo "Unknown architecture"
    exit 1
esac

BUILD_DIR=$(mktemp -d -p $(pwd) build.XXXXXXXX)
trap 'rm -rf $BUILD_DIR' EXIT

cd $BUILD_DIR
tar --strip-components=1 -xf $BASE_DIR/$FFMPEG_TARBALL

FFMPEG_CONFIGURE_FLAGS+=(--prefix=$BASE_DIR/$TARGET)

./configure "${FFMPEG_CONFIGURE_FLAGS[@]}"
make
make install

chown $(stat -c '%u:%g' $BASE_DIR) -R $BASE_DIR/$TARGET
