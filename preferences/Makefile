include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = A12CustomResFix
A12CustomResFix_FILES = $(wildcard *.m)
A12CustomResFix_INSTALL_PATH = /Library/PreferenceBundles
A12CustomResFix_FRAMEWORKS = CoreGraphics UIKit
A12CustomResFix_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/A12CustomResFix.plist$(ECHO_END)
