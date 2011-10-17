all: compile

update-core:
	@cd Dependencies/GPGTools_Core; git pull origin master; cd -
update-libmac:
	@cd Dependencies/Libmacgpg; git pull origin lion; cd -
update-me:
	@git pull
	
update: update-core update-libmac update-me

compile:
	@INSTALL_GPGMAIL=0 xcodebuild -project GPGMail.xcodeproj -target GPGMail -configuration Release build

install:
	@killall Mail||/usr/bin/true
	@INSTALL_GPGMAIL=1 xcodebuild -project GPGMail.xcodeproj -target GPGMail -configuration Release build

dmg: clean update compile
	@./Utilities/create_sparkle.sh
	@./Dependencies/GPGTools_Core/scripts/create_dmg.sh

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

check-all-warnings: clean-gpgmail
	make | grep "warning: "

check-warnings: clean-gpgmail
	make | grep "warning: "|grep -v "#warning"

check: clean-gpgmail
	@if [ "`which scan-build`" == "" ]; then echo 'usage: PATH=$$PATH:path_to_scan_build make check'; echo "see: http://clang-analyzer.llvm.org/"; exit; fi
	@echo "";
	@echo "Have a closer look at these warnings:";
	@echo "=====================================";
	@echo "";
	@scan-build -analyzer-check-objc-missing-dealloc \
	            -analyzer-check-dead-stores \
	            -analyzer-check-idempotent-operations \
	            -analyzer-check-llvm-conventions \
	            -analyzer-check-objc-mem \
	            -analyzer-check-objc-methodsigs \
	            -analyzer-check-objc-missing-dealloc \
	            -analyzer-check-objc-unused-ivars \
	            -analyzer-check-security-syntactic \
	            --use-cc clang -o build/report xcodebuild \
	            -project GPGMail.xcodeproj -target GPGMail \
	            -configuration Release build 2>error.log|grep "is deprecated"
	@echo "";
	@echo "Now have a look at build/report/ or at error.log";

style:
	@if [ "`which uncrustify`" == "" ]; then echo 'usage: PATH=$$PATH:path_to_uncrustify make style'; echo "see: https://github.com/bengardner/uncrustify"; exit; fi
	uncrustify -c Utilities/uncrustify.cfg --no-backup Source/*.h
	uncrustify -c Utilities/uncrustify.cfg --no-backup Source/*.m
	uncrustify -c Utilities/uncrustify.cfg --no-backup Source/PrivateHeaders/*
	uncrustify -c Utilities/uncrustify.cfg --no-backup Source/GPG.subproj/*

