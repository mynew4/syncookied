#!/bin/sh
set -e

BUILD_DIR=$(pwd)

echo "=> Cloning netmap"
git clone -q --depth=1 https://github.com/luigirizzo/netmap/

echo "=> Cloning libpcap"
git clone -q --depth=1 https://github.com/the-tcpdump-group/libpcap

echo "=> Cloning linux headers"
git clone -q --depth=1 https://github.com/sabotage-linux/kernel-headers

echo "=> Installing headers locally"
(cd kernel-headers && make ARCH=`arch` prefix=/ DESTDIR=`pwd`/kernel-headers install > /dev/null)

echo "=> Building static libpcap"
cd libpcap && CC=musl-gcc CFLAGS='-fPIC -I../kernel-headers/kernel-headers/include' ./configure
make

STATIC_LIBPCAP_PATH=$(pwd) CFLAGS=-I${BUILD_DIR}/netmap/sys cargo build --target=x86_64-unknown-linux-musl --release