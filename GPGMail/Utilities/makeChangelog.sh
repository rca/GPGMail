#!/bin/bash

#################################################
# MakeChangelog Script				#
# Creates a Nice HTML Changelog for Sparkle 	#
# Copyright the GPGMail Project 2010	   	#
#						#
# to call it: 					#
# $ ./makeChangelog <ChangelogFile> <Version>	#
#################################################

if [ $# -ne 2 ]
then
  echo "Usage: $ ./makeChangelog <ChangelogFile> <Version>"
  exit 1
fi

## INIT ##
orig=$1
version=$2

## Settings ##
headerFile="changelog_header.html"
footerFile="changelog_footer.html"

newFileName="CHANGELOG_$version.html"

## Start ##
if [ -e $headerFile ]
then
	cat $headerFile | sed -e "s/{VERSION}/$version/" >$newFileName
fi
sed -e 's/\</\&lt;/' $orig >temp.html
sed  -i '' -e 's/^        \(.*\)/<li>\1<\/li>/' temp.html
sed  -e 's/^\([[:digit:]].*\)/<\/ul><\/div><div class="box"><div class="box-head">\1<\/div><ul>/' -e '1s/<\/ul><\/div>//' temp.html >> $newFileName
echo '</ul></div>' >>$newFileName
if [ -e $footerFile ]
then
        cat $footerFile >>$newFileName
fi

## Cleanup ##
rm temp.html


exit 0
