# 	toplevel.mk
#
#	Copyright (C) - Scott Pitcher, 2020
#
# 	Generic toplevel recursive Makefile for defining some things that will be used by other Makefiles.
#


# Find the target OS.
ifeq ($(OS),Windows_NT)
	BUILD_OS=WINDOWS
else
	UNAME_S := $(shell uname -s)
	ifeq ($(UNAME_S),Linux)
		BUILD_OS=LINUX
	else
		ifeq ($(UNAME_S),Darwin)
			BUILD_OS=MAC
		else
			$(error Unknown BUILD_OS. I couldn't determine if this is a WINDOWS LINUX or MAC build.)
		endif
	endif
endif

export BUILD_OS

# And we also include the subdirectory skeleton.
include $(MAKE_INCLUDE_DIR)/subdirectories.mk
