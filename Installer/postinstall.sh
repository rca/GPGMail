#!/bin/bash
# This is the package post-install script for GPGMail.


# config #######################################################################
sysdir="/Library/Mail/Bundles"
netdir="/Network/Library/Mail/Bundles"
homedir="$HOME/Library/Mail/Bundles"
bundle="GPGMail.mailbundle"
USER=${USER:-$(id -un)}
temporarydir=/private/tmp/org.gpgtools/gpgmail_lml_install
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
	9) bundleCompVer=7 ;;
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

if [[ -n "$uuid1" ]] && ! grep -q $uuid1 "${plistBundle}.plist" ;then
	defaults write "$plistBundle" "SupportedPluginCompatibilityUUIDs" -array-add "$uuid1"
fi
if [[ -n "$uuid2" ]] && ! grep -q $uuid2 "${plistBundle}.plist" ;then
	defaults write "$plistBundle" "SupportedPluginCompatibilityUUIDs" -array-add "$uuid2"
fi

plutil -convert xml1 "$plistBundle.plist"
chmod +r "$plistBundle.plist"
################################################################################


# Remove old plist #############################################################
a=$'\6'
b=$'\7'
p1=".*?${b}name: ([^$a]*)"
p2=".*?${a}uid: ([^$a]*)"
p3=".*?${a}gid: ([^$a]*)"
p4=".*?${a}dir: ([^$a]*)"
pend="[^$b]*"

temptext=$b$(dscacheutil -q user | perl -0 -pe "s/\n\n/$b/g;s/\n/$a/g") # Get all users and replace all newlines, so the next RE can work correctly.
perl -pe "s/$p1$p2$p3$p4$pend/\1 \2 \3 \4\n/g" <<<"$temptext" | # This RE create one line per user.
while read username uid gid homedir # Iterate through each user.
do
	[[ -n "$uid" && "$uid" -ge 500 && -d "$homedir" ]] || continue # Only proceed with regular accounts, which also have a homedir.
	[[ "$gid" -lt 500 ]] || continue # I think a gid >= 500 indicates a special user. (e.g. like macports)

	[[ "$homedir" == "${homedir#/Network}" ]] || continue # Ignore home-dirs starting with "/Network".

	# If the plist exists, remove it.
	oldPlist="$homedir/Library/Containers/com.apple.mail/Data/Library/Preferences/org.gpgtools.gpgmail.plist"
	if [[ -f "$oldPlist" ]] ;then
		rm -f "$oldPlist"
	fi
done
################################################################################


# Disable Mail.app 32-bit mode if needed #######################################
PlistBuddy=/usr/libexec/PlistBuddy
plist=$HOME/Library/Preferences/com.apple.LaunchServices.plist

if [[ "$($PlistBuddy -c "print LSArchitecturesForX86_64v2:com.apple.mail:1" "$plist")"  == "i386" ]] ;then
    $PlistBuddy -c "set LSArchitecturesForX86_64v2:com.apple.mail:1 x86_64" "$plist"
    killall -HUP Finder Dock
fi
################################################################################

# Remove obsolete uuid-patcher .plist from LaunchAgents. It should reside in LaunchDaemons
# from now on.
UUID_PATCHER_PLIST="/Library/LaunchAgents/org.gpgtools.gpgmail.patch-uuid.plist"
if [ -f "$UUID_PATCHER_PLIST" ]; then
    rm -f "$UUID_PATCHER_PLIST"
fi


exit 0
