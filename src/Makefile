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

AVAILABLE_TARGETS := $(notdir $(wildcard ../targets/*))
ifeq ($(filter $(AVAILABLE_TARGETS),$(TARGET)),)
  $(error TARGET is not set or invalid. Available targets are: $(AVAILABLE_TARGETS))
endif
include ../targets/$(TARGET)/variables.mk

# Versions/SHAs of things to download
GTK_SHA=4461ac64a3a5389193331ac8941d44c266cf3e3b
BASH_SHA=e1c760dfe65a770fb5cc32f8c4c75d52a1b93ee5
BUILD_FILES_SHA=3e650253c9f1ce37efd82055c4241cf3c46ec302
CAIRO_SHA=0a19c554acc0340f7a362119a72dec026440f82a
MESON_VERSION=1.7.0
PATTERN_RACE_SHA=60a3f77db041dda95900ef29768cad2637a9f578
SCREENWM_SHA=4776f2540422187730f9f4c4b81cfec6d99d7261
SIMPLE_TERMINAL_SHA=947ec5466117bed06c847c9af0a70a21062102e4
RPI_GPIO_SHA=8df6d3b40e0a508a6924f24c732aa1444e35313c
RPI_MAILBOX_SHA=3aaf49d7616832695086f779ee82deabc57cdaa3
RPI_THERMAL_SHA=36a27b6d0c254bde4bd20a4790a631abaf3834f3
THORVG_SHA=15aafbfe621fae39156b0cbc825942ce181db011
SDL_VERSION=release-2.32.8
SDL_IMAGE_VERSION=release-2.8.8
SDL_NET_VERSION=release-2.2.0
SDL_TTF_VERSION=release-2.24.0
VIM_VERSION=v9.1.1198
MESON_gtk=110642dd7

QCONF_OVERRIDE=$(PWD)/qconf-override.mk
STAGE_ROOT=$(PWD)/stage/nto
STAGE_COMMON=$(STAGE_ROOT)
STAGE_TARGET=$(STAGE_ROOT)/$(QNX_ARCHDIR)

.PHONY: all clean

PKGS = bash vim gtk cairo simple-terminal screenwm SDL SDL_image SDL_ttf SDL_net pattern-race 
ifneq ($(filter rpi4,$(TARGET)),)
PKGS += rpi-gpio rpi-mailbox rpi-thermal thorvg qnx-lottie_thorvg
endif
all: $(foreach p,$(PKGS),source/$(p)-built-$(QNX_ARCH))

source/build-files-ready:
	@if [ ! -d "source" ]; then \
		echo "Creating source directory..."; \
		mkdir -p source; \
	fi
	@if [ ! -d "source/build-files" ]; then \
		echo "Cloning build-files repo..."; \
		cd source && git clone https://github.com/qnx-ports/build-files.git; \
	else \
		echo "build-files repo already exists, skipping clone."; \
	fi
	@if [ ! -d "source/meson" ]; then \
		echo "Cloning meson repo..."; \
		cd source && git clone https://github.com/mesonbuild/meson.git -b ${MESON_VERSION}; \
	else \
		echo "meson repo already exists, skipping clone."; \
	fi
	#cd source/meson && git fetch && git checkout $(MESON_gtk)
	touch $@

source/gtk-ready:
	@if [ ! -d "source" ]; then \
		echo "Creating source directory..."; \
		mkdir -p source; \
	fi
	@if [ ! -d "source/gtk" ]; then \
		echo "Cloning gtk repo..."; \
		cd source && git clone https://github.com/qnx-ports/gtk.git; \
	else \
		echo "gtk repo already exists, skipping clone."; \
	fi
	@cd source/gtk && git fetch && git checkout $(GTK_SHA)
	@touch $@

source/gtk-built-$(QNX_ARCH): source/gtk-ready source/build-files-ready
	QCONF_OVERRIDE=$(PWD)/qconf-override.mk \
	CPULIST=$(QNX_ARCH) \
	QNX_ARCH=$(QNX_ARCH) \
	QNX_PROJECT_ROOT="$(PWD)/source/gtk" make -C source/build-files/ports/gtk install -j4
	touch $@

source/bash-ready:
	mkdir -p source
	cd source && git clone https://github.com/qnx-ports/bash.git
	cd source/bash && git checkout $(BASH_SHA)
	touch $@
source/bash-built-$(QNX_ARCH): source/bash-ready source/build-files-ready
	QCONF_OVERRIDE=$(PWD)/qconf-override.mk \
	CPULIST=$(QNX_ARCH) \
	QNX_ARCH=$(QNX_ARCH) \
	QNX_PROJECT_ROOT="$(PWD)/source/bash" make -C source/build-files/ports/bash install -j4
	touch $@

source/vim-ready:
	mkdir -p source
	cd source && git clone https://github.com/vim/vim.git -b $(VIM_VERSION)
	touch $@
source/vim-built-$(QNX_ARCH): source/vim-ready source/build-files-ready
	QCONF_OVERRIDE=$(PWD)/qconf-override.mk \
	QNX_ARCH=$(QNX_ARCH) \
	CPULIST=$(QNX_ARCH) \
	QNX_PROJECT_ROOT="$(PWD)/source/vim" make -C source/build-files/ports/vim install
	touch $@

source/cairo-ready:
	mkdir -p source
	cd source && git clone https://github.com/qnx-ports/cairo.git
	cd source/cairo && git checkout $(CAIRO_SHA)
	cd source && QCONF_OVERRIDE=$(PWD)/qconf-override.mk \
	/bin/bash build-files/ports/cairo/install_all.sh
	QCONF_OVERRIDE=$(PWD)/qconf-override.mk \
	touch $@
source/cairo-built-$(QNX_ARCH): source/build-files-ready source/cairo-ready
	QNX_ARCH=$(QNX_ARCH) \
	QNX_PROJECT_ROOT="$(PWD)/source/cairo" JLEVEL=4 make \
	  -C source/build-files/ports/cairo/nto-$(QNX_ARCH)-* install
	touch $@

source/thorvg-ready: source/build-files-ready
	mkdir -p source
	cd source/ && git clone https://github.com/thorvg/thorvg.git
	cd source/thorvg && git checkout $(THORVG_SHA)
	cd source/thorvg && git apply $(PWD)/patches/thorvg.patch
	touch $@
source/thorvg-built-$(QNX_ARCH): source/thorvg-ready
	cd source/thorvg && python3 $(PWD)/source/meson/meson.py \
		setup build-$(QNX_ARCH) \
		--cross-file $(PWD)/patches/meson/qnx8_$(QNX_ARCH).txt \
		-Dcpp_std=gnu++14 \
		-Dprefix=$(STAGE_TARGET)/usr/local
	cd source/thorvg && \
		sed -i "s/\-fopenmp/-lgomp/" build-$(QNX_ARCH)/build.ninja
	cd source/thorvg && echo "y" | \
		ninja -C build-$(QNX_ARCH) install
	touch $@

source/rpi-gpio-ready:
	mkdir -p source
	cd source && git clone https://gitlab.com/qnx/projects/rpi-gpio
	cd source/rpi-gpio && git checkout $(RPI_GPIO_SHA)
	touch $@
source/rpi-gpio-built-$(QNX_ARCH): source/cairo-built-$(QNX_ARCH) source/rpi-gpio-ready
	cd source/rpi-gpio && \
	QCONF_OVERRIDE=$(PWD)/qconf-override.mk \
	QNX_ARCH=$(QNX_ARCH) \
	make hinstall
	cd source/rpi-gpio && \
	EXTRA_INCVPATH=$(STAGE_COMMON)/usr/local/include \
	EXTRA_LIBVPATH=$(STAGE_TARGET)/usr/local/lib \
	MY_STAGE=$(STAGE_ROOT) make
	cd source/rpi-gpio && \
	QCONF_OVERRIDE=$(PWD)/qconf-override.mk \
	QNX_ARCH=$(QNX_ARCH) \
	EXTRA_INCVPATH=$(STAGE_TARGET)/usr/local/include \
	EXTRA_LIBVPATH=$(STAGE_TARGET)/usr/local/lib \
	MY_STAGE=$(STAGE_ROOT) make install
	touch $@

source/simple-terminal-ready:
	mkdir -p source
	cd source && git clone https://gitlab.com/qnx/sample-apps/simple-terminal.git
	cd source/simple-terminal && git checkout $(SIMPLE_TERMINAL_SHA)
	touch $@
source/simple-terminal-built-$(QNX_ARCH): source/cairo-built-$(QNX_ARCH) source/simple-terminal-ready
	cd source/simple-terminal && \
	QCONF_OVERRIDE=$(PWD)/qconf-override.mk \
	QNX_ARCH=$(QNX_ARCH) \
	CPULIST=$(QNX_ARCH) \
	EXTRA_INCVPATH=$(STAGE_COMMON)/usr/local/include \
	EXTRA_LIBVPATH=$(STAGE_TARGET)/usr/local/lib \
	MY_STAGE=$(STAGE_ROOT) make -C qnx/build/nto/$(QNX_ARCH) install
	touch $@

source/screenwm-ready:
	mkdir -p source
	cd source && git clone https://gitlab.com/elahav/screenwm.git
	cd source/screenwm && git checkout $(SCREENWM_SHA)
	mkdir -p source/screenwm/themes/photon/aarch64/so.le
	echo "include ../../common.mk" > source/screenwm/themes/photon/aarch64/so.le/Makefile
	touch $@
source/screenwm-built-$(QNX_ARCH): source/cairo-built-$(QNX_ARCH) source/screenwm-ready
	cd source/screenwm/$(QNX_ARCH) && \
	QCONF_OVERRIDE=$(PWD)/qconf-override.mk \
	QNX_ARCH=$(QNX_ARCH) \
	EXTRA_INCVPATH=$(STAGE_COMMON)/usr/local/include \
	EXTRA_LIBVPATH=$(STAGE_TARGET)/usr/local/lib \
	MY_STAGE=$(STAGE_ROOT) make hinstall install
	cd source/screenwm/themes/photon/$(QNX_ARCH) && \
	QCONF_OVERRIDE=$(PWD)/qconf-override.mk \
	QNX_ARCH=$(QNX_ARCH) \
	LIBCAIRO_INC_PATH=$(STAGE_COMMON)/usr/local/include \
	LIBCAIRO_LIB_PATH=$(STAGE_TARGET)/usr/local/lib \
	MY_STAGE=$(STAGE_ROOT) make hinstall install
	$(RM_HOST) -rf $(STAGE_COMMON)/usr/share/screenwm/themes
	mkdir -p $(STAGE_COMMON)/usr/share/screenwm/themes/photon
	cp source/screenwm/themes/photon/*.png $(STAGE_COMMON)/usr/share/screenwm/themes/photon
	touch $@

source/rpi-thermal-ready:
	mkdir -p source
	cd source && git clone https://gitlab.com/qnx/projects/rpi-thermal.git
	cd source/rpi-thermal && git checkout $(RPI_THERMAL_SHA)
	touch $@
source/rpi-thermal-built-$(QNX_ARCH): source/rpi-mailbox-built-$(QNX_ARCH) source/rpi-thermal-ready
	cd source/rpi-thermal && \
	QCONF_OVERRIDE=$(PWD)/qconf-override.mk \
	QNX_ARCH=$(QNX_ARCH) \
	MY_STAGE=$(STAGE_ROOT) make
	mkdir -p $(STAGE_TARGET)/sbin
	cp source/rpi-thermal/$(QNX_ARCH)/le/rpi_thermal $(STAGE_TARGET)/sbin/rpi_thermal
	touch $@

source/rpi-mailbox-ready:
	mkdir -p source
	cd source && git clone https://gitlab.com/qnx/projects/rpi-mailbox.git
	cd source/rpi-mailbox && git checkout $(RPI_MAILBOX_SHA)
	touch $@
source/rpi-mailbox-built-$(QNX_ARCH): source/rpi-mailbox-ready
	cd source/rpi-mailbox && \
	QCONF_OVERRIDE=$(PWD)/qconf-override.mk \
	QNX_ARCH=$(QNX_ARCH) \
	MY_STAGE=$(STAGE_ROOT) make
	mkdir -p $(STAGE_TARGET)/sbin
	cp source/rpi-mailbox/$(QNX_ARCH)/le/rpi_mbox $(STAGE_TARGET)/sbin/rpi_mbox
	mkdir -p $(STAGE_COMMON)/usr/include
	cp -r source/rpi-mailbox/public/* $(STAGE_COMMON)/usr/include
	touch $@

source/qnx-lottie_thorvg-ready:
	mkdir -p source
	cp -r $(PWD)/local/qnx-lottie_thorvg source/
	touch $@
source/qnx-lottie_thorvg-built-$(QNX_ARCH): source/qnx-lottie_thorvg-ready source/thorvg-built-$(QNX_ARCH) \
	source/rpi-mailbox-built-$(QNX_ARCH)
	mkdir -p $(STAGE_TARGET)/usr/local/bin
	cd source/qnx-lottie_thorvg && \
		EXTRA_INCVPATH=$(STAGE_TARGET)/usr/local/include \
		EXTRA_LIBVPATH=$(STAGE_TARGET)/usr/local/lib \
		MY_STAGE=$(STAGE_ROOT) make install
	touch $@


source/SDL-ready:
	mkdir -p source
	cd source && git clone https://github.com/libsdl-org/SDL.git -b $(SDL_VERSION)
	cd source/SDL && git apply $(PWD)/patches/SDL.patch
	touch $@
source/SDL-built-$(QNX_ARCH): source/SDL-ready
	mkdir -p source/SDL/build-$(QNX_ARCH)
	cd source/SDL/build-$(QNX_ARCH) && cmake .. \
		-DCMAKE_TOOLCHAIN_FILE=$(PWD)/patches/$(QNX_ARCH)-qnx.cmake \
		-DSDL_X11=0 -DCMAKE_BUILD_TYPE=Release \
	        -DCMAKE_INSTALL_PREFIX=$(STAGE_TARGET)
	cd source/SDL/build-$(QNX_ARCH) && make install
	touch $@

source/SDL_image-ready:
	mkdir -p source
	cd source && git clone https://github.com/libsdl-org/SDL_image.git -b $(SDL_IMAGE_VERSION)
	touch $@
source/SDL_image-built-$(QNX_ARCH): source/SDL_image-ready source/SDL-built-$(QNX_ARCH)
	$(RM_HOST) -rf SDL_image
	mkdir -p source/SDL_image/build-$(QNX_ARCH)
	cd source/SDL_image/build-$(QNX_ARCH) && cmake .. \
		-DCMAKE_TOOLCHAIN_FILE=$(PWD)/patches/$(QNX_ARCH)-qnx.cmake \
	        -DCMAKE_BUILD_TYPE=Release \
	        -DCMAKE_INSTALL_PREFIX=$(STAGE_TARGET) \
	        -DSDL2_LIBRARY=$(STAGE_TARGET)/lib/libSDL2-2.0.so \
	        -DSDL2_INCLUDE_DIR=$(STAGE_TARGET)/include/SDL2
	cd source/SDL_image/build-$(QNX_ARCH) && make
	cd source/SDL_image/build-$(QNX_ARCH) && make install
	mkdir -p $(STAGE_TARGET)/bin
	cp source/SDL_image/build-$(QNX_ARCH)/show* $(STAGE_TARGET)/bin
	touch $@

source/SDL_net-ready:
	mkdir -p source
	cd source && git clone https://github.com/libsdl-org/SDL_net.git -b $(SDL_NET_VERSION)
	cd source/SDL_net && git apply $(PWD)/patches/SDL_net.patch
	touch $@
source/SDL_net-built-$(QNX_ARCH): source/SDL_net-ready source/SDL-built-$(QNX_ARCH)
	mkdir -p source/SDL_net/build-$(QNX_ARCH)
	cd source/SDL_net/build-$(QNX_ARCH) && cmake .. \
		-DCMAKE_TOOLCHAIN_FILE=$(PWD)/patches/$(QNX_ARCH)-qnx.cmake \
	        -DCMAKE_BUILD_TYPE=Release \
	        -DCMAKE_INSTALL_PREFIX=$(STAGE_TARGET) \
	        -DSDL2_LIBRARY=$(STAGE_TARGET)/lib/libSDL2-2.0.so \
	        -DSDL2_INCLUDE_DIR=$(STAGE_TARGET)/include/SDL2
	cd source/SDL_net/build-$(QNX_ARCH) && make
	cd source/SDL_net/build-$(QNX_ARCH) && make install
	touch $@

source/SDL_ttf-ready:
	cd source && git clone https://github.com/libsdl-org/SDL_ttf.git -b $(SDL_TTF_VERSION)
	touch $@
source/SDL_ttf-built-$(QNX_ARCH): source/SDL_ttf-ready source/SDL-built-$(QNX_ARCH)
	mkdir -p source/SDL_ttf/build-$(QNX_ARCH)
	cd source/SDL_ttf/build-$(QNX_ARCH) && cmake .. \
		-DCMAKE_TOOLCHAIN_FILE=$(PWD)/patches/$(QNX_ARCH)-qnx.cmake \
	        -DCMAKE_BUILD_TYPE=Release \
	        -DCMAKE_INSTALL_PREFIX=$(STAGE_TARGET) \
	        -DSDL2_LIBRARY=$(STAGE_TARGET)/lib/libSDL2-2.0.so \
	        -DSDL2_INCLUDE_DIR=$(STAGE_TARGET)/include/SDL2
	cd source/SDL_ttf/build-$(QNX_ARCH) && make
	cd source/SDL_ttf/build-$(QNX_ARCH) && make install
	mkdir -p $(STAGE_TARGET)/bin
	cp source/SDL_ttf/build-$(QNX_ARCH)/showfont $(STAGE_TARGET)/bin
	touch $@

$(STAGE_COMMON)/usr/include/SDL2: $(foreach p,SDL SDL_image SDL_net SDL_ttf,source/$(p)-built-$(QNX_ARCH))
	rm -rf $(STAGE_COMMON)/usr/include/SDL2
	mkdir -p $(STAGE_COMMON)/usr/include
	cp -r $(STAGE_TARGET)/include/SDL2 $(STAGE_COMMON)/usr/include

source/pattern-race-ready:
	mkdir -p source
	cd source && git clone https://gitlab.com/ad2lahav/pattern-race
	cd source/pattern-race && git checkout $(PATTERN_RACE_SHA)
	touch $@
source/pattern-race-built-$(QNX_ARCH): source/pattern-race-ready $(STAGE_COMMON)/usr/include/SDL2
	mkdir -p source/pattern-race/build-$(QNX_ARCH)
	cd source/pattern-race/build-$(QNX_ARCH) && cmake .. \
		-DCMAKE_TOOLCHAIN_FILE=$(PWD)/patches/$(QNX_ARCH)-qnx.cmake \
	        -DCMAKE_BUILD_TYPE=Release \
	        -DCMAKE_INSTALL_PREFIX=$(STAGE_TARGET) \
	        -DSDL2_DIR=$(STAGE_TARGET)/lib/cmake/SDL2 
	cd source/pattern-race/build-$(QNX_ARCH) && make
	mkdir -p $(STAGE_COMMON)/share/patrace
	cp source/pattern-race/build-$(QNX_ARCH)/patrace $(STAGE_COMMON)/share/patrace
	cp -r source/pattern-race/assets $(STAGE_COMMON)/share/patrace
	touch $@

subdirs:=$(subst /Makefile,,$(wildcard */[Mm]akefile)) $(subst /CMakeLists.txt,,$(wildcard */CMakeLists.txt))

clean:
	$(foreach dir,$(subdirs), $(RM_HOST) -rf $(dir);$(NEWLINE))
	$(RM_HOST) -rf source
	$(RM_HOST) -rf $(STAGE_ROOT)
-include $(BUILD_TEMPLATE)/template.mk
