all: install

install:
	INSTALL_GPGMAIL=1 xcodebuild -project GPGMail.xcodeproj -target GPGMail -configuration Release build

clean-gpgme:
	rm -rf Dependencies/MacGPGME/build/dist

clean-gpgmail:
	xcodebuild -project GPGMail.xcodeproj -target GPGMail -configuration Release clean
	xcodebuild -project GPGMail.xcodeproj -target GPGMail -configuration Debug clean

clean: clean-gpgme clean-gpgmail

check: clean-gpgmail
	@clear
	@if [ "`which scan-build`" == "" ]; then echo 'usage: PATH=$$PATH:path_to_scan_build make check'; echo "see: http://clang-analyzer.llvm.org/"; exit; fi
	#@scan-build -analyzer-check-objc-missing-dealloc -analyzer-check-llvm-conventions --experimental-checks --use-cc clang -o build/report xcodebuild -project GPGMail.xcodeproj -target GPGMail -configuration Debug 2>error.log|grep "is deprecated"
	scan-build -analyzer-check-objc-missing-dealloc -analyzer-check-llvm-conventions --experimental-checks --use-cc clang -o build/report xcodebuild -project GPGMail.xcodeproj -target GPGMail -configuration Debug
	@echo "Have a look above and at build/report/index.html (and maybe at error.log)"

style:
	@if [ "`which uncrustify`" == "" ]; then echo 'usage: PATH=$$PATH:path_to_uncrustify make style'; echo "see: https://github.com/bengardner/uncrustify"; exit; fi
	uncrustify -c Utilities/uncrustify.cfg --no-backup Source/*.h
	uncrustify -c Utilities/uncrustify.cfg --no-backup Source/*.m
	uncrustify -c Utilities/uncrustify.cfg --no-backup Source/PrivateHeaders/*
	uncrustify -c Utilities/uncrustify.cfg --no-backup Source/GPG.subproj/*

