PROJECT = GPGMail
TARGET = GPGMail
PRODUCT = GPGMail.mailbundle
MAKE_DEFAULT = Dependencies/GPGTools_Core/newBuildSystem/Makefile.default
NEED_LIBMACGPG = 1

ifeq ($(USER),root)
	INSTALL_DIR = /Library/Mail/Bundles
else
	INSTALL_DIR = "$$HOME/Library/Mail/Bundles"
endif


-include $(MAKE_DEFAULT)

.PRECIOUS: $(MAKE_DEFAULT)
$(MAKE_DEFAULT):
	@bash -c "$$(curl -fsSL https://raw.github.com/GPGTools/GPGTools_Core/master/newBuildSystem/prepare-core.sh)"

init: $(MAKE_DEFAULT)

update: update-libmacgpg

pkg: pkg-libmacgpg

clean-all: clean-libmacgpg

$(PRODUCT): Source/* Resources/* Resources/*/* GPGMail.xcodeproj
	@xcodebuild -project $(PROJECT).xcodeproj -configuration $(CONFIG) -target $(TARGET) build $(XCCONFIG)

install: $(PRODUCT)
	@echo Installing GPGMail...
	@mkdir -p "$(INSTALL_DIR)"
	@rsync -rltDE "build/$(CONFIG)/GPGMail.mailbundle" "$(INSTALL_DIR)"
	@echo Done
	@echo "In order to use GPGMail, please don't forget to install MacGPG2 and Libmacgpg."

