#!/bin/bash

START=`pwd`
PREFIX=`pwd`/prefix
DEPS=`pwd`/deps
export PATH=$PREFIX/bin:$PATH
export DYLD_FALLBACK_LIBRARY_PATH="$PREFIX/lib"

mkdir $PREFIX

cd $DEPS/ogg
./autogen.sh --prefix=$PREFIX
make -j2
make install
cd $PREFIX/lib/
install_name_tool -id @rpath/libogg.0.dylib libogg.0.dylib

cd $DEPS/flac
./autogen.sh
CFLAGS="-I$PREFIX/include $CFLAGS" LDFLAGS="-L$PREFIX/lib $LDFLAGS" ./configure --prefix=$PREFIX
make -j2
make install
cd $PREFIX/lib/
install_name_tool -id @rpath/libFLAC.8.dylib libFLAC.8.dylib

cd $DEPS/vorbis
CFLAGS="-O2 $CFLAGS" ./autogen.sh --with-ogg=$PREFIX --prefix=$PREFIX
make -j2
make install
cd $PREFIX/lib
install_name_tool -id @rpath/libvorbisfile.3.dylib libvorbisfile.3.dylib
install_name_tool -id @rpath/libvorbis.0.dylib libvorbis.0.dylib
install_name_tool -change $PREFIX/lib/libvorbis.0.dylib @rpath/libvorbis.0.dylib libvorbisfile.3.dylib

cd $DEPS/taglib
cmake -DCMAKE_INSTALL_PREFIX=$PREFIX -DCMAKE_CXX_FLAGS="-stdlib=libstdc++"
make -j2
make install
cd $PREFIX/lib
install_name_tool -id @rpath/libtag.1.14.0.dylib libtag.1.14.0.dylib
