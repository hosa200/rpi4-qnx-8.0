# fonts

## Overview

One of the ways you would likely want to customize your image are adding assets
like fonts, which could be shared by multiple applications that are integrated
into the project.

All fonts that are placed into the **$(FONT_DST)** folder will be placed into
the image at the location: **/system/fonts**. This location is then linked from
two other locations for compatibility reasons:
- /usr/share/fonts
- /system/share/fonts

To ensure the fonts are properly installed, the startup script was updated to
refresh the font cache on boot.

## General Integration Approach

In general, each font integration follows the same steps:
1. Download font archive
2. Extract font archive to unique build folder
3. Copy desired fonts from extracted archive to FONT_DST
4. Copy desired fonts' fontconfig from extracted archive to FONTCONFIG_DST
5. Add unique build folder to FONTS variable

Steps 1-4 are generally all carried out by the same rule in the makefile.

### Download font archive

An archive of the fonts is downloaded from the internet. The method used
depends on what the source of the fonts makes available. It could be a clone
of a GIT repo, or a pre-made release package, or just a zip file that was
placed somewhere.

In any case, it is best to identify a specific version of the archive to
download. That way it won't change behind the scenes on you, and it makes
it easier to download a new version later without conflicts.

A new target should be added to the Makefile. The target should be the unique
build location where the archive is extracted. The target should depend on
**build**, **$(FONT_DST)**, and **$(FONTCONFIG_DST)**. A rule should be added
to the target to download the fonts using whatever method was selected.

> If you are cloning a GIT repo instead of downloading an archive, you should
> clone that repo into the build folder. Once the clone is created, checkout
> a specific tag or SHA.

### Extract font archive to unique build folder

Add additional rules to the target to unpack the archive into the unique build
folder selected for these fonts.

> This step may be skipped if a GIT repo was cloned directly into the build
> tree.

### Copy desired fonts from extracted archive to FONT_DST

Add additional rules to the target to copy the desired font files out of the
unique build folder and into **$(FONT_DST)**. The font files are generally
.ttf (true-type font) files. Any font files copied to **$(FONT_DST)** will
be included in the final image.

### Copy desired fonts' fontconfig from extracted archive to FONTCONFIG_DST

Add additional rules to the target to copy the fontconfig information, if
available, out of the unique build folder and into **$(FONTCONFIG_DST)**.

### Add unique build folder to FONTS variable

Near the top of the Makefile is a FONTS variable. The unique build directory
of each font integrated should be added to this variable. This is what will
drive make to actually do the work of acquiring fonts.

## Font Integrations

### fontconfig

The /system/etc/fontconfig folder for the target is generated as follows:
1. The fonts engine package is installed from QNX Software Center to integrate
   the base fontconfig binaries and configuration
2. The fontconfig files are downloaded from the QNX ports fontconfig repository
   on GitHub: [https://github.com/qnx-ports/fontconfig.git](https://github.com/qnx-ports/fontconfig.git))
3. Any font packages with their own fontconfig files are mixed in with the
   conf.avail folder from the above download. This is where
   **$(FONTCONFIG_DST)** points.
4. A conf.d folder that contains soft links to all files in conf.avail is
   generated and then the local fontconfig folder is imported into the image.

### DejaVu Fonts

The currently available Quickstart image includes some DejaVu fonts, so
integrating these fonts was a natural starting point. However, the repository
where these fonts are located, also included some additional DejaVu fonts for
international characters and math symbols, so these fonts have also been
integrated.

The DejaVu fonts site, where you can go obtain the latest fonts is:
[https://dejavu-fonts.github.io/](https://dejavu-fonts.github.io/)

The Makefile is currently downloading version 2.37 of the font sets.

### Google Fonts

Google has sponsored the creation of many useful free fonts for mobile
platforms and web applications.

The Google Fonts Web site, where you can browse to find fonts of interest,
is: [https://fonts.google.com/](https://fonts.google.com/)

The repo containing the source fonts is found here:
[https://github.com/google/fonts/tree/main](https://github.com/google/fonts/tree/main)

The Makefile is currently downloading the zip distribution of this repo
generated from SHA 48d15b319. Downloading the zip distribution and unpacking it
is faster than cloning the entire git repo.

Note that, unlike the DejaVu fonts, Google fonts in the repo downloaded are
mainly variable True Type fonts.  Depending on the naming scheme, certain
attributes can be adjusted after loading with either the FreeType or SDL_ttf
APIs. Static versions of the fonts are only available to download manually
from the Google Fonts site, or in an automated fashion via
[Google APIs](https://developers.google.com/fonts/docs/developer_api) that
require an API key to access.

We chose not to obtain fonts this way for simplicity, but end users who extend
this project are free to change how their obtain Google fonts for their own
build variant.

### Font Awesome Desktop Fonts (free edition)

Font Awesome is best known for their Web fonts that provide a great collection
of useful icons for Web application user interfaces. Their Web fonts are also
available for the desktop as well. Three of their OpenType fonts are available
for free download from their Web site:
[https://docs.fontawesome.com/desktop/setup/get-started](https://docs.fontawesome.com/desktop/setup/get-started)

Go to this page: [https://fontawesome.com/icons](https://fontawesome.com/icons)
to browse the icons available in the fonts. The font code represents the
unicode character represented by that icon's character in the font that
contains it. You will need that information to assemble the unicode or UTF-8
string to render the icon, once it is installed in the image.

Note that the Pro icons are only available in the Pro fonts that are only
available after you purchase a license.

OpenType fonts contain True Type fonts, so they are supported by the FreeType
library integrated into the Quickstart image.

## Other Sources for Free Fonts

There are a number of sources of open source and free fonts that can be
explored.  Here are a few sources that we did not include:
- OpenFoundry: [https://www.google.com/url?sa=t&source=web&rct=j&opi=89978449&url=https://open-foundry.com/&ved=2ahUKEwi1mJOF56CMAxWhFjQIHTXDE0UQFnoECBsQAQ&usg=AOvVaw1YGvdHClzIREgvzKKFoqe-](https://www.google.com/url?sa=t&source=web&rct=j&opi=89978449&url=https://open-foundry.com/&ved=2ahUKEwi1mJOF56CMAxWhFjQIHTXDE0UQFnoECBsQAQ&usg=AOvVaw1YGvdHClzIREgvzKKFoqe-)
- Adobe Open Source Fonts: [https://fonts.adobe.com/foundries/open-source](https://fonts.adobe.com/foundries/open-source)
- The League of Movable Type: [https://www.google.com/url?sa=t&source=web&rct=j&opi=89978449&url=https://www.theleagueofmoveabletype.com/&ved=2ahUKEwi1mJOF56CMAxWhFjQIHTXDE0UQFnoECDMQAQ&usg=AOvVaw0q9j8an7Vy4JuExqa1Mx5C](https://www.google.com/url?sa=t&source=web&rct=j&opi=89978449&url=https://www.theleagueofmoveabletype.com/&ved=2ahUKEwi1mJOF56CMAxWhFjQIHTXDE0UQFnoECDMQAQ&usg=AOvVaw0q9j8an7Vy4JuExqa1Mx5C)
- FontShare open source fonts: [https://www.google.com/url?sa=t&source=web&rct=j&opi=89978449&url=https://fontshare.com/licenses/sil-ofl&ved=2ahUKEwi1mJOF56CMAxWhFjQIHTXDE0UQFnoECC8QAQ&usg=AOvVaw0vsiJXXBqlDg3XT4wJ35r0](https://www.google.com/url?sa=t&source=web&rct=j&opi=89978449&url=https://fontshare.com/licenses/sil-ofl&ved=2ahUKEwi1mJOF56CMAxWhFjQIHTXDE0UQFnoECC8QAQ&usg=AOvVaw0vsiJXXBqlDg3XT4wJ35r0)

## Utilities

### showfont

A utility application called showfont was integrated after the SDL_ttf library
was integrated.  This application allows you to render fonts in different ways,
either using the default or custom text and sizes.

This utility is useful to check that integrated fonts are correctly integrated
into the image.  See some example commands below, and associated screenshots,
that you can run to confirm some of the integrated fonts are working correctly
in your generated image.

Usage:
```bash
qnxuser@qnxpi:~$ showfont
INFO: Usage: showfont [-solid] [-shaded] [-blended] [-wrapped] [-utf8|-unicode] [-b] [-i] [-u] [-s] [-outline size] [-hintlight|-hintmono|-hintnone] [-nokerning] [-wrap] [-fgcol r,g,b,a] [-bgcol r,g,b,a] <font>.ttf [ptsize] [text]
```

## Checking integrated fonts

## DejaVu LGC Sans Bold font

Run the following command to confirm that select Greek, Cyrillic and Coptic
characters from one of the new DejaVu fonts renders correctly.

```bash
showfont -utf8 /usr/share/fonts/DejaVuLGCSans-Bold.ttf 30 "πΦϢ ЂЖϠ Ω"
```

In the event that this command does not work because the special characters
pasted do not preserved, you may need to copy and paste the characters from
another source, such as this Web page
[https://www.utf8-chartable.de/unicode-utf8-table.pl](https://www.utf8-chartable.de/unicode-utf8-table.pl)
in place of the characters at the end of the command.  To get this to work
locally, I created a test script with vi on my Ubuntu host, and checked the
script with "od -c" to confirm that the characters copied were saved correctly.

Once you are successful in executing the command, the following will be
displayed on the screen:
![sample DejaVU LGC character render screenshot](./dejavu_lgc_test.bmp)

## DejaVu Math Tex Gyre font

Run the following command to confirm that select mathematical symbols from
another of the new DejaVu fonts renders correctly.

```bash
showfont -utf8 /usr/share/fonts/DejaVuLGCSans-Bold.ttf 30 "∊ ∑ ∓ √ ∞ ∡ ∫ ∰  ≄ ⋃"
```

In the event that this command does not work because the special characters
pasted do not preserved, you may need to copy and paste the characters from
another source, such as this Web page
[https://www.utf8-chartable.de/unicode-utf8-table.pl](https://www.utf8-chartable.de/unicode-utf8-table.pl)
in place of the characters at the end of the command.  To get this to work
locally, I created a test script with vi on my Ubuntu host, and checked the
script with "od -c" to confirm that the characters copied were saved correctly.

Once you are successful in executing the command, the following will be
displayed on the screen:
![sample DejaVU MathTexGyre character render screenshot](./dejavu_mtg_test.bmp)

## Google Roboto Condensed Italic font

Run the following command to confirm that one of the Google Roboto fonts
integrated, specifically the Condensed Italic font, renders correctly.

```bash
showfont /usr/share/fonts/RobotoCondensed-Italic[wght].ttf
```

The following will be displayed on the screen after executing the command:
![sample Roboto Condensed Italic render screenshot](./roboto_cdit_test.bmp)

## FontAwesome GitHub brand icon

Run the following command to test rendering the GitHub icon from the Font
Awesome 6 Brands font:

```bash
showfont -utf8 /usr/share/fonts/Font\ Awesome\ 6\ Brands-Regular-400.otf 100 
```

In the event that this command does not work because the special character
pasted is not preserved, you may need to use a utility to copy and paste the
unicode code / character f09b in place of the character at the end of the
command.  To get this to work locally, I created a test script with vi on my
Ubuntu host, and checked the script with "od -c" to confirm that it converted
the unicode character I copied from an online tool into the correct UTF-8
character sequence when it saved the script.


Once you are successful in executing the command, the following will be
displayed on the screen:
![GitHub icon render screenshot](./fa_github.bmp)
