#!/bin/sh
tempdir=/private/tmp/GPGMail_Installation

# determine where to install the bundle to
if ( test -e "/Library/Mail/Bundles/GPGMail.mailbundle" ) then
	mv "$tempdir/GPGMail.mailbundle" "/Library/Mail/Bundles/"
else
	sudo -u $USER mkdir -p "$HOME/Library/Mail/Bundles"
	# The installer has to make sure, that the "GPGMail.mailbundle" is installed in $tempdir
    rm -fr "$HOME/Library/Mail/Bundles/GPGMail.mailbundle"
    chown -R $USER:Staff "$tempdir/GPGMail.mailbundle"
    sudo -u $USER cp -r "$tempdir/GPGMail.mailbundle" "$HOME/Library/Mail/Bundles/"
	# change the user and group to avoid problems when updating (so this skript needs to be run as root!)
	chown -R $USER:Staff "$HOME/Library/Mail/Bundles/GPGMail.mailbundle"
fi

if [ ! "`diff -r $tempdir/GPGMail.mailbundle $HOME/Library/Mail/Bundles/GPGMail.mailbundle`" == "" ]; then
    echo "Installation failed. GPGMail bundle was not installed or updated at $HOME/Library/Mail/Bundles/";
    rm -fr "$tempdir/GPGMail.mailbundle"
    exit 1;
fi
rm -fr "$tempdir/GPGMail.mailbundle"

# cleanup tempdir "rm -d" deletes the temporary installation dir only if empty.
# that is correct because if eg. /tmp is you install dir, there can be other stuff
# in there that should not be deleted
rm -d "$tempdir"

# enable bundles in Mail
######
# Note that we are running sudo'd, so these defaults will be written to
# /Library/Preferences/com.apple.mail.plist
#
# Mail must NOT be running by the time this script executes
######
if [ `whoami` == root ] ; then
    #defaults acts funky when asked to write to the root domain but seems to work with a full path
	domain=/Library/Preferences/com.apple.mail
else
    domain=com.apple.mail
fi

defaults write "$domain" EnableBundles -bool YES
defaults write "$domain" BundleCompatibilityVersion -int 3

