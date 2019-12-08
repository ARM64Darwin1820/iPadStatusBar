export THEOS_PLATFORM_SDK_ROOT=$(THEOS)/sdks/iPhoneOS11.2.sdk
ARCHS = arm64 arm64e
FINALPACKAGE=1


include $(THEOS)/makefiles/common.mk

TWEAK_NAME = A12CustomResFix
A12CustomResFix_FILES = Tweak.xm
A12CustomResFix_CFLAGS += -fobjc-arc -I$(THEOS_PROJECT_DIR)/

include $(THEOS_MAKE_PATH)/tweak.mk

SUBPROJECTS += preferences

include $(THEOS_MAKE_PATH)/aggregate.mk

after-install::
	install.exec "killall -9 SpringBoard"
