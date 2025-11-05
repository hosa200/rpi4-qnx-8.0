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

# versions of fonts to download
DEJAVU_VERSION=2.37
FONT_AWESOME_VERSION=6.7.2
FONTCONFIG_SHA=5523f3c5a2f1224d831ec4cd7981d8101390a5f9
GOOGLE_FONT_SHA=48d15b3193a0d26077155ab1a174c148c9ba6f06


FONT_DST=build/stage/usr/share/fonts
FONTCONFIG_STAGE=build/stage/etc/fontconfig
FONTCONFIG_DST=$(FONTCONFIG_STAGE)/conf.avail
FONTS=dejavu-fonts-ttf-$(DEJAVU_VERSION) \
      dejavu-lgc-fonts-ttf-$(DEJAVU_VERSION) \
      google_fonts_$(GOOGLE_FONT_SHA) \
      fontawesome-free-$(FONT_AWESOME_VERSION)-desktop

.PHONY: all clean

all: build/confd_setup

build:
	mkdir -p build

build/fontconfig:| build
	cd build && \
        git clone https://github.com/qnx-ports/fontconfig.git && \
	cd fontconfig && \
	git checkout $(FONTCONFIG_SHA)

$(FONT_DST):
	mkdir -p $(FONT_DST)
$(FONTCONFIG_DST): build/fontconfig
	mkdir -p $(FONTCONFIG_STAGE)/conf.d
	mkdir -p $(FONTCONFIG_DST)
	cp -r build/fontconfig/conf.d/* $(FONTCONFIG_DST)
	$(RM_HOST) $(FONTCONFIG_DST)/05-reset-dirs-sample.conf
	sed -i '/<description/d; /its\:/d' $(FONTCONFIG_DST)/*.conf
	cp local.conf $(FONTCONFIG_DST)

build/dejavu-fonts-ttf-$(DEJAVU_VERSION):| build $(FONT_DST) $(FONTCONFIG_DST)
	wget -P build http://sourceforge.net/projects/dejavu/files/dejavu/$(DEJAVU_VERSION)/dejavu-fonts-ttf-$(DEJAVU_VERSION).zip
	cd build && unzip -DD -o dejavu-fonts-ttf-$(DEJAVU_VERSION).zip
	cp build/dejavu-fonts-ttf-$(DEJAVU_VERSION)/fontconfig/* $(FONTCONFIG_DST)
	cp build/dejavu-fonts-ttf-$(DEJAVU_VERSION)/ttf/* $(FONT_DST)

build/dejavu-lgc-fonts-ttf-$(DEJAVU_VERSION):| build $(FONT_DST) $(FONTCONFIG_DST)
	wget -P build http://sourceforge.net/projects/dejavu/files/dejavu/$(DEJAVU_VERSION)/dejavu-lgc-fonts-ttf-$(DEJAVU_VERSION).zip
	cd build && unzip -DD -o dejavu-lgc-fonts-ttf-$(DEJAVU_VERSION).zip
	cp build/dejavu-lgc-fonts-ttf-$(DEJAVU_VERSION)/fontconfig/* $(FONTCONFIG_DST)
	cp build/dejavu-lgc-fonts-ttf-$(DEJAVU_VERSION)/ttf/* $(FONT_DST)

build/google_fonts_$(GOOGLE_FONT_SHA).zip:| build
	wget -O $@ https://github.com/google/fonts/archive/$(GOOGLE_FONT_SHA).zip
build/google_fonts_$(GOOGLE_FONT_SHA): build/google_fonts_$(GOOGLE_FONT_SHA).zip | build $(FONT_DST) $(FONTCONFIG_DST)
	$(RM_HOST) -rf $@
	cd build && unzip -DD $(notdir $<)
	mv build/fonts-$(GOOGLE_FONT_SHA) $@
	cp $@/ofl/robotomono/RobotoMono-Italic[wght].ttf $(FONT_DST)
	cp $@/ofl/robotomono/RobotoMono[wght].ttf $(FONT_DST)
	cp $@/apache/robotoslab/RobotoSlab[wght].ttf $(FONT_DST)
	cp $@/ofl/robotoserif/RobotoSerif-Italic[GRAD,opsz,wdth,wght].ttf $(FONT_DST)
	cp $@/ofl/robotoserif/RobotoSerif[GRAD,opsz,wdth,wght].ttf $(FONT_DST)
	cp $@/ofl/roboto/Roboto-Italic[wdth,wght].ttf $(FONT_DST)
	cp $@/ofl/roboto/Roboto[wdth,wght].ttf $(FONT_DST)
	cp $@/ofl/robotoflex/RobotoFlex[GRAD,XOPQ,XTRA,YOPQ,YTAS,YTDE,YTFI,YTLC,YTUC,opsz,slnt,wdth,wght].ttf $(FONT_DST)
	cp $@/ofl/robotocondensed/RobotoCondensed-Italic[wght].ttf $(FONT_DST)
	cp $@/ofl/robotocondensed/RobotoCondensed[wght].ttf $(FONT_DST)

build/fontawesome-free-$(FONT_AWESOME_VERSION)-desktop:| build $(FONT_DST) $(FONTCONFIG_DST)
	wget -P build https://use.fontawesome.com/releases/v$(FONT_AWESOME_VERSION)/fontawesome-free-$(FONT_AWESOME_VERSION)-desktop.zip
	cd build && unzip -DD fontawesome-free-$(FONT_AWESOME_VERSION)-desktop.zip
	cp build/fontawesome-free-$(FONT_AWESOME_VERSION)-desktop/otfs/* $(FONT_DST)

build/confd_setup: $(addprefix build/,$(FONTS)) | $(FONTCONFIG_DST)
	$(foreach file,$(notdir $(wildcard $(FONTCONFIG_DST)/*)),$(LN_HOST) ../conf.avail/$(file) $(FONTCONFIG_STAGE)/conf.d/$(file);)
	touch $@

clean:
	$(RM_HOST) -rf build

-include $(BUILD_TEMPLATE)/template.mk
