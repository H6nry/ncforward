TARGET := iphone:clang

TARGET_SDK_VERSION := 7.1
TARGET_IPHONEOS_DEPLOYMENT_VERSION := 5.0
ARCHS := armv7 arm64

include theos/makefiles/common.mk

TWEAK_NAME = NCForward
NCForward_FILES = Tweak.xm
#NCForward_PRIVATE_FRAMEWORKS = BulletinBoard
#NCForward_FRAMEWORKS = CoreFoundation

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += ncfprefs
include $(THEOS_MAKE_PATH)/aggregate.mk
