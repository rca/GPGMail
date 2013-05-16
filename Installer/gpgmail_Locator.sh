#!/bin/bash
# This is the bundle pre-install script for GPGMail.


# config #######################################################################
linkPath="${2%/*}"
sysdir="/Library/Mail/Bundles"
netdir="/Network/Library/Mail/Bundles"
homedir="$HOME/Library/Mail/Bundles"
bundle="GPGMail.mailbundle"
################################################################################

# determine where to install the bundle to #####################################
if [[ -e "$netdir/$bundle" ]]; then
    target="$netdir"
elif [[ -e "$homedir/$bundle" ]]; then
    target="$homedir"
else
    target="$sysdir"
fi
echo "Install to: $target"
mkdir -p "$target" || exit 1
################################################################################

# make a symlink to the install location  ######################################
echo "Link path: $linkPath"
rm -rf "$linkPath"
mkdir -p "${linkPath%/*}"
ln -s "$target" "$linkPath" || exit 1
################################################################################

exit 0
