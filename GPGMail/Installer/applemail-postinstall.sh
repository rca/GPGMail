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

###############################################################
# copied from GPGPreferences. This should be avoided:
# http://gpgtools.lighthouseapp.com/projects/65162/tickets/30
###############################################################

_bundleId="gpgmail";
_bundleName="GPGMail.mailbundle";
_bundleRootPath="$HOME/Library/Mail/Bundles";
_bundlePath="$_bundleRootPath/$_bundleName";
_plistBundle="$_bundlePath/Contents/Info";
_plistMail="/Applications/Mail.app/Contents/Info";
_plistFramework="/System/Library/Frameworks/Message.framework/Resources/Info";

isInstalled=`if [ -d "$_bundlePath" ]; then echo "1"; else echo "0"; fi`

if [ "1" == "$isInstalled" ]; then
  echo "[$_bundleId] is installed";
else
  foundDisabled=`find "$_bundleRootPath ("* -type d -name "$_bundleName"|head -n1`
  if [ "" != "$foundDisabled" ]; then
    mkdir -p "$_bundleRootPath";
    mv "$foundDisabled" "$_bundleRootPath";
  else
    echo "[$_bundleId] not found";
  fi
    echo "[$_bundleId] was reinstalled";
fi

uuid1=`defaults read "$_plistMail" "PluginCompatibilityUUID"`
uuid2=`defaults read "$_plistFramework" "PluginCompatibilityUUID"`
isPatched1=`grep $uuid1 "$_bundlePath/Contents/Info.plist" 2>/dev/null`
isPatched2=`grep $uuid2 "$_bundlePath/Contents/Info.plist" 2>/dev/null`

if [ "" != "$isPatched1" ] && [ "" != "$isPatched2" ] ; then
  echo "[$_bundleId] already patched";
else
  defaults write "$_plistBundle" "SupportedPluginCompatibilityUUIDs" -array-add "$uuid1"
  defaults write "$_plistBundle" "SupportedPluginCompatibilityUUIDs" -array-add "$uuid2"
  plutil -convert xml1 "$_plistBundle.plist"
  echo "[$_bundleId] successfully patched";
fi

# change the user and group to avoid problems when updating (so this skript needs to be run as root!)
chown -R $USER:Staff "$HOME/Library/Mail/Bundles/GPGMail.mailbundle"

exit 0
