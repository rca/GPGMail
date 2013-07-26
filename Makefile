PROJECT = GPGMail
TARGET = GPGMail
PRODUCT = GPGMail
MAKE_DEFAULT = Dependencies/GPGTools_Core/newBuildSystem/Makefile.default
VPATH = build/$(CONFIG)/GPGMail.mailbundle/Contents/MacOS
NEED_LIBMACGPG = 1


-include $(MAKE_DEFAULT)

.PRECIOUS: $(MAKE_DEFAULT)
$(MAKE_DEFAULT):
	@bash -c "$$(curl -fsSL https://raw.github.com/GPGTools/GPGTools_Core/master/newBuildSystem/prepare-core.sh)"

init: $(MAKE_DEFAULT)


$(PRODUCT): Source/* Resources/* Resources/*/* GPGMail.xcodeproj
	@xcodebuild -project $(PROJECT).xcodeproj -configuration $(CONFIG) -target $(TARGET) build $(XCCONFIG)

install: $(PRODUCT)
	@echo "Installing GPGMail into $(INSTALL_ROOT)Library/Mail/Bundles"
	@mkdir -p "$(INSTALL_ROOT)Library/Mail/Bundles"
	@rsync -rltDE "build/$(CONFIG)/GPGMail.mailbundle" "$(INSTALL_ROOT)Library/Mail/Bundles"
	@echo Done
	@echo "In order to use GPGMail, please don't forget to install MacGPG2 and Libmacgpg."

