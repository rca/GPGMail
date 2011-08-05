#!/bin/bash
###############################################
# Test to compile GPGMail.
#
# @author   Alex <alex@gpgtools.org>
# @version  2011-08-05
#
###############################################

_root="`pwd`";

function clone {
    echo " * Removing old version...";
    cd $_root;
    : > $0.log
    rm -rf GPGMail.testbuild;
    echo -n " * Cloning sources: ";
    git clone --recursive --depth 1 git@github.com:GPGTools/GPGMail.git -b lion GPGMail.testbuild >> $0.log 2>&1
    if [ "$?" == "0" ]; then echo "PASS"; else echo "FAIL"; exit 1; fi
    cd GPGMail.testbuild
}

echo "Testing GPGMail.";
echo "(have a look at $0.log for details)";
echo "";

clone
echo -n " * Building (Release): ";
make clean >> $0.log 2>&1
INSTALL_GPGMAIL=0 xcodebuild -project GPGMail.xcodeproj -target GPGMail -configuration Release build >> $0.log 2>&1
if [ "$?" == "0" ]; then echo "PASS"; else echo "FAIL"; exit 1; fi
echo -n " * Building (Debug): ";
make clean >> $0.log 2>&1
INSTALL_GPGMAIL=0 xcodebuild -project GPGMail.xcodeproj -target GPGMail -configuration Debug build >> $0.log 2>&1
if [ "$?" == "0" ]; then echo "PASS"; else echo "FAIL"; exit 1; fi

clone
echo -n " * Building (update): ";
make clean update compile >> $0.log 2>&1
if [ "$?" == "0" ]; then echo "PASS"; else echo "FAIL"; exit 1; fi
echo -n " * Building (install): ";
rm -rf ~/Library/Mail/Bundles/GPGMail.mailbundle
make clean update install >> $0.log 2>&1
if [ "$?" == "0" ]; then echo -n "PASS - "; else echo "FAIL"; exit 1; fi
if [ -e ~/Library/Mail/Bundles/GPGMail.mailbundle ]; then echo "PASS"; else echo "FAIL"; exit 1; fi
