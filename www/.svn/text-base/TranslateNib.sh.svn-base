#!/bin/sh
#
# TranslateNib.sh
#
# This tools helps creating localized nib files,
# using (n)ibtool.
#
# Copyright Stephane Corthesy 2001-2004, stephane@sente.ch
#
# Mar 7 2002: v1, initial public release
# Jul 12 2002: v2, corrected CVS problem
# Jan 3 2003: v3, adapted for Dec 2002 Dev Tools; added Subversion support
# May 8 2005: v4, fixed Subversion support
# Jan 29 2006: v5, uses oids; aborts when .strings file is invalid
# Jan 6 2008: v6, updated for 10.5
#

usage ( ) {
	echo "Usage: `basename $0` operation language file"
	echo "       operation must be 'start' or 'end'"
	echo "       language must be English, French, Spanish, ..."
	echo "       file is the original nib file"
	echo "       (Output directory must be writable)"
}

if [ $# -ne 3 ] ; then \
	usage ; \
	exit 1
fi

operation="$1"
editor="/Applications/TextEdit.app"
# FIXME: Xcode tools can now be placed anywhere
if [ -f "/usr/bin/nibtool" ] ; then \ 
IS_NIBTOOL=1
NIBTOOL=/usr/bin/nibtool
else
IS_NIBTOOL=0
IBTOOL=/usr/bin/ibtool
fi

if [ "$operation" != "start" -a "$operation" != "end" ] ; then \
	usage ; \
	exit 1
fi

# Let's remove .nib/ suffix, if any
filename=`basename "$3" .nib`
inputDir=`dirname "$3"`
inputFile="$inputDir/$filename.nib"

# Now we check that source nib exists
if [ ! -d "$inputFile" ] ; then \
	echo "No such file "$inputFile ; \
	exit 1
fi

language="$2"
outputDir="$inputDir/../$language.lproj"
tempStringFile="$outputDir/___$filename.strings"
outputFile="$outputDir/$filename.nib"

if [ ! -d "$outputDir" ] ; then \
	mkdir "$outputDir"
fi

# If user already translated nib in the past, we update it:
# We use old translation strings + layout, merged with
# new strings+elements

if [ "$operation" = "start" ] ; then {
	rm -rf "$tempStringFile"
	if [ -d "$outputFile" ] ; then {
		if [ $IS_NIBTOOL -eq 1 ] ; then
            "$NIBTOOL" \
                --use-oids \
                --previous "$outputFile" \
                --localizable-strings \
                --incremental "$outputFile" \
                "$inputFile" \
                > "$tempStringFile"
        else
            "$IBTOOL" \
                --generate-stringsfile "$tempStringFile" \
                --previous-file "$outputFile" \
                --incremental-file "$outputFile" \
                "$inputFile"
        fi
	} else {
		if [ $IS_NIBTOOL -eq 1 ] ; then
            "$NIBTOOL" \
                --use-oids \
                --localizable-strings \
                "$inputFile" \
                > "$tempStringFile"
        else
            "$IBTOOL" \
                --generate-stringsfile "$tempStringFile" \
                "$inputFile"
        fi
	} fi
	open "$inputFile"
	open -a "$editor" "$tempStringFile"
} else {
    # Verify that .strings file format is correct
	plutil -lint -s -- "$tempStringFile"
    if [ $? -ne 0 ] ; then 
        exit 1
    fi
	if [ -d "$outputFile" ] ; then {
		# Let's preserve CVS/Subversion information, as (n)ibtool doesn't...
		if [ -d "$outputFile/CVS" ] ; then
			cp -pR "$outputFile/CVS" "$outputFile/../CVS.tmp"
		fi
		if [ -d "$outputFile/.svn" ] ; then
			cp -pR "$outputFile/.svn" "$outputFile/../.svn.tmp"
		fi
		if [ $IS_NIBTOOL -eq 1 ] ; then
            "$NIBTOOL" \
                $OID_OPTION \
                --dictionary "$tempStringFile" \
                --Write "$outputFile" \
                --incremental "$outputFile" \
                "$inputFile"
        else
            "$IBTOOL" \
                --localize-incremental \
                --previous-file "$outputFile" \
                --incremental-file "$outputFile" \
                --strings-file "$tempStringFile" \
                --write "$outputFile" \
                "$inputFile" ; \
        fi
		if [ -d "$outputFile/../CVS.tmp" ] ; then
			mv "$outputFile/../CVS.tmp" "$outputFile/CVS"
		fi
		if [ -d "$outputFile/../.svn.tmp" ] ; then
			mv "$outputFile/../.svn.tmp" "$outputFile/.svn"
		fi
	} else
		if [ $IS_NIBTOOL -eq 1 ] ; then
            "$NIBTOOL" \
                $OID_OPTION \
                --dictionary "$tempStringFile" \
                --write "$outputFile" \
                "$inputFile"
        else
            "$IBTOOL" \
                --strings-file "$tempStringFile" \
                --write "$outputFile" \
                "$inputFile"
        fi
	fi
	rm -rf "$tempStringFile"
	open "$outputFile"
} fi

# If file has only 2 bytes, it is empty
#if [ -z `cut -b "3,4" < "$tempStringFile"` ] ; then \
#	echo "Nothing to translate" 
#	rm -rf "$tempStringFile" ; \
#else
#	open "$inputFile"
#	open -a "$editor" "$tempStringFile"
#fi

exit 0
