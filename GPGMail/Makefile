all: install

install:
	xcodebuild -project GPGMail.xcodeproj -target GPGMail -configuration Release build
	SetFile -a B build/Release/GPGMail.mailbundle/

clean:
	rm -rf Dependencies/MacGPGME/build/dist
	xcodebuild -project GPGMail.xcodeproj -target GPGMail -configuration Release clean
