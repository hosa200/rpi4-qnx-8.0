# Integrating Open Source Projects / Applications into the QuickStart Self-build BSP

## Overview

There are four sources of open source projects that are integrated into this
project:
- projects from QNX Ports on GitHub
- projects from QNX projects on Gitlab
- projects from QNX Sample Apps on Gitlab
- projects from the Internet in general
- local projects

## General Approach to Project Integration

### Common build environment

All integrations take advantage of the following features of the project:
- separate SDP installation located in the qnx800 subfolder created under the
  project root folder
- a staging folder created in this folder (named `stage`) where locally built
  binaries and artifacts are installed as the different projects are built
  (this is important for building projects to find artifacts generated from
  other projects that they are dependent on)

Similar steps apply to integrating projects from any of the four sources above:

### Add a make target to download the project called `source/<project>-ready`

Add a make target to represent downloading and, if required, unpacking the
project's source. The make target should:
- add a command to clone the repo, or a command to download the project package
- if required, add an option to clone a specific branch or add a command to
  cd into the folder and checkout a specific branch
- if downloading a package, add a command to unpackage the package
- if required, a patch may need to be applied to build the project successfully
  for QNX.  A general approach for patching includes:
  - from within the cloned project folder, make any changes required to
    successfully build the project
  - run the git diff command and save the patch in the src/patches folder
  - update the make target commands after cloning to run 'git apply' to apply
    the patch before the build commands

The target MUST create a sentinel file called `source/<project>-ready` as
its last step. While the actual project directory can be used it is not
recommended as the modification timestamp of the directory can often confuse
make.

> It is strongly recommended that a specific, explicit, version of the project
> is used instead of using whatever is the latest at time of download. That
> way things don't change behind the scenes unexpectedly.

### Add a Make target to build the project called `source/<project>-built-$(QNX_ARCH)`

Add a make target to actually build the source. The target should depend on
the sentinel file created in the last step. In addition, if this is a project
from QNX ports, `source/build-files-ready` must also be added as a dependency.
Any other project that needs to be built first, must be integrated beforehand
using a similar process as described below and its make target has to be added
as a dependency.

> **NOTE** The target may be built multiple times for different architectures.
> This target's makefile rules should be able to handle that possibility.

- consult the project build instructions and add commands to cd into the
  project folder and build the project (note that in some cases, you must make
  build folders and go into the build folders to build the project)
- add commands to install the project binaries and includes (if required) into
  the src/stage folder that represents the local installation (some projects
  "make install" commands may work properly to do this or you may need to add
  custom commands to copy to the appropriate spot)

The target MUST create a sentinel file called
`source/<project>-built-$(QNX_ARCH)` as a final step when the build completes
successfully. This represents the successful build of the target for the
current architecture in the `$(QNX_ARCH)` variable.

### Add <project> to the PKGS variable

The name of the project needs to be added to the `PKGS` variable. This will
automatically add it as a dependency of the `all` target, so that it will
be built by default.

> If you only want to build <project> in specific circumstances, only add it
> to `PKGS` when those circumstances are present.

### Update the snippets to include generated artifacts

Once the project artifacts are successfully built, note where they are located
within the `stage` directory and update the appropriate [snippets](../snippets)
files (review the README of this folder more details) to include the artifacts
built for the new project.

### Rebuild the project and check for warnings

Rebuild the project and make sure there are no warnings during image generation.
That would indicate that the recipe updates are incorrect.

### Flash the build image and confirm new content is present

Flash the build and check that the new content is present and running properly.
Note that some open source applications expect their content at certain
locations that are not standard in the image, requiring additional recipe
updates to add symbolic links to the content to make it also available at an
expected path.

## Integrations

### QNX ports integrations

URL: [https://github.com/qnx-ports](https://github.com/qnx-ports)

projects:
- bash
- vim
- cairo

#### Example integation: bash

Let's review the [Makefile](Makefile) to see how bash was integrated.

##### Add a make target to download the project called `source/<project>-ready`

Here is the make target that was added to download bash:

```bash
source/bash-ready:
	mkdir -p source
	cd source && git clone https://github.com/qnx-ports/bash.git
	cd source/bash && git checkout $(BASH_SHA)
	touch $@
```

Note that a specific SHA is checked out to enable a reproducible build.

##### Add a Make target to build the project called `source/<project>-built-$(QNX_ARCH)`

Here is the make target that was added to build bash:

```bash
source/bash-built-$(QNX_ARCH): source/bash-ready source/build-files-ready
	QCONF_OVERRIDE=$(PWD)/qconf-override.mk \
	CPULIST=$(QNX_ARCH) \
	QNX_ARCH=$(QNX_ARCH) \
	QNX_PROJECT_ROOT="$(PWD)/source/bash" make -C source/build-files/ports/bash install -j4
	touch $@
```

Note the following:
- There is a dependency on `source/bash-ready`. This ensures the source for
  bash is available.
- Since this is a QNX ports project, it needs the `source/build-files` target
  as a dependency. This target performs the steps to setup the local build
  folders needed to build QNX ports projects.
- `CPULIST` and `QNX_ARCH` is used to build bash only for the current
  architecture being built.
- The make command used to build bash is similar to the one found in the README
  for the bash port [repo](https://github.com/qnx-ports/build-files/tree/main/ports/bash).

##### Add <project> to the PKGS variable

Since bash is always built it is always added to the PKGS variable.

```bash
PKGS = bash vim cairo simple-terminal screenwm SDL SDL_image SDL_ttf SDL_net pattern-race
```

### QNX projects integrations

URL: [https://gitlab.com/qnx/projects](https://gitlab.com/qnx/projects)

projects:
- rpi-gpio
- rpi-mailbox
- rpi-thermal
- simple-terminal

#### Example integration: rpi-gpio

Let's review the [Makefile](Makefile) to see how rpi-gpio was integrated.

##### Add a make target to download the project called `source/<project>-ready`

Here is the make target that was added to download rpi-gpio:

```bash
source/rpi-gpio-ready:
	mkdir -p source
	cd source && git clone https://gitlab.com/qnx/projects/rpi-gpio
	cd source/rpi-gpio && git checkout $(RPI_GPIO_SHA)
	touch $@
```

Note that a specific SHA is checked out to enable a reproducible build.

##### Add a Make target to build the project called `source/<project>-built-$(QNX_ARCH)`

```bash
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
	EXTRA_INCVPATH=$(STAGE_COMMON)/usr/local/include \
	EXTRA_LIBVPATH=$(STAGE_TARGET)/usr/local/lib \
	MY_STAGE=$(STAGE_ROOT) make install
	touch $@
```

### Completing the Make target for the rpi-gpio project

Note the following:
- Although this project is not from QNX ports, it does have a dependency to
  the cairo project built from QNX ports.
- We execute more build steps than the previous project integration example.
  The reason for this is that this project uses QNX make, instead of a third
  party build system to build the project. There is at least one extra build
  step to install headers in the stage, that are required by the rpi-thermal
  project that is also integrated.

##### Add <project> to the PKGS variable

We only build the rpi-gpio project when we are building for a Raspberry PI
target.

```bash
ifneq ($(filter rpi4,$(TARGET)),)
PKGS += rpi-gpio rpi-mailbox rpi-thermal
endif
```

### Internet (in general)

This project integrates the following additional open source projects, not
currently included (or enabled) in the prebuilt Quickstart image:
- screenwm
- SDL
- SDL_image
- SDL_ttf
- SDL_net
- pattern-race
- thorvg

#### Example Integration: SDL_net

Let's review the [Makefile](Makefile) to see how SDL_net was integrated.

### Add a Make target for the SDL_net project folder
##### Add a make target to download the project called `source/<project>-ready`

Here is the make target that was added to download SDL_net:

```bash
source/SDL_net-ready:
	mkdir -p source
	cd source && git clone https://github.com/libsdl-org/SDL_net.git -b $(SDL_NET_VERSION)
	cd source/SDL_net && git apply $(PWD)/patches/SDL_net.patch
	touch $@
```

Note the following:
- A specific version is cloned to enable a reproducible build.
- This project required a small patch to build, specifically to adjust an entry
  for the library to add a dynamic link to libsocket. When figuring out patches
  like this, you can determine patches while testing the new target being added.
  If you are patching a cloned git repo, you can use "git diff" to create the
  patch and then "git apply" to apply the patch after cloning.

##### Add a Make target to build the project called `source/<project>-built-$(QNX_ARCH)`

Here is the make target that was added to build SDL_net:

```bash
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
```

Note the following:
- This project has a dependency on the SDL project, that was integrated first.
- We execute different build steps than the previous project integration
  example. The reason for this is that this project is a open source project,
  that supports multiple platforms, so it uses CMake to support this
  flexibility, which has different build steps than QNX make projects.

### Add <project> to the PKGS variable

Since SDL_net is always built it is always added to the PKGS variable.

```bash
PKGS = bash vim cairo simple-terminal screenwm SDL SDL_image SDL_ttf SDL_net pattern-race
```

### Local Projects

#### Example Integration: qnx-lottie_thorvg
Let's review the [Makefile](Makefile) to see how qnx-lottie_thorvg was integrated.

### Add a Make target for the qnx-lottie_thorvg project folder
##### Add a make target to copy the project from `local/` to `source/`
Here is the make target that was added to copy qnx-lottie_thorvg:

```bash
source/qnx-lottie_thorvg-ready:
	mkdir -p source
	cp -r $(PWD)/local/qnx-lottie_thorvg source/
	touch $@
```
##### Add a Make target to build the project called `source/<project>-built-$(QNX_ARCH)`
```bash
source/qnx-lottie_thorvg-built-$(QNX_ARCH): source/qnx-lottie_thorvg-ready source/thorvg-built-$(QNX_ARCH) \
    source/rpi-mailbox-built-$(QNX_ARCH)
	mkdir -p $(STAGE_TARGET)/usr/local/bin
    cd source/qnx-lottie_thorvg && \
        EXTRA_INCVPATH=$(STAGE_TARGET)/usr/local/include \
        EXTRA_LIBVPATH=$(STAGE_TARGET)/usr/local/lib \
		MY_STAGE=$(STAGE_ROOT) make install
    touch $@
```
Note the following:
- This project has a dependency on the thorvg project and the rpi-mailbox
  project, both of which were integrated first.

### Add <project> to the PKGS variable

We only build the qnx-lottie_thorvg project when we are building for a
Raspberry PI target, since it relies on rpi-mailbox.

```bash
ifneq ($(filter rpi4,$(TARGET)),)
PKGS += rpi-gpio rpi-mailbox rpi-thermal qnx-lottie_thorvg
endif
```

## Testing the integrations

### showimage

See the [icons](../assets/icons) README for more details regarding this utility,
which is included from the SDL_image project integration.

### showfont

See the [fonts](../assets/fonts) README for more details regarding this utility,
which is included from the SDL_ttf project integration.

### thorvg

thorvg is a lightweight vector graphics library. It can be used to integrate
other projects built with thorvg.

### qnx-lottie_thorvg

qnx-lottie_thorvg is a harness application that reads and plays lottie animation
files using thorvg and rpi-mailbox. It is currently used to play the
on-boot animation.

### screenwm

screenwm is an alternative window manager that can be used in place of the
default fullscreen window manager.

See the [snippets](../snippets) README for more details regarding how to modify
the configuration to launch the alternate window manager instead of the
demolauncher (that launches by default).

### SDL and related libraries

The SDL2 libraries (SDL, SDL_image, SDL_ttf, and SDL_net) have been integrated
into the build. SDL_mixer will be added in a future release. These libraries
can be used to integrate other open source games built with SDL.

### pattern-race

Pattern Race is a simple pattern-matching game that uses three of the SDL
libraries. After you successfully build and flash the image, you can run it as
follows:

Usage:

```bash
patrace
```

and the starting screen looks like this:

![Pattern Race start screen](./patrace_start.bmp)

You may see more game integrations in a future release.  Stay tuned.
