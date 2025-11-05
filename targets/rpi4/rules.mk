# Target specific rules to set

# Extract and patch the BSP
$(BUILD)/bsp: $(STAGE_QNX_SDP) $(lastword $(wildcard $(STAGE_QNX_SDP)/bsp/BSP_raspberrypi-bcm2711-rpi4_*)) | $(BUILD)
	rm -rf $@
	unzip -d $(BUILD)/bsp $(lastword $(wildcard $(STAGE_QNX_SDP)/bsp/BSP_raspberrypi-bcm2711-rpi4_*))
	cd $(BUILD)/bsp && $(MAKE) clean

# Build the bsp
$(BUILD)/built_bsp: $(BUILD)/bsp
	/bin/bash -c "set -a && source $(STAGE_QNX_SDP)/qnxsdp-env.sh && make -C$(BUILD)/bsp prebuilt"
	/bin/bash -c "set -a && source $(STAGE_QNX_SDP)/qnxsdp-env.sh && make -C$(BUILD)/bsp/src hinstall install"
	rm -f $(BUILD)/bsp/prebuilt/aarch64le/sbin/i2c-bcm2711
	cp $(BUILD)/bsp/install/aarch64le/sbin/i2c-bcm2711 $(BUILD)/bsp/prebuilt/aarch64le/sbin/i2c-bcm2711
	/bin/bash -c "set -a && source $(STAGE_QNX_SDP)/qnxsdp-env.sh && make -C$(BUILD)/bsp all install"
	touch $@

# $1 = name of file to install to lib/dll
define INSTALL_RPI4_IO_SND_DRIVER
$(BUILD)/$(1): $(BUILD)/source_package_rpi4_snd
$(BUILD)/bsp/install/aarch64le/lib/dll/$(notdir $(1)): $(BUILD)/$(1) | $(BUILD)/built_bsp
	cp $$< $$@
$(BUILD)/rpi4.img: $(BUILD)/bsp/install/aarch64le/lib/dll/$(notdir $(1))
endef

# Disabled until rpi4 io_snd support available
#$(foreach f,$(IO_SND_RPI4_DRIVER_FILES),$(eval $(call INSTALL_RPI4_IO_SND_DRIVER,$(f))))

# Build the image
$(BUILD)/rpi4.img: $(TARGET_BASE_DEPS) $(BUILD)/built_bsp boot
	echo "Building rpi4.img ..."
	$(RM_HOST) -rf $(BUILD)/rpi4.img
	$(mkqnximage_prep)
	cd $(BUILD) && \
	BUILD=$(BUILD) BOOT=$(BOOT) SYSTEM=$(SYSTEM) BSP=$(BUILD)/bsp ASSETS=$(ASSETS) SRC=$(SRC) QNX_ARCHDIR=$(QNX_ARCHDIR) \
	MKQNXIMAGE_EXTRAS=$(PROJECT_DIR)/mkqnximage \
	/bin/bash -c "set -a && source $(STAGE_QNX_SDP)/qnxsdp-env.sh && \
	$(PWD)/make_image.sh --config=$(PROJECT_DIR)/targets/$(TARGET)/mkqnximage.config --copy=all"

