#!/bin/sh

# cd to dir and then make zipfile
cd build/Release
ditto -ck --keepParent "GPGMail.mailbundle" "GPGMail.zip"