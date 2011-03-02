#!/bin/bash

if [ ! -e Makefile.config ]; then
	echo "Wrong directory..." >&2
	exit 1
fi

source "Makefile.config"

PRIVATE_KEY_NAME="$sshKeyname"
dmgName=${dmgName:-"$name-$version.dmg"}
dmgPath=${dmgPath:-"build/$dmgName"}

cd build/Release
zip -r "../$name-$version.zip" GPGMail.mailbundle;

echo " * Filename: build/$name-$version.zip";
echo -n " * Sparkle signature: ";
openssl dgst -sha1 -binary < "../$name-$version.zip" | \
openssl dgst -dss1 -sign <(security find-generic-password -g -s "$PRIVATE_KEY_NAME" 2>&1 >/dev/null | \
perl -pe '($_) = /<key>NOTE<\/key>.*<string>(.*)<\/string>/; s/\\012/\n/g') | \
openssl enc -base64

echo ""
cd -
