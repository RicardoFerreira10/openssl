#!/bin/bash

ROOT_DIR=$(pwd)
SOURCE_DIR=${ROOT_DIR}/"openssl-1.0.2n"
archs=(armeabi-v7a arm64-v8a x86 x86_64)

########################################################
########################################################
################## ANDROID BUILD #######################
########################################################
########################################################

cd ..

for arch in ${archs[@]}; do
    #### CONFIGURE ANDROID ENVIRONMENT

    xLIB="lib"
    case ${arch} in
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
        *)
        configure_platform="linux-elf"
        ;;
    esac
    cd ${ROOT_DIR}

    echo "Configuring OpenSSL ${VERSION} for ${arch}"
    . ./setenv-android-mod.sh

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
    mkdir -p ${ROOT_DIR}/c4s.build/libs/Android/${arch}/
    find . -name '*.h' -exec cp \{\} ${ROOT_DIR}/c4s.build/ \;
    mkdir -p ${ROOT_DIR}/c4s.build/include/openssl
    cp libcrypto.a ${ROOT_DIR}/c4s.build/libs/Android/${arch}/libcrypto.a
    cp libssl.a ${ROOT_DIR}/c4s.build/libs/Android/${arch}/libssl.a
done

exit 0
