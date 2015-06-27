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

cd $DEPS/ffmpeg
./configure --prefix=$PREFIX --disable-encoders --disable-hwaccels --disable-muxers --disable-devices --disable-filters --disable-programs --disable-protocols --enable-shared --disable-doc --disable-decoder=h264_vda
make -j4
make install
cd $PREFIX/lib
install_name_tool -id @rpath/libavformat.56.dylib libavformat.56.dylib
install_name_tool -id @rpath/libavcodec.56.dylib libavcodec.56.dylib
install_name_tool -id @rpath/libswresample.1.dylib libswresample.1.dylib
install_name_tool -id @rpath/libavutil.54.dylib libavutil.54.dylib
install_name_tool -change $PREFIX/lib/libavutil.54.dylib @rpath/libavutil.54.dylib libswresample.1.dylib
install_name_tool -change $PREFIX/lib/libavutil.54.dylib @rpath/libavutil.54.dylib libavcodec.56.dylib
install_name_tool -change $PREFIX/lib/libavutil.54.dylib @rpath/libavutil.54.dylib libavformat.56.dylib
install_name_tool -change $PREFIX/lib/libswresample.1.dylib @rpath/libswresample.1.dylib libavcodec.56.dylib
install_name_tool -change $PREFIX/lib/libswresample.1.dylib @rpath/libswresample.1.dylib libavformat.56.dylib
install_name_tool -change $PREFIX/lib/libavcodec.56.dylib @rpath/libavcodec.56.dylib libavformat.56.dylib

