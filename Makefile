PROJECT = GPGMail
TARGET = GPGMail
CONFIG = Release

include Dependencies/GPGTools_Core/make/default

all: compile

update-core:
	@cd Dependencies/GPGTools_Core; git pull origin master; cd -
update-libmac:
	@cd Dependencies/Libmacgpg; git pull origin master; cd -
update-me:
	@git pull

update: update-core update-libmac update-me

compile:
	@INSTALL_GPGMAIL=0 xcodebuild -project GPGMail.xcodeproj -target GPGMail -configuration Release build

install:
	@killall Mail||/usr/bin/true
	@INSTALL_GPGMAIL=1 xcodebuild -project GPGMail.xcodeproj -target GPGMail -configuration Release build

test: compile
	@./Dependencies/GPGTools_Core/scripts/create_dmg.sh auto

clean-libmacgpg:
	xcodebuild -project Dependencies/Libmacgpg/Libmacgpg.xcodeproj -target Libmacgpg -configuration Release clean > /dev/null
	xcodebuild -project Dependencies/Libmacgpg/Libmacgpg.xcodeproj -target Libmacgpg -configuration Debug clean > /dev/null

clean-gpgmail:
	xcodebuild -project GPGMail.xcodeproj -target GPGMail -configuration Release clean > /dev/null
	xcodebuild -project GPGMail.xcodeproj -target GPGMail -configuration Debug clean > /dev/null

clean: clean-libmacgpg clean-gpgmail

test-compile:
	@./Utilities/testCompile.sh

