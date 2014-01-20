#!/bin/bash

cd deps/cocoalumberjack
git apply ../cocoalumberjack.patch

cd ../cocoafob
git apply ../cocoafob.patch
