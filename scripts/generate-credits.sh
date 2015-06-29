#!/bin/sh

CREDITS_HTML="$BUILT_PRODUCTS_DIR/$CONTENTS_FOLDER_PATH/Resources/en.lproj/Credits.html"

cp "$SRCROOT/AUTHORS" AUTHORS.TEMP
sed -i '' -e 's/</\&lt;/g' -e 's/>/\&gt;/g' AUTHORS.TEMP
sed -i '' -e '/__AUTHORS__/{' -e "r AUTHORS.TEMP" -e 'd' -e '}' "$CREDITS_HTML"
rm AUTHORS.TEMP

sed -i '' -e '/__LICENSE__/{' -e "r $SRCROOT/LICENSE" -e 'd' -e '}' "$CREDITS_HTML"
sed -i '' -e '/__LICENSE_SPMEDIAKEYTAP__/{' -e "r $SRCROOT/deps/SPMediaKeyTap/LICENSE" -e 'd' -e '}' "$CREDITS_HTML"
sed -i '' -e '/__LICENSE_COCOALUMBERJACK__/{' -e "r $SRCROOT/deps/cocoalumberjack/LICENSE.txt" -e 'd' -e '}' "$CREDITS_HTML"
sed -i '' -e '/__LICENSE_FLAC__/{' -e "r $SRCROOT/deps/flac/COPYING.Xiph" -e 'd' -e '}' "$CREDITS_HTML"
sed -i '' -e '/__LICENSE_OGG__/{' -e "r $SRCROOT/deps/ogg/COPYING" -e 'd' -e '}' "$CREDITS_HTML"
sed -i '' -e '/__LICENSE_VORBIS__/{' -e "r $SRCROOT/deps/vorbis/COPYING" -e 'd' -e '}' "$CREDITS_HTML"
sed -i '' -e '/__LICENSE_SPARKLE__/{' -e "r $SRCROOT/deps/sparkle/LICENSE" -e 'd' -e '}' "$CREDITS_HTML"
sed -i '' -e '/__LICENSE_TAGLIB__/{' -e "r $SRCROOT/deps/taglib/COPYING.LGPL" -e 'd' -e '}' "$CREDITS_HTML"
sed -i '' -e '/__LICENSE_MASPREFERENCES__/{' -e "r $SRCROOT/deps/MASPreferences/LICENSE.md" -e 'd' -e '}' "$CREDITS_HTML"
sed -i '' -e '/__LICENSE_FFMPEG__/{' -e "r $SRCROOT/deps/ffmpeg/COPYING.LGPLv2.1" -e 'd' -e '}' "$CREDITS_HTML"
