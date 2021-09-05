# 	buildos.mk
#
#	Copyright (C) - Scott Pitcher, 2020
#
# 	Single Makefile OS specific code.
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

# The file extension for executables is set under windows.
ifeq ($(BUILD_OS),WINDOWS)
EXEEXTENSION=.exe
SLIBEXTENSION=.a
DLIBEXTENSION=.dll
else
EXEEXTENSION=
SLIBEXTENSION=.a
DLIBEXTENSION=.so
endif

# Common compiler defs.
CC=		gcc
AS=		as
AR=		ar
CC=		gcc
LD=		ld
OBJDUMP=	objdump
RM=		rm

