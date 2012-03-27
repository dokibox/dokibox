#!/bin/bash

START=`pwd`

cd mpg123
./configure --with-cpu=x86-64 --enable-static
make
cd src/libmpg123/.libs
install_name_tool -id @executable_path/../Frameworks/libmpg123.0.dylib libmpg123.0.dylib
cd $START

cd libogg
./configure --prefix=`pwd`/../prefix
make
make install
cd $START/prefix/lib/
install_name_tool -id @executable_path/../Frameworks/libogg.0.dylib libogg.0.dylib
cd $START

cd flac
./configure --disable-asm-optimizations -with-ogg=`pwd`/../prefix --prefix=`pwd`/../prefix
make
make install
cd $START/prefix/lib/
install_name_tool -id @executable_path/../Frameworks/libFLAC.8.2.0.dylib libFLAC.8.2.0.dylib
install_name_tool -change $START/libogg/../prefix/lib/libogg.0.dylib @executable_path/../Frameworks/libogg.0.dylib libFLAC.dylib

