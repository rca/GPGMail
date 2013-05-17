PROJECT = GPGMail
TARGET = GPGMail
PRODUCT = GPGMail.mailbundle
MAKE_DEFAULT = Dependencies/GPGTools_Core/newBuildSystem/Makefile.default
NEED_LIBMACGPG = 1

-include $(MAKE_DEFAULT)

.PRECIOUS: $(MAKE_DEFAULT)
$(MAKE_DEFAULT):
	@bash -c "$$(curl -fsSL https://raw.github.com/GPGTools/GPGTools_Core/master/newBuildSystem/prepare-core.sh)"

init: $(MAKE_DEFAULT)

update: update-libmacgpg

pkg: pkg-libmacgpg

clean-all: clean-libmacgpg

$(PRODUCT): Source/* Resources/* Resources/*/* GPGMail.xcodeproj
ifeq ($(CONFIG),Debug)
	# When using Scheme, Libmacgpg is built.
	@xcodebuild -project $(PROJECT).xcodeproj -configuration $(CONFIG) -scheme $(PROJECT) build $(XCCONFIG)
else
	# For release builds, do not build Libmacgpg by specifying the target to build.
	@xcodebuild -project $(PROJECT).xcodeproj -configuration $(CONFIG) -target $(TARGET) build $(XCCONFIG)
endif
