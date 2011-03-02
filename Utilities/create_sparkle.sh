#!/bin/bash

if [ ! -e Makefile.config ]; then
	echo "Wrong directory..." >&2
	exit 1
fi

read -p "Create Sparkle zip file [y/n]? " input

if [ "x$input" == "xy" -o "x$input" == "xY" ]; then
    source "Makefile.config"
    cd build/Release

    filename="../$name-$version.zip";
    rm -f "$filename"
    zip -qyr "$filename" GPGMail.mailbundle/;

    echo " * Filename: build/$name-$version.zip";

    echo -n " * File size: ";
    stat -f "%z" "$filename"

    echo -n " * Sparkle signature: ";
    openssl dgst -sha1 -binary < "$filename" | \
    openssl dgst -dss1 -sign <(security find-generic-password -g -s "$sshKeyname" 2>&1 >/dev/null | \
    perl -pe '($_) = /<key>NOTE<\/key>.*<string>(.*)<\/string>/; s/\\012/\n/g') | \
    openssl enc -base64

    echo -n " * SHA-1: ";
    shasum "$filename"

    gpg2 -bau 76D78F0500D026C4 -o "$filename.sig" "$filename"

    echo ""
    cd - > /dev/null
fi
