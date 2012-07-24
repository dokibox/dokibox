#!/bin/bash

# Adapted from https://gist.github.com/1397146

PREFIX=`pwd`/prefix
export PATH="$PREFIX/bin:$PATH"

CURL="curl -O"
TAR="tar xf" # os x's BSD tar autodetects gzip and bzip2 compression (as does GNU tar)

mkdir tmp
cd tmp

$CURL ftp://ftp.gnu.org/gnu/m4/m4-1.4.16.tar.bz2
$CURL ftp://ftp.gnu.org/gnu/autoconf/autoconf-2.68.tar.bz2
$CURL ftp://ftp.gnu.org/gnu/automake/automake-1.11.1.tar.bz2
$CURL ftp://ftp.gnu.org/gnu/libtool/libtool-2.4.tar.gz
$CURL http://pkg-config.freedesktop.org/releases/pkg-config-0.25.tar.gz
$CURL http://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.14.tar.gz
$CURL http://ftp.gnu.org/pub/gnu/gettext/gettext-0.18.1.1.tar.gz

# m4
$TAR m4*
cd m4*
./configure\
    --prefix=$PREFIX
make -j2
make install-strip
cd ..

# autoconf
$TAR autoconf-2*
cd autoconf-2*
./configure\
    --prefix=$PREFIX\
    --disable-debug
make -j2
make install-strip
cd ..

# automake
$TAR automake-*
cd automake-*
./configure\
    --prefix=$PREFIX
    --disable-debug
make -j2
make install-strip
cd ..

# libtool
$TAR libtool-*
cd libtool-*
./configure\
    --prefix=$PREFIX
make -j2
make install-strip
cd ..

#pkg-config
$TAR pkg-config*
cd pkg-config*
./configure\
    --prefix=$PREFIX
make -j2
make install
cd ..

#iconv
$TAR libiconv*
cd libiconv*
./configure\
    --prefix=$PREFIX
make -j2
make install
cd ..

#gettext
$TAR gettext*
cd gettext*
curl -O https://trac.macports.org/export/79617/trunk/dports/devel/gettext/files/stpncpy.patch
patch -p0 < stpncpy.patch
./configure\
    --prefix=$PREFIX -with-libiconv-prefix=$PREFIX
make -j2
make install
cd ..


cd ..
rm -rf tmp
