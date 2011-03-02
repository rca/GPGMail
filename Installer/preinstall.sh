#!/bin/sh

# fix permissions (http://gpgtools.lighthouseapp.com/projects/65764-gpgmail/tickets/134)
mkdir -p "$HOME/Library/Mail/Bundles"
chown -R $USER:Staff "$HOME/Library/Mail/Bundles"
chmod 755 "$HOME/Library/Mail/Bundles"

# remove old version of bundle
rm -rf "$HOME/Library/Mail/Bundles/GPGMail.mailbundle"
# remove possible leftovers of previous installations
rm -rf "/private/tmp/GPGMail_Installation"
