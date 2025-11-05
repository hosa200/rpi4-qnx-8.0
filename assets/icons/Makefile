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

.PHONY: all clean

MATERIAL_DESIGN_ICONS_VERSION=4.0.0

all:

# $1 == Icon to convert within material-design folder
# $2 == Desired output size of icon
# $3 == Output basename of icon. Suffix and extension will automatically be added
# $4 == List of icon types to make. Allowed types are 'black', 'white', 'black_translucent', and 'white_translucent'
define CONVERT_ICON
material-design-icons-$(MATERIAL_DESIGN_ICONS_VERSION)/$(1) : material-design-icons-$(MATERIAL_DESIGN_ICONS_VERSION)

ifneq ($(filter black,$(4)),)
icons/google/$(3)_black.png: material-design-icons-$(MATERIAL_DESIGN_ICONS_VERSION)/$(1)
	convert material-design-icons-$(MATERIAL_DESIGN_ICONS_VERSION)/$(1) -resize $(2)x$(2) -type TrueColorAlpha PNG32:$$@
all: icons/google/$(3)_black.png
endif

ifneq ($(filter white,$(4)),)
icons/google/$(3)_white.png: material-design-icons-$(MATERIAL_DESIGN_ICONS_VERSION)/$(1)
	convert material-design-icons-$(MATERIAL_DESIGN_ICONS_VERSION)/$(1) -resize $(2)x$(2) -type TrueColorAlpha +level-colors "#ffffff", PNG32:$$@
all: icons/google/$(3)_white.png
endif

ifneq ($(filter black_translucent,$(4)),)
icons/google/$(3)_black_translucent.png: material-design-icons-$(MATERIAL_DESIGN_ICONS_VERSION)/$(1)
	convert material-design-icons-$(MATERIAL_DESIGN_ICONS_VERSION)/$(1) \
		-resize $(2)x$(2) -type TrueColorAlpha \
	        -alpha set -background none -channel A -evaluate multiply 0.25 +channel \
		PNG32:$$@
all: icons/google/$(3)_black_translucent.png
endif

ifneq ($(filter white_translucent,$(4)),)
icons/google/$(3)_white_translucent.png: material-design-icons-$(MATERIAL_DESIGN_ICONS_VERSION)/$(1)
	convert material-design-icons-$(MATERIAL_DESIGN_ICONS_VERSION)/$(1) \
		-resize $(2)x$(2) -type TrueColorAlpha +level-colors "#ffffff", \
	        -alpha set -background none -channel A -evaluate multiply 0.25 +channel \
		PNG32:$$@
all: icons/google/$(3)_white_translucent.png
endif

endef

# Download and extract latest Material Icon's release zip file
$(MATERIAL_DESIGN_ICONS_VERSION).zip:
	wget https://github.com/google/material-design-icons/archive/refs/tags/$(MATERIAL_DESIGN_ICONS_VERSION).zip

material-design-icons-$(MATERIAL_DESIGN_ICONS_VERSION): $(MATERIAL_DESIGN_ICONS_VERSION).zip
	mkdir -p icons/google
	unzip -DD $(MATERIAL_DESIGN_ICONS_VERSION).zip

$(eval $(call CONVERT_ICON,android/action/power_settings_new/materialiconsround/black/res/drawable-xxxhdpi/round_power_settings_new_black_36.png,128,round_power_button,black white))

$(eval $(call CONVERT_ICON,android/content/add_circle_outline/materialiconsround/black/res/drawable-xxxhdpi/round_add_circle_outline_black_36.png,128,round_add_circle_button,black white black_translucent white_translucent))

$(eval $(call CONVERT_ICON,android/action/settings/materialicons/black/res/drawable-xxxhdpi/baseline_settings_black_36.png,128,gears_icon_large,black white))
$(eval $(call CONVERT_ICON,android/action/settings/materialicons/black/res/drawable-xxxhdpi/baseline_settings_black_36.png,40,gears_icon,black white))

$(eval $(call CONVERT_ICON,android/image/crop_square/materialicons/black/res/drawable-xxxhdpi/baseline_crop_square_black_36.png,128,cube_icon_large,black white))
$(eval $(call CONVERT_ICON,android/image/crop_square/materialicons/black/res/drawable-xxxhdpi/baseline_crop_square_black_36.png,40,cube_icon,black white))

$(eval $(call CONVERT_ICON,android/navigation/subdirectory_arrow_left/materialiconssharp/black/res/drawable-xxxhdpi/sharp_subdirectory_arrow_left_black_36.png,128,maze_icon_large,black white))
$(eval $(call CONVERT_ICON,android/navigation/subdirectory_arrow_left/materialiconssharp/black/res/drawable-xxxhdpi/sharp_subdirectory_arrow_left_black_36.png,40,maze_icon,black white))

$(eval $(call CONVERT_ICON,android/av/videocam/materialicons/black/res/drawable-xxxhdpi/baseline_videocam_black_36.png,128,video_icon_large,black white))
$(eval $(call CONVERT_ICON,android/av/videocam/materialicons/black/res/drawable-xxxhdpi/baseline_videocam_black_36.png,40,video_icon,black white))

clean:
	rm -rf icons/google
	rm -rf material-design-icons-$(MATERIAL_DESIGN_ICONS_VERSION)
	rm -rf $(MATERIAL_DESIGN_ICONS_VERSION).zip

-include $(BUILD_TEMPLATE)/template.mk
