# Configurable part of a buildsystem.
# In most cases, this file is subject to edit.

# Android SDK installation directory. Normally it is maintained as an
# environment variable and doesn't need to be changed.
ANDROID_HOME ?= ~/android

# The following few variables are subjects to change according to your Android
# SDK installation.

# Platform SDK level the project is to be built against.
# TODO: change according to the desired build SDK level. Don't forget to
# install using sdkmanager or directly to the following location:
# $(ANDROID_HOME)/platforms/android-$(PLATFORM_VERSION)
PLATFORM_VERSION := 36

# Build tools (aapt d8 etc) version.
# TODO: change according to your SDK installation (the name of the directory
# located in $ANDROID_HOME/build-tools)
BUILD_TOOLS_VERSION := $(PLATFORM_VERSION).0.0

# Android (debug) keystore and its password.
# TODO: change according to your keystore location (or create ad-hoc keystore).
KS ?= ~/.android/debug.keystore
KS_PASS ?= android

# Application package name. Keep in sync with the manifest.
PACKAGE_NAME ?= me.split
