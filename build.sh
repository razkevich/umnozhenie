#!/bin/sh
set -eu
cd "$(dirname "$0")"
export JAVA_HOME=/opt/homebrew/opt/openjdk@21
export PATH="$JAVA_HOME/bin:$PATH"
SDK=/opt/homebrew/share/android-commandlinetools
BT=$SDK/build-tools/36.1.0
JAR=$SDK/platforms/android-36/android.jar
PW=$(security find-generic-password -s umnozhenie-upload-key -w)
OUT=build
rm -rf $OUT && mkdir -p $OUT/classes $OUT/dex $OUT/module/manifest $OUT/module/dex

$BT/aapt2 compile --dir app/res -o $OUT/res.zip
javac_sources() { find app/src $OUT/gen -name '*.java'; }

# APK for direct install
$BT/aapt2 link -o $OUT/base.apk -I $JAR --manifest app/AndroidManifest.xml -A app/assets --java $OUT/gen $OUT/res.zip
javac -source 11 -target 11 -Xlint:-options -classpath $JAR -d $OUT/classes $(javac_sources)
$BT/d8 --min-api 26 --lib $JAR --output $OUT/dex $(find $OUT/classes -name '*.class')
cp $OUT/base.apk $OUT/unaligned.apk
(cd $OUT/dex && zip -q ../unaligned.apk classes.dex)
$BT/zipalign -f -p 4 $OUT/unaligned.apk $OUT/aligned.apk
$BT/apksigner sign --ks upload.jks --ks-key-alias upload --ks-pass "pass:$PW" --key-pass "pass:$PW" --out umnozhenie.apk $OUT/aligned.apk

# AAB for Google Play
$BT/aapt2 link --proto-format -o $OUT/proto.apk -I $JAR --manifest app/AndroidManifest.xml -A app/assets $OUT/res.zip
(cd $OUT/module && unzip -q ../proto.apk && mv AndroidManifest.xml manifest/ && cp ../dex/classes.dex dex/ && zip -q -r ../base.zip .)
rm -f umnozhenie.aab
bundletool build-bundle --modules=$OUT/base.zip --output=umnozhenie.aab
jarsigner -sigalg SHA256withRSA -digestalg SHA-256 -keystore upload.jks -storepass "$PW" -keypass "$PW" umnozhenie.aab upload >/dev/null

$BT/apksigner verify umnozhenie.apk
jarsigner -verify umnozhenie.aab | tail -1
ls -l umnozhenie.apk umnozhenie.aab
