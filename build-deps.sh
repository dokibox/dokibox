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
install_name_tool -id @rpath/libogg.0.dylib libogg.0.dylib

cd $DEPS/flac
./autogen.sh
CFLAGS="-L$PREFIX/lib -I$PREFIX/include $CFLAGS" ./configure --disable-asm-optimizations --with-ogg=$PREFIX --prefix=$PREFIX
CFLAGS="-L$PREFIX/lib -I$PREFIX/include $CFLAGS" make -j2
cd src
make install
cd ../include
make install
cd $PREFIX/lib/
install_name_tool -id @rpath/libFLAC.8.dylib libFLAC.8.dylib
install_name_tool -change $START/libogg/../prefix/lib/libogg.0.dylib @rpath/libogg.0.dylib libFLAC.8.dylib

cd $DEPS/vorbis
CFLAGS="-O2 $CLFAGS" ./autogen.sh --with-ogg=$PREFIX --prefix=$PREFIX
make -j2
make install
cd $PREFIX/lib
install_name_tool -id @rpath/libvorbisfile.3.dylib libvorbisfile.3.dylib
install_name_tool -id @rpath/libvorbis.0.dylib libvorbis.0.dylib
install_name_tool -change $PREFIX/lib/libvorbis.0.dylib @rpath/libvorbis.0.dylib libvorbisfile.3.dylib

cd $DEPS/taglib
cmake -DCMAKE_INSTALL_PREFIX=$PREFIX
make -j2
make install
cd $PREFIX/lib
install_name_tool -id @executable_path/../Frameworks/libtag.1.11.0.dylib libtag.1.11.0.dylib
