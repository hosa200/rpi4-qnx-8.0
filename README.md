# Custom Target Image Builds - Raspberry Pi 4 - QNX 8.0

## Overview

This project allows QNX developers to build their own custom target images for
the RaspBerry PI 4. The default configuration is similar to that of the
Quickstart Image, which is available to download from the QNX Software
Center (QSC).

This project is different from the existing Quickstart images, in that it can
be customized to suit your needs.

## Contents

- [Hardware Requirements](#hardware-requirements)
- [Prerequisites](#prerequisites)
- [Getting Started](#getting-started)
- [Using the Image](#using-the-image)
- [Customization](#customization)
- [Troubleshooting](#troubleshooting)

## <a name="hardware-requirements"></a> Hardware requirements

For the PI4 target you'll need:
- Raspberry Pi 4 - 2GB model or higher OR a Raspberry Pi 5
- Micro SD card - 8GB or more
- (Optional) USB keyboard
- (Optional) USB mouse
- (Optional) HDMI display and micro HDMI to HDMI cable (or touchscreen and
             micro HDMI to HDMI and USB dual cable)
- (Optional) USB-TTL converter
- (Optional) Camera

## <a name="prerequisites"></a> Prerequisites

### Linux Utilities

This project can only be built on Linux hosts at the present time, and it
requires some utilities to build correctly.

Please run the command below to install required utilities for building
successfully (the command below works with Ubuntu Linux hosts):

```bash
sudo apt install cmake git texinfo ninja-build g++ libtool automake pkg-config wget curl unzip imagemagick bridge-utils
```

### QNX Software Development Platform (SDP)

The QNX Software Development Platform (version 8.0) and a development
license is required to build this project. If you do not already have these,
follow the steps below before proceeding with the steps in the next section:

1. Get a free, non-commercial QNX Software Development Platform 8.0 license at
   [https://www.qnx.com/getqnx]( https://www.qnx.com/getqnx).
2. Accept and deploy your license.
3. Install the QNX Software Center (QSC). The QSC allows users to install the
   QNX SDP and pre-built packages.
4. Install the QNX Software Development Platform 8.0.

## <a name="getting-started"></a> Getting Started

1. Clone this repo.

    ```bash
    git clone https://gitlab.com/qnx/custom-target-image-builds/raspberry-pi-4-qnx-8.0.git
    ```

2. Navigate into the project folder.

    ```bash
    cd raspberry-pi-4-qnx-8.0
    ```

3. Export path to the qnxsoftwarecenter_clt executable (modify accordingly to
   your installation location)

    ```bash
    export QSC_CLT_PATH=$HOME/qnx/qnxsoftwarecenter/qnxsoftwarecenter_clt
    ```

4. Setup the QNX SDP environment to perform the build and export some
   environment values required for building:

    ```bash
    source ~/qnx800/qnxsdp-env.sh
    ```

    (or point to the location of your installation if different)

5. Create a file called "options_file" and populate it with:

    ```bash
    -myqnx.user
    <username>
    -myqnx.password
    <password>
    ```

   (Replace the placeholders with your qnx.com credentials)

   This file is used to provide your credentials to QNX Software Center (QSC)
   to install required packages locally for the image build. Take care not to
   share this file with others or commit it to a fork of this project.

Once the above steps are performed, execute make while specifying your desired
target.

### Building RPi4
```bash
make TARGET=rpi4
```

### Build Notes
The first time you build, it will take some time, roughly 30 minutes or longer
depending on your Internet connection speed.

Some noteworthy items to be aware of:

- A separate installation of the QNX Software Development Platform (SDP) is
  installed within the project folder. This separate SDP installation is also
  used to build the open source projects integrated into the build.
- Due to the size of asset packages and projects that are downloaded from the
  Internet, you will likely need approximately 10 GB of free disk space.
- During the build, you will see output from the different integration download
  and build steps in each of the project subfolders, as the build proceeds.
  This is normal and expected.  Some of the steps seen in the initial build are
  skipped in later builds, because the required artifacts have been downloaded
  and unpacked in previous builds.

If the build is successful, an image file appropriate for the target is
produced in the target's build directory.
- For RPi4: **build/rpi4/rpi4.img** is produced

If the image generation is not successful, refer to the Troubleshooting
section below for more details on how to resolve.

## <a name="using-the-image"></a> Using the Image

How the image produced by the build process is used depends on the target.

### Flashing the image to an RPi4
The image file produced by the build process can be flashed using rpi-imager.

Instructions for doing so are available in the [Getting Started -> Flashing the image to a micro SD card](https://gitlab.com/qnx/quick-start-images/raspberry-pi-qnx-8.0-quick-start-image/-/wikis/Getting-started#flashing-the-image-to-a-micro-sd-card)
section of the wiki for the Quickstart Image.

## <a name="customization"></a> Customization

This project has been designed so that the content integrated into the image
can be modified to suit your needs.

This section will serve as a guide pointing to additional READMEs in the
project folders that document the customizations possible:

### Resizing Partitions

> As you customize this project with additional assets and open source
> software, you may need to increase the size of the **system** partition.
> The **data** partition may also need to be resized if assets are integrated
> into the data partition for users.

The maximum partition sizes are defined in the target's config file.

### RPi4
The configuration file for RPi4 is [targets/rpi4/mkqnximage.config](targets/rpi4/mkqnximage.config).

This line controls the partition sizes:
```bash
OPT_PART_SIZES='70:3072:32000'
```

The first number controls the boot partition size, the second number controls
the system partition size and the third number controls the data partition size.
The third size is optional, as the default behavior is to create a data
partition that fills the available space.
The numbers represent multiples of 2048 sectors, that are 512 bytes in size,
or equivalent to the number of megabytes.
The above sizing is meant to fit on a 32 GB SD card (the data size partition
is slightly too large, but the boot mechanism that creates the file system
partitions ensures that the actual partition size does not exceed what is
available on the SD Card).

If you have a larger SD card, such as a 64 GB SD card, you can roughly double
the size of the data partition as follows:

```bash
OPT_PART_SIZES='70:3072:62000'
```

and run the build again. If you flash the resulting image to a 64 GB SD Card
and boot up a device with the image, the data partition has roughly double the
number of blocks.

Note that increasing either the system partition size or data partition size
will not generate a larger overall image size. However, integrating extra
content will increase the size of the generated image file proportionally to
the size of the extra content integrated.

### Adding / Changing QNX Software Center (QSC) Packages

The QNX SOftware Center (QSC) Command Line Tool is used to install a local
SDP into **qnx800** that will be used to build the desired target image. The
tool is provided an explicit list of packages, and their associated versions,
to install. Since this list depends on the target being built, switching
between targets may cause the local SDP to be re-installed.

You can customize the list of packages that are installed from QSC by modifying
the appropriate qsc_install_packages.list files.

> It is highly recommended that no attempt is made to remove QSC packages until
> you are more familiar with the project, and understand the purpose of the
> packages included by default and know how to rollback a change to get back
> to a stable state.

Just installing new packages from QSC is usually not sufficient for the
contents of those packages to be added to the resulting CTI image. Any new
files will need to be explicitly added to the image by modifying an appropriate
snippet file. Please see the [snippets](snippets) and [system](system) READMEs
for more details on which snippets will need to be modified, and how t
modify them.

> If you clean your project and rebuild after removing packages without
> updating snippets, you will likely encounter warnings/errors of missing files
> preventing the image from being created.  The only way to get past this is to
> find the entries in the snippets for those files and removing them.

To learn more about how the QNX Software Center (QSC) Command Line Tool can be
used, see the online [documentation](https://www.qnx.com/developers/docs/qsc/com.qnx.doc.qsc.user_guide/topic/commandline_qsc.html)
to learn more about the tool.

#### qsc_install_packages.list

This file contains the base list of packages that are required to build all
targets. If you want to add things to all targets this is the file you
would want to modify.

#### targets/<target>/qsc_install_packages.list

This file contains the list of packages that are relevant to the specific
target. It is processed after the qsc_install_pacakges.txt file in the root
of the repo. If you want to add something to a specific target, say something
to support HW specific to the target, this is the file you would want to modify.

## Sub-folders

### boot

The boot folder manages files that are added to the boot partition. Some files
are already present in the repo, others are downloaded from the internet and
then cached locally.

This partition gets mounted to **/boot** when the target is running.

See the [boot](boot) folder README for more details regarding what it doess
and some of the customizations possible.

### assets

The assets folder Makefile integrates additional fixed assets, such as fonts
and icons, into the image. Some files are already present in the repo, others
are downloaded from the internet and then cached locally.

See the [assets](assets) folder README for more details regarding what it does
and some of the customizations possible.

### src

The src folder Makefile controls what open source projects are downloaded,
built and readied for integration into the image.

See the [src](src) folder README for more details regarding what it does and
some of the customizations possible.

### snippets

The snippets folder contains snippets of build files that are combined with
some boilerplate build segments to generate final build files for the three
partitions:
- boot
- data
- system

These three partitions are then combined to create the final image.

See the [snippets](snippets) folder README for details regarding some of the
customizations possible.

### system

The system folder contains files that are placed into the resulting
system partition. These are usually configuration files of one kind or another.

See the [system](system) folder README for details regarding some of the
customizations possible.

## <a name="troubleshooting"></a> Troubleshooting

### Authentication Errors from QNX Software Center

If you see a build failure during QNX Software Center package installationu
that looks like this:

```bash
/home/devuser/qnx/qnxsoftwarecenter/qnxsoftwarecenter_clt -mirrorBaseline qnx800 @options_file
Info: Mirroring repositories: remote server https://www.qnx.com/swcenter
Info: Generating metadata for dropins-repo.
Info: Generation completed with success [0 seconds].
Info: Generating metadata for seeds-q2-repo-devuser_-www_qnx_com_80_swcenter.
Error: publishing result: Server synchronization failed: Authentication failed, check credentials and try again; 
Error: Failed to synchronize repositories: Failed to retrieve package metadata from seeds-q2-repo-devuser_org-www_qnx_com_80_swcenter
make: *** [qsc_packages.mk:46: /home/devuser/work/raspberry-pi-4-qnx-8.0/qnx800] Error 1
```

it means that an error with the options_file during step 5 of the
[Getting Started](#getting-started) section.  Re-read the instructions,
correct the information and then run:

```bash
make TARGET=<target> clean
```

and then re-run:

```bash
make TARGET=<target>
```

to restart the build.

### Build QNX SDP Installation Error

In the course of installing the local SDP installation at the beginning of the
build, an error in the qsc_install_packages.list file, resulting from
customization, may result in the deletion of the existing SDP 8.0 installation
directory at $HOME/qnx800. If this happens, please utilize the Verify and Repair
functionality of QNX Software Center, as per:

[https://www.qnx.com/developers/docs/qsc/com.qnx.doc.qsc.user_guide/topic/repair_packages.html](https://www.qnx.com/developers/docs/qsc/com.qnx.doc.qsc.user_guide/topic/repair_packages.html)

to repair that SDP installation first.  Before trying the build again, double
check the changes made to the various qsc_install_packages.list files and
correct the error(s) that triggered this deletion to prevent it from recurring
on your next attempt to build the project.

It is recommended that you run:

```bash
make TARGET=<target> clean
```

and then run:

```bash
make TARGET=<target>
```

to rebuild the project.

### Missing Prerequisites

Fatal errors might occur during the assets or open source integrations in your
first attempt to build if you missed one of the prerequisite steps listed above.

Try the following remedy:

1. Repeat the prerequisite installation commands one more time.

2. Note that on Linux hosts running older Ubuntu distributions, this command
   may also need to be executed as well:

    ```bash
    sudo apt install python3-distutils
    ```

3. It is recommended that you run:

    ```bash
    make TARGET=<target> clean
    ```

4. Run:

    ```bash
    make TARGET=<target>
    ```

to try building the image again.

### Customization Missed Steps

Once you start customizing the project, fatal errors can and will likely happen
in the section your are customizing. As you start adding the steps to integrate
new open source projects or assets, especially if you miss a step, or something
unexpected occurs as you are trying to build a project being integrated.

This is normal and expected.

Try the following remedy:

1. Fix the Make target by adding the missing step(s).

2. It is recommended that you run:

    ```bash
    make TARGET=<target> clean
    ```

    to reset back to a clean initial state, but you can also be more precise,
    and clean only certain folders.  For example, to clean only the src folder,
    run:

    ```bash
    make TARGET=<target> -Csrc clean
    ```

3. Run:

    ```bash
    make TARGET=<target?
    ```

### Missing File Warnings

The last step of the build generates the image. If something went wrong earlier
in the build process, or a snippet change for customization is incorrectd,
you will see warnings printed indicating that files that are expected to be
integrated are missing.

These warnings should not happen the first time you build, with no
customizations, so earlier troubleshooting steps may help with first time
build errors.

If you see missing file warnings while in the midst of customizing, this would
indicate that one of your snippets changes is incorrect, likely that the
relative path inside the project folder is incorrect. Recheck your snippets
changes and then try the remedy above to proceed.

> The final .build files that are used to generate the partitions can be found
> in build/<target>/output/build. When chasing problems with missing or
> unexpected files in a generated partition, it often helps to check the
> appropriate build file to find the problem, then work backwards to find the
> snippet that contains the error.
