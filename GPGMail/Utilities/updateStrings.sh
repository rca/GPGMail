#!/bin/bash
###############################################
# Update some strings in the project.
#
# @author   Alexander Willner <alex@willner.ws>
# @version  2010-07-27
###############################################

###############################################
# Setup
###############################################
ext=( `echo strings plist xml` );
###############################################


###############################################
# Change strings
###############################################
for ((i=0; i<${#ext[*]}; i++)) do
	find . -iname "*.${ext[$i]}" -type f -exec sed -i "" "s/\/gpgmail.org/\/www.gpgmail.org/" {} \;
	find . -iname "*.${ext[$i]}" -type f -exec sed -i "" "s/1\.2\.3 (v62)/1.3.0/" {} \;
	find . -iname "*.${ext[$i]}" -type f -exec sed -i "" "s/1\.2\.3/1.3.0/" {} \;
	find . -iname "*.${ext[$i]}" -type f -exec sed -i "" "s/2000-2008/2000-2010/" {} \;
	find . -iname "*.${ext[$i]}" -type f -exec sed -i "" "s/Stéphane Corthésy/GPGMail Project Team/" {} \;
	find . -iname "*.${ext[$i]}" -type f -exec sed -i "" "s/St&eacute;phane Corth&eacute;sy/GPGMail Project Team/" {} \;
done
###############################################
