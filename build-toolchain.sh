#!/bin/bash

# Adapted from https://gist.github.com/1397146

PREFIX=`pwd`/prefix
export PATH="$PREFIX/bin:$PATH"

mkdir tmp
cd tmp

curl -O ftp://ftp.gnu.org/gnu/m4/m4-1.4.16.tar.bz2
curl -O ftp://ftp.gnu.org/gnu/autoconf/autoconf-2.68.tar.bz2
curl -O ftp://ftp.gnu.org/gnu/automake/automake-1.11.1.tar.bz2
curl -O ftp://ftp.gnu.org/gnu/libtool/libtool-2.4.tar.gz
curl -O http://pkg-config.freedesktop.org/releases/pkg-config-0.25.tar.gz
curl -O http://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.14.tar.gz
curl -O http://ftp.gnu.org/pub/gnu/gettext/gettext-0.18.1.1.tar.gz

# m4
tar xjf m4*
cd m4*
./configure\
    --prefix=$PREFIX
make -j2
make install-strip
cd ..

# autoconf
tar xjf autoconf-2*
cd autoconf-2*
./configure\
    --prefix=$PREFIX\
    --disable-debug
make -j2
make install-strip
cd ..

# automake
tar xjf automake-*
cd automake-*
./configure\
    --prefix=$PREFIX
    --disable-debug
make -j2
make install-strip
cd ..

# libtool
tar xjf libtool-*
cd libtool-*
./configure\
    --prefix=$PREFIX
make -j2
make install-strip
cd ..

#pkg-config
tar xjf pkg-config*
cd pkg-config*
./configure\
    --prefix=$PREFIX
make -j2
make install
cd ..

#iconv
tar xjf libiconv*
cd libiconv*
./configure\
    --prefix=$PREFIX
make -j2
make install
cd ..

#gettext
tar xjf gettext*
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

