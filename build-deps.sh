#!/bin/bash

START=`pwd`
PREFIX=`pwd`/prefix
DEPS=`pwd`/deps
PATH=$PREFIX/bin:$PATH

mkdir $PREFIX

cd $DEPS/ogg
./autogen.sh --prefix=$PREFIX
make -j2
make install
cd $PREFIX/lib/
install_name_tool -id @executable_path/../Frameworks/libogg.0.dylib libogg.0.dylib

cd $DEPS/flac
touch config.rpath
CFLAGS="-L$PREFIX/lib -I$PREFIX/include $CFLAGS" ./autogen.sh --disable-asm-optimizations --with-ogg=$PREFIX --prefix=$PREFIX
CFLAGS="-L$PREFIX/lib -I$PREFIX/include $CFLAGS" make -j2
cd src
make install
cd ../include
make install
cd $PREFIX/lib/
install_name_tool -id @executable_path/../Frameworks/libFLAC.8.dylib libFLAC.8.dylib
install_name_tool -change $START/libogg/../prefix/lib/libogg.0.dylib @executable_path/../Frameworks/libogg.0.dylib libFLAC.8.dylib

cd $DEPS/mpg123
autoreconf -iv
./configure --with-cpu=x86-64 --enable-static --prefix=$PREFIX
make -j2
make install
cd $PREFIX/lib
install_name_tool -id @executable_path/../Frameworks/libmpg123.0.dylib libmpg123.0.dylib

cd $DEPS/vorbis
CFLAGS="-O2 $CLFAGS" ./autogen.sh --with-ogg=$PREFIX --prefix=$PREFIX
make -j2
make install
cd $PREFIX/lib
install_name_tool -id @executable_path/../Frameworks/libvorbisfile.3.dylib libvorbisfile.3.dylib
install_name_tool -id @executable_path/../Frameworks/libvorbis.0.dylib libvorbis.0.dylib
install_name_tool -change $PREFIX/lib/libvorbis.0.dylib @executable_path/../Frameworks/libvorbis.0.dylib libvorbisfile.3.dylib

cd $DEPS/taglib
cmake -DCMAKE_INSTALL_PREFIX=$PREFIX
make -j2
make install
cd $PREFIX/lib
install_name_tool -id @executable_path/../Frameworks/libtag.1.7.2.dylib libtag.1.7.2.dylib
