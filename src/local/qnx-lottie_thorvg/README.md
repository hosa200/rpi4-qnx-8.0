# rpi-lottie

## Overview

Sample application that uses thorvg and rpi-mailbox to render lottie animations
on RPi4.

## Building

Run the following command,

```
EXTRA_INCVPATH=<inc_path> \
EXTRA_LIBVPATH=<lib_path> \
make
```

Where <inc_path> refers to the path to the directory
storing the rpi_mbox and thorvg headers, and <lib_path>
refers to the path to the directory storing the thorvg libraries.
