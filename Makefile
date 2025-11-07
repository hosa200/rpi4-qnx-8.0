#
# Copyright (c) 2025, BlackBerry Limited. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
QSC_CLT_PATH=~/qnx/qnxsoftwarecenter/qnxsoftwarecenter_clt
ROOT_DIR := $(notdir $(CURDIR))
ifndef QCONFIG
QCONFIG=qconfig.mk
endif
include $(QCONFIG)
unexport ROOT_DIR

.PHONY: all clean boot assets src force_sdp_update

# Include config file if it exists. Set a default location
# if one hasn't been explicitly given.
CTI_CONFIG_FILE ?= private/config.mk
-include $(CTI_CONFIG_FILE)

# Set defaults for configurable variables if they haven't been specified
# on the command line or via a config file.
CTI_QSC_URL ?= https://www.qnx.com/swcenter

# Make sure QSC_CLT_PATH has been given an value and exists
ifeq ("${QSC_CLT_PATH}","")
  $(error QSC_CLT_PATH is not defined. Please set it to the qnxsoftwarecenter_clt binary))
else ifeq ($(wildcard $(QSC_CLT_PATH)),)
  $(error QSC_CLT_PATH '$(QSC_CLT_PATH)' is invalid. Please set it to the qnxsoftwarecenter_clt binary))
endif

TARGET ?= rpi4

# Figure out what targets are available, and make sure one of
# them has been specified
AVAILABLE_TARGETS := $(filter-out README.md,$(notdir $(wildcard targets/*)))
ifeq ($(filter $(AVAILABLE_TARGETS),$(TARGET)),)
  $(error TARGET is not set or invalid. Available targets are: $(AVAILABLE_TARGETS))
endif

# Expands to a single newline character
define NEWLINE


endef

SUFFIXES := .mk

HOST_MKDIR := mkdir

PROJECT_DIR := $(shell pwd)
BUILD:= $(PROJECT_DIR)/build/$(TARGET)
ifneq ($(BUILD_QSTI),)
BUILD:= $(BUILD)_qsti
endif

BOOT=$(PROJECT_DIR)/boot/build/$(TARGET)
SYSTEM=$(PROJECT_DIR)/system
ASSETS=$(PROJECT_DIR)/assets
SRC=$(PROJECT_DIR)/src/stage
BUILD_VERSION_FILE=$(BUILD)/cti_build_version.txt
STAGE_QNX_SDP=$(PROJECT_DIR)/qnx800

PACKAGES_LIST = ${PWD}/qsc_install_packages.list
TARGET_PACKAGES_LIST = $(wildcard $(PWD)/targets/$(TARGET)/qsc_install_packages.list)

# Include target specific variables.
include targets/$(TARGET)/variables.mk

all: $(ALL_TARGET)

$(BUILD)/qsc_install_packages.list : $(PACKAGES_LIST) $(TARGET_PACKAGES_LIST) | $(BUILD)
	cat $(PACKAGES_LIST) $(TARGET_PACKAGES_LIST) > $@

# Since the SDP install is shared between targets, and each target has its own
# customized set of packages, I need to make sure the current set of packages
# installed in the SDP is correct for the current target.
ifneq ($(wildcard $(STAGE_QNX_SDP)/cti_package_set),)
ifeq ($(filter $(TARGET),$(file < $(STAGE_QNX_SDP)/cti_package_set)),)
$(info Forcing SDP update due to TARGET change)
FORCE_SDP_UPDATE := force_sdp_update
endif
endif
$(STAGE_QNX_SDP): $(BUILD)/qsc_install_packages.list options_file $(FORCE_SDP_UPDATE)
	$(QSC_CLT_PATH) -url $(CTI_QSC_URL) -mirrorBaseline qnx800 @options_file
	$(QSC_CLT_PATH) -url $(CTI_QSC_URL) -cleanInstall -setExperimentalEnabled=true \
		        -setPolicy=conservative \
		        -destination $(STAGE_QNX_SDP) \
			-importAndInstall $(BUILD)/qsc_install_packages.list \
			-profile com.qnx.cti \
			$(CTI_QSC_EXTRA_OPTIONS) \
			@options_file
	echo -n $(TARGET) > $(STAGE_QNX_SDP)/cti_package_set

$(BUILD):
	$(HOST_MKDIR) -p $(BUILD)

clean_qnx800:
	$(QSC_CLT_PATH) -uninstallBaseline $(STAGE_QNX_SDP)

subdirs:=$(subst /Makefile,,$(wildcard */[Mm]akefile))
clean:
	$(foreach dir,$(subdirs), $(MAKE) -C$(dir) clean $(NEWLINE) TARGET=$(TARGET))
	-$(MAKE) clean_qnx800
	-$(RM_HOST) -rf $(BUILD)

boot:
	$(MAKE) -Cboot TARGET=$(TARGET)

assets:
	$(MAKE) -Cassets

src:
	/bin/bash -c "set -a && source $(STAGE_QNX_SDP)/qnxsdp-env.sh && make -Csrc TARGET=$(TARGET)"

system/etc/ssl/certs/cacert.pem:
	mkdir -p system/etc/ssl/certs
	curl --show-error --fail --etag-save "$(PROJECT_DIR)/system/etc/ssl/certs/etag.txt" -o $@ "https://curl.se/ca/cacert.pem"
	echo "Roots certificate download succeeded."

# Deliberately done so that every build re-generates this file
build_version:
	$(HOST_MKDIR) -p $(dir $(BUILD_VERSION_FILE))
	rm -rf $(BUILD_VERSION_FILE)
	echo -n "`date -I`:" > $(BUILD_VERSION_FILE)
	git log -1 --pretty=format:"%h" >> $(BUILD_VERSION_FILE)
	if [ `git status --porcelain=1 --untracked-files=no | wc -l` -ne 0 ]; then echo -n '*' >> $(BUILD_VERSION_FILE); fi


# A macro that does a bunch of prep before running mkqnximage
# Mostly sets up the target's specific snippets in the right place
# Snippets are copied from several locations into a single destination.
# This means that snippets with the same name copied from later locations
# will override snippets from earlier locations.

SNIPPET_LOCATIONS := $(PWD)/snippets/common
ifneq ($(BUILD_QSTI),)
SNIPPET_LOCATIONS += $(PWD)/snippets/common/qsti
endif
ifneq ($(wildcard $(PWD)/snippets/$(TARGET)/.),)
SNIPPET_LOCATIONS += $(PWD)/snippets/$(TARGET)
endif
ifneq ($(and $(BUILD_QSTI),$(wildcard $(PWD)/snippets/$(TARGET)/qsti/.)),)
SNIPPET_LOCATIONS += $(PWD)/snippets/$(TARGET)/qsti
endif

define mkqnximage_prep =
$(HOST_MKDIR) -p $(BUILD)
$(HOST_MKDIR) -p $(BUILD)/local
$(HOST_MKDIR) -p $(BUILD)/local/snippets
$(RM_HOST) -rf $(BUILD)/output
$(foreach l,$(SNIPPET_LOCATIONS),find $(l) -maxdepth 1 -type f -exec cp {} $(BUILD)/local/snippets \;;)
touch $(BUILD)/root_authorized_keys
endef

# The default dependencies valid for any target
TARGET_BASE_DEPS = build_version \
		   $(PROJECT_DIR)/qnx800 \
                   system/etc/ssl/certs/cacert.pem \
		   assets \
		   src

# Include target specific rules
include targets/$(TARGET)/rules.mk
