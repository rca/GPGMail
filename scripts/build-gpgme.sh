#!/bin/bash

export PREFIX="`pwd`/library-build"
export SOURCES="`pwd`/sources"

echo "SOURCES $SOURCES"
echo "PREFIX $PREFIX"

mkdir -p $SOURCES

pushd $SOURCES;

if [ ! -f "gettext-0.18.1.1.tar.gz" ]; then

curl -O http://ftp.gnu.org/gnu/gettext/gettext-0.18.1.1.tar.gz
tar xzf gettext-0.18.1.1.tar.gz

fi

# Build gettext.

pushd gettext-0.18.1.1

CFLAGS="-isysroot /Developer/SDKs/MacOSX10.6.sdk -arch x86_64 -arch i386" \
    ./configure --prefix=$PREFIX --disable-shared --disable-dependency-tracking \
    --disable-java --disable-native-java --disable-csharp \
    --with-included-gettext --with-included-glib \
    --with-included-libcroco --with-included-libxml --disable-libasprintf

make install

popd

# Build libgpg-error

if [ ! -f "libgpg-error-1.8.tar.bz2" ]; then

curl -O ftp://ftp.gnupg.org/gcrypt/libgpg-error/libgpg-error-1.8.tar.bz2
tar xjf libgpg-error-1.8.tar.bz2

fi

pushd libgpg-error-1.8

CFLAGS="-isysroot /Developer/SDKs/MacOSX10.6.sdk -arch x86_64 -arch i386" LDFLAGS="-framework CoreFoundation" ./configure --prefix=$PREFIX --disable-shared --disable-dependency-tracking --with-libintl-prefix=$PREFIX

make install

popd

# Build libassuan

if [ ! -f "libassuan-2.0.0.tar.bz2" ]; then
    
curl -O ftp://ftp.gnupg.org/gcrypt/libassuan/libassuan-2.0.0.tar.bz2
tar xjf libassuan-2.0.0.tar.bz2

fi

pushd libassuan-2.0.0

CFLAGS="-isysroot /Developer/SDKs/MacOSX10.6.sdk -arch x86_64 -arch i386" ./configure --prefix=$PREFIX --disable-shared --disable-dependency-tracking --with-gpg-error-prefix=$PREFIX

make install

popd

# Build gpgpme

if [ ! -f "gpgme-1.3.0.tar.bz2" ]; then

curl -O ftp://ftp.gnupg.org/gcrypt/gpgme/gpgme-1.3.0.tar.bz2
tar xjf gpgme-1.3.0.tar.bz2

fi

pushd gpgme-1.3.0

echo "./configure --prefix=$PREFIX --enable-static --disable-shared --disable-dependency-tracking --with-gpg-error-prefix=$PREFIX --with-gpg=$PREFIX/bin/gpg --with-libassuan-prefix=$PREFIX --without-pth --disable-glibtest"
CFLAGS="-isysroot /Developer/SDKs/MacOSX10.6.sdk -arch x86_64 -arch i386" ./configure --prefix=$PREFIX --enable-static --disable-shared --disable-dependency-tracking --with-gpg-error-prefix=$PREFIX --with-gpg=$PREFIX/bin/gpg --with-libassuan-prefix=$PREFIX --without-pth --disable-glibtest

make install

popd

