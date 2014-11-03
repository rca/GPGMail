#!/usr/bin/env python

import sys
from time import time
import subprocess

KEY_ID = "85E3 8F69 046B 44C1 EC9F B07B 76D7 8F05 00D0 26C4"

def add_expiration_date(path, minutes):
	fh = open(path, "a")
	timestamp = int(time()) + (minutes * 60)
	fh.write("%s" % (timestamp))
	fh.close()
	
def create_signature(path, destination):
	subprocess.call(["gpg", "-bs", "-u", KEY_ID.replace(" ", ""), "--batch", "--output", destination, path])

def main():
	EXECUTABLE = "build/Release/GPGMail.mailbundle/Contents/MacOS/GPGMail"
	SIG = "build/Release/GPGMail.mailbundle/Contents/Resources/signature-icon.gif"
	add_expiration_date(EXECUTABLE, int(sys.argv[1]))
	create_signature(EXECUTABLE, SIG)

print "Adding expiration date."
main()