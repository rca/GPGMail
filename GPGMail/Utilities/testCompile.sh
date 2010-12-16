#!/bin/bash
###############################################
# Test to compile GPGMail.
#
# @author   Alexander Willner <alex@willner.ws>
# @version  2010-12-14
# @todo     Nothing yet
#
###############################################

echo "Testing GPGMail.";
echo "(have a look at $0.log for details)";
echo "";

echo -n " * Removing old version: ";
rm -rf GPGMail && rm -rf ~/Library/Mail/Bundles/GPGMail.mailbundle
if [ "$?" == "0" ]; then echo "PASS"; else echo "FAIL"; exit 1; fi

echo -n " * Cloning sources: ";
git clone --recursive git://github.com/GPGMail/GPGMail.git > $0.log 2>&1
if [ "$?" == "0" ]; then echo "PASS"; else echo "FAIL"; exit 1; fi

echo -n " * Building: ";
cd GPGMail/GPGMail
make > $0.log 2>&1
if [ "$?" == "0" ]; then echo "PASS"; else echo "FAIL"; exit 1; fi

echo -n " * Is installed: ";
if [ -e ~/Library/Mail/Bundles/GPGMail.mailbundle ]; then echo "PASS"; else echo "FAIL"; exit 1; fi

rm $0.log
