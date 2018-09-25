#!/bin/bash

. ./c4s.config/android/build.config

########################################################
########################################################
################## OPENSSL SOURCE ######################
########################################################
########################################################

ANDROID_NDK="android-ndk-r15c"
VERSION="1.0.2n"
URL="https://www.openssl.org/source/openssl-1.0.2n.tar.gz"
SOURCE="${URL##*/}"
ROOT_DIR=$(pwd)
SOURCE_DIR=${ROOT_DIR}/"openssl-1.0.2n"

if [ ! -d ${SOURCE_DIR} ]; then
    if [ ! -f ${SOURCE} ]; then
      echo "Downloading OpenSSL ${VERSION}"
      wget --quiet ${URL}
    fi
    echo "Extracting OpenSLL ${VERSION}"
    tar -zxf ${SOURCE}
fi

########################################################
################### ANDROID NDK ########################
########################################################
########################################################
if [ ! -d ${ROOT_DIR}/../android-ndk/${ANDROID_NDK} ]; then
    cd ${ROOT_DIR}/../android-ndk/
    echo "Downloading Android NDK"
    wget --quiet "https://dl.google.com/android/repository/${ANDROID_NDK}-linux-x86_64.zip"
    unzip -q ${ANDROID_NDK}-linux-x86_64.zip
    rm -rf *.zip*
fi

cd ${ROOT_DIR}

echo "Setting Android NDK environment"

set -e
NDK_ROOT=$(readlink -f "../android-ndk/${ANDROID_NDK}")

exit 0
# export ANDROID_NDK_ROOT=${NDK_ROOT}
# export ANDROID_NDK_HOME=${NDK_ROOT}
# export NDK_PLATFORM=android-21

########################################################
########################################################
################## ANDROID BUILD #######################
########################################################
########################################################

for arch in ${archs[@]}; do
    #### CONFIGURE ANDROID ENVIRONMENT

    xLIB="lib"
    case ${arch} in
      "armeabi")
          _ANDROID_TARGET_SELECT=arch-arm
          _ANDROID_ARCH=arch-arm
          _ANDROID_EABI=arm-linux-androideabi-4.9
          configure_platform="android-armv7"
        ;;
        "armeabi-v7a")
          _ANDROID_TARGET_SELECT=arch-arm
          _ANDROID_ARCH=arch-arm
          _ANDROID_EABI=arm-linux-androideabi-4.9
            configure_platform="android-armv7"
        ;;
        "arm64-v8a")
          _ANDROID_TARGET_SELECT=arch-arm64-v8a
          _ANDROID_ARCH=arch-arm64
          _ANDROID_EABI=aarch64-linux-android-4.9
          configure_platform="linux-generic64 -DB_ENDIAN"
        ;;
        "x86")
          _ANDROID_TARGET_SELECT=arch-x86
          _ANDROID_ARCH=arch-x86
          _ANDROID_EABI=x86-4.9
          configure_platform="android-x86"
        ;;
        "x86_64")
          _ANDROID_TARGET_SELECT=arch-x86_64
          _ANDROID_ARCH=arch-x86_64
          _ANDROID_EABI=x86_64-4.9
          xLIB="lib64"
          configure_platform="linux-generic64"
        ;;
        "mips")
          _ANDROID_TARGET_SELECT=arch-mips
          _ANDROID_ARCH=arch-mips
          _ANDROID_EABI=mipsel-linux-android-4.9
          configure_platform="android -DB_ENDIAN"
        ;;
        "mips64")
          _ANDROID_TARGET_SELECT=arch-mips64
          _ANDROID_ARCH=arch-mips64
          _ANDROID_EABI=mips64el-linux-android-4.9
          xLIB="/lib64"
          configure_platform="linux-generic64 -DB_ENDIAN"
        ;;
        *)
        configure_platform="linux-elf"
        ;;
    esac
    cd ${ROOT_DIR}

    echo "Configuring OpenSSL ${VERSION} for ${arch}"
    . ./c4s.config/setenv-android-mod.sh

    cd ${SOURCE_DIR}

    #### CONFIGURE BUILD
    xCFLAGS="-mandroid -I$ANDROID_DEV/include -B$ANDROID_DEV/$xLIB -fPIC -O3 -fomit-frame-pointer -Wall"

    perl -pi -e 's/install: all install_docs install_sw/install: install_docs install_sw/g' Makefile.org
    ./Configure no-shared no-comp no-asm no-ssl2 no-ssl3 no-hw no-engine $configure_platform $xCFLAGS

    #### BUILD
    echo "Building OpenSSL ${VERSION} for ${arch}"
    make clean
    make depend V=0
    make V=0

    echo "Installing OpenSSL ${VERSION}"
    #### COPY LIBS TO OUT-OF-SOURCE
    mkdir -p ${ROOT_DIR}/c4s.build/libs/Android/${arch}/
    find . -name '*.h' -exec cp --parents \{\} ${ROOT_DIR}/c4s.build/ \;
    mkdir -p ${ROOT_DIR}/c4s.build/include/openssl
    cp libcrypto.a ${ROOT_DIR}/c4s.build/libs/Android/${arch}/libcrypto.a
    cp libssl.a ${ROOT_DIR}/c4s.build/libs/Android/${arch}/libssl.a

done

echo "Deleting openssl ${VERSION} temporary files"
cd ${ROOT_DIR}
rm -rf ${SOURCE_DIR}
rm -rf *.tar.gz*

exit 0
