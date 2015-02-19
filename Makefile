PROJECT = GPGMail
TARGET = GPGMail
PRODUCT = GPGMail.mailbundle
UPDATER_PROJECT = GPGMail_Updater
UPDATER_TARGET = GPGMail_Updater
UPDATER_PRODUCT = GPGMail_Updater.app
VPATH = build/Release

all: $(PRODUCT) $(UPDATER_PRODUCT)

$(PRODUCT): Source/* Resources/* Resources/*/* GPGMail.xcodeproj
	@xcodebuild -project $(PROJECT).xcodeproj -target $(TARGET) build $(XCCONFIG)

updater: $(UPDATER_PRODUCT)

$(UPDATER_PRODUCT): GPGMail_Updater/* GPGMail_Updater/*/* GPGMail_Updater.xcodeproj
	@xcodebuild -project $(UPDATER_PROJECT).xcodeproj -target $(UPDATER_TARGET) build $(XCCONFIG)

clean:
	rm -rf "./build"
