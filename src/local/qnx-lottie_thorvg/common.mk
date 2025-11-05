ifndef QCONFIG
QCONFIG=qconfig.mk
endif
include $(QCONFIG)

define PINFO
PINFO DESCRIPTION = Sample lottie animation renderer using thorvg
endef
INSTALLDIR=usr/local/bin
NAME=rpi-lottie
USEFILE=

LIBS=thorvg gomp
DEBUG=-g -O0

include $(MKFILES_ROOT)/qtargets.mk
