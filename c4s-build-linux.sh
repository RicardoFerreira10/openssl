#!/bin/bash

########################################################
########################################################
################## OPENSSL SOURCE ######################
########################################################
########################################################

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
########################################################
################## LINUX BUILD #########################
########################################################
########################################################

#### GET ENVIRONMENT

MACHINE_ENV=$(gcc -dumpmachine)

if [[ ${MACHINE_ENV} == *"x86_64"* ]]; then
    ARCH=64
else
    ARCH=32
fi

#### BUILD

cd ${SOURCE_DIR}
make clean
echo "Configuring OpenSSL ${VERSION}"
./config no-shared no-comp no-asm -fPIC -O3 -fomit-frame-pointer -Wall
echo "Building OpenSSL ${VERSION}"
make depend V=0
make V=0

#### COPY LIBS TO OUT-OF-SOURCE
echo "Installing OpenSSL ${VERSION}"
mkdir -p ${ROOT_DIR}/c4s.build/libs/Linux/${ARCH}

find . -name '*.h' -exec cp --parents \{\} ${ROOT_DIR}/c4s.build/ \;
cp libcrypto.a ${ROOT_DIR}/c4s.build/libs/Linux/${ARCH}
cp libssl.a ${ROOT_DIR}/c4s.build/libs/Linux/${ARCH}

echo "Deleting OpenSSL ${VERSION} temporary files"
cd ${ROOT_DIR}
rm -rf ${SOURCE_DIR}
rm -rf *.tar.gz*

exit 0
