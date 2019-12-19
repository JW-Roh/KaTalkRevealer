ARCHS := armv7 armv7s arm64 arm64e
TARGET := iphone:clang:12.2:9.3

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = KaTalkRevealer
$(TWEAK_NAME)_FILES = Tweak.x
$(TWEAK_NAME)_EXTRA_FRAMEWORKS += Cephei
$(TWEAK_NAME)_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += KaTalkRevealerPrefs
include $(THEOS_MAKE_PATH)/aggregate.mk
