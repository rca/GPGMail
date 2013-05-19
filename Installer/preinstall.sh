#!/bin/bash
# This is the package pre-install script for GPGMail.

ps -xo command -u "$USER" | grep -q '/\Mail.app/' || exit 0

echo "Mail is running. Killing it softly..."

osascript -e 'tell application "/System/Library/CoreServices/Installer.app"
	activate
	display dialog "In order to finish the installation of GPGMail we have to quit Mail" buttons {"Quit Mail"} default button 1 giving up after 60 with icon caution
	end tell
	quit app "Mail"'
