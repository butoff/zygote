# This is a makefile for building Android applications using only and
# exclusively make(1) as a buildsystem.

# Normally, you doesn't need to edit this file. All the configurable properties
# are located in the following included part:
include config.mk

# SDK paths and tools. Values are derived from previously defined variables.

PLATFORM_PATH := $(ANDROID_HOME)/platforms/android-$(PLATFORM_VERSION)
ANDROID_JAR := $(PLATFORM_PATH)/android.jar

BUILD_TOOLS_PATH := $(ANDROID_HOME)/build-tools/$(BUILD_TOOLS_VERSION)
AAPT := $(BUILD_TOOLS_PATH)/aapt
D8 := $(BUILD_TOOLS_PATH)/d8
ZIPALIGN := $(BUILD_TOOLS_PATH)/zipalign
APKSIGNER := $(BUILD_TOOLS_PATH)/apksigner

PLATFORM_TOOLS_PATH := $(ANDROID_HOME)/platform-tools
ADB := $(PLATFORM_TOOLS_PATH)/adb

# Application manifest file
MANIFEST := AndroidManifest.xml

# Java source code location
SRC_DIR := java

# Output directory for intermediate files and result apk
OUT_DIR := out

# Intermediate apk files
APK_DIR := $(OUT_DIR)/apk
UNALIGNED_APK := $(APK_DIR)/unaligned.apk
UNSIGNED_APK := $(APK_DIR)/unsigned.apk
SIGNED_APK := $(OUT_DIR)/signed.apk

# *.class and *.dex related variables
CLASSES_DIR := $(OUT_DIR)/classes
DEX_DIR := $(OUT_DIR)/dex
DEX := $(DEX_DIR)/classes.dex

# java compiler and its command line arguments
JAVAC := javac
JAVAC_ARGS := -sourcepath $(SRC_DIR) -d $(CLASSES_DIR) -classpath $(ANDROID_JAR)

################################################################################

# TODO: write brif but explanatory help message, print variables
.PHONY: help
help:
	@echo Targets: build install run etc

.PHONY: build
build: $(SIGNED_APK)

java_sources := $(shell find $(SRC_DIR) -name *.java)
java_classes := $(OUT_DIR)/java_classes

.PHONY: compile
compile: $(java_classes)

$(java_classes): $(java_sources)
	mkdir -p $(CLASSES_DIR)
	$(JAVAC) $(JAVAC_ARGS) $^
	find $(CLASSES_DIR) -name *.class > $@

$(DEX): compile
	mkdir -p $(DEX_DIR)
	$(D8) --output $(DEX_DIR) @$(java_classes)

$(UNALIGNED_APK): $(DEX) $(MANIFEST)
	mkdir -p $(APK_DIR)
	$(AAPT) package -f -M $(MANIFEST) -I $(ANDROID_JAR) -F $@ $(DEX_DIR)

$(UNSIGNED_APK): $(UNALIGNED_APK)
	$(ZIPALIGN) -f -v 4 -p $< $@

$(SIGNED_APK): $(UNSIGNED_APK)
	$(APKSIGNER) sign --ks $(KS) --ks-pass pass:$(KS_PASS) --in $< --out $@

.PHONY: install
install: $(SIGNED_APK)
	$(ADB) install $<

.PHONY: uninstall
uninstall:
	$(ADB) uninstall $(PACKAGE_NAME)

# TODO: dependency from install!
.PHONY: run
run: #install
	$(ADB) shell am start $(PACKAGE_NAME)

# TODO: dependency from uninstall?
.PHONY: clean
clean: #uninstall
	rm -rf $(OUT_DIR)
