# RPi4 snippets

## Overview

These snippets are specific to the RPi4 target and are only used when it is
being built.

- [boot_files.custom](#boot_files.custom)
- [data_files.motd](#data_files.motd)
- [definitions.type_raspi_patch](#definitions.type_raspi_patch)
- [group_file.devel](#group_file.devel)
- [ifs_env.11.custom](#ifs_env.11.custom)
- [ifs_files.custom](#ifs_files.custom)
- [post_start.~10.hardware](#post_start.~10.hardware)
- [post_start.~20.graphics](#post_start.~20.graphics)
- [post_start.~21.mtouch](#post_start.~21.mtouch)
- [post_start.~30.sensor_framework](#post_start.~30.sensor_framework)
- [system_files.custom](#system_files.custom)
- [system_files.custom.camera_demo.rpi4](#system_files.custom.camera_demo.rpi4)
- [system_files.custom.graphics](#system_files.custom.graphics)
- [system_files.custom.rpi_gpio](#system_files.custom.rpi_gpio)
- [system_files.custom.window_managers.rpi4](#system_files.custom.window_managers.rpi4)
- [system_files.custom.boot_anim](#system_files.custom.boot_anim)

#### <a name="boot_files.custom"></a> boot_files.custom

This snippet controls which extra files are incorporated into the boot
partition.

See the [boot](../boot) folder README for details on what boot customizations
are possible to make with respect to these files.

No other changes should be required with this snippet at this time.

#### <a name="data_files.motd"></a> data_files.motd

This snippet defines the motd (Message Of The Day) that is printed whenever the
target starts or a user logs into it.

#### <a name="definitions.type_raspi_patch"></a> definitions.type_raspi_patch

This file adds some low level driver definitions to the build.

No customizations require changing this snippet at this time.

#### <a name="group-file-devel"></a> ### group_file.devel

This snippet contains entries that are added to /etc/group during the build.
Any customizations to user group membership should be manipulated here.

See the note at the end of the
[Next Steps -> Display resolution](https://gitlab.com/qnx/quick-start-images/raspberry-pi-qnx-8.0-quick-start-image/-/wikis/Next-steps#display-resolution)
section of the wiki as an example change that could be made in this snippet.

#### <a name="ifs_env.11.custom"></a> ifs_env.11.custom

This snippet contains entries for setting up the basic runtime environment of
the IFS. This includes creating symbolic links to map system partition paths
to paths typically found on Linux.

No customizations require adjusting its content at this time.

#### <a name="ifs_files.custom"></a> ifs_files.custom

This snippet contains additional files that need to be added in the IFS.
Typically these are HW drivers that are required by the IFS to bring up the
system enough to mount partitions to continue the boot process.

#### <a name="post_start.~10.hardware"></a> post_start.~10.hardware

This snippet contains extra commands to start HW drivers specific to the
target. Things like the GPIO resmgr are started here. It is added to the
startup script found at `/system/etc/startup/post_startup.sh`.

#### <a name="post_start.~20.graphics"></a> post_start.~20.graphics

This snippet contains extra commands to start the QNX graphics stack.
It is added to the startup script found at
`/system/etc/startup/post_startup.sh.`

#### <a name="post_start.~21.mtouch"></a> post_start.~21.mtouch

This snippet contains extra commands to start the touch input driver.
It is added to the startup script found at
`/system/etc/startup/post_startup.sh.`

#### <a name="post_start.~30.sensor_framework"></a> post_start.~30.sensor_framework

This snippet contains extra commands to start the sensor framework. The sensor
framework provides access to HW cameras and hence depends on the HW of the
target. It is added to the startup script found at 
`/system/etc/startup/post_startup.sh`.

No customizations are expected to this file at this time.

#### <a name="system_files.custom"></a> system_files.custom

This snippet contains entries for general HW specific files that are needed to
be added to the system partition.

No customizations are expected to this file at this time.

#### <a name="system_files.custom.camera_demo.rpi4"></a> system_files.custom.camera_demo.rpi4

This snippet contains entries for camera HW specific files that are needed to
be added to the system partition.

No customizations are expected to this file at this time.

#### <a name="system_files.custom.graphics"></a> system_files.custom.graphics

This snippet contains entries for graphics HW specific files that are needed
to be added to the system partition.

No customizations are expected to this file at this time.

#### <a name="system_files.custom.rpi_gpio"></a> system_files.custom.rpi_gpio

This snippet contains entries for new entries added to integrate the GPIO
resource manager, gpioctrl utility, and GPIO sample Python code.

No customizations are expected to this file at this time.

#### <a name="system_files.custom.window_managers_screenwm.rpi4"><a/> system_files.custom.window_managers_screenwm.rpi4

This snippet contains HW specific entries relating to the screenwm window
managers integrated into the project, as well as their assets and configuration
files.

Updates may be made to this snippet in future releases, but end users can
modify this snippet as per customization options that will be described in
following sections.

#### <a name="system_files.custom.boot_anim"><a/> system_files.custom.boot_anim

This snippet contains entries for HW specific files used to run the on-boot 
animations.

No customizations are expected to this file at this time.
