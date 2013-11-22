#!/bin/bash

cd deps/flac
git apply ../flac-gnu89.patch
cd ../..

cd deps/cocoalumberjack
git apply ../cocoalumberjack.patch
