PROJECT = GPGMail
TARGET = GPGMail
PRODUCT = GPGMail
UPDATER_PROJECT = GPGMail_Updater
UPDATER_TARGET = GPGMail_Updater
UPDATER_PRODUCT = build/$(CONFIG)/GPGMail_Updater.app
MAKE_DEFAULT = Dependencies/GPGTools_Core/newBuildSystem/Makefile.default
VPATH = build/$(CONFIG)/GPGMail.mailbundle/Contents/MacOS
NEED_LIBMACGPG = 1


-include $(MAKE_DEFAULT)

.PRECIOUS: $(MAKE_DEFAULT)
$(MAKE_DEFAULT):
	@echo "Dependencies/GPGTools_Core is missing.\nPlease clone it manually from https://github.com/GPGTools/GPGTools_Core\n"
	@exit 1

init: $(MAKE_DEFAULT)


$(PRODUCT): Source/* Resources/* Resources/*/* GPGMail.xcodeproj
	@xcodebuild -project $(PROJECT).xcodeproj -configuration $(CONFIG) -target $(TARGET) build $(XCCONFIG)

updater:
	@xcodebuild -project $(UPDATER_PROJECT).xcodeproj -target $(UPDATER_TARGET) -configuration $(CONFIG) build $(XCCONFIG)

clean-updater:
	@xcodebuild -project $(UPDATER_PROJECT).xcodeproj -target $(UPDATER_TARGET) -configuration $(CONFIG) clean > /dev/null


$(UPDATER_PRODUCT): GPGMail_Updater/* GPGMail_Updater/*/* GPGMail_Updater.xcodeproj
	@xcodebuild -project $(UPDATER_PROJECT).xcodeproj -target $(UPDATER_TARGET) -configuration $(CONFIG) build $(XCCONFIG)

compile: $(UPDATER_PRODUCT)

install: $(PRODUCT)
	@echo "Installing GPGMail into $(INSTALL_ROOT)Library/Mail/Bundles"
	@mkdir -p "$(INSTALL_ROOT)Library/Mail/Bundles"
	@rsync -rltDE "build/$(CONFIG)/GPGMail.mailbundle" "$(INSTALL_ROOT)Library/Mail/Bundles"
	@echo Done
	@echo "In order to use GPGMail, please don't forget to install MacGPG2 and Libmacgpg."

