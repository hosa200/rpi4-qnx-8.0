# Common snippets

## Overview

Snippets that are used by all CTI targets.

- [data_files.custom](#data_files.custom)
- [data_files.home](#data_files.home)
- [ifs_env.10.custom](#ifs_env.10.custom)
- [post_start.~15.networking](#post_start.~15.networking)
- [post_start.~40.window_manager](#post_start.~40.window_manager)
- [post_start.~99.final](#post_start.~99.final)
- [profile.custom](#profile.custom)
- [system_files.custom.camera_demo](#system_files.custom.camera_demo)
- [system_files.custom.common](#system_files.custom.common)
- [system_files.custom.SDL](#system_files.custom.SDL)
- [system_files.custom.window_managers](#system_files.custom.window_managers)
- [system_files.custom.window_managers_demolauncher_config](#system_files.custom.window_managers_demolauncher_config)
- [system_files.custom.window_managers_screenwm](#system_files.custom.window_managers_screenwm)

The following snippet is optional:
- [wifi.custom](#wifi-custom)

#### <a name="data-files.custom"></a> data_files.custom

This snippet is used to add files to the `/data` partition. For example,
configuration files for various services running on the device.

Customizations may be required here if a new service is ported and integrated,
and it requires a file under `/data`.

### <a name="data-files.home"></a> data_files.home

This snippet includes entries for the home directories of the image's users.

If a new utility is integrated and it can benefit from a files, such as
configuration files, that exist within a user's home directory, those files
can be added here for each user account that requires them.

If a new user account is added, extra entries would need to be added here to
create the new user's home directory and extra configuration files. See the
entries for qnxuser as an example of what entries to add for another user.

#### <a name="ifs_env.10.custom"></a> ifs_env.10.custom

This snippet contains entries for setting up the basic runtime environment of
the IFS.

No customizations require adjusting its content at this time.

#### <a name="post_start.~15.networking"></a> post_start.~15.networking

This snippet contains extra commands, related to networking, to add into the
startup script found at `/system/etc/startup/post_startup.sh`.

#### <a name="post_start.~40.window_manager"></a> post_start.~40.window_manager

This snippet contains extra commands, that starts the window manager, to add
into the startup script found at `/system/etc/startup/post_startup.sh`.

#### <a name="post_start.~99.final"></a> post_start.~99.final

This snippet contains extra commands to add into the startup script found at
`/system/etc/post_startup.sh`. These commands are meant to be the last thing
executed at the end of the startup script.

#### <a name="profile.custom"></a> profile.custom

This snippet contains extra environment variables or entries to add into
`/system/etc/profile`. The profile file is sourced by every instance of the
shell and hence can be used to add global environment variables
to each user's environment when they start a new shell.

A new open source service that is integrated, that would need environment
variables to be defined to operate, would require changes to this snippet.

#### <a name="system_files.custom.common"></a> system_files.custom.common

This snippet is merged into the system partition build file, and serves as a
general location where extra entries for files to be integrated into the system
partition would be added.  Extra snippets where subsets of entries are added
following a specific theme or service will be covered below.

For extra integrations, the user has a choice to update this snippet with extra
system entries or create a subset snippet to do so.

#### <a name="system_files.custom.camera_demo"></a> system_files.custom.camera_demo

This snippet is merged into the system build file. It contains entries related
to sensor framework, camera libraries and related sample apps.

#### <a name="system_files.custom.SDL"></a> system_files.custom.SDL

This snippet contains entries to integrate the SDL related libraries and files
into the system build file.

Updates are expected to this snippet in future releases, but end users can
modify this snippet if they want to integrate extra SDL projects on their own.

#### <a name="system_files.custom.window_managers"></a> system_files.custom.window_managers

This snippet contains entries relating to the two window managers integrated
into the project, as well as their assets and configuration files.

Updates may be made to this snippet in future releases, but end users can
modify this snippet as per customization options that will be described in
following sections.

#### <a name="system_files.custom.window_managers_demolauncher_config"></a> system_files.custom.window_managers_demolauncher_config

This snippet contains entries related to the configuration of the demolauncher
window manager. It is broken out separately from the main
`system_files.custom.window_managers` file in order to allow variant specific
demolauncher configuration.

#### <a name="system_files.custom.window_managers_screenwm"></a> system_files.custom.window_managers_screenwm

This snippet contains entries related to the optional screenwm window manager.
It is broken out separately from the main `system_files.custom.window_managers`
file in order to allow variant specific screenwm behaviour.

#### <a name="wifi-custom"></a> wifi.custom

If this snippet is added, it can contain a network block that can get
injected into the wpa_supplicant.conf file for Wi-Fi settings.

See the [Getting Started -> Wi-Fi](https://gitlab.com/qnx/quick-start-images/raspberry-pi-qnx-8.0-quick-start-image/-/wikis/Getting-started#wi-fi)
section of the wiki for the Quickstart Image for more details on how to
populate the file.

Note that this method of setting Wi-Fi settings is not recommended unless your
image is slated for devices that are operating in a fixed environment, such as
a school / corporate lab or a guest network, as opposed to an image being
shared with others in the developer community abroad.

