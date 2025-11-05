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

ROOT_DIR := $(notdir $(CURDIR))
ifndef QCONFIG
QCONFIG=qconfig.mk
endif
include $(QCONFIG)

.PHONY: all clean
all:

# Firmware that is checked in and gets copied
LOCAL_FILES =
# Firmware that comes in a tarball and so needs to be extracted
REMOTE_TARBALLS =
# Firmware that comes from the linux kernel
REMOTE_LINUX_FW_FILES =

# Add firmware as required by different targets
ifneq ($(filter $(TARGET),rpi4),)
    RPI_FW_RELEASE = 1.20250430
    REMOTE_TARBALLS += https://github.com/raspberrypi/firmware/archive/refs/tags/$(RPI_FW_RELEASE).tar.gz
    LOCAL_FILES += wpa_supplicant.conf wpa_supplicant.conf.verbose
endif
ifeq ($(TARGET),rpi4)
    LINUX_FW_URL = https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git/plain
    LINUX_FW_RELEASE=20250509
    REMOTE_LINUX_FW_FILES += $(LINUX_FW_URL)/cypress/cyfmac43455-sdio.bin \
		             $(LINUX_FW_URL)/cypress/cyfmac43455-sdio.clm_blob \
		             $(LINUX_FW_URL)/brcm/brcmfmac43455-sdio.raspberrypi,4-model-b.txt
endif

# $1 = tarball URL
define REMOTE_TARBALL_RULES
build/$(notdir $(1)):
	mkdir -p build
	wget -P build $(1)

build/$(TARGET)/.extracted_$(notdir $(1)): build/$(notdir $(1))
	mkdir -p build/$(TARGET)
	tar xvf $$< --touch --strip-components=1 -C build/$(TARGET)
	touch $$@

all: build/$(TARGET)/.extracted_$(notdir $(1))
endef

# $1 file URL
define REMOTE_LINUX_FW_FILE_RULES
build/$(notdir $(1))@$(LINUX_FW_RELEASE):
	mkdir -p build
	wget -O $$@ $(1)?id=$(LINUX_FW_RELEASE)

build/$(TARGET)/$(notdir $(1)): build/$(notdir $(1))@$(LINUX_FW_RELEASE)
	mkdir -p build/$(TARGET)
	cp $$< $$@

all: build/$(TARGET)/$(notdir $(1))
endef

# $1 = Local file path
define LOCAL_FILE_RULES
build/$(TARGET)/$(notdir $(1)): $(1)
	mkdir -p build/$(TARGET)
	cp $$< $$@

all: build/$(TARGET)/$(notdir $(1))
endef

# Add the actual rules for all the targets
$(foreach tb,$(REMOTE_TARBALLS),$(eval $(call REMOTE_TARBALL_RULES,$(tb))))
$(foreach tb,$(REMOTE_LINUX_FW_FILES),$(eval $(call REMOTE_LINUX_FW_FILE_RULES,$(tb))))
$(foreach tb,$(LOCAL_FILES),$(eval $(call LOCAL_FILE_RULES,$(tb))))

clean:
	$(RM_HOST) -rf build/$(TARGET)
	$(if $(REMOTE_TARBALLS),$(RM_HOST) -rf $(addprefix build/,$(notdir $(REMOTE_TARBALLS))))
	$(if $(REMOTE_LINUX_FW_FILES),$(RM_HOST) -rf $(addsuffix @$(LINUX_FW_RELEASE),$(addprefix build/,$(notdir $(REMOTE_LINUX_FW_FILES)))))
	if find build -maxdepth 0 -empty | read REPLY; then rmdir build; fi

-include $(BUILD_TEMPLATE)/template.mk
