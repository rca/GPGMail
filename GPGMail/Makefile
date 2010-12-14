all: install

install:
	INSTALL=1 xcodebuild -project GPGMail.xcodeproj -target GPGMail -configuration Release build

clean:
	rm -rf Dependencies/MacGPGME/build/dist
	xcodebuild -project GPGMail.xcodeproj -target GPGMail -configuration Release clean
