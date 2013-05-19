#!/bin/bash
# This is the package post-install script for GPGMail.


# config #######################################################################
sysdir="/Library/Mail/Bundles"
netdir="/Network/Library/Mail/Bundles"
homedir="$HOME/Library/Mail/Bundles"
bundle="GPGMail.mailbundle"
USER=${USER:-$(id -un)}
temporarydir="$2"
################################################################################


# Find real target #############################################################
existingInstallationAt=""

if [[ -e "$netdir/$bundle" ]]; then
    existingInstallationAt="$netdir"
    target="$netdir"
elif [[ -e "$homedir/$bundle" ]]; then
    existingInstallationAt="$homedir"
    target="$homedir"
elif [[ -e "$sysdir/$bundle" ]]; then
    existingInstallationAt="$sysdir"
    target="$sysdir"
else
    target="$sysdir"
fi

################################################################################

echo "Temporary dir: $temporarydir"
echo "existing installation at: $existingInstallationAt"
echo "installation target: $target"

# Check if GPGMail is correct installed ########################################
if [[ ! -e "$temporarydir/$bundle" ]]; then
	echo "[gpgmail] Couldn't install '$bundle' in temporary directory $temporarydir.  Aborting." >&2
	exit 1
fi
################################################################################

# Cleanup ######################################################################
if [[ "$existingInstallationAt" != "" ]]; then
    echo "[gpgmail] Removing existing installation of the bundle..."
    rm -rf "$existingInstallationAt/$bundle" || exit 1
fi
################################################################################

# Proper installation ##########################################################
echo "[gpgmail] Moving bundle to final destination: $target"
if [[ ! -d "$target" ]]; then
	mkdir -p "$target" || exit 1
fi
mv "$temporarydir/$bundle" "$target/" || exit 1
################################################################################

# Permissions ##################################################################
# see http://gpgtools.lighthouseapp.com/projects/65764-gpgmail/tickets/134
# see http://gpgtools.lighthouseapp.com/projects/65764-gpgmail/tickets/169
echo "[gpgmail] Fixing permissions..."
if [ "$target" == "$homedir" ]; then
    chown "$USER:staff" "$HOME/Library/Mail"
    chown -R "$USER:staff" "$homedir"
fi
chmod -R 755 "$target"
################################################################################

# TODO: Update for Mountain Lion!
# enable bundles in Mail #######################################################
echo "[gpgmail] Enabling bundle..."
######
# Mail must NOT be running by the time this script executes
######

case "$(sw_vers -productVersion | cut -d . -f 2)" in
	8) bundleCompVer=6 ;;
	7) bundleCompVer=5 ;;
	6) bundleCompVer=4 ;;
	*) bundleCompVer=3 ;;
esac

defaults write "/Library/Preferences/com.apple.mail" EnableBundles -bool YES
defaults write "/Library/Preferences/com.apple.mail" BundleCompatibilityVersion -int $bundleCompVer
################################################################################


# Add the PluginCompatibilityUUIDs #############################################
echo "[gpgmail] Adding PluginCompatibilityUUIDs..."
plistBundle="$target/$bundle/Contents/Info"
plistMail="/Applications/Mail.app/Contents/Info"
plistFramework="/System/Library/Frameworks/Message.framework/Resources/Info"

uuid1=$(defaults read "$plistMail" "PluginCompatibilityUUID")
uuid2=$(defaults read "$plistFramework" "PluginCompatibilityUUID")

if [[ -z "$uuid1" || -z "$uuid2" ]] ;then
    echo "No UUIDs found."
else
	if ! grep -q $uuid1 "${plistBundle}.plist" || ! grep -q $uuid2 "${plistBundle}.plist" ;then
		defaults write "$plistBundle" "SupportedPluginCompatibilityUUIDs" -array-add "$uuid1"
		defaults write "$plistBundle" "SupportedPluginCompatibilityUUIDs" -array-add "$uuid2"
		plutil -convert xml1 "$plistBundle.plist"
		echo "GPGMail successfully patched."
	fi
fi
################################################################################

exit 0
